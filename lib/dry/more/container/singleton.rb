require_relative 'lazy'
module Dry
  module More
    module Container
      class Singleton < Lazy

        class Item

          def initialize(lock, clazz)
            unless clazz.is_a?(Class)
              raise Dry::Container::Error, "service needs to be Class: ${clazz}"
            end
            @_lock = lock
            @clazz = clazz
            @circular = false
          end

          def call
            unless @instance
              @instance = create
            end
            @instance
          end

          def create
            @_lock.acquire_write_lock
            begin
              if @circular
                raise Dry::Container::Error, "circular dependency detected: #{@clazz} depends on itself"
              end
              @circular = true
              @clazz.new
            ensure
              @_lock.release_write_lock
            end
          end
        end

        class Registry

          def initialize
            @_lock = Concurrent::ReentrantReadWriteLock.new
            @_mutex = Concurrent::Synchronization::Lock.new
          end

          def call(container, key, item, options)
            key = key.to_s.dup.freeze
            @_mutex.synchronize do
              if container.key?(key)
                raise Dry::Container::Error, "There is already an item registered with the key #{key.inspect}"
              end

              container[key] = Item.new(@_lock, item)
            end
          end
        end

        def orig_register(key, item = nil, options = {}, &block)
          if block_given?
            raise Dry::Container::Error, 'can not register block'
          else
            config.registry.call(_container, key, item, options)

            self
          end
        end

        def finalize_eager
          keys.each do |key|
            self[key]
          end
        end

        configure do |config|
          config.registry = Registry.new
        end
      end
    end
  end
end
