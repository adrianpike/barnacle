module Barnacle
  
  class Peer
    attr_accessor :uuid, :host, :server, :connection
    
    def initialize(opts = {})
      @connected = false
      
      @host = opts[:host]
      @server = opts[:server]
      @uuid = opts[:uuid]
      @connection = opts[:connection]
    end
    
    def connect
      puts "[Barnacle] Connecting to #{@host}..."
      EventMachine.connect @host, 6061, PeerHandler, self
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