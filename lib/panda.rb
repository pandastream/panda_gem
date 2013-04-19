require 'multi_json'
require 'forwardable'

require 'panda/version'
require 'panda/api_authentication'
require 'panda/connection'
require 'panda/config'
require 'panda/modules/router'
require 'panda/modules/finders'
require 'panda/modules/builders'
require 'panda/modules/destroyers'
require 'panda/modules/associations'
require 'panda/modules/updatable'
require 'panda/modules/video_state'
require 'panda/modules/cloud_connection'
require 'panda/proxies/proxy'
require 'panda/proxies/scope'
require 'panda/proxies/encoding_scope'
require 'panda/proxies/video_scope'
require 'panda/proxies/profile_scope'
require 'panda/errors'
require 'panda/base'
require 'panda/resources/resource'
require 'panda/resources/cloud'
require 'panda/resources/encoding'
require 'panda/resources/profile'
require 'panda/resources/video'

require 'panda/panda'
require 'panda/http_client'

module Panda
  extend Forwardable

  load_name = MultiJson.respond_to?(:load) ? 'load' : 'decode'
  def_delegator 'MultiJson', load_name, 'load_json'

  dump_name = MultiJson.respond_to?(:dump) ? 'dump' : 'encode'
  def_delegator 'MultiJson', dump_name, 'dump_json'

  extend self
end
