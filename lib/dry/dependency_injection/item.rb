module Dry
  module DependencyInjection
    class Item

      def initialize(lock, clazz)
        unless clazz.is_a?(Class)
          raise Dry::Container::Error, "needs to be Class object: #{clazz}"
        end
        @_lock = lock
        @clazz = clazz
        @circular = false
      end

      def call
        @_lock.acquire_read_lock
        unless @instance
          @instance = create
        end
        @instance
      ensure
        @_lock.release_read_lock
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
  end
end
