class PaymentController < ApplicationController

  before_action :set_payment
  
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
      params.require(:payment).permit(:work_id, :user_id, :status, :transaction_id, :purchased_at, :notification_params)
    end
end