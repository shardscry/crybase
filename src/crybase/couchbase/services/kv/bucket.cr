module CryBase::CouchBase::Services::KV
  # Mixin that performs the SELECT_BUCKET handshake — switches the
  # connection's active bucket. Depends on the includer also mixing
  # in `RequestWriter` (for `write`) and `ResponseReader` (for `read`).
  #
  # Maps server-side errors onto typed exceptions:
  # `Status::AuthError`/`AuthContinue` → `AuthFailed`, anything else
  # non-success → plain `Error`.
  #
  # ```
  # class Peer
  #   include KV::RequestWriter
  #   include KV::ResponseReader
  #   include KV::Bucket
  #
  #   def initialize(@socket : IO)
  #   end
  # end
  #
  # # `io` is wired to a real KV node (or a fake responder)
  # Peer.new(io).use("default")
  # ```
  module Bucket
    # Sends a SELECT_BUCKET request for *bucket* and waits for the
    # response. Returns `Nil` on success, raises on any non-success
    # status.
    private def use(bucket : String) : Nil
      write(Request.new(Opcode::SelectBucket, key: bucket))
      resp = read
      return if resp.success?
      case resp.status
      when .auth_error?, .auth_continue?
        raise AuthFailed.new(resp.status, "SELECT_BUCKET #{bucket}")
      else
        raise Error.new(resp.status, "SELECT_BUCKET #{bucket}")
      end
    end
  end
end
