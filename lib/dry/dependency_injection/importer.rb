require 'dry/core/inflector'

module Dry
  module DependencyInjection
    class Importer

      def initialize(container)
        @container = container
      end

      def import(path, prefix = '')
        unless File.directory?(path)
          raise ArgumentError.new("path must be  directory: #{path}")
        end
        full = File.expand_path(path)
        Dir[File.join(full, prefix, '**', '*.rb')].each do |file|
          next if block_given? && !yield(file)
          require file
          subpath = file.gsub(/#{full}\/|\.rb/, '')
          class_name = Dry::Core::Inflector.camelize(subpath)
          clazz = Dry::Core::Inflector.constantize(class_name)
          if clazz.is_a?(Class)
            key = subpath.gsub('/', '.')
            @container.register(key, clazz)
          end
        end
        self
      end

      def finalize
        @container.finalize if @container.respond_to?(:finalize)
      end
    end
  end
end
