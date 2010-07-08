class Proxy
  include Panda::Router::ClassMethods
  
  attr_accessor :name, :cloud
  attr_writer :connection
  
  def connection
    @cloud.connection
  end
  
end
