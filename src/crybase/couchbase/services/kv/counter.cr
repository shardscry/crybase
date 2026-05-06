module CryBase::CouchBase::Services::KV
  COUNTER_EXTRAS_SIZE = 20

  def self.counter_extras(delta : UInt64, initial : UInt64, expiry : UInt32) : Bytes
    io = IO::Memory.new(COUNTER_EXTRAS_SIZE)
    io.write_bytes(delta, IO::ByteFormat::BigEndian)
    io.write_bytes(initial, IO::ByteFormat::BigEndian)
    io.write_bytes(expiry, IO::ByteFormat::BigEndian)
    io.to_slice
  end

  def self.counter_value(value : Bytes) : UInt64
    raise IO::Error.new("invalid KV counter response size #{value.size}") unless value.size == 8

    IO::ByteFormat::BigEndian.decode(UInt64, value)
  end
end
