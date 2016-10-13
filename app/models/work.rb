class Work < ActiveRecord::Base

    belongs_to :user
    has_many :prices, dependent: :destroy
    has_many :pictures, dependent: :destroy

end
