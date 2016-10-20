class WorkRecommender < ActionController::Base

  def initialize work, works
    @work, @_works = work, works
  end
  
  def recommendations(id)

    # Map jaccard_index to each item and sort array
    @_works.each do |this_work|

          # We can define jaccard_index getter in runtime as singleton...
          this_work.define_singleton_method(:jaccard_index) do
            @jaccard_index
          end
    
          # also setter
          this_work.define_singleton_method("jaccard_index=") do |index|
            @jaccard_index = index || 0.0
          end
    
          # Calculate intersection between sets
          intersection = (@work.words & this_work.words).size
          # ... and union
          union = (@work.words | this_work.words).size
    
          if this_work.id != id
            # Assign the division and rescue if division is not possible with 0
            this_work.jaccard_index = (intersection.to_f / union.to_f) rescue 0.0
          else
              this_work.jaccard_index = 0
          end
    
          this_work
          # Sort items
        end

    @_works.sort_by { |work| 1 - work.jaccard_index }
  end
  
  def recommendations_by_words(words)

    # Map jaccard_index to each item and sort array
    @_works.each do |this_work|

          # We can define jaccard_index getter in runtime as singleton...
          this_work.define_singleton_method(:jaccard_index) do
            @jaccard_index
          end
    
          # also setter
          this_work.define_singleton_method("jaccard_index=") do |index|
            @jaccard_index = index || 0.0
          end
    
          # Calculate intersection between sets
          intersection = (words & this_work.words).size
          # ... and union
          union = (words | this_work.words).size
    
          #if this_work.id != id
            # Assign the division and rescue if division is not possible with 0
            this_work.jaccard_index = (intersection.to_f / union.to_f) rescue 0.0
         # else
         #     this_work.jaccard_index = 0
         # end
    
          this_work
          # Sort items
        end

    @_works.sort_by { |work| 1 - work.jaccard_index }
  end

end