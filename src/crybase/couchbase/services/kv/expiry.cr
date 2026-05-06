module CryBase::CouchBase::Services::KV
  EXPIRY_EXTRAS_SIZE = 4

  def self.expiry_extras(expiry : UInt32) : Bytes
    io = IO::Memory.new(EXPIRY_EXTRAS_SIZE)
    io.write_bytes(expiry, IO::ByteFormat::BigEndian)
    io.to_slice
  end
end
