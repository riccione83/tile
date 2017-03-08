class WorkClassifier < ActionController::Base
require 'classifier-reborn'

  @@classifier_file   = File.join(Rails.root, 'db', 'classifier.dat')
  @@training_set_file = File.join(Rails.root, 'db', 'training_data.txt')

  def initialize
     self.load_classifier
  end
  
  def load_classifier
      if File.exist?(@@classifier_file)
            # This is now saved to a file, and you can safely restart the application
             data = File.open(@@classifier_file, 'rb').read
              # Or data = Redis.current.get "classifier"
             @classifier  = Marshal.load data
      else
            self.train
      end
  end
  
  def save
      classifier_snapshot = Marshal.dump @classifier
      # This is a string of bytes, you can persist it anywhere you like
  
      File.open(@@classifier_file, "wb") { |f| f.write(classifier_snapshot) }
      # Or Redis.current.save "classifier", classifier_snapshot  
  end
 
 
  def learn
    
    @works = Work.all
    
    @categories = "informatica"
    
    @classifier = ClassifierReborn::Bayes.new(
                  @categories,                 # one or more categories
                  enable_threshold: false, # default: false
                  auto_categorize:  true)
        
    @works.each do |work|
       @classifier.train(work.categories, ActionView::Base.full_sanitizer.sanitize(work.description).delete!("\r\n\t"))
    end
    
    self.save
  end
 
  def train 
     # This is now saved to a file, and you can safely restart the application
        data = File.read ( @@training_set_file )
        training_set = data.split("\n")
        @categories   = training_set.shift.split(',').map{|c| c.strip}
      
        @classifier = ClassifierReborn::Bayes.new(
                            @categories,                 # one or more categories
                            enable_threshold: false, # default: false
                            auto_categorize:  true
        )
        
        training_set.each do |a_line|
          next if a_line.empty? || '#' == a_line.strip[0]
          parts = a_line.strip.split(':')
          puts parts.first + " - " + parts.last
          @classifier.train(parts.first, parts.last)
        end
  end
  
  def new_train_data(category, data)
  #  byebug
    puts "*** NEW DATA TO LEARN ***"
    puts category.downcase + " => " + data
    @classifier.train(category.downcase, data)
    self.save
    puts "**** LEARNED ****"
  end
 
  def get_categories
        @classifier.categories
  end
 
  def classifier_test
        puts @classifier.classify "I hate bad words and you" #=> 'Uninteresting'
        puts @classifier.classify "I hate javascript" #=> 'Uninteresting'
        puts @classifier.classify "javascript is bad" #=> 'Uninteresting'
        
        puts @classifier.classify "all you need is ruby" #=> 'Interesting'
        puts @classifier.classify "i love ruby" #=> 'Interesting'
        
        puts @classifier.classify "which is better dogs or cats" #=> 'dog'
        puts @classifier.classify "what do I need to kill rats and mice" #=> 'cat'
        
        puts @classifier.classify "Cerco ragazzo capace di sistemare i computer" #=> 'cat'
  end
  
  def classify(string)
     return  @classifier.classify string
  end

end