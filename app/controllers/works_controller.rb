class WorksController < ApplicationController
  require 'paypal-sdk-adaptivepayments'

  include ApplicationHelper
  include WorksHelper

  skip_before_action :verify_authenticity_token, only: [:new_bid]
  
  before_action :check_user_login, except: [:list]
  before_action :set_work, only: [:show, :edit, :update, :destroy, :follow, :new_bid, :payments, :pay, :undo_pay], except: [:list]
  protect_from_forgery except: [:hook]

  def check_user_login
    if !user_signed_in?
      redirect_to(root_path)
    end
  end


#/payment/execute?paymentId=PAY-69V82858NK912443LLADZPVY&token=EC-54537771YR158502P&PayerID=DBU7ZW58YH94E
  def ipn_notify
      params.permit! # Permit all Paypal input params
      byebug
      if PayPal::SDK::Core::API::IPN.valid?(request.raw_post)
        logger.info("IPN message: VERIFIED")
        render :text => "VERIFIED"
      else
        logger.info("IPN message: INVALID")
        render :text => "INVALID"
      end
      render nothing: true
  end
  
  def undo_pay
    redirect_to work_path
  end
  
  def pay
      byebug
      @pay = @api.build_pay(params[:PayRequest] || default_api_value)
      @pay.ipnNotificationUrl ||= ipn_notify_url
      @pay.returnUrl ||= adaptive_payments_url(:pay)
      @pay.cancelUrl ||= adaptive_payments_url(:pay)
      @pay_response = api.pay(@pay) if request.post?
      render nothing: true
  end

  def payments
    PayPal::SDK.configure( :mode => "sandbox", # "sandbox" or "live"
                           :client_id => "AeXBBsIkOg821eVIkhMzc3TWYTXai4wtaE2V04rYSGisElrVwYFM7JqNyV3gVOlPY9f3XKo2oP_6F5hk",
                           :client_secret => "EI1SaIZ8513J0dVIIJbXxlYKxfl61L93FP7pCe7kIZYOGMz6jYFi_t2pmnvYaqledqzEMr0P0BuRjVit")
                           
    @api = PayPal::SDK::AdaptivePayments.new

    @total = getCurrentPriceForWork(@work).to_f
    @percent = @total * 0.05
    @total_new = @total - @percent


#
    # Build request object
    @pay = @api.build_pay({
      :actionType => "CREATE",
      :cancelUrl => "https://tile-riccione83.c9users.io/works/#{@work.id}/undo_pay",
      :currencyCode => "EUR",
      :feesPayer => "SENDER",
      :ipnNotificationUrl => "https://tile-riccione83.c9users.io/works/#{@work.id}/ipn_notify",
      :receiverList => {
        :receiver => [{
          :amount => @total_new,
          :email => "r.riki-facilitator@tiscali.it" },
          {
          :amount => @percent,
          :email => "r.riki-buyer@tiscali.it" }
          ]
      },
      :returnUrl => "https://tile-riccione83.c9users.io/works/#{@work.id}/pay" })
    
    # Make API call & get response
    @response = @api.pay(@pay)
    
#    @set_payment_options = @api.build_set_payment_options({
#                                    :payKey => @response.pay_key,
#                                                                   :receiverOptions => [{
#                                                                :receiver => { 
#                                                                  :email => "pay_pal_shop_email@test.com@test.com" 
#                                                                },                                                                     
#                                                                :description => "Descrition",
#                                                                :invoiceData => {
#                                                                :item => [{
#                                                                                :name => "Item Name",
#                                                                                :price => 23.33,
#                                                                                :itemPrice => 45.44,
#                                                                                :itemCount => 5}]},
#                                                                                }]})
    
