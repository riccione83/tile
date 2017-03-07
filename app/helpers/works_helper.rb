module WorksHelper    


    def update_category(work,category)
        work.categories = category
        work.save!
    end
    
    def default_api_value
      t("#{service_name}.#{service_action}", :default => {})
    end

    def service_name
      params[:controller].gsub(/^.*\//, "")
    end

    def service_action
      params[:action]
    end
end
