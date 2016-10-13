module ApplicationHelper
    
    
    def getCurrentPriceForWork(work)
      @price = work.prices.where("price > ?", 0).order('price asc').first
      if @price == nil
        @price = "0.0"
      else
        @price = @price.price.to_s
      end
    end
    
    
    def truncateHTMLString(string)
     # byebug
      a = truncate_html(string, length: 30, omission: '...')
      return a
    end
  
end  