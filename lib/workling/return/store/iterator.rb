#
#  Iterator class for iterating over return values. 
#
module Workling
  module Return
    module Store
      class Iterator
        
        include Enumerable
        
        def initialize(uid)
          @uid = uid
        end
        
        def each
          while item = Workling.return.get(@uid)
            yield item
          end
        end
        
      end
    end
  end
end
