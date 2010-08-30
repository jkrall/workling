#
#  Stores directly into memory. This is for tests only - not for production use. aight?
#
module Workling
  module Return
    module Store
      class MemoryReturnStore < Base
        attr_accessor :sky
        
        def initialize
          self.sky = Hash.new([])
        end
        
        def set(key, value)
          self.sky[key] << value
        end
        
        def get(key)
          self.sky[key].shift
        end
      end
    end
  end
end