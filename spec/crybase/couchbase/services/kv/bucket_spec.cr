require "../../../../spec_helper"

private alias KV = CryBase::CouchBase::Services::KV

private class BucketPeer
  include KV::RequestWriter
  include KV::ResponseReader
  include KV::Bucket

  @socket : IO

  def initialize(@socket : IO)
  end

  def call(name : String) : Nil
    use(name)
  end
end

private def encode_response(
  io : IO,
  opcode : UInt8,
  status : UInt16,
) : Nil
  io.write_byte(KV::RESPONSE_MAGIC)
  io.write_byte(opcode)
  io.write_bytes(0_u16, IO::ByteFormat::BigEndian) # key length
  io.write_byte(0_u8)                              # extras length
  io.write_byte(0_u8)                              # data type
  io.write_bytes(status, IO::ByteFormat::BigEndian)
  io.write_bytes(0_u32, IO::ByteFormat::BigEndian) # total body
  io.write_bytes(0_u32, IO::ByteFormat::BigEndian) # opaque
  io.write_bytes(0_u64, IO::ByteFormat::BigEndian) # cas
end

describe KV::Bucket do
  it "sends SELECT_BUCKET with the bucket name in the key field" do
    read_buf = IO::Memory.new
    encode_response(read_buf, KV::Opcode::SelectBucket.value, KV::Status::Success.value)
    read_buf.rewind

    write_buf = IO::Memory.new
    io = IO::Stapled.new(read_buf, write_buf)

    BucketPeer.new(io).call("default")

    write_buf.rewind
    header = Bytes.new(KV::HEADER_SIZE)
    write_buf.read_fully(header)
    header[0].should eq(KV::REQUEST_MAGIC)
    header[1].should eq(KV::Opcode::SelectBucket.value)
    key_len = IO::ByteFormat::BigEndian.decode(UInt16, header[2, 2])
    key_len.should eq(7_u16)

    key = Bytes.new(key_len.to_i)
    write_buf.read_fully(key)
    String.new(key).should eq("default")
  end

  it "raises AuthFailed on AuthError status" do
    read_buf = IO::Memory.new
    encode_response(read_buf, KV::Opcode::SelectBucket.value, KV::Status::AuthError.value)
    read_buf.rewind

    io = IO::Stapled.new(read_buf, IO::Memory.new)

    expect_raises(KV::AuthFailed, /SELECT_BUCKET/) do
      BucketPeer.new(io).call("locked")
    end
  end

  it "raises Error on a generic non-success status" do
    read_buf = IO::Memory.new
    encode_response(read_buf, KV::Opcode::SelectBucket.value, KV::Status::NoBucket.value)
    read_buf.rewind

    io = IO::Stapled.new(read_buf, IO::Memory.new)

    expect_raises(KV::Error, /SELECT_BUCKET/) do
      BucketPeer.new(io).call("missing")
    end
  end
end
