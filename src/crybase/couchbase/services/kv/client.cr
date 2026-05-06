module CryBase::CouchBase::Services::KV
  # Talks the Couchbase memcached binary protocol against a single KV
  # node. Composed from `RequestWriter`, `ResponseReader`, and `Bucket`
  # mixins.
  #
  # On construct: TCP-connects to *endpoint*, sends `HELLO` (advertising
  # `FEATURE_SELECT_BUCKET`), `SASL_AUTH` (PLAIN), and `SELECT_BUCKET` for
  # *bucket*. Then exposes plain `get` / `set` / `delete` against that
  # bucket.
  #
  # ```
  # endpoint = CryBase::CouchBase::Endpoint.new(
  #   "node1", 11210, CryBase::CouchBase::Service::KV, false
  # )
  # kv = KV::Client.new(endpoint, "user", "pass", "default")
  # kv.set("hello", "world")
  # kv.get("hello") # => "world".to_slice
  # kv.delete("hello")
  # kv.close
  # ```
  #
  # Out of scope (deliberate, can be layered on top later):
  # * vbucket-aware routing — assumes the caller already picked the right node
  # * CAS, flags, durability, observe, and other op modifiers
  # * connection pooling / reconnect / retry
  class Client
    include RequestWriter
    include ResponseReader
    include Bucket

    # The `Endpoint` this client is connected to.
    getter endpoint : Endpoint

    # The bucket selected during the construction handshake.
    getter bucket : String

    @socket : TCPSocket
    @opaque : UInt32

    # Connects, performs HELLO + SASL PLAIN + SELECT_BUCKET, and leaves
    # the client ready for `get`/`set`/`delete`.
    #
    # Raises:
    # * `IO::Error` / `Socket::Error` — TCP connect failed
    # * `KV::AuthFailed` — SASL auth or bucket selection denied
    # * `KV::Error` — server returned any other non-success status
    #
    # The socket is closed and the exception re-raised if any handshake
    # step fails.
    def initialize(
      @endpoint : Endpoint,
      username : String,
      password : String,
      @bucket : String,
      connect_timeout : Time::Span = 5.seconds,
    )
      @socket = TCPSocket.new(@endpoint.host, @endpoint.port, connect_timeout: connect_timeout)
      @socket.sync = false
      @opaque = 0_u32
      begin
        hello
        sasl_auth_plain(username, password)
        use(@bucket)
      rescue ex
        @socket.close rescue nil
        raise ex
      end
    end

    # Fetches the document at *key*. Raises `NotFound` if absent.
    #
    # ```
    # bytes = kv.get("user:42")
    # JSON.parse(String.new(bytes))
    # ```
    def get(key : String) : Bytes
      resp = call(Opcode::Get, key: key, vbucket: vbucket_id(key))
      ensure_success!(resp, "GET #{key}")
      resp.value
    end

    # Stores *value* at *key* with optional *expiry* (seconds, or unix
    # timestamp if greater than 30 days). Returns the new CAS token.
    #
    # ```
    # cas = kv.set("hello", "world")
    # cas = kv.set("hello", "world".to_slice, expiry: 60_u32)
    # ```
    def set(key : String, value : String | Bytes, expiry : UInt32 = 0_u32) : UInt64
      bytes = value.is_a?(String) ? value.to_slice : value
      extras = IO::Memory.new(8)
      extras.write_bytes(0_u32, IO::ByteFormat::BigEndian) # flags
      extras.write_bytes(expiry, IO::ByteFormat::BigEndian)
      resp = call(Opcode::Set, key: key, extras: extras.to_slice, value: bytes, vbucket: vbucket_id(key))
      ensure_success!(resp, "SET #{key}")
      resp.cas
    end

    # Deletes the document at *key*. Raises `NotFound` if absent.
    #
    # ```
    # kv.delete("hello")
    # ```
    def delete(key : String) : Nil
      resp = call(Opcode::Delete, key: key, vbucket: vbucket_id(key))
      ensure_success!(resp, "DELETE #{key}")
    end

    # Closes the underlying TCP socket. Idempotent — safe to call when
    # already closed.
    def close : Nil
      @socket.close
    rescue
      # already closed / mid-shutdown — nothing useful to do
    end

    private def hello : Nil
      features = IO::Memory.new(2)
      features.write_bytes(FEATURE_SELECT_BUCKET, IO::ByteFormat::BigEndian)
      resp = call(Opcode::Hello, key: AGENT, value: features.to_slice)
      ensure_success!(resp, "HELLO")
    end

    private def sasl_auth_plain(username : String, password : String) : Nil
      payload = String.build do |io|
        io.write_byte(0_u8)
        io << username
        io.write_byte(0_u8)
        io << password
      end
      resp = call(Opcode::SaslAuth, key: "PLAIN", value: payload.to_slice)
      raise AuthFailed.new(resp.status, "SASL PLAIN") unless resp.success?
    end

    private def call(
      opcode : Opcode,
      *,
      key : String = "",
      extras : Bytes = Bytes.empty,
      value : Bytes = Bytes.empty,
      cas : UInt64 = 0_u64,
      vbucket : UInt16 = 0_u16,
    ) : Response
      @opaque &+= 1
      write(Request.new(opcode, key, extras, value, cas, @opaque, vbucket))
      read
    end

    private def vbucket_id(key : String) : UInt16
      CryBase::CouchBase::Services::KV.vbucket_id(key)
    end

    private def ensure_success!(resp : Response, op : String) : Nil
      return if resp.success?
      case resp.status
      when .key_not_found?
        raise NotFound.new(resp.status, op)
      when .auth_error?, .auth_continue?
        raise AuthFailed.new(resp.status, op)
      else
        raise Error.new(resp.status, op)
      end
    end
  end
end
