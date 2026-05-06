require "base64"

module CryBase::SpecHelpers::CouchbaseIntegrationHelpers
  private alias CB = CryBase::CouchBase

  def self.enabled? : Bool
    ENV["COUCHBASE_INTEGRATION"]? == "1"
  end

  def self.config : Config
    Config.new(
      host: ENV["COUCHBASE_HOST"]? || "127.0.0.1",
      user: ENV["COUCHBASE_USER"]? || "Administrator",
      pass: ENV["COUCHBASE_PASS"]? || "password",
      bucket: ENV["COUCHBASE_BUCKET"]? || "default",
    )
  end

  def self.kv_endpoint(config : Config) : CB::Endpoint
    CB::Endpoint.new(config.host, 11210, CB::Service::KV, false)
  end

  def self.management_document_uri(config : Config, key : String) : URI
    encoded_key = URI.encode_path_segment(key)
    URI.parse("http://#{config.host}:8091/pools/default/buckets/#{config.bucket}/scopes/_default/collections/_default/docs/#{encoded_key}")
  end

  def self.auth_headers(config : Config) : HTTP::Headers
    HTTP::Headers{"Authorization" => "Basic #{Base64.strict_encode("#{config.user}:#{config.pass}")}"}
  end
end
