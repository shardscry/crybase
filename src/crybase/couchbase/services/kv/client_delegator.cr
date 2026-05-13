private module CryBase::CouchBase::Services::KV::ClientDelegator
  macro delegate_to_client
    {% methods = [
         :get,
         :get_as,
         :set,
         :delete,
         :touch,
         :increment,
         :decrement,
       ] %}
    {% for method in methods %}
      def {{ method.id }}(*args, **kwargs)
        checkout do |client|
          client.{{ method.id }}(*args, **kwargs)
        end
      end
    {% end %}
  end
end
