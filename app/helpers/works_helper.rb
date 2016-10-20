module WorksHelper

    def update_category(work,category)
        work.categories = category
        work.save!
    end
    
end
