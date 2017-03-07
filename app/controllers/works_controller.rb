class WorksController < ApplicationController
  
  require 'paypal-sdk-adaptivepayments'
  include ApplicationHelper
  include WorksHelper
  

  skip_before_filter :verify_authenticity_token #, :only => [:ipn_notify]
  protect_from_forgery except: [:hook]
 
  skip_before_action :verify_authenticity_token, only: [:new_bid, :ipn_notify]
  
  before_action :check_user_login, except: [:list, :ipn_notify]
  before_action :set_work, only: [:show, :edit, :update, :destroy, :follow, :new_bid, :pay, :undo_pay, :ipn_notify], except: [:list, :make_payment, :accept]


  def check_user_login
    if !user_signed_in?
      redirect_to(root_path)
    end
  end


#/payment/execute?paymentId=PAY-69V82858NK912443LLADZPVY&token=EC-54537771YR158502P&PayerID=DBU7ZW58YH94E
  def ipn_notify
      params.permit! # Permit all Paypal input params
      if PayPal::SDK::Core::API::IPN.valid?(request.raw_post)
        logger.info("IPN message: VERIFIED")
        @payment = Payment.create
        @payment.status = params["status"].to_s
        @payment.transaction_id = params["pay_key"].to_s
        @payment.purchased_at = params["payment_request_date"]
        @payment.notification_params = params["transaction"].to_s
        user = User.find(params["user_id"])
        @payment.user_id = user.id
        @payment.work_id = params["id"]
        @payment.save!
        render :text => "VERIFIED"
      else
        logger.info("IPN message: INVALID")
         render :text => "INVALID"
      end
   #   byebug
  end
  
  def undo_pay
    redirect_to work_path
  end
  
  def pay
   # byebug
      @api = PayPal::SDK::AdaptivePayments.new
      @pay = @api.build_pay(params[:PayRequest] || default_api_value)
      @pay.ipnNotificationUrl ||= ipn_notify_url
      @pay_response = api.pay(@pay) if request.post?
      redirect_to payment_done_path(params["id"],params["user_id"])
  end



  def make_payment
    PayPal::SDK.configure( :mode => "sandbox", # "sandbox" or "live"
                           :client_id => "AeXBBsIkOg821eVIkhMzc3TWYTXai4wtaE2V04rYSGisElrVwYFM7JqNyV3gVOlPY9f3XKo2oP_6F5hk",
                           :client_secret => "EI1SaIZ8513J0dVIIJbXxlYKxfl61L93FP7pCe7kIZYOGMz6jYFi_t2pmnvYaqledqzEMr0P0BuRjVit")
                           
    @api = PayPal::SDK::AdaptivePayments.new

    @bid = Price.find(params[:id])
    @work = @bid.work
    @total = @bid.price.to_f
    @percent = (@total * 0.05).round(2)
    @total_new = (@total - @percent).round(2)
    
   # byebug
    # Build request object
    @pay = @api.build_pay({
      :actionType => "CREATE",
      :cancelUrl => "https://tile-riccione83.c9users.io/works/#{@work.id}/undo_pay",
      :currencyCode => "EUR",
      :feesPayer => "SENDER",
      :ipnNotificationUrl => "https://tile-riccione83.c9users.io/works/#{@bid.id}/ipn_notify/#{current_user.id}",
      :receiverList => {
        :receiver => [{
          :amount => @total_new,
          :email =>  @bid.user.email },
          {
          :amount => @percent,
          :email => "riccione83@me.com" }
          ]
      },
      :returnUrl => "https://tile-riccione83.c9users.io/works/#{@bid.id}/pay/#{current_user.id}" })
    
    # Make API call & get response
    @response = @api.pay(@pay)
    
    # Access response
   # byebug
    if @response.success? && @response.payment_exec_status != "ERROR"
      @response.payKey
      redirect_to @api.payment_url(@response)  # Url to complete payment
    else
      flash[:notice] = @response.error[0].message
      redirect_to work_path(@work)
    end
  end
  
  def assign_work
    byebug
    @payment = Payment.create
    @payment.status = "COMPLETE"
    @payment.transaction_id = "RANDOM_NUMBER"
    @payment.purchased_at = "DATE NOW"
    @payment.notification_params = ""
    user = User.find(params["user_id"])
    @payment.user_id = user.id
    @payment.work_id = params["id"]
    @payment.save!
  end
  
  def accept
    @bid = Price.find(params[:id])
    @work = @bid.work
    @total = @bid.price.to_f
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
   #byebug
    @works = Work.all
    if @works.any?
      @bids = @work.prices.all
      @recomends = WorkRecommender.new(@work,@works).recommendations(@work.id).first(2)
      @isAvailable = !isWorkClosed?(@work)
    end
  end

  # GET /works/new
  def new
    @work = Work.new
  end

  # GET /works/1/edit
  def edit
  end
  
  def follow
    #first check if this user follow this work
    follow = @work.prices.all.where(:user_id => current_user.id)
    #byebug
    if !follow.any?
      @work.prices.create(:user_id => current_user.id, :price => 0.0)
      @work.save!
    else
      flash[:notice] = "Hai già fatto offerte oppure segui già la gara."
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
        
        format.html { redirect_to @work, notice: 'Nuovo annuncio creato.' }
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
        
        format.html { redirect_to @work, notice: '' }
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
      format.html { redirect_to works_url, notice: '' }
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
