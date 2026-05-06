module CryBase::CouchBase::Services::KV
  # Raised when the server replies with `Status::KeyNotFound`. Typical
  # source: `Client#get` for an absent key.
  #
  # ```
  # begin
  #   kv.get("never-set")
  # rescue KV::NotFound
  #   # handle missing key
  # end
  # ```
  class NotFound < Error
  end
end
