module Barnacle

  class ServerHandler < EventMachine::Connection
    def initialize(server)
      @server = server
    
      @remote_uuid = nil
      super
    end
  
    def post_init # Somebody just opened up a connection to us, let's identify them and make them a Peer if need be.
      # TODO: make sure it's actually connected FFS
      m = Message.new({
        :type => :node_identification,
        :key => @server.uuid,
        :value => nil # Since it's the initial handshake, they should use the IP they used to find us, which should be our public interface.
      })
      send_data m.to_protocol(1)
    end
  
    def receive_data(data)
      m = Message.new(data)
      case m.type
      when :node_identification
        if @server.peers[m.key] or m.key == @server.uuid then
        
        else
          # The client just let us know who they were.
          port, ip = Socket.unpack_sockaddr_in(get_peername)
      
          n = Peer.new(:host => ip, :uuid => m.key, :connection => self)
          @remote_uuid = m.key
          @server.peers[m.key] = n
        end
      when :node_request
        # They asked for more nodes, let's give them some.
    
      when :app_message
        # Pass it to the App, and pass it on to other nodes if needed.
        @server.rebroadcast_message(m, @remote_uuid)
      end
    end
  end

end