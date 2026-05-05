require "../../spec_helper"

private alias Service = CryBase::CouchBase::Service

describe Service do
  it "exposes plaintext default ports for every service" do
    Service::KV.default_port(false).should eq(11210)
    Service::Query.default_port(false).should eq(8093)
    Service::Search.default_port(false).should eq(8094)
    Service::Analytics.default_port(false).should eq(8095)
    Service::Index.default_port(false).should eq(9102)
    Service::Eventing.default_port(false).should eq(8096)
    Service::Views.default_port(false).should eq(8092)
    Service::Management.default_port(false).should eq(8091)
  end

  it "exposes TLS default ports for every service" do
    Service::KV.default_port(true).should eq(11207)
    Service::Query.default_port(true).should eq(18093)
    Service::Management.default_port(true).should eq(18091)
  end
end
