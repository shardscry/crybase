module CryBase::CouchBase
  # Dummy client that enumerates and probes every Couchbase service interface
  # (KV, Query, Search, Analytics, Index, Eventing, Views, Management) for the
  # configured hosts, over either plaintext or TLS ports.
  #
  # No protocol handshake is performed yet — this stage only validates TCP
  # reachability so callers can confirm the cluster's network surface.
  class Client
    getter connection_string : ConnectionString
    getter username : String?
    getter password : String?
    getter connect_timeout : Time::Span
    getter endpoints : Array(Endpoint)
    getter? connected : Bool = false

    def self.connect(
      uri : String,
      username : String? = nil,
      password : String? = nil,
      connect_timeout : Time::Span = 5.seconds,
    ) : Client
      client = new(uri, username, password, connect_timeout)
      client.connect
      client
    end

    def initialize(
      uri : String,
      @username : String? = nil,
      @password : String? = nil,
      @connect_timeout : Time::Span = 5.seconds,
    )
      @connection_string = ConnectionString.parse(uri)
      @endpoints = build_endpoints(@connection_string)
    end

    def connect : Array(Endpoint)
      reachable = [] of Endpoint
      @endpoints.each do |ep|
        reachable << ep if probe(ep)
      end

      if reachable.empty?
        raise IO::Error.new(
          "no Couchbase service endpoints reachable for hosts " \
          "#{@connection_string.hosts.join(", ")}"
        )
      end

      @connected = true
      reachable
    end

    def close : Nil
      @connected = false
    end

    def endpoints_for(service : Service) : Array(Endpoint)
      @endpoints.select { |e| e.service == service }
    end

    private def build_endpoints(cs : ConnectionString) : Array(Endpoint)
      list = [] of Endpoint
      cs.hosts.each do |host|
        Service.all_services.each do |service|
          port = cs.explicit_port && service.management? ? cs.explicit_port.not_nil! : service.default_port(cs.tls)
          list << Endpoint.new(host, port, service, cs.tls)
        end
      end
      list
    end

    private def probe(endpoint : Endpoint) : Bool
      socket = TCPSocket.new(endpoint.host, endpoint.port, connect_timeout: @connect_timeout)
      socket.close
      true
    rescue IO::Error | Socket::Error
      false
    end
  end
end
