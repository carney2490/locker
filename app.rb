require 'sinatra'
require 'rubygems'
require 'tilt/erb'
require 'bcrypt'
require 'pony'
require 'pg'
require 'mail'
require 'pp'
load "./local_env.rb" if File.exists?("./local_env.rb")

db_params = {
   host: ENV['db'],
   port:ENV['port'],
   dbname:ENV['dbname'],
   user:ENV['dbuser'],
   password:ENV['dbpassword'],    
}

db = PG::Connection.new(db_params)

set :sessions, 
  key: ENV['sessionkey'],
  domain:  ENV['domain'],
  path: '/',
  expire_after: 3600,
  secret: ENV['sessionsecret']

def get_order_total()
  order_total = 0.0

    if session[:cart]
      session[:cart].each do |item|
        order_total += item["total"]
      end
    end
  session[:ordertotal] = order_total
end

get '/' do
    @title = 'LockerRoom'
    erb :index
end
get '/faq' do
    @title = 'FAQ'
    erb :faq
end

get '/about' do
    title = 'About'
    erb :about
end

get '/contact' do
    @title = 'Contact Us'
    erb :contact
end
Mail.defaults do
  delivery_method :smtp, 
  address: "email-smtp.us-east-1.amazonaws.com", 
  port: 587,
  :user_name  => ENV['a3smtpuser'],
  :password   => ENV['a3smtppass'],
  :enable_ssl => true
end

post '/contact' do
  name = params[:firstname]
  lname= params[:lastname]
  email= params[:email]                  
  comments = params[:message]
  subject= params[:subject]
  email_body = erb(:email2,:layout=>false, :locals=>{:subject => subject,:firstname => name, :lastname => lname, :email => email, :message => comments})
  
  mail = Mail.new do
    from         ENV['from']
    to           email
    bcc          ENV['from']
    subject      subject
    
    html_part do
      content_type 'text/html'
      body         email_body
    end
  end

  mail.deliver!
    erb :success, :locals => {:message => "Thanks for contacting us."}
end

post '/submit' do
    erb :submit1
end 

get '/customer_order' do
    @title = 'Orders'
    erb :customer_order
end



get '/customer_register' do
    @title = 'Register'
    erb :customer_register, :locals => {:message => " ", :message1 => " "}
end

