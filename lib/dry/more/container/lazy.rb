require 'concurrent'
require 'dry-container'
module Dry
  module More
    module Container
      class Lazy
        include Dry::Container::Mixin

        def initialize(*args, &block)
          @_lock = Mutex.new
          super
        end
      
        setting :lazy, true

        alias :orig_register :register

        def register(key, item = nil, options = {}, &block)
          if @_finalized
            raise Dry::Container::Error, 'can not register. container already finalized'
          else
            orig_register(key, item, options, &block)
          end
        end

        def finalize
          unless config.lazy
            @_lock.synchronize do
              finalize_eager
            end
          end
          @_finalized = ! config.lazy        
        end

        def finalize_eager
          raise 'not implemented'
        end
      end
    end
  end
end
