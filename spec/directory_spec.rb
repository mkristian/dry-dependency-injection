require 'dry/more/container/directory'
describe Dry::More::Container::Directory do

  class Component

    def initialize(key, &block)
      @key = key
      @block = block
    end

    def call
      @block.call(@key)
    end
  end

  class Builder < Dry::More::Container::Directory::Builder

    attr_reader :container

    def initialize(container = nil)
      @container = (container || Dry::More::Container::Directory.new).tap do |c|
        c.config.path = 'spec/components'
      end
      super(container: @container)
    end

    def create(key, &block)
      Component.new(key, &block)
    end
  end

  class TestBuilder < Builder
    def self.container(c = nil)
      @c = c if c
      @c
    end

    def initialize
      super(self.class.container)
    end
  end
    
  it 'is empty after in lazy mode' do
    container = Builder.new.container
    container.finalize
    expect(container.keys).to eq []
  end

  it 'loads all component in eager mode' do
    TestBuilder.container(Dry::More::Container::Directory.new)
    container = TestBuilder.new.container
    container.config.lazy = false
    container.finalize
    expect(container.keys).to eq ['a', 'b']
    expect { container['c'] }.to raise_error Dry::Container::Error
    expect { container.register('c', 'something') }.to raise_error Dry::Container::Error
  end

  it 'loads components one by one in lazy mode' do
    ['a', 'b'].each do |name|
      $LOADED_FEATURES.delete(File.expand_path("spec/components/#{name}.rb"))
    end
    TestBuilder.container(Dry::More::Container::Directory.new)
    container = TestBuilder.new.container
    container.config.lazy = true
    expect(container.keys).to eq []
    container['b']
    expect(container.keys).to eq ['b']
    container['a']
    expect(container.keys).to eq ['b', 'a']
    container.finalize_eager
    expect(container.keys).to eq ['b', 'a']
    expect { container['c'] }.to raise_error Dry::Container::Error
  end
end