post '/customer_register' do
    fname = params[:fname]
    lname = params[:lname]
    address = params[:address]
    city = params[:city]
    state = params[:state]
    zipcode = params[:zipcode]
    email = params[:email]
    phone = params[:phone]
    password = params[:password]
    
    #This is for creating profile and preventing duplication
    check_email = db.exec("SELECT * FROM users WHERE email = '#{email}'")
    
    hash = BCrypt::Password.create(password, :cost => 11) 
    
    
        if check_email.num_tuples.zero? == false
            erb :customer_register, :locals => {:message => " ", :message1 => "That email already exists"}
        else
             db.exec ("INSERT INTO users (fname, lname, address, city, state, zipcode, email, phone, encrypted_password,name) 
                      VALUES ('#{fname}', '#{lname}', '#{address}','#{city}', '#{state}', '#{zipcode}', '#{email}','#{phone}', '#{hash}','#{fname} #{lname}')" )
            erb :success, :locals => {:message => "You have successfully registered.", :message1 => " "}
        end
end

post '/facebook' do
    @title = 'Facebook Login'    
    name= params[:name]
    email = params[:email]
    
    check_email = db.exec("SELECT * FROM users WHERE email = '#{email}'")
    
    if check_email.count > 0
        puts '#{check_email}'
    else
        facebook_log = db.exec ("INSERT INTO users (open_sso_data, name, email) VALUES ('facebook', '#{name}','#{email}' )" )
    end
    session[:user] = name
    session[:email] = email
    
    redirect '/'   
end

post '/google' do
    @title = 'Google Login'
    
    name = params[:gname]
    email = params[:gemail]
    
    check_email = db.exec("SELECT * FROM users WHERE email = '#{email}'")
    
    if check_email.count > 0
        puts '#{check_email}'
    else
        google_log = db.exec ("INSERT INTO users (open_sso_data, name, email) VALUES ('google', '#{name}','#{email}')" )
    end
    session[:user] = name
    session[:email] = email
    
    redirect '/'   
end


post '/login' do
    email = params[:email]
    password = params[:password]
    name = params[:name]
    match_login = db.exec("SELECT encrypted_password,user_type,email,name,fname,lname FROM users WHERE email = '#{email}'")
        if match_login.num_tuples.zero? == true
            error = erb :login, :locals => {:message => "invalid email and password combination"}
            return error
        end
    
    password1 = match_login[0]['encrypted_password']
    comparePassword = BCrypt::Password.new(password1)
  
    user_email = match_login[0]['email']
   name = match_login[0]['name']
    user_type = match_login[0]['user_type']

    
      if match_login[0]['email'] == email && comparePassword == password
          session[:email] = user_email  
          session[:usertype] = user_type
          session[:user] = name
          puts "authenticated"
          erb :index
      else
      erb :login, :locals => {:message => "invalid username and password combination",:user => session[:user]}
      end 
end
      
get '/logout' do
  session[:user] = nil
  session[:usertype] = nil
    session[:email] = nil
    session[:ordertotal] = nil
   session[:cart] = nil
  redirect '/'
end

get '/admin_page' do
    @title = 'Admin Page'
    mailing_list = db.exec("SELECT email FROM mailing_list")
    mailing_list = mailing_list.values.join(", ")
   
    erb :admin_page,:locals =>{:mailing_list => mailing_list}
end
get '/edit_profile'do
    @title = 'Edit Profile'
    users = db.exec("SELECT * FROM users WHERE email='#{session[:email]}'")
    edit_profile = db.exec("SELECT fname,lname,address,city,state,zipcode,email,phone,company FROM users WHERE email = '#{session[:email]}' ")  
    current_profile= db.exec("SELECT * FROM users WHERE email='#{session[:email]}'")
    erb :edit_profile, :locals => {:edit_profile => edit_profile,:users =>users,:current_profile =>current_profile}
end

post '/edit_profile' do
   fname = params[:fname]
   lname = params[:lname]
   address = params[:address]
   city = params[:city]
   state = params[:state]
   zipcode = params[:zipcode]
   email = params[:email]
   phone = params[:phone]
   company = params[:company]
    users = db.exec("SELECT * FROM users WHERE email='#{session[:email]}'")       
    update_profile = db.exec ("UPDATE users SET (fname,lname, address, city, state, zipcode, email, phone,company)  =  ('#{fname}','#{lname}', '#{address}','#{city}', '#{state}', '#{zipcode}', '#{email}', '#{phone}', '#{company}' ) WHERE email = '#{email}'" )
    redirect '/edit_profile'
end

get '/jefferson_morgan_items' do
    @title = 'LockerRoom'
    erb :jefferson_morgan_items
end

post '/jefferson_morgan_items' do
    @title = 'LockerRoom'
    erb :product_details, :locals => {:product_info => product_info, :size_price => size_price}
end

post '/product_details' do
    url = params[ :url]
    
    size_price = db.exec("SELECT size, price FROM products2 WHERE product_url = '#{url}' ORDER BY size ASC  ")
    
    product_info = db.exec("SELECT product_name, product_description, order_information, product_url, personalization FROM products2 WHERE product_url = '#{url}' LIMIT 1")
    

    erb :product_details, :locals => {:product_info => product_info, :size_price => size_price}
end

get '/shop_cart' do
    @title = 'Shopping Cart'
    session[:cart] ? cart = session[:cart] : cart = []
    get_order_total()
     
    erb :shop_cart, :locals => {:cart => cart, :ordertotal => session[:ordertotal], :name => "",:price => "",
                                :quantity => "",:size => "",:line1 => "",:line2 => "",:line3 => "", :line4 => "", :url => ""}
   
  
end

post '/add_to_cart' do
    @title = 'Shopping Cart'
    
    session[:cart] ||= []
        session[:cart] ? cart = session[:cart] : cart = []

    name = params[:productName]
    description = params[:productDescription]
    url = params[:productURL]
    size = params[:size]
    quantity = params[:quantity].to_i
    price = params[:price].to_f
    line1 = params[:line1]
    line2 = params[:line2]
    line3 = params[:line3]
    line4 = params[:line4]
    total = quantity * price
        
    session[:cart].push({"productname" => name, "description" => description, "url" => url, "size" => size,
                         "quantity" => quantity, "price" => price,"total" => total, "line1" => line1,
                         "line2" => line2, "line3" => line3, "line4" => line4})

    erb :shop_cart, :locals => {:cart => cart, :ordertotal => session[:ordertotal], :name => name ,:price => price,
                                :quantity => quantity,:size => size,:line1 => line1,:line2 => line2,:line3 => line3,
                                :line4 => line4, :url => url}
end


post '/update_cart' do
    session[:cart].each_with_index do |shoppingcart_item, cart_index|
        #item_index = params[index].to_i
        i = cart_index.to_s.to_sym
        quantity = params[i].to_i
        price =session[:cart][cart_index]["price"]
        total = quantity * price
        session[:cart][cart_index]["quantity"] = quantity
        session[:cart][cart_index]["total"] = total
    end
    redirect '/shop_cart'
end

post '/remove_from_cart' do
    index = params[:index].to_i
    session[:cart].delete_at(index)
    redirect '/shop_cart'
end

get '/checkout1' do
    @title = 'Checkout Step1'
    "Session email is #{session[:email]}"
end
get '/checkout1_prefilled' do
    @title = 'Checkout Step1'
    #"Session email is #{session[:email]}"
   # "Session cart is #{session[:cart]}"
   if session[:email] != nil
      customerinfo = db.exec("SELECT * FROM users WHERE email='#{session[:email]}'")
      erb :checkout1_prefilled, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal],
                                            :customerinfo => customerinfo}
  else
      erb :checkout1, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal]}

  end
