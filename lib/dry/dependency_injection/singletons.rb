require 'concurrent'
require 'dry-container'
require_relative 'registry'
require_relative 'eager'

module Dry
  module DependencyInjection
    module Singletons

      def self.extended(base)
        hooks_mod = ::Module.new do
          def inherited(subclass)
            subclass.instance_variable_set(:@_lock, Mutex.new)
            subclass.instance_variable_set(:@_lock, @_eager.dup)
            super
          end
        end
        base.class_eval do
          extend Dry::Container::Mixin
          extend hooks_mod

          setting :lazy, true
          setting :registry, Registry.new

          class << self
            def register(*args)
              register_singleton(*args)
            end
          end

          @_eager = []
          @_lock = Mutex.new
        end
      end

      module Initializer
        def initialize(*, &block)
          @_eager = []
          @_lock = Mutex.new
          super
        end
      end

      def self.included(base)
        base.class_eval do
          include ::Dry::Container::Mixin
          prepend Initializer

          setting :lazy, true
          setting :registry, Registry.new

          def register(*args)
            register_singleton(*args)
          end
        end
      end

      def finalize
        @_lock.synchronize do
          if config.lazy
            finalize_lazy
          else
            finalize_eager
          end
          @_finalized = ! config.lazy
        end
      end

      private

      def register_singleton(key, item = nil, options = {}, &block)
        @_lock.synchronize do
          check_finalized
        end
        if block_given?
          raise Dry::Container::Error, 'can not register block'
        else
          config.registry.call(_container, key, item, options)
          @_eager << key if options[:eager] || item.kind_of?(Eager)
          self
        end
      end

      def check_finalized
        if @_finalized
          raise Dry::Container::Error, 'can not register. container already finalized'
        end
      end

      def finalize_eager
        keys.each do |key|
          self[key]
        end
      end

      def finalize_lazy
        @_eager.each do |key|
          self[key]
        end
      end
    end
  end
end
