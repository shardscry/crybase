module CryBase::SpecHelpers::KVHelpers
  class WriterPeer
    include CryBase::CouchBase::Services::KV::RequestWriter

    @socket : IO

    def initialize(@socket : IO)
    end

    def call(request : CryBase::CouchBase::Services::KV::Request) : Nil
      write(request)
    end
  end
end
