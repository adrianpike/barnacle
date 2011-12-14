require 'rubygems'
require 'eventmachine'
require 'uuid'
require 'yaml'
require 'dnssd'

require 'barnacle/message'
require 'barnacle/peer'
require 'barnacle/server'

require 'barnacle/peer_handler'
require 'barnacle/server_handler'

module Barnacle
  
  # TODO: delicious config
  
  def self.log(event)
    p event
  end
  
end