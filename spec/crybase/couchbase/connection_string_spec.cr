require "../../spec_helper"

private alias ConnectionString = CryBase::CouchBase::ConnectionString

describe ConnectionString do
  it "defaults to plaintext couchbase scheme" do
    cs = ConnectionString.parse("localhost")
    cs.hosts.should eq(["localhost"])
    cs.tls.should be_false
    cs.explicit_port.should be_nil
  end

  it "parses couchbases:// as TLS" do
    cs = ConnectionString.parse("couchbases://node1.example.com")
    cs.tls.should be_true
  end

  it "parses comma-separated hosts and explicit port" do
    cs = ConnectionString.parse("couchbase://a,b,c:8091")
    cs.hosts.should eq(["a", "b", "c"])
    cs.explicit_port.should eq(8091)
  end
end
