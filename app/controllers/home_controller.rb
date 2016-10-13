class HomeController < ApplicationController
   include ApplicationHelper
   
    def homepage
        @works = Work.all
    end
    
    def testpage
        
    end
end
