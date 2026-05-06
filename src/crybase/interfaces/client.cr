module CryBase::Interfaces
  # Common contract every database-specific client in CryBase must satisfy.
  # Subtypes carry their own auth, endpoint shape, and `connect` semantics
  # on top of this base.
  #
  # ```
  # client = CryBase::CouchBase::Client.new("couchbase://localhost")
  # client.is_a?(CryBase::Interfaces::Client) # => true
  # client.connection_string.hosts            # => ["localhost"]
  # client.connected?                         # => false
  # client.close
  # ```
  abstract class Client
    # The parsed connection string the client was constructed from.
    abstract def connection_string : ConnectionString

    # Releases any resources held by the client. Must be idempotent.
    abstract def close : Nil

    # Whether the client has completed a successful `connect`.
    abstract def connected? : Bool
  end
end
