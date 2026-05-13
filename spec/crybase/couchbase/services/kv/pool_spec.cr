require "../../../../spec_helper"

private alias CB = CryBase::CouchBase
private alias KV = CryBase::CouchBase::Services::KV

describe KV::Pool do
  it "uses 10 connections by default" do
    KV::Pool::DEFAULT_SIZE.should eq(10)
  end

  it "requires at least one connection" do
    endpoint = CB::Endpoint.new("127.0.0.1", 11210, CB::Service::KV, false)

    expect_raises(ArgumentError, /pool size/) do
      KV::Pool.new(endpoint, "user", "pass", "bucket", size: 0)
    end
  end

  it "exposes delegated client operations" do
    pool = uninitialized KV::Pool

    typeof(pool.get("key")).should eq(Bytes)
    typeof(pool.get("key", expiry: 1_u32)).should eq(Bytes)
    typeof(pool.get_as("key", String)).should eq(String)
    typeof(pool.get("key", String)).should eq(String)
    typeof(pool.set("key", "value")).should eq(UInt64)
    typeof(pool.set("key", "value", expiry: 1_u32)).should eq(UInt64)
    typeof(pool.delete("key")).should eq(Nil)
    typeof(pool.touch("key", 1_u32)).should eq(UInt64)
    typeof(pool.increment("key")).should eq(UInt64)
    typeof(pool.increment("key", delta: 2_u64, initial: 10_u64, expiry: 1_u32)).should eq(UInt64)
    typeof(pool.decrement("key")).should eq(UInt64)
  end
end
