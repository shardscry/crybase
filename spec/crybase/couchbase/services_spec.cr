require "../../spec_helper"

private alias Services = CryBase::CouchBase::Services
private alias Service = CryBase::CouchBase::Service

describe Services do
  describe ".list" do
    it "returns every Service enum value" do
      Services.list.should eq([
        Service::KV,
        Service::Query,
        Service::Search,
        Service::Analytics,
        Service::Index,
        Service::Eventing,
        Service::Views,
        Service::Management,
      ])
    end

    it "covers every member of the Service enum" do
      Services.list.size.should eq(Service.values.size)
    end
  end
end
