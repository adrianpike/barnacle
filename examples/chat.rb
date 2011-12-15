$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'barnacle'
require 'readline'

$username = Readline.readline("What's your username? ", true)

class KeyboardHandler < EM::Connection
  include EM::Protocols::LineText2

  attr_reader :server

  def initialize(barnacle_server)
    @server = barnacle_server
  end

  def receive_line(data)
    
    if (data.match(/^\/(.*)/)) then
      
      case $1
      when "network"
        printf "\n"
        puts "We are #{@server.uuid}."
        @server.peers.each{|k, node|
          printf " #{k} -> #{node.host}" 
          printf "\n"
        }
      end
      
    else
      @server.send($username + ':' + data, {
        :queue => 'msg_q',
        :peers => 'all', # or a number of peers
        :peer_order => 'fastest' # or slowest, or random
      })
    end
  end
end

class BarnacleTest < Barnacle::Server
  
  def peer_connect(peer)
  end

  def peer_disconnect(peer)
  end
  
  def message_received(msg)
    p msg
  end

  def post_setup
    EventMachine.open_keyboard(KeyboardHandler, self)
  end

end


opts = {}
if ARGV[0] then
  opts[:seed_hosts] = [ARGV[0]]
end

b=BarnacleTest.new(opts)
b.run # This fires up an eventmachine reactor!