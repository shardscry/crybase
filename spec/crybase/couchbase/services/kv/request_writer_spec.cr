require "../../../../spec_helper"

private alias KV = CryBase::CouchBase::Services::KV

private class WriterPeer
  include KV::RequestWriter

  @socket : IO

  def initialize(@socket : IO)
  end

  def call(request : KV::Request) : Nil
    write(request)
  end
end

describe KV::RequestWriter do
  it "writes a 24-byte header followed by extras + key + value" do
    io = IO::Memory.new
    extras = IO::Memory.new
    extras.write_bytes(0_u32, IO::ByteFormat::BigEndian)
    extras.write_bytes(0_u32, IO::ByteFormat::BigEndian)
    req = KV::Request.new(
      KV::Opcode::Set,
      key: "foo",
      extras: extras.to_slice,
      value: "bar".to_slice,
    )
    WriterPeer.new(io).call(req)
    io.size.should eq(KV::HEADER_SIZE + 8 + 3 + 3)
  end

  it "encodes the GET header layout" do
    io = IO::Memory.new
    req = KV::Request.new(KV::Opcode::Get, key: "hello", opaque: 7_u32)
    WriterPeer.new(io).call(req)

    io.rewind
    header = Bytes.new(KV::HEADER_SIZE)
    io.read_fully(header)

    header[0].should eq(KV::REQUEST_MAGIC)
    header[1].should eq(KV::Opcode::Get.value)
    IO::ByteFormat::BigEndian.decode(UInt16, header[2, 2]).should eq(5_u16)
    header[4].should eq(0_u8)
    header[5].should eq(0_u8)
    IO::ByteFormat::BigEndian.decode(UInt16, header[6, 2]).should eq(0_u16)
    IO::ByteFormat::BigEndian.decode(UInt32, header[8, 4]).should eq(5_u32)
    IO::ByteFormat::BigEndian.decode(UInt32, header[12, 4]).should eq(7_u32)
    IO::ByteFormat::BigEndian.decode(UInt64, header[16, 8]).should eq(0_u64)

    body = Bytes.new(5)
    io.read_fully(body)
    String.new(body).should eq("hello")
  end

  it "honors the cas field" do
    io = IO::Memory.new
    req = KV::Request.new(KV::Opcode::Set, key: "k", cas: 0xDEADBEEF_u64)
    WriterPeer.new(io).call(req)

    io.rewind
    header = Bytes.new(KV::HEADER_SIZE)
    io.read_fully(header)
    IO::ByteFormat::BigEndian.decode(UInt64, header[16, 8]).should eq(0xDEADBEEF_u64)
  end

  it "honors the opaque field" do
    io = IO::Memory.new
    req = KV::Request.new(KV::Opcode::Get, key: "k", opaque: 42_u32)
    WriterPeer.new(io).call(req)

    io.rewind
    header = Bytes.new(KV::HEADER_SIZE)
    io.read_fully(header)
    IO::ByteFormat::BigEndian.decode(UInt32, header[12, 4]).should eq(42_u32)
  end

  it "honors the vbucket field" do
    io = IO::Memory.new
    req = KV::Request.new(KV::Opcode::Get, key: "crybase:hello", vbucket: 475_u16)
    WriterPeer.new(io).call(req)

    io.rewind
    header = Bytes.new(KV::HEADER_SIZE)
    io.read_fully(header)
    IO::ByteFormat::BigEndian.decode(UInt16, header[6, 2]).should eq(475_u16)
  end
end
