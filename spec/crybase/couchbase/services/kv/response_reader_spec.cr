require "../../../../spec_helper"

private alias KV = CryBase::CouchBase::Services::KV

private class ReaderPeer
  include KV::ResponseReader

  @socket : IO

  def initialize(@socket : IO)
  end

  def call : KV::Response
    read
  end
end

private def encode_response(
  io : IO,
  opcode : UInt8,
  status : UInt16,
  *,
  cas : UInt64 = 0_u64,
  extras : Bytes = Bytes.empty,
  key : String = "",
  value : Bytes = Bytes.empty,
) : Nil
  key_bytes = key.to_slice
  total_body = extras.size + key_bytes.size + value.size
  io.write_byte(KV::RESPONSE_MAGIC)
  io.write_byte(opcode)
  io.write_bytes(key_bytes.size.to_u16, IO::ByteFormat::BigEndian)
  io.write_byte(extras.size.to_u8)
  io.write_byte(0_u8)
  io.write_bytes(status, IO::ByteFormat::BigEndian)
  io.write_bytes(total_body.to_u32, IO::ByteFormat::BigEndian)
  io.write_bytes(0_u32, IO::ByteFormat::BigEndian)
  io.write_bytes(cas, IO::ByteFormat::BigEndian)
  io.write(extras) unless extras.empty?
  io.write(key_bytes) unless key_bytes.empty?
  io.write(value) unless value.empty?
end

describe KV::ResponseReader do
  it "decodes a successful GET response with extras, key, and value" do
    io = IO::Memory.new
    flags = IO::Memory.new
    flags.write_bytes(0_u32, IO::ByteFormat::BigEndian)
    encode_response(io,
      opcode: KV::Opcode::Get.value,
      status: KV::Status::Success.value,
      cas: 0xCAFE_u64,
      extras: flags.to_slice,
      key: "k",
      value: "world".to_slice,
    )
    io.rewind

    resp = ReaderPeer.new(io).call

    resp.opcode.should eq(KV::Opcode::Get.value)
    resp.status.should eq(KV::Status::Success)
    resp.cas.should eq(0xCAFE_u64)
    resp.key.should eq("k")
    resp.value.should eq("world".to_slice)
    resp.success?.should be_true
  end

  it "decodes a KeyNotFound response (no body)" do
    io = IO::Memory.new
    encode_response(io,
      opcode: KV::Opcode::Get.value,
      status: KV::Status::KeyNotFound.value,
    )
    io.rewind

    resp = ReaderPeer.new(io).call
    resp.status.should eq(KV::Status::KeyNotFound)
    resp.success?.should be_false
  end

  it "raises on invalid magic" do
    io = IO::Memory.new
    io.write_byte(0xFF_u8)
    23.times { io.write_byte(0_u8) }
    io.rewind

    expect_raises(IO::Error, /invalid KV response magic/) do
      ReaderPeer.new(io).call
    end
  end

  it "raises on unknown status code" do
    io = IO::Memory.new
    encode_response(io,
      opcode: KV::Opcode::Get.value,
      status: 0xFFFE_u16,
    )
    io.rewind

    expect_raises(IO::Error, /unknown KV status/) do
      ReaderPeer.new(io).call
    end
  end
end
