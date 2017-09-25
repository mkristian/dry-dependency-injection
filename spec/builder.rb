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
  CONTAINER = Dry::More::Container::Directory.new.tap do |c|
    c.config.path = 'spec/components'
  end

  def initialize
    super(container: CONTAINER)
  end

  def create(key, &block)
    Component.new(key, &block)
  end
end
