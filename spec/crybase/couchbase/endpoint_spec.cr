require "../../spec_helper"

private alias Endpoint = CryBase::CouchBase::Endpoint
private alias Service = CryBase::CouchBase::Service

describe Endpoint do
  it "stores host/port/service/tls" do
    ep = Endpoint.new("node1", 11210, Service::KV, false)
    ep.host.should eq("node1")
    ep.port.should eq(11210)
    ep.service.should eq(Service::KV)
    ep.tls?.should be_false
  end

  it "renders the couchbase scheme for plaintext KV" do
    ep = Endpoint.new("h", 11210, Service::KV, false)
    ep.scheme.should eq("couchbase")
    ep.address.should eq("couchbase://h:11210")
  end

  it "renders the couchbases scheme for TLS KV" do
    ep = Endpoint.new("h", 11207, Service::KV, true)
    ep.scheme.should eq("couchbases")
    ep.address.should eq("couchbases://h:11207")
  end

  it "renders http for non-KV services" do
    ep = Endpoint.new("h", 8093, Service::Query, false)
    ep.scheme.should eq("http")
    ep.address.should eq("http://h:8093")
  end

  it "renders https for non-KV services with TLS" do
    ep = Endpoint.new("h", 18091, Service::Management, true)
    ep.scheme.should eq("https")
    ep.address.should eq("https://h:18091")
  end

  it "to_s prepends the service display name" do
    ep = Endpoint.new("h", 11210, Service::KV, false)
    ep.to_s.should eq("Data (KV) couchbase://h:11210")
  end
end
