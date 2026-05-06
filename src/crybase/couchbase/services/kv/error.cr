module CryBase::CouchBase::Services::KV
  # Base exception for any non-`Success` status returned by the KV
  # service. Subclasses (`NotFound`, `AuthFailed`) cover well-known
  # cases; everything else surfaces as a plain `Error`.
  #
  # ```
  # begin
  #   kv.get("missing")
  # rescue ex : KV::Error
  #   ex.status # => KV::Status::KeyNotFound
  # end
  # ```
  class Error < Exception
    # The protocol status that triggered the exception.
    getter status : Status

    def initialize(@status : Status, op : String)
      super("#{op} failed: #{status} (0x#{status.value.to_s(16)})")
    end
  end
end
