require "sinatra"
require "paypal"
require "paypal-sdk-rest"

get "/" do
  payment_request = Paypal::Payment::Request.new(
    :billing_type  => :MerchantInitiatedBilling,
    :billing_agreement_description => "My recurring payment"
  )
  response = req.setup(
    payment_request,
    "http://localhost:45677/",
    "http://localhost:45677/shop_cart",

  )
  redirect response.redirect_uri
end

get "/success" do
  response = req.agree! params["token"]
  billing_agreement_id = response.billing_agreement.identifier
  response = req.charge! billing_agreement_id, 100
  "Your payment was a success, transaction # #{response.transaction_id}"
end

get "/cancel" do
  "No purchase for you!"
end

def req
  @req ||= begin
    Paypal.sandbox!

    Paypal::Express::Request.new(
      username: "teecee-facilitator_api1.minedminds.org",
      password: "C7MKXZ6FBFP58H8W",
      signature: "AFcWxV21C7fd0v3bYYYRCpSSRl31AZHguvI9yBPQnLMZVyYgpmraufnf"
    )
  end
end