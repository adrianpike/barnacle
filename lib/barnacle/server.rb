module Barnacle

  class Server
    attr_accessor :peers, :uuid, :port
  
    def initialize(args)
      @peers = {}
      @sent_messages = []
      @uuid = nil
      @options = {
        :max_edges => 50,
        :seed_hosts => []
      }.merge(args)
    end
  
    def send(message, *opts)
      m=Message.new({
        :type => :app_message,
        :key => UUID.new.generate,
        :value => message
      })
    
      @peers.each {|uuid, peer|
        peer.send_message(m)
      }
    end
  
    def rebroadcast_message(message, source_uuid)
      Barnacle.log "REBROADCASTING #{message.value} from #{source_uuid}"
      unless @sent_messages.include?(message.key)
        @peers.each{|uuid, peer|
          next if uuid == source_uuid
    
          peer.send_message(message)
        }
  
        message_received(message.value)
  
        @sent_messages << message.key
      else
        Barnacle.log "dropping a message that weve already broadcasted from #{source_uuid}"
      end
    end
    
    def find_available_port
      starting_port = 6061
      
    end
  
    def run
      EventMachine::run {
        printf "[Barnacle] node initializing..."
        @uuid = UUID.new.generate
        @signature = EventMachine.start_server("0.0.0.0", 0, ServerHandler, self)
        socket = EventMachine.get_sockname(@signature)
        @port, address = Socket.unpack_sockaddr_in(socket)
        post_setup
        puts " initialized on port #{@port}"
      
        
        @options[:seed_hosts].each{|host|
          Peer.new(:host => host.split(':').first, :port => host.split(':').last, :server => self).connect
        }
        
        DNSSD.register(@uuid, '_barnacle._tcp', nil, @port) do |r|; end
        
        # Now we need to set up a thread to ask for new nodes every once in a while, and ask DNSSD to autodiscover stuff. skeet.
        EventMachine::add_periodic_timer(1) do
         DNSSD.browse('_barnacle._tcp') do |result|
           unless @peers[result.name] or result.name == @uuid then
             p "DISCOVERED #{result.name} FROM DNSSD"
             DNSSD.resolve(result) do |resolved|
               p "RESOLVED #{resolved.target}:#{resolved.port}"
               #Peer.new(:host => resolved.target+':'+resolved.port, :server => self).connect
             end
           end
         end
        end
      }
    end
  
    def post_setup # stub
    end
  end

end