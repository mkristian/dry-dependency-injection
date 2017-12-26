class First
  extend Dry::DependencyInjection::Eager
  include Dependency['registry']

  def initialize(**)
    super
    registry.register(Dry::Core::Inflector.underscore(self.class).sub('/', '.'), self)
  end
end
