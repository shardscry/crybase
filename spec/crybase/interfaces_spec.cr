require "../spec_helper"

private alias Interfaces = CryBase::Interfaces
private alias CB = CryBase::CouchBase

describe Interfaces::ConnectionString do
  it "is the parent of CouchBase::ConnectionString" do
    cs = CB::ConnectionString.parse("localhost")
    cs.is_a?(Interfaces::ConnectionString).should be_true
  end

  it "exposes hosts and tls through the abstract contract" do
    cs = CB::ConnectionString.parse("couchbases://h1,h2")
    abs = cs.as(Interfaces::ConnectionString)
    abs.hosts.should eq(["h1", "h2"])
    abs.tls?.should be_true
  end
end

describe Interfaces::Endpoint do
  it "is the parent of CouchBase::Endpoint" do
    ep = CB::Endpoint.new("h", 11210, CB::Service::KV, false)
    ep.is_a?(Interfaces::Endpoint).should be_true
  end

  it "exposes host/port/tls through the abstract contract" do
    ep = CB::Endpoint.new("h", 18091, CB::Service::Management, true)
    abs = ep.as(Interfaces::Endpoint)
    abs.host.should eq("h")
    abs.port.should eq(18091)
    abs.tls?.should be_true
  end
end

describe Interfaces::Client do
  it "is the parent of CouchBase::Client" do
    client = CB::Client.new("couchbase://h")
    client.is_a?(Interfaces::Client).should be_true
  end

  it "exposes connection_string and connected? through the abstract contract" do
    client = CB::Client.new("couchbase://h")
    abs = client.as(Interfaces::Client)
    abs.connection_string.hosts.should eq(["h"])
    abs.connected?.should be_false
  end
end