end

get '/checkout2' do
    @title = 'Checkout Step2'
    erb :checkout2, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal]}
end

get '/checkout3' do
    @title = 'Checkout Step3'
    erb :checkout3, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal]}
end

get '/checkout4' do
    @title = 'Checkout Step4'
    session[:cart] = []
    erb :checkout4, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal],:delivery_method => delivery_method}
end

post '/checkout1' do
    @title = 'Checkout Step1'
    session[:customerinfo] ||= []
   
    
   erb :checkout1, :locals => {:cart => session[:cart],:ordertotal => session[:ordertotal],:customerinfo => customerinfo}

end
post '/checkout2' do
    @title = 'Checkout Step2'
    firstname = params[:firstname]
    lastname = params[:lastname]
    company = params[:company]
    street = params[:street]
    city = params[:city]
    state = params[:state]
    zip = params[:zip]
    phone=params[:phone]
    email = params[:email]
     session[:cart2] = []
     session[:cart2].push({"firstname" => firstname, "lastname" => lastname, "company" => company, "street" => street, "city" => city , "state" => state, "zip" => zip, "phone" => phone, "email" => email})
     

    erb :checkout2,:locals => {:cart => session[:cart],:customerinfo => session[:customerinfo],:ordertotal => session[:ordertotal],:cart2 => session[:cart2]}
  end

post '/checkout4' do
    @title = 'Checkout Step4'
    firstname = params[:firstname]
    lastname = params[:lastname]
    street = params[:street]
    city = params[:city]
    state = params[:state]
    zip = params[:zip]
    order_date = Time.now
    delivery_method = params[:delivery_method]
    payment_method = params[:payment_method]
    order_number = '2'
    delivery_method = params[:delivery_method]

    db.exec("INSERT INTO users(fname,lname,address,city,state,zipcode) 
            VALUES ('#{firstname}','#{lastname}','#{street}','#{city}','#{state}','#{zip}')")
       
      session[:cart].each do |m|

     
          db.exec ("INSERT INTO orders (product_name,quantity,line1,line2,line3,line4,unit_price,total_price,order_date,delivery_method,payment_method) 
                    VALUES ('#{m['productname']}','#{m['quantity']}','#{m['line1']}','#{m['line2']}','#{m['line3']}','#{m['line4']}',
                    '#{m['price']}','#{m['total']}','#{order_date}','#{delivery_method}','#{payment_method}')" )
      end
    erb :checkout4,:locals => {:cart => session[:cart],:cart2 => session[:cart2],:ordertotal => session[:ordertotal],:delivery_method => delivery_method}
end

get '/receipt' do
    @title = 'Receipt'
   
    erb :receipt,:locals => {:cart => session[:cart],:cart2 => session[:cart2],:ordertotal => session[:ordertotal],:message =>"Thanks for your order, here is a receipt you can print for your records."}
  
  redirect to ('/paypal')
end
get '/category_shirts' do
    @title = 'Shirts'
    erb :category_shirts
end
get '/category_sports' do
    @title = 'Sports Equipment'
    erb :category_sports
end
get '/category_hats' do
    @title = 'Hats'
    erb :category_hats
end

get '/paypal' do
session[:cart] ? cart = session[:cart] : cart = []
    get_order_total()
  erb :paypal, :locals => {:ordertotal => session[:ordertotal],:cart => cart}

end
post '/subscribe' do
    email= params[:email]
    check_email = db.exec("SELECT * FROM mailing_list WHERE email = '#{email}'")
       
    if
        check_email.num_tuples.zero? == false
            erb :mailing_list, :locals => {:message => "You have already joined our mailing list"}
    else
         subscribe=db.exec("insert into mailing_list(email)VALUES('#{email}')")
         erb :mailing_list, :locals => {:message => "Thanks, for joining our mailing list."}
    end
end
get '/category_waynesburg' do
@title = 'Waynesburg University'
erb :category_waynesburg
end

get '/send_emails' do
   subscribers = db.exec("select email from mailing_list")

  erb :subscribers, :locals => {:subscribers => subscribers, :message => ""}
end 

post '/send_mail_to_list' do
      subject = params[:subject]
      subscribers = db.exec("select email from mailing_list")
      message = params[:message]
      

      subscribers.each do |email|
      emails = email["email"]
  
    Pony.mail(
        :to => "#{emails}",
        :from => 'info@minedminds.org',
        :subject => "#{subject}", 
        :content_type => 'text/html', 
        :body => erb(:send_mailer,:layout=>false,:locals=>{:subject => subject,:message => message}),
        :via => :smtp, 
        :via_options => {
          :address              => 'smtp.gmail.com',
          :port                 => '587',
          :enable_starttls_auto => true,
           :user_name           => ENV['email'],
           :password            => ENV['email_pass'],
           :authentication       => :plain, 
           :domain               => "minedminds-mailinglist.herokuapp.com" 
        }
      )
end
   erb :subscribers, :locals => {:subscribers => "",:message => "You Sent an email to your list"}
end 
