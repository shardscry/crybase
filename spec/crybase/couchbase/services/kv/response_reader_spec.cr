require "../../../../spec_helper"

private alias KV = CryBase::CouchBase::Services::KV
private alias KVSpec = CryBase::SpecHelpers::KVHelpers

describe KV::ResponseReader do
  it "decodes a successful GET response with extras, key, and value" do
    io = IO::Memory.new
    flags = IO::Memory.new
    flags.write_bytes(0_u32, IO::ByteFormat::BigEndian)
    KVSpec.encode_response(io,
      opcode: KV::Opcode::Get.value,
      status: KV::Status::Success.value,
      cas: 0xCAFE_u64,
      extras: flags.to_slice,
      key: "k",
      value: "world".to_slice,
    )
    io.rewind

    resp = KVSpec::ReaderPeer.new(io).call

    resp.opcode.should eq(KV::Opcode::Get.value)
    resp.status.should eq(KV::Status::Success)
    resp.cas.should eq(0xCAFE_u64)
    resp.key.should eq("k")
    resp.value.should eq("world".to_slice)
    resp.success?.should be_true
  end

  it "decodes a KeyNotFound response (no body)" do
    io = IO::Memory.new
    KVSpec.encode_response(io,
      opcode: KV::Opcode::Get.value,
      status: KV::Status::KeyNotFound.value,
    )
    io.rewind

    resp = KVSpec::ReaderPeer.new(io).call
    resp.status.should eq(KV::Status::KeyNotFound)
    resp.success?.should be_false
  end

  it "raises on invalid magic" do
    io = IO::Memory.new
    io.write_byte(0xFF_u8)
    23.times { io.write_byte(0_u8) }
    io.rewind

    expect_raises(IO::Error, /invalid KV response magic/) do
      KVSpec::ReaderPeer.new(io).call
    end
  end

  it "raises on unknown status code" do
    io = IO::Memory.new
    KVSpec.encode_response(io,
      opcode: KV::Opcode::Get.value,
      status: 0xFFFE_u16,
    )
    io.rewind

    expect_raises(IO::Error, /unknown KV status/) do
      KVSpec::ReaderPeer.new(io).call
    end
  end
end
