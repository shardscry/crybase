require "../spec_helper"
require "base64"
require "http/client"

private alias CB = CryBase::CouchBase
private alias KV = CryBase::CouchBase::Services::KV

private INTEGRATION = ENV["COUCHBASE_INTEGRATION"]? == "1"

describe "Couchbase KV integration" do
  it "stores a document that is visible through Couchbase management" do
    key = "crybase:ci:#{Time.utc.to_unix_ms}"
    kv = nil
    pending! "set COUCHBASE_INTEGRATION=1 to run real Couchbase integration specs" unless INTEGRATION

    host = ENV["COUCHBASE_HOST"]? || "127.0.0.1"
    user = ENV["COUCHBASE_USER"]? || "Administrator"
    pass = ENV["COUCHBASE_PASS"]? || "password"
    bucket = ENV["COUCHBASE_BUCKET"]? || "default"
    value = %({"source":"crybase","kind":"integration"})

    endpoint = CB::Endpoint.new(host, 11210, CB::Service::KV, false)
    kv = KV::Client.new(endpoint, user, pass, bucket)
    kv.set(key, value)
    String.new(kv.get(key)).should eq(value)

    encoded_key = URI.encode_path_segment(key)
    uri = URI.parse("http://#{host}:8091/pools/default/buckets/#{bucket}/scopes/_default/collections/_default/docs/#{encoded_key}")
    headers = HTTP::Headers{"Authorization" => "Basic #{Base64.strict_encode("#{user}:#{pass}")}"}
    response = HTTP::Client.get(uri, headers)

    response.status_code.should eq(200)
    response.body.should contain(key)
  ensure
    kv.try &.delete(key.not_nil!) rescue nil if INTEGRATION
    kv.try &.close rescue nil
  end
end
