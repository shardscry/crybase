module CryBase::CouchBase::Services::KV
  # Forwarding mixin for KV pools that lease a client per operation.
  module ClientDelegate
    private def with_client(& : Client -> T) : T forall T
      checkout { |client| yield client }
    end

    def get(key : String, expiry : UInt32? = nil) : Bytes
      with_client(&.get(key, expiry))
    end

    # Fetches the document through a pooled client and decodes it as *type*.
    #
    # See `KV::Client#get_as` for value encoding and expiration behavior.
    def get_as(key : String, type : T.class, expiry : UInt32? = nil) : T forall T
      with_client(&.get_as(key, type, expiry))
    end

    # Compatibility alias for `get_as(key, type, expiry)`.
    def get(key : String, type : T.class, expiry : UInt32? = nil) : T forall T
      get_as(key, type, expiry)
    end

    def set(key : String, value : String | Bytes, expiry : UInt32 = 0_u32) : UInt64
      with_client(&.set(key, value, expiry))
    end

    def set(key : String, value : T, expiry : UInt32 = 0_u32) : UInt64 forall T
      with_client(&.set(key, value, expiry))
    end

    def delete(key : String) : Nil
      with_client(&.delete(key))
    end

    def touch(key : String, expiry : UInt32) : UInt64
      with_client(&.touch(key, expiry))
    end

    def increment(
      key : String,
      delta : UInt64 = 1_u64,
      initial : UInt64 = 0_u64,
      expiry : UInt32 = 0_u32,
    ) : UInt64
      with_client(&.increment(key, delta, initial, expiry))
    end

    def decrement(
      key : String,
      delta : UInt64 = 1_u64,
      initial : UInt64 = 0_u64,
      expiry : UInt32 = 0_u32,
    ) : UInt64
      with_client(&.decrement(key, delta, initial, expiry))
    end
  end
end
