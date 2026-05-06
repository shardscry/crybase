# Database-agnostic abstract types every backend in CryBase implements.
#
# Each abstract here defines the minimum contract a concrete adapter
# (`CryBase::CouchBase::*`, future `CryBase::Postgres::*`, …) must satisfy:
#
# * `Interfaces::ConnectionString` — parsed cluster/database address
# * `Interfaces::Endpoint`         — single addressable network target
# * `Interfaces::Client`           — connection-bearing entry point
#
# ```
# def connect(uri : String) : CryBase::Interfaces::Client
#   CryBase::CouchBase::Client.connect(uri)
# end
# ```
module CryBase::Interfaces
end

require "./interfaces/connection_string"
require "./interfaces/endpoint"
require "./interfaces/client"
