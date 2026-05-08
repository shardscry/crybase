# Cluster-level probe — opens a TCP connection to every service
# interface (KV, Query, Search, …) on every host in the connection
# string, prints the reachable subset.
#
# Reads from `.envrc` (loaded via direnv): COUCHBASE_HOST.
#
#   crystal run examples/cluster_probe.cr
require "../src/crybase"

host = ENV["COUCHBASE_HOST"]? || "localhost"
uri = "couchbase://#{host}"

client = CryBase::CouchBase::Client.new(uri)
puts "Probing #{client.connection_string.hosts.join(", ")} (#{client.endpoints.size} endpoints total)..."

reachable = client.connect
puts "Reachable:"
reachable.each { |endpoint| puts "  - #{endpoint}" }

client.close
