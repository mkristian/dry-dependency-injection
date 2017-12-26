require 'dry/dependency_injection/singletons'
require 'dry-auto_inject'
describe Dry::DependencyInjection::Singletons do

  class Lazy; include Dry::DependencyInjection::Singletons; end
  Import = Dry::AutoInject(Lazy.new)
  Dependencies = Dry::AutoInject(Lazy.new)

  class Eager; extend Dry::DependencyInjection::Singletons; end
  Eager.config.lazy = false
  Include = Dry::AutoInject(Eager)

  class A; include Import['b']; end

  class B; include Import['c']; end

  class C; include Import['d']; end

  class D; end

  class E; include Import['d']; include Import['f']; end

  class F; include Import['e']; end

  class G; include Include['h']; end

  class H; include Include['g']; end

  class I; attr_accessor :plugin; end

  class J
    include Dependencies['i']
    extend Dry::DependencyInjection::Eager

    def initialize(i:)
      super
      i.plugin = self
    end
  end

  class K; include Dependencies['l']; end

  class L; include Dependencies['k']; end

  ['a', 'b', 'c', 'd', 'e', 'f'].each do |name|
    Import.container.register(name, Object.const_get(name.upcase))
  end

  ['g', 'h'].each do |name|
    Include.container.register(name, Object.const_get(name.upcase))
  end

  ['i', 'j', 'k', 'l'].each do |name|
    Dependencies.container.register(name, Object.const_get(name.upcase))
  end

  it 'does initialize' do
    ['a', 'b', 'c', 'd'].each do |name|
      expect(Import.container[name].class).to eq Object.const_get(name.upcase)
    end
  end

  it 'does initialize eager component' do
    expect(Dependencies.container['i'].plugin).to eq nil
    Dependencies.container.finalize
    expect(Dependencies.container['i'].plugin).to eq Dependencies.container['j']
    # all other components are still lazy and contain a circular dependency
    expect { K.new }.to raise_error Dry::Container::Error
  end

  it 'bails out on circular dependencies' do
    expect { E.new }.to raise_error Dry::Container::Error
  end

  it 'bails out on finalize' do
    expect { Include.container.finalize }.to raise_error Dry::Container::Error
  end
end
