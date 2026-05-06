module CryBase::CouchBase::Services::KV
  # Fixed-size pool of authenticated KV clients for concurrent fibers.
  class Pool
    DEFAULT_SIZE = 10

    getter endpoint : Endpoint
    getter bucket : String
    getter size : Int32

    @available : Channel(Client)
    @clients : Array(Client)
    @mutex : Mutex
    @closed : Bool

    def initialize(
      @endpoint : Endpoint,
      username : String,
      password : String,
      @bucket : String,
      @size : Int32 = DEFAULT_SIZE,
      connect_timeout : Time::Span = 5.seconds,
    )
      raise ArgumentError.new("pool size must be at least 1") if @size < 1

      @available = Channel(Client).new(@size)
      @clients = [] of Client
      @mutex = Mutex.new
      @closed = false

      build_clients(username, password, connect_timeout)
    end

    private def build_clients(username : String, password : String, connect_timeout : Time::Span) : Nil
      @size.times do
        client = Client.new(@endpoint, username, password, @bucket, connect_timeout)
        @clients << client
        @available.send(client)
      end
    rescue ex
      @clients.each(&.close)
      raise ex
    end

    def checkout(& : Client -> T) : T forall T
      raise_closed! if closed?

      client = @available.receive
      if closed?
        client.close
        raise_closed!
      end

      begin
        yield client
      ensure
        if closed?
          client.close
        else
          @available.send(client)
        end
      end
    end

    def get(key : String) : Bytes
      checkout { |client| client.get(key) }
    end

    def set(key : String, value : String | Bytes, expiry : UInt32 = 0_u32) : UInt64
      checkout { |client| client.set(key, value, expiry) }
    end

    def delete(key : String) : Nil
      checkout { |client| client.delete(key) }
    end

    def close : Nil
      should_close = @mutex.synchronize do
        next false if @closed

        @closed = true
        true
      end

      return unless should_close
      @clients.each(&.close)
    end

    def closed? : Bool
      @mutex.synchronize { @closed }
    end

    private def raise_closed! : NoReturn
      raise IO::Error.new("KV pool is closed")
    end
  end
end
