class Picture < ActiveRecord::Base
  belongs_to :work

  has_attached_file :image,
    :styles => {
    :large => "250x166>",
    :medium => "250x166>",
    :square => "250x166#", 
    :small => "250x166>" },
      :convert_options => { :all => '-auto-orient' },
      :path => ":rails_root/public/images/:id/:filename",
      :url => "/images/:id/:filename"
                    
  do_not_validate_attachment_file_type :image
   
  #has_attached_file :image,
  #                  :storage => :s3,
  #                  :s3_credentials => Proc.new{|a| a.instance.s3_credentials }
  
  #def s3_credentials
  #  {:bucket => "xxx", :access_key_id => "xxx", :secret_access_key => "xxx"}
  #end
  
  #has_attached_file :attachment, 
  #:styles => {
  #  :large => "250x166>",
  #  :medium => "250x166>",
  #  :square => "250x166#", 
  #  :small => "250x166>" },
  #:convert_options => { :all => '-auto-orient' },   
  #:storage => :s3,
  #:s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
  #:s3_permissions => 'public-read',
  #:s3_protocol => 'https',
  #:path => "images/:id_partition/:basename_:style.:extension"

  #after_attachment_post_process  :post_process_photo 
  
  def post_process_photo
    imgfile = EXIFR::JPEG.new(image.queued_for_write[:original].path)
    return unless imgfile
  
    self.width         = imgfile.width             
    self.height        = imgfile.height            
    self.model         = imgfile.model             
    self.date_time     = imgfile.date_time         
    self.exposure_time = imgfile.exposure_time.to_s
    self.f_number      = imgfile.f_number.to_f     
    self.focal_length  = imgfile.focal_length.to_s
    self.description   = imgfile.image_description
  end
  
end
