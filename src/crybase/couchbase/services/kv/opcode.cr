module CryBase::CouchBase::Services::KV
  # Operation codes for the memcached binary protocol commands this
  # client speaks. Values match the Couchbase Server wire protocol
  # specification.
  #
  # ```
  # KV::Opcode::Get.value          # => 0x00
  # KV::Opcode::SelectBucket.value # => 0x89
  # ```
  enum Opcode : UInt8
    Get          = 0x00
    Set          = 0x01
    Delete       = 0x04
    Hello        = 0x1F
    SaslAuth     = 0x21
    SelectBucket = 0x89
  end
end
