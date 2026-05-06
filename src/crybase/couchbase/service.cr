module CryBase::CouchBase
  # Catalog of services a Couchbase node can expose. Couchbase's
  # multi-dimensional scaling lets each node enable any subset of these,
  # and each service runs on its own well-known port.
  #
  # ```
  # CryBase::CouchBase::Service::KV.default_port(false) # => 11210
  # CryBase::CouchBase::Service::KV.default_port(true)  # => 11207
  # CryBase::CouchBase::Service::Query.display_name     # => "Query (N1QL)"
  # ```
  enum Service
    KV
    Query
    Search
    Analytics
    Index
    Eventing
    Views
    Management

    # Returns the well-known port this service listens on for the given
    # transport — `tls=true` for the TLS variant, `tls=false` for plaintext.
    #
    # ```
    # Service::Management.default_port(false) # => 8091
    # Service::Management.default_port(true)  # => 18091
    # ```
    def default_port(tls : Bool) : Int32
      case self
      in KV         then tls ? 11207 : 11210
      in Query      then tls ? 18093 : 8093
      in Search     then tls ? 18094 : 8094
      in Analytics  then tls ? 18095 : 8095
      in Eventing   then tls ? 18096 : 8096
      in Views      then tls ? 18092 : 8092
      in Index      then tls ? 19102 : 9102
      in Management then tls ? 18091 : 8091
      end
    end

    # Human-readable name as it appears in Couchbase's own UI/docs
    # (e.g. `"Data (KV)"`, `"Query (N1QL)"`).
    #
    # ```
    # Service::KV.display_name    # => "Data (KV)"
    # Service::Search.display_name # => "Search (FTS)"
    # ```
    def display_name : String
      case self
      in KV         then "Data (KV)"
      in Query      then "Query (N1QL)"
      in Search     then "Search (FTS)"
      in Analytics  then "Analytics"
      in Index      then "Index"
      in Eventing   then "Eventing"
      in Views      then "Views"
      in Management then "Management"
      end
    end
  end
end
