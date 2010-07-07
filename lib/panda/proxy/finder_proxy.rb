class FinderProxy < Proxy

  include Panda::Finders::ClassMethods
  include Panda::Finders::PathFinder

  def initialize(name, cloud)
    @name = name
    @cloud = cloud
  end
  
  def find_by_path(url, map={})
    object = super(url, map)
    if object.is_a?(Array)
      object.each{|o| o.cloud = @cloud}
    else
      object.cloud = @cloud
    end
    object
  end
  
end