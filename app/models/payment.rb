class Payment < ActiveRecord::Base
    
    has_many :works
    belongs_to :user
    
end
