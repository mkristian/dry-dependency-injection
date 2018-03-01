module Ng
  class Third
    extend Dry::DependencyInjection::Eager
    include Dependency['registry']

    def initialize(**)
      super
      registry.register(Dry::Core::Inflector.underscore(self.class.to_s).sub('/', '.'), self)
    end
  end
end
