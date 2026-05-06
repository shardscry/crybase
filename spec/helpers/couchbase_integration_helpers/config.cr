module CryBase::SpecHelpers::CouchbaseIntegrationHelpers
  record Config,
    host : String,
    user : String,
    pass : String,
    bucket : String
end
