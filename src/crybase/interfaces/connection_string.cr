module CryBase::Interfaces
  # Common contract every database-specific connection string in CryBase
  # must satisfy. Subtypes provide their own `parse` and any extra fields
  # (ports, buckets, paths, credentials) on top of this base.
  #
  # ```
  # cs = CryBase::CouchBase::ConnectionString.parse("couchbases://h1,h2")
  # cs.is_a?(CryBase::Interfaces::ConnectionString) # => true
  # cs.hosts                                        # => ["h1", "h2"]
  # cs.tls?                                         # => true
  # ```
  abstract struct ConnectionString
    # The cluster nodes parsed from the connection string.
    abstract def hosts : Array(String)

    # Whether the connection should be made over TLS.
    abstract def tls? : Bool
  end
end
