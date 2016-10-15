class Work < ActiveRecord::Base

    belongs_to :user
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
	
	def words
    	@words ||= self.description.gsub(/[a-zA-Z]{3,}/).map(&:downcase).uniq.sort
	end
	
	def paypal_url(return_path)
    values = {
        business: "merchant@gotealeaf.com",
        cmd: "_xclick",
        upload: 1,
        return: "#{Rails.application.secrets.app_host}#{return_path}",
        invoice: id,
        amount: work.price,
        item_name: work.title,
        item_number: work.id,
        quantity: '1'
    }
    "#{Rails.application.secrets.paypal_host}/cgi-bin/webscr?" + values.to_query
	end
  
end
