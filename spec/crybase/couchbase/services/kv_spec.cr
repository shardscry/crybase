require "../../../spec_helper"

private alias KV = CryBase::CouchBase::Services::KV

describe KV do
  it "pins documented opcode values" do
    KV::Opcode::Get.value.should eq(0x00_u8)
    KV::Opcode::Set.value.should eq(0x01_u8)
    KV::Opcode::Delete.value.should eq(0x04_u8)
    KV::Opcode::Hello.value.should eq(0x1F_u8)
    KV::Opcode::SaslAuth.value.should eq(0x21_u8)
    KV::Opcode::SelectBucket.value.should eq(0x89_u8)
  end

  it "pins documented status values" do
    KV::Status::Success.value.should eq(0x0000_u16)
    KV::Status::KeyNotFound.value.should eq(0x0001_u16)
    KV::Status::KeyExists.value.should eq(0x0002_u16)
    KV::Status::AuthError.value.should eq(0x0020_u16)
    KV::Status::TempFailure.value.should eq(0x0086_u16)
  end

  it "pins protocol framing constants" do
    KV::REQUEST_MAGIC.should eq(0x80_u8)
    KV::RESPONSE_MAGIC.should eq(0x81_u8)
    KV::HEADER_SIZE.should eq(24)
  end
end