#    @set_payment_options_response = @api.set_payment_options(@set_payment_options)

    # Access response
    if @response.success? && @response.payment_exec_status != "ERROR"
      @response.payKey
      redirect_to @api.payment_url(@response)  # Url to complete payment
    else
      @response.error[0].message
    end
  end

  def categories
     if params[:s] and params[:s] != ""
            @works = Work.search_by_category(params[:s]).order("created_at DESC") if params[:where] != "0" and params[:where] != "1"
     end
  end

  def list
     if params[:search] and params[:search] != ""
       	 # byebug
       	  if (params[:where] == nil or params[:where] == "0" or params[:where] == "1")
            @works = Work.search(params[:search]).order("created_at DESC")  
          else
            @works = Work.search_with_place(params[:search],params[:where]).order("created_at DESC") if params[:where] != "0" and params[:where] != "1"
          end
     else
          @works = Work.all
     end
  end
  
  # GET /works
  # GET /works.json
  def index
    @works = Work.where(:user_id => current_user.id)
  end

  # GET /works/1
  # GET /works/1.json
  def show
    @works = Work.all
    if @works.any?
      @bids = @work.prices.all
      @recomends = WorkRecommender.new(@work,@works).recommendations(@work.id).first(2)
    end

   # redirect_to @work.paypal_url(work_path(@work))
  end

  # GET /works/new
  def new
    @work = Work.new
  end

  # GET /works/1/edit
  def edit
  end
  
  def accept
  end
  
  def follow
    #first check if this user follow this work
    follow = @work.prices.all.where(:user_id => current_user.id)
    #byebug
    if !follow.any?
      @work.prices.create(:user_id => current_user.id, :price => 0.0)
      @work.save!
    else
      flash[:notice] = "Hai già fatto offerte, già segui la gara."
    end
    redirect_to(work_path(@work))
  end
  
  def new_bid
    #byebug
    current_price = getCurrentPriceForWork(@work).to_f
    if params[:new_price].to_f >= current_price and current_price > 0.0
      flash[:notice] = "Devi fare un'offerta minore di " + getCurrentPriceForWork(@work) + "€"
      redirect_to(work_path(@work))
    else
      #byebug
      if @work.user_id == current_user.id
         flash[:notice] = "Non puoi fare offerte ai tuoi annunci."
      else
        if @bid = @work.prices.all.where(:user_id => current_user.id).last
          if params[:new_price].to_f > 0.0
            @bid.price = params[:new_price]
            @bid.save!
          else
            flash[:notice] = "Hai già fatto offerte, già segui la gara."
            redirect_to(work_path(@work))
          end
        else
          @work.prices.create(:user_id => current_user.id, :price =>params[:new_price])
        end
        @work.save!
      end
      redirect_to(work_path(@work))
    end
  end

  # POST /works
  # POST /works.json
  def create
    @work = Work.new(work_params)

    respond_to do |format|
      if @work.save
        
        if params[:images]
        params[:images].each { |image|
          @work.pictures.create(image: image)
        }
        end
        
        if params[:categories]
          $work_classifier.new_train_data(params[:categories], ActionView::Base.full_sanitizer.sanitize(@work.description).delete!("\r\n\t") )
        end  
        
        format.html { redirect_to @work, notice: 'Work was successfully created.' }
        format.json { render :show, status: :created, location: @work }
      else
        format.html { render :new }
        format.json { render json: @work.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /works/1
  # PATCH/PUT /works/1.json
  def update
    respond_to do |format|
      
      if @work.update(work_params)
        
        if params[:images]
          # The magic is here ;)
          params[:images].each { |image|
            @work.pictures.create(image: image)
          }
        end
        
       # byebug
        if work_params[:categories]
          $work_classifier.new_train_data(@work.categories, ActionView::Base.full_sanitizer.sanitize(@work.description).delete!("\r\n\t") )
        end  
        
        format.html { redirect_to @work, notice: 'Work was successfully updated.' }
        format.json { render :show, status: :ok, location: @work }
      else
        format.html { render :edit }
        format.json { render json: @work.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /works/1
  # DELETE /works/1.json
  def destroy
    @work.destroy
    respond_to do |format|
      format.html { redirect_to works_url, notice: 'Work was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work
      if params[:id] && params[:id] != "pay"
          @work = Work.find(params[:id]) 
          @price = @work.prices.where("price > ?", 0).order('price asc').first
          if @price == nil
            @price = "No offer"
          else
            @price = @price.price
          end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_params
      params.require(:work).permit(:user_id, :title, :description, :price_id, :location, :categories)
    end
end
