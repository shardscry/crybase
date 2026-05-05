module CryBase::CouchBase
  enum Service
    KV
    Query
    Search
    Analytics
    Index
    Eventing
    Views
    Management

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

    def self.all_services : Array(Service)
      [KV, Query, Search, Analytics, Index, Eventing, Views, Management]
    end
  end
end
