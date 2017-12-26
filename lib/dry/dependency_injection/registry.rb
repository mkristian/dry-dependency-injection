require_relative 'item'

module Dry
  module DependencyInjection
    class Registry

      def initialize
        @_lock = Concurrent::ReentrantReadWriteLock.new
        @_mutex = Concurrent::Synchronization::Lock.new
      end

      def call(container, key, item, _options)
        key = key.to_s.dup.freeze
        @_mutex.synchronize do
          if container.key?(key)
            raise Dry::Container::Error, "There is already an item registered with the key #{key.inspect}"
          end

          container[key] = Item.new(@_lock, item)
        end
      end
    end
  end
end
