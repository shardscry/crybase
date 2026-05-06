module CryBase::CouchBase::Services::KV
  # One decoded inbound packet from the KV service. Produced by
  # `ResponseReader#read`.
  #
  # ```
  # resp = KV::Response.new(
  #   opcode: KV::Opcode::Get.value,
  #   status: KV::Status::Success,
  #   cas: 0_u64,
  #   extras: Bytes.empty,
  #   key: "",
  #   value: "world".to_slice,
  # )
  # resp.success?          # => true
  # String.new(resp.value) # => "world"
  # ```
  record Response,
    opcode : UInt8,
    status : Status,
    cas : UInt64,
    extras : Bytes,
    key : String,
    value : Bytes

  struct Response
    def success? : Bool
      status.success?
    end
  end
end
