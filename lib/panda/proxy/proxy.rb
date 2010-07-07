class Proxy
  include Panda::Router::ClassMethods
  
  attr_accessor :connection, :name, :cloud
  
  def connection
    @cloud.connection
  end
  
end
