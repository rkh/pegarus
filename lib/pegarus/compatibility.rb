class String
  unless method_defined? :each_char
    def each_char(&block)
      return scan(/./u, &block) if $KCODE =~ /^u/i
      split(//).each(&block)

      self
    end
  end
end

class Module
  unless method_defined? :thunk_method
    def thunk_method(name, value)
      define_method(name) { return value }
    end
  end
end

class Object
  unless method_defined? :metaclass
    def metaclass
      class << self; self; end
    end
  end
end

unless defined?(Type)
  module Type
    def self.coerce_to(obj, cls, meth)
      return obj if obj.kind_of? cls

      begin
        ret = obj.__send__(meth)
      rescue Exception
        raise TypeError, "Coercion error: #{obj.inspect}.#{meth} => #{cls} failed"
      end

      return ret if ret.kind_of? cls

      raise TypeError, "Coercion error: obj.#{meth} did NOT return a #{cls} (was #{ret.class})"
    end
  end
end
