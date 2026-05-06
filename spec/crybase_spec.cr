require "./spec_helper"

describe CryBase do
  it "exposes a non-empty VERSION" do
    CryBase::VERSION.empty?.should be_false
  end

  it "VERSION matches semver-ish shape" do
    (CryBase::VERSION =~ /\A\d+\.\d+\.\d+\z/).should_not be_nil
  end
end
