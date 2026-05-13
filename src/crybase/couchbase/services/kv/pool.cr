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

    private macro delegate_to_client(*methods)
      {% for method in methods %}
        def {{ method.id }}(*args, **kwargs)
          checkout do |client|
            client.{{ method.id }}(*args, **kwargs)
          end
        end
      {% end %}
    end

    delegate_to_client get, get_as, set, delete, touch, increment, decrement

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
