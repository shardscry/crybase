# Combine cluster-level discovery with the KV protocol client:
# probe the cluster for reachable endpoints, pick the first KV one,
# and store/read a typed JSON value against it.
#
# Reads from `.envrc` (loaded via direnv): COUCHBASE_HOST,
# COUCHBASE_USER, COUCHBASE_PASS, COUCHBASE_BUCKET.
#
#   crystal run examples/kv_endpoint_from_cluster.cr
require "json"
require "../src/crybase"

struct Profile
  include JSON::Serializable

  property name : String
  property score : Int32

  def initialize(@name : String, @score : Int32)
  end
end

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

kv.set("crybase:demo", Profile.new("ada", 42))
puts "stored crybase:demo"
profile = kv.get("crybase:demo", Profile)
puts "loaded: #{profile.name} scored #{profile.score}"
# kv.delete("crybase:demo")

kv.close
cluster.close
