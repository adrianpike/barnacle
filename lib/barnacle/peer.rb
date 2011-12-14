module Barnacle
  
  class Peer
    attr_accessor :uuid, :host, :port, :server, :connection
    
    def initialize(opts = {})
      @connected = false
      
      @host = opts[:host]
      @port = opts[:port]
      @server = opts[:server]
      @uuid = opts[:uuid]
      @connection = opts[:connection]
    end
    
    def connect
      puts "[Barnacle] Connecting to #{@host}:#{@port}..."
      EventMachine.connect @host, @port, PeerHandler, self
    end
    
    def send_message(msg)
      if @connection
        Barnacle.log "SENDING MESSAGE #{msg}"
        @connection.send_data msg.to_protocol(1) 
      else
        Barnacle.log "Just tried to send a message without a connection!"
      end
    end
  end
  
end