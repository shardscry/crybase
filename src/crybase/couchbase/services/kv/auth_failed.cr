module CryBase::CouchBase::Services::KV
  # Raised when the server returns `Status::AuthError` or
  # `Status::AuthContinue`. Typical source: bad SASL credentials, or
  # a SELECT_BUCKET against a bucket the user can't access.
  #
  # ```
  # begin
  #   KV::Client.new(endpoint, "user", "wrong-pass", "default")
  # rescue KV::AuthFailed
  #   # bad creds
  # end
  # ```
  class AuthFailed < Error
  end
end
