require 'paypal-sdk-merchant'

class PaypalInterface
  attr_reader :api, :express_checkout_response

  PAYPAL_RETURN_URL = Rails.application.routes.url_helpers.paid_orders_url(host: HOST_WO_HTTP)
  PAYPAL_CANCEL_URL = Rails.application.routes.url_helpers.revoked_orders_url(host: HOST_WO_HTTP)
  PAYPAL_NOTIFY_URL = Rails.application.routes.url_helpers.ipn_orders_url(host: HOST_WO_HTTP)

  def initialize(order)
    @api = PayPal::SDK::Merchant::API.new
    @order = order
  end
  
end