require_relative 'lazy'
module Dry
  module More
    module Container
      class Directory < Lazy

        class Builder

          def initialize(container:)
            @container = container
          end

          def build(key, &block)
            instance = create(key, &block)
            @container.register(key, instance)
            instance
          end

          def create(key, &block)
            raise 'not implemented'
          end
        end

        setting :path, 'lib/components'

        class Resolver < Dry::Container::Resolver
          def initialize(config)
            @config = config
          end

          def call(container, key)
            unless container.key?(key)
              file = key.to_s.gsub(/(.)([A-Z])/,'\1_\2').downcase + '.rb'
              require File.join('.', @config.path, file)
            end
            super(container, key)
          rescue LoadError
            raise Dry::Container::Error, "Nothing registered with the key #{key.inspect}"
          end
        end

        def finalize_eager
          Dir[File.join('.', config.path, '*.rb')].each do |file|
            require file
          end
        end

        configure do |config|
          config.resolver = Resolver.new(config)
        end
      end
    end
  end
end
