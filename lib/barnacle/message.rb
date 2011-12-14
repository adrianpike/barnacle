module Barnacle

  class Message
    attr_accessor :type, :key, :value
    
    def initialize(opts)
      if opts.is_a?(Hash) then
        opts.each{|k,v|
          self.send("#{k}=", v)
        }
      else
        interpret_message(opts)
      end
    end
    
    def to_s
      to_protocol(0)
    end
    
    def interpret_message(string)
      # look for a protocol version
      YAML::load(string).each{|k,v| # UNSAFE AS SHIT, FIXME
        self.send("#{k}=", v)
      }
    end
    
    def to_protocol(version = nil)
      {:type => @type, :key => @key, :value => @value}.to_yaml
    end
    
  end

end