class HomeController < ApplicationController
   include ApplicationHelper
   
    def homepage
        @works = Work.all
        $work_classifier.load_classifier
    end
    
    def testpage
        
    end
end
