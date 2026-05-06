# Combine cluster-level discovery with the KV protocol client:
# probe the cluster for reachable endpoints, pick the first KV one,
# and run a get/set/delete cycle against it.
#
# Reads from `.envrc` (loaded via direnv): COUCHBASE_HOST,
# COUCHBASE_USER, COUCHBASE_PASS, COUCHBASE_BUCKET.
#
#   crystal run examples/kv_endpoint_from_cluster.cr
require "../src/crybase"

host = ENV["COUCHBASE_HOST"]? || "localhost"
user = ENV["COUCHBASE_USER"]? || "Administrator"
pass = ENV["COUCHBASE_PASS"]? || "password"
bucket = ENV["COUCHBASE_BUCKET"]? || "default"

cluster = CryBase::CouchBase::Client.new("couchbase://#{host}")
reachable = cluster.connect

kv_endpoints = reachable.select { |e| e.service == CryBase::CouchBase::Service::KV }
abort "no reachable KV endpoints on #{host}" if kv_endpoints.empty?

endpoint = kv_endpoints.first
puts "Using KV endpoint: #{endpoint}"

kv = CryBase::CouchBase::Services::KV::Client.new(endpoint, user, pass, bucket)

kv.set("crybase:demo", %({"hello":"world"}))
puts "stored crybase:demo"
puts "loaded: #{String.new(kv.get("crybase:demo"))}"
# kv.delete("crybase:demo")

kv.close
cluster.close
