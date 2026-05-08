require "json"

module CryBase::CouchBase::Services::KV
  # Codec used by KV clients to store raw values and JSON-backed objects.
  module Serializable
    macro included
      include ::JSON::Serializable
    end

    def self.encode(value : String) : Bytes
      value.to_slice
    end

    def self.encode(value : Bytes) : Bytes
      value
    end

    def self.encode(value : T) : Bytes forall T
      {% if T < ::JSON::Serializable %}
        value.to_json.to_slice
      {% else %}
        value.to_s.to_slice
      {% end %}
    end

    def self.decode(value : Bytes, type : Bytes.class) : Bytes
      value
    end

    def self.decode(value : Bytes, type : String.class) : String
      String.new(value)
    end

    def self.decode(value : Bytes, type : T.class) : T forall T
      T.from_json(String.new(value))
    end
  end
end
