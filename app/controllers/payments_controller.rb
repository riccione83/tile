class PaymentsController < ApplicationController
  
  def index
    @payments = Payment.all
  end

  def show
  end
  
   # GET /works/new
  def new
    @payment = Payment.new
  end

  # GET /works/1/edit
  def edit
  end
  
  def ricevuti

    @bids = Price.where(:user_id => current_user.id, :id => Payment.select("work_id").where(status: "COMPLETED"))
    
  end
  
  def inviati
   # byebug
    @payments = Payment.where(:user_id => current_user.id)
  end
  
  def done
    @bid = Price.find(params[:id])
    @work = @bid.work
    @payment = Payment.all.where("work_id = ? and user_id = ?", @bid.id, params["user_id"]).first
 #   byebug
  end
  
  def cancelled
    
  end


# POST /works
  # POST /works.json
  def create
    @payment = Payment.new(payment_params)

    respond_to do |format|
      if @payment.save
        
        format.html { redirect_to @payment, notice: 'Payment was successfully created.' }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /works/1
  # PATCH/PUT /works/1.json
  def update
    respond_to do |format|
      
      if @payment.update(payment_params)

        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /works/1
  # DELETE /works/1.json
  def destroy
    @payment.destroy
    respond_to do |format|
      format.html { redirect_to works_url, notice: 'Payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
        @payment = Payment.find(params[:id]) 
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_params
      params.require(:payment).permit(:work_id, :user_id, :status, :transaction_id, :purchased_at, :notification_params, :id)
    end
end