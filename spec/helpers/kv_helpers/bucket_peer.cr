module CryBase::SpecHelpers::KVHelpers
  class BucketPeer
    include CryBase::CouchBase::Services::KV::RequestWriter
    include CryBase::CouchBase::Services::KV::ResponseReader
    include CryBase::CouchBase::Services::KV::Bucket

    @socket : IO

    def initialize(@socket : IO)
    end

    def call(name : String) : Nil
      use(name)
    end
  end
end
