module CryBase::CouchBase
  # A single addressable Couchbase service interface — the combination
  # of a host, a port, the `Service` running on that port, and whether
  # the connection should be TLS.
  #
  # ```
  # ep = CryBase::CouchBase::Endpoint.new("h1", 11210, CryBase::CouchBase::Service::KV, false)
  # ep.scheme  # => "couchbase"
  # ep.address # => "couchbase://h1:11210"
  # ep.to_s    # => "Data (KV) couchbase://h1:11210"
  # ```
  struct Endpoint < CryBase::Interfaces::Endpoint
    getter host : String
    getter port : Int32
    getter service : Service
    getter tls : Bool

    def initialize(@host : String, @port : Int32, @service : Service, @tls : Bool)
    end

    # The URI scheme appropriate for this endpoint:
    # * `"couchbase"` / `"couchbases"` for the KV service
    # * `"http"` / `"https"` for every other service
    #
    # ```
    # Endpoint.new("h", 11210, Service::KV, false).scheme    # => "couchbase"
    # Endpoint.new("h", 11207, Service::KV, true).scheme     # => "couchbases"
    # Endpoint.new("h", 8093, Service::Query, false).scheme  # => "http"
    # ```
    def scheme : String
      case service
      when .kv?
        tls ? "couchbases" : "couchbase"
      else
        tls ? "https" : "http"
      end
    end

    # Full `scheme://host:port` string for this endpoint.
    #
    # ```
    # Endpoint.new("h", 11210, Service::KV, false).address # => "couchbase://h:11210"
    # ```
    def address : String
      "#{scheme}://#{host}:#{port}"
    end

    # Renders the endpoint as `"<service display name> <address>"`.
    #
    # ```
    # Endpoint.new("h", 11210, Service::KV, false).to_s # => "Data (KV) couchbase://h:11210"
    # ```
    def to_s(io : IO) : Nil
      io << service.display_name << " " << address
    end
  end
end
