# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?
     
  def new
    super
  end

  def create
    super
  end

  def update
    super
  end


  protected

  def configure_permitted_parameters
        #byebug
         devise_parameter_sanitizer.permit(:sign_up, keys: [:user_type])
  end
end 