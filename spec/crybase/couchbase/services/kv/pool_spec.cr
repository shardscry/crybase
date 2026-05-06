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
end
