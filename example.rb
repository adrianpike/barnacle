$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'barnacle'

class KeyboardHandler < EM::Connection
  include EM::Protocols::LineText2

  attr_reader :server

  def initialize(barnacle_server)
    @server = barnacle_server
  end

  def receive_line(data)
    
    @server.send(data, {
      :queue => 'msg_q',
      :peers => 'all', # or a number of peers
      :peer_order => 'fastest' # or slowest, or random
    })
  end
end

class BarnacleTest < Barnacle::Server
  
  def peer_connect(peer)
    p "peer connected: #{peer}"
  end

  def peer_disconnect(peer)
  end
  
  def message_received(msg)
    p "MESSAGE CAME IN: #{msg}"
  end

  def post_setup
    EventMachine.open_keyboard(KeyboardHandler, self)
    
    EventMachine::add_periodic_timer(5) do

      printf "\n"
      puts "We are #{uuid}."
      peers.each{|k, node|
        printf " #{k} -> #{node.host}" 
        printf "\n"
      }

    end
    
  end

end


opts = {}
if ARGV[0] then
  opts[:seed_hosts] = [ARGV[0]]
end

b=BarnacleTest.new(opts)
b.run # This fires up an eventmachine reactor!