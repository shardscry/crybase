require "../spec_helper"
require "http/client"

private alias KV = CryBase::CouchBase::Services::KV
private alias Couchbase = CryBase::SpecHelpers::CouchbaseIntegrationHelpers

describe "Couchbase KV integration" do
  it "stores a document that is visible through Couchbase management" do
    key = "crybase:ci:#{Time.utc.to_unix_ms}"
    kv = nil
    pending! "set COUCHBASE_INTEGRATION=1 to run real Couchbase integration specs" unless Couchbase.enabled?

    config = Couchbase.config
    value = %({"source":"crybase","kind":"integration"})

    kv = KV::Client.new(Couchbase.kv_endpoint(config), config.user, config.pass, config.bucket)
    kv.set(key, value)
    String.new(kv.get(key)).should eq(value)

    response = HTTP::Client.get(
      Couchbase.management_document_uri(config, key),
      Couchbase.auth_headers(config)
    )

    response.status_code.should eq(200)
    response.body.should contain(key)
  ensure
    kv.try &.delete(key.not_nil!) rescue nil if Couchbase.enabled?
    kv.try &.close rescue nil
  end

  it "reuses pooled connections for KV operations" do
    key = "crybase:pool:#{Time.utc.to_unix_ms}"
    pool = nil
    pending! "set COUCHBASE_INTEGRATION=1 to run real Couchbase integration specs" unless Couchbase.enabled?

    config = Couchbase.config

    pool = KV::Pool.new(Couchbase.kv_endpoint(config), config.user, config.pass, config.bucket, size: 2)
    pool.set(key, "pooled")
    String.new(pool.get(key)).should eq("pooled")

    pool.checkout do |client|
      client.set("#{key}:checkout", "borrowed")
      String.new(client.get("#{key}:checkout")).should eq("borrowed")
      client.delete("#{key}:checkout")
    end

    pool.delete(key)
    pool.close
    pool.closed?.should be_true

    expect_raises(IO::Error, /KV pool is closed/) do
      pool.get(key)
    end
  ensure
    pool.try &.delete(key.not_nil!) rescue nil if Couchbase.enabled?
    pool.try &.close rescue nil
  end
end
