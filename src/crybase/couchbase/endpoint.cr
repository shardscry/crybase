module CryBase::CouchBase
  struct Endpoint
    getter host : String
    getter port : Int32
    getter service : Service
    getter tls : Bool

    def initialize(@host : String, @port : Int32, @service : Service, @tls : Bool)
    end

    def scheme : String
      case service
      when .kv?
        tls ? "couchbases" : "couchbase"
      else
        tls ? "https" : "http"
      end
    end

    def address : String
      "#{scheme}://#{host}:#{port}"
    end

    def to_s(io : IO) : Nil
      io << service.display_name << " " << address
    end
  end
end
