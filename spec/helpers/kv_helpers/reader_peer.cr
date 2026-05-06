module CryBase::SpecHelpers::KVHelpers
  class ReaderPeer
    include CryBase::CouchBase::Services::KV::ResponseReader

    @socket : IO

    def initialize(@socket : IO)
    end

    def call : CryBase::CouchBase::Services::KV::Response
      read
    end
  end
end
