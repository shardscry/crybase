require "../spec_helper"
require "http/client"

private alias KV = CryBase::CouchBase::Services::KV
private alias Couchbase = CryBase::SpecHelpers::CouchbaseIntegrationHelpers

describe "Couchbase KV integration" do
  config = Couchbase.config
  keys = [] of String
  kv = nil
  pool = nil

  before_all do
    next unless Couchbase.enabled?

    endpoint = Couchbase.kv_endpoint(config)
    kv = KV::Client.new(endpoint, config.user, config.pass, config.bucket)
    pool = KV::Pool.new(endpoint, config.user, config.pass, config.bucket, size: 2)
  end

  before_each do
    pending! "set COUCHBASE_INTEGRATION=1 to run real Couchbase integration specs" unless Couchbase.enabled?
  end

  after_each do
    if Couchbase.enabled?
      keys.each do |key|
        kv.try &.delete(key) rescue nil
        pool.try &.delete(key) rescue nil
      end
      keys.clear
    end
  end

  after_all do
    kv.try &.close rescue nil
    pool.try &.close rescue nil
  end

  it "stores a document that is visible through Couchbase management" do
    key = "crybase:ci:#{Time.utc.to_unix_ms}"
    keys << key
    value = %({"source":"crybase","kind":"integration"})

    kv.not_nil!.set(key, value)
    String.new(kv.not_nil!.get(key)).should eq(value)

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

    pool.not_nil!.set(key, "pooled")
    String.new(pool.not_nil!.get(key)).should eq("pooled")

    pool.not_nil!.checkout do |client|
      client.set(checkout_key, "borrowed")
      String.new(client.get(checkout_key)).should eq("borrowed")
    end
  end

  it "increments and decrements counters" do
    key = "crybase:counter:#{Time.utc.to_unix_ms}"
    keys << key

    kv.not_nil!.increment(key, delta: 2_u64, initial: 10_u64).should eq(10_u64)
    kv.not_nil!.increment(key, delta: 5_u64).should eq(15_u64)
    kv.not_nil!.decrement(key, delta: 3_u64).should eq(12_u64)
  end

  it "increments and decrements counters through the pool" do
    key = "crybase:pool:counter:#{Time.utc.to_unix_ms}"
    keys << key

    pool.not_nil!.increment(key, delta: 4_u64, initial: 20_u64).should eq(20_u64)
    pool.not_nil!.increment(key, delta: 6_u64).should eq(26_u64)
    pool.not_nil!.decrement(key, delta: 10_u64).should eq(16_u64)
  end

  it "touches document expiration" do
    key = "crybase:touch:#{Time.utc.to_unix_ms}"
    keys << key

    kv.not_nil!.set(key, "alive", expiry: 2_u32)
    sleep 1.second
    kv.not_nil!.touch(key, 10_u32)
    sleep 2.seconds

    String.new(kv.not_nil!.get(key)).should eq("alive")
  end

  it "gets and resets expiration atomically" do
    key = "crybase:get-touch:#{Time.utc.to_unix_ms}"
    keys << key

    pool.not_nil!.set(key, "alive", expiry: 2_u32)
    sleep 1.second

    String.new(pool.not_nil!.get(key, expiry: 10_u32)).should eq("alive")
    sleep 2.seconds

    String.new(pool.not_nil!.get(key)).should eq("alive")
  end
end
