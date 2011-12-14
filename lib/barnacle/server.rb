module Barnacle

  class Server
    attr_accessor :peers, :uuid
  
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
  
    def run
      EventMachine::run {
        printf "[Barnacle] node initializing..."
        @uuid = UUID.new.generate
        @signature = EventMachine.start_server("0.0.0.0", "6061", ServerHandler, self)
        post_setup
        puts " initialized."
      
        @options[:seed_hosts].each{|host|
          Peer.new(:host => host, :server => self).connect
        }
      }
    end
  
    def post_setup # stub
    end
  end

end