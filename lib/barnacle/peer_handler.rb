module Barnacle
  
  class PeerHandler < EventMachine::Connection
    def initialize(node)
      @node = node
      super
    end
    
    def post_init
        # TODO: make sure it's actually connected FFS
        m = Message.new({
          :type => :node_identification,
          :key => @node.server.uuid,
          :value => nil # Since it's the initial handshake, they should use the IP they used to find us, which should be our public interface.
        })
        @node.connection = self
        @node.send_message(m)
    end

    def receive_data(data)
      m = Message.new(data)
      case m.type
      when :node_identification
        # The server just told us who they were.
        if @node.server.peers[m.key] or m.key == @node.server.uuid then
          
        else
          @node.uuid = m.key
          @node.server.peers[m.key] = @node
        end
      when :node_request
        # They asked for more nodes, let's give them some.
      when :app_message
        # Pass it to the App, and pass it on to other nodes if needed.
        @node.server.rebroadcast_message(m, @node.uuid)
      end
      
    end
  end

end