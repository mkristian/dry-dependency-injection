require 'dry-dependency-injection'
require 'dry-auto_inject'

class Singletons; extend Dry::DependencyInjection::Singletons; end
Dependency = Dry::AutoInject(Singletons)
path = File.join(File.dirname(File.expand_path(__FILE__)), 'plugins')
Dry::DependencyInjection::Importer.new(Singletons).import(path) do |file|
  !file.include?('ignore')
end.finalize

class App
  include Dependency['registry']

  def run
    registry.keys.each_with_object({}) do |key, map|
      map[key] = registry[key].to_s
    end
  end
end

#p App.new.run
