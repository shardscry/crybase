module CryBase::Interfaces
  # Common contract every database-specific endpoint in CryBase must
  # satisfy. Subtypes add their own service/role metadata and stringification
  # rules on top of this base.
  #
  # ```
  # ep = CryBase::CouchBase::Endpoint.new("h", 11210, CryBase::CouchBase::Service::KV, false)
  # ep.is_a?(CryBase::Interfaces::Endpoint) # => true
  # ep.host                                 # => "h"
  # ep.port                                 # => 11210
  # ep.tls?                                 # => false
  # ```
  abstract struct Endpoint
    # The hostname or IP address for this endpoint.
    abstract def host : String

    # The TCP port for this endpoint.
    abstract def port : Int32

    # Whether this endpoint speaks TLS.
    abstract def tls? : Bool
  end
end
