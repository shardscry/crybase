module CryBase::CouchBase
  # Parses a Couchbase connection string of the form:
  #
  # * `couchbase://host[,host2][:port]`     — plaintext
  # * `couchbases://host[,host2][:port]`    — TLS
  # * `http(s)://host[:port]`               — treated as the Management URL
  #
  # ```
  # cs = CryBase::CouchBase::ConnectionString.parse("couchbases://n1,n2:18091")
  # cs.hosts         # => ["n1", "n2"]
  # cs.tls           # => true
  # cs.explicit_port # => 18091
  # ```
  struct ConnectionString < CryBase::Interfaces::ConnectionString
    getter hosts : Array(String)
    getter tls : Bool

    # Port explicitly given in the URI, or `nil` when none was supplied.
    # Used to override the `Management` service's default port; other
    # services always use their `Service#default_port`.
    getter explicit_port : Int32?

    def initialize(@hosts : Array(String), @tls : Bool, @explicit_port : Int32? = nil)
      raise ArgumentError.new("at least one host required") if @hosts.empty?
    end

    # Parses *input* into a `ConnectionString`.
    #
    # Raises `ArgumentError` if the string is empty or has no host
    # component.
    #
    # ```
    # ConnectionString.parse("localhost")          # plaintext, no port
    # ConnectionString.parse("couchbases://h1,h2") # TLS, two hosts
    # ```
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
      authority = rest.split('/', 2).first.split('?', 2).first
      if (colon = authority.rindex(':')) && authority[(colon + 1)..].to_i?
        {authority[0...colon], authority[(colon + 1)..].to_i}
      else
        {authority, nil}
      end
    end
  end
end
