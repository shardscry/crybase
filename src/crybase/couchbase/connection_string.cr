module CryBase::CouchBase
  # Parses a Couchbase connection string of the form:
  #   couchbase://host[,host2][:port]
  #   couchbases://host[,host2][:port]
  #   http(s)://host[:port]   (treated as Management URL)
  struct ConnectionString
    getter hosts : Array(String)
    getter tls : Bool
    getter explicit_port : Int32?

    def initialize(@hosts : Array(String), @tls : Bool, @explicit_port : Int32? = nil)
      raise ArgumentError.new("at least one host required") if @hosts.empty?
    end

    def self.parse(input : String) : ConnectionString
      raise ArgumentError.new("connection string is empty") if input.empty?

      scheme, rest = split_scheme(input)
      tls = scheme.in?({"couchbases", "https"})

      hosts_part, port = split_host_port(rest)
      hosts = hosts_part.split(',', remove_empty: true).map(&.strip)
      raise ArgumentError.new("no hosts parsed from #{input.inspect}") if hosts.empty?

      new(hosts, tls, port)
    end

    private def self.split_scheme(input : String) : {String, String}
      if idx = input.index("://")
        {input[0...idx].downcase, input[(idx + 3)..]}
      else
        {"couchbase", input}
      end
    end

    private def self.split_host_port(rest : String) : {String, Int32?}
      # Strip path/query if present (we only care about authority).
      authority = rest.split('/', 2).first.split('?', 2).first
      if (colon = authority.rindex(':')) && authority[(colon + 1)..].to_i?
        {authority[0...colon], authority[(colon + 1)..].to_i}
      else
        {authority, nil}
      end
    end
  end
end
