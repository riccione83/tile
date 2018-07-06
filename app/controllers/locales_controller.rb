class LocalesController < ApplicationController
    
    def set_locale
      set_locale_cookie(params[:locale])
      puts "Setto il linguaggio: " +  params[:locale].to_s
      redirect_to root_path
    end
    
     def set_locale_cookie(locale)
        cookies['locale'] = locale.to_s
     end

end