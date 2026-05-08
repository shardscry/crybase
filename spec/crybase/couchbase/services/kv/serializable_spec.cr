require "../../../../spec_helper"
require "json"

private alias KV = CryBase::CouchBase::Services::KV

private module KVSerializableSpec
  struct Profile
    include JSON::Serializable

    property name : String
    property score : Int32

    def initialize(@name : String, @score : Int32)
    end
  end
end

describe KV::Serializable do
  it "keeps strings and bytes as raw KV values" do
    KV::Serializable.encode("hello").should eq("hello".to_slice)
    KV::Serializable.encode("hello".to_slice).should eq("hello".to_slice)

    KV::Serializable.decode("hello".to_slice, String).should eq("hello")
    KV::Serializable.decode("hello".to_slice, Bytes).should eq("hello".to_slice)
  end

  it "serializes and deserializes JSON::Serializable objects" do
    encoded = KV::Serializable.encode(KVSerializableSpec::Profile.new("ada", 42))

    String.new(encoded).should eq(%({"name":"ada","score":42}))

    decoded = KV::Serializable.decode(encoded, KVSerializableSpec::Profile)
    decoded.name.should eq("ada")
    decoded.score.should eq(42)
  end

  it "stringifies values that do not include JSON serialization" do
    KV::Serializable.encode(123).should eq("123".to_slice)
  end
end
