class Work < ActiveRecord::Base

    belongs_to :user
    has_one :payment
    
    has_many :prices, dependent: :destroy
    has_many :pictures, dependent: :destroy

	def self.search(search)
			where("lower(description) LIKE '%#{search.downcase}%' OR lower(title) LIKE '%#{search.downcase}%'")
	end
	
	def self.search_with_place(search,place)
			where("(lower(description) LIKE '%#{search.downcase}%' OR 
			       lower(title) LIKE '%#{search.downcase}%') AND
			       lower(location) LIKE '%#{place.downcase}%' ")
	end
	
	def self.search_by_category(category)
			where("(lower(categories) LIKE '%#{category.downcase}%')")
	end
	
	def words
    	@words ||= self.description.gsub(/[a-zA-Z]{3,}/).map(&:downcase).uniq.sort
	end
	
end
