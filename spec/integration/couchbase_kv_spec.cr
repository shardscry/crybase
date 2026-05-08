require "../spec_helper"
require "http/client"

private alias KV = CryBase::CouchBase::Services::KV
private alias Couchbase = CryBase::SpecHelpers::CouchbaseIntegrationHelpers

describe "Couchbase KV integration" do
  config = Couchbase.config
  keys = [] of String
  kv = uninitialized KV::Client
  pool = uninitialized KV::Pool

  before_all do
    next unless Couchbase.enabled?

    kv = KV::Client.new(Couchbase.kv_endpoint(config), config.user, config.pass, config.bucket)
    pool = KV::Pool.new(Couchbase.kv_endpoint(config), config.user, config.pass, config.bucket, size: 2)
  end

  before_each do
    pending! "set COUCHBASE_INTEGRATION=1 to run real Couchbase integration specs" unless Couchbase.enabled?
  end

  after_each do
    if Couchbase.enabled?
      keys.each do |key|
        kv.delete(key) rescue nil
        pool.delete(key) rescue nil
      end
      keys.clear
    end
  end

  after_all do
    if Couchbase.enabled?
      kv.close rescue nil
      pool.close rescue nil
    end
  end

  it "stores a document that is visible through Couchbase management" do
    key = "crybase:ci:#{Time.utc.to_unix_ms}"
    keys << key
    value = %({"source":"crybase","kind":"integration"})

    kv.set(key, value)
    String.new(kv.get(key)).should eq(value)

    response = HTTP::Client.get(
      Couchbase.management_document_uri(config, key),
      Couchbase.auth_headers(config)
    )

    response.status_code.should eq(200)
    response.body.should contain(key)
  end

  it "reuses pooled connections for KV operations" do
    key = "crybase:pool:#{Time.utc.to_unix_ms}"
    checkout_key = "#{key}:checkout"
    keys << key
    keys << checkout_key

    pool.set(key, "pooled")
    String.new(pool.get(key)).should eq("pooled")

    pool.checkout do |client|
      client.set(checkout_key, "borrowed")
      String.new(client.get(checkout_key)).should eq("borrowed")
    end
  end

  it "increments and decrements counters" do
    key = "crybase:counter:#{Time.utc.to_unix_ms}"
    keys << key

    kv.increment(key, delta: 2_u64, initial: 10_u64).should eq(10_u64)
    kv.increment(key, delta: 5_u64).should eq(15_u64)
    kv.decrement(key, delta: 3_u64).should eq(12_u64)
  end

  it "increments and decrements counters through the pool" do
    key = "crybase:pool:counter:#{Time.utc.to_unix_ms}"
    keys << key

    pool.increment(key, delta: 4_u64, initial: 20_u64).should eq(20_u64)
    pool.increment(key, delta: 6_u64).should eq(26_u64)
    pool.decrement(key, delta: 10_u64).should eq(16_u64)
  end

  it "touches document expiration" do
    key = "crybase:touch:#{Time.utc.to_unix_ms}"
    keys << key

    kv.set(key, "alive", expiry: 2_u32)
    sleep 1.second
    kv.touch(key, 10_u32)
    sleep 2.seconds

    String.new(kv.get(key)).should eq("alive")
  end

  it "gets and resets expiration atomically" do
    key = "crybase:get-touch:#{Time.utc.to_unix_ms}"
    keys << key

    pool.set(key, "alive", expiry: 2_u32)
    sleep 1.second

    String.new(pool.get(key, expiry: 10_u32)).should eq("alive")
    sleep 2.seconds

    String.new(pool.get(key)).should eq("alive")
  end
end
