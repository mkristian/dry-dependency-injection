# need a plural class to test the inflection from filename to class constant
class Books
  extend Dry::DependencyInjection::Eager
  include Dependency['registry']

  def initialize(**)
    super
    registry.register(Dry::Core::Inflector.underscore(self.class.to_s).sub('/', '.'), self)
  end
end
