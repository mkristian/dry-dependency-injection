require 'dry/more/container/directory'
require 'dry-auto_inject'
describe Dry::More::Container::Directory do

  Container = Hash.new
  Service = Dry::AutoInject(Container)

  before do
    Dry::More::Container::Directory.new.tap do |c|
      c.config.path = 'spec/components'
      Container[:container] = c
    end

    ['a', 'b', 'c'].each do |name|
      $LOADED_FEATURES.delete(File.expand_path("spec/components/#{name}.rb"))
    end
  end
  
  class Component

    def initialize(key, &block)
      @key = key
      @block = block
    end

    def call
      @block.call(@key)
    end
  end

  class Builder2 < Dry::More::Container::Directory::Builder2
    include Service[:container]

    def do_build(&block)
      Proc.new { block.call(@key) }
    end
  end

  class Builder < Dry::More::Container::Directory::Builder2
    include Service[:container]

    def do_build(&block)
      Component.new(@key, &block)
    end
  end

  it 'load string from directory-container' do
    container = Container[:container]

    c = container['c']
    expect(c).to eq "called spec/components/c.rb with 'c'"
  end

  it 'is empty after in lazy mode' do
    container = Container[:container] = Dry::More::Container::Directory.new
    container.finalize
    expect(container.keys).to eq []
  end

  it 'loads all component in eager mode' do
    container = Container[:container]
    container.config.lazy = false
    container.finalize
    expect(container.keys).to eq ['a', 'b', 'c']
    expect { container['d'] }.to raise_error Dry::Container::Error
    expect { container.register('d', 'something') }.to raise_error Dry::Container::Error
  end

  it 'loads components one by one in lazy mode' do
    container = Container[:container]
    container.config.lazy = true
    expect(container.keys).to eq []
    container['b']
    expect(container.keys).to eq ['b']
    container['a']
    expect(container.keys).to eq ['b', 'a']
    container['c']
    expect(container.keys).to eq ['b', 'a', 'c']
    container.finalize_eager
    expect(container.keys).to eq ['b', 'a', 'c']
    expect { container['d'] }.to raise_error Dry::Container::Error
  end
end
