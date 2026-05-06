module CryBase::CouchBase::Services::KV
  # Status codes returned by the server in every response packet.
  # `Success` (`0x0000`) is the only non-error value. The `Response`
  # struct keeps the typed status; `Client` maps a few of these onto
  # specific exception subclasses.
  #
  # ```
  # KV::Status::Success.value     # => 0x0000
  # KV::Status::KeyNotFound.value # => 0x0001
  # ```
  enum Status : UInt16
    Success        = 0x0000
    KeyNotFound    = 0x0001
    KeyExists      = 0x0002
    ValueTooLarge  = 0x0003
    InvalidArgs    = 0x0004
    ItemNotStored  = 0x0005
    DeltaBadValue  = 0x0006
    NotMyVbucket   = 0x0007
    NoBucket       = 0x0008
    AuthError      = 0x0020
    AuthContinue   = 0x0021
    InvalidRange   = 0x0022
    UnknownCommand = 0x0081
    OutOfMemory    = 0x0082
    NotSupported   = 0x0083
    InternalError  = 0x0084
    Busy           = 0x0085
    TempFailure    = 0x0086
  end
end
