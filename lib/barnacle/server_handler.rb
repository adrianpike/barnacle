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
        unless @server.peers[m.key] or m.key == @server.uuid then
          if (m.value) then
            # The other end is sending us some nodes to know about.
            ip = m.value[:ip]
            port = m.value[:port]
          else
            # The client just let us know who they were.
            port, ip = Socket.unpack_sockaddr_in(get_peername)
            @remote_uuid = m.key
          end
          # TODO: use port correctly :/
          n = Peer.new(:host => ip, :port => port, :uuid => m.key, :connection => self)
          @server.peers[m.key] = n
        end
      when :node_request
        # They asked for more nodes, let's give them some.
        @server.peers.each{|peer_uuid, peer|
          m = Message.new({
            :type => :node_identification,
            :key => peer_uuid,
            :value => peer
          })
          send_data m.to_protocol(1)
        }
      when :app_message
        # Pass it to the App, and pass it on to other nodes if needed.
        @server.rebroadcast_message(m, @remote_uuid)
      end
    end
  end

end