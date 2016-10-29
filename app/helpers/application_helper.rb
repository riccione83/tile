module ApplicationHelper
    include CookieAlert
    
    def flash_class(level)
        if level == "notice"
        	return "alert alert-info alert-dismissible"
        elsif level == "success" 
        	return "alert alert-success alert-dismissible"
        elsif level == "error" 
        	return "alert alert-danger alert-dismissible"
        elsif level == "alert"
        	return "alert alert-warning alert-dismissible"
        end
    end

    def isWorkClosed?(work)
     # byebug
       bids = Price.where(:work_id =>work.id, :id => Payment.select("work_id").where(status: "COMPLETED"))
       if bids.any?
         return true
       else
         return false
       end
    end
    
    def getCurrentPriceForWork(work)
      @price = work.prices.where("price > ?", 0).order('price asc').first
      if @price == nil
        @price = "0.0"
      else
        @price = @price.price.to_s
      end
    end
    
    def truncateHTMLString(string, len)
     # byebug
      a = truncate_html(string, length: len, omission: '...')
      return a
    end
    
    def categories
      
      return     ["Tutte le categorie",
                  "Auto",
                  "Moto e Scooter",
                  "Nautica",
                  "Caravan e Camper",
                  "Veicoli commerciali",
                  "Terreni e rustici",
                  "Garage e box",
                  "Case",
                  "Informatica",
                  "Console e Videogiochi",
                  "Audio/Video",
                  "Fotografia",
                  "Telefonia",
                  "Arredamento",
                  "Elettrodomestici",
                  "Giardino",
                  "Animali",
                  "Musica e Arte",
                  "Strumenti Musicali",
                  "Biciclette",
                  "Collezionismo",
                  "Altro"]
    end
    
    
    def regioni_html
      
      return       ["  <option value='0' selected='selected'>Sicilia</option> ",
                    "  <option value='1' disabled='disabled'>-- LE PROVINCE --</option>",
                    "  <option value='Agrigento' >Agrigento</option>",
                    "  <option value='Caltanissetta' >Caltanissetta</option>",
                    "  <option value='Catania' >Catania</option>",
                    "  <option value='Enna' >Enna</option>",
                    "  <option value='Messina' >Messina</option>",
                    "  <option value='Palermo' >Palermo</option>",
                    "  <option value='Ragusa' >Ragusa</option>",
                    "  <option value='Siracusa' >Siracusa</option>",
                    "  <option value='Trapani' >Trapani</option>"]
    end
  
    def regioni
      
      return       ["Sicilia",
                    "Agrigento",
                    "Caltanissetta",
                    "Catania",
                    "Enna",
                    "Messina",
                    "Palermo",
                    "Ragusa",
                    "Siracusa",
                    "Trapani"]
    end  
  
end  