module CryBase::CouchBase::Services::KV
  # Mixin that serializes a `Request` into the binary KV wire format
  # and writes it to the includer's `@socket`. The includer is expected
  # to own an IO-typed `@socket` (e.g. `TCPSocket` in `KV::Client`).
  #
  # Used together with `ResponseReader` and `Bucket` to compose
  # `KV::Client`. Stateless on its own.
  #
  # ```
  # class Peer
  #   include KV::RequestWriter
  #
  #   def initialize(@socket : IO)
  #   end
  # end
  #
  # io = IO::Memory.new
  # Peer.new(io).write(KV::Request.new(KV::Opcode::Get, key: "foo"))
  # ```
  module RequestWriter
    # Frames *request* into a single `HEADER_SIZE`-byte header followed
    # by `extras + key + value`, writes it to `@socket`, and flushes.
    private def write(request : Request) : Nil
      key_bytes = request.key.to_slice
      total_body = request.extras.size + key_bytes.size + request.value.size
      io = IO::Memory.new(HEADER_SIZE + total_body)
      io.write_byte(REQUEST_MAGIC)
      io.write_byte(request.opcode.value)
      io.write_bytes(key_bytes.size.to_u16, IO::ByteFormat::BigEndian)
      io.write_byte(request.extras.size.to_u8)
      io.write_byte(0_u8)                              # data type
      io.write_bytes(0_u16, IO::ByteFormat::BigEndian) # vbucket
      io.write_bytes(total_body.to_u32, IO::ByteFormat::BigEndian)
      io.write_bytes(request.opaque, IO::ByteFormat::BigEndian)
      io.write_bytes(request.cas, IO::ByteFormat::BigEndian)
      io.write(request.extras) unless request.extras.empty?
      io.write(key_bytes) unless key_bytes.empty?
      io.write(request.value) unless request.value.empty?
      @socket.write(io.to_slice)
      @socket.flush
    end
  end
end
