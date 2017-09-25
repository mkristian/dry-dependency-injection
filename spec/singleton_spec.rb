require 'dry/more/container/singleton'
require 'dry-auto_inject'
describe Dry::More::Container::Directory do

  Import = Dry::AutoInject(Dry::More::Container::Singleton.new)
  Dry::More::Container::Singleton.new.tap do |singleton|
    singleton.config.lazy = false
    Include = Dry::AutoInject(singleton)
  end

  class A; include Import['b']; end

  class B; include Import['c']; end

  class C; include Import['d']; end

  class D; end

  class E; include Import['d']; include Import['f']; end

  class F; include Import['e']; end

  class G; include Include['h']; end

  class H; include Include['g']; end

  ['a', 'b', 'c', 'd', 'e', 'f'].each do |name|
    Import.container.register(name, Object.const_get(name.upcase))
  end

  ['g', 'h'].each do |name|
    Include.container.register(name, Object.const_get(name.upcase))
  end

  it 'does initialize' do
    ['a', 'b', 'c', 'd'].each do |name|
      expect(Import.container[name].class).to eq Object.const_get(name.upcase)
    end
  end

  it 'bails out on circular dependencies' do
    expect { Import.container['e'] }.to raise_error Dry::Container::Error
  end

  it 'bails out on finalize' do
    expect { Include.container.finalize }.to raise_error Dry::Container::Error
  end
end
