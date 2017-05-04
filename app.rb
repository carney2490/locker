require 'sinatra'
require 'rubygems'
require 'tilt/erb'
require 'bcrypt'
require 'pony'
require 'pg'
require 'mail'
require 'pp'
require 'date'
require_relative 'helpers.rb'
load "./local_env.rb" if File.exists?("./local_env.rb")

class App < Sinatra::Base

  db_params = {
    host: ENV['db'],
    port:ENV['port'],
    dbname:ENV['dbname'],
    user:ENV['dbuser'],
    password:ENV['dbpassword'],
  }

  db = PG::Connection.new(db_params)
enable :sessions
#  set :sessions,
#    key: ENV['sessionkey'],
#    domain:  ENV['domain'],
#    path: '/',
#    expire_after: 3600,
#    secret: ENV['sessionsecret']

  Mail.defaults do
    delivery_method :smtp,
    address: "email-smtp.us-east-1.amazonaws.com",
    port: 587,
    :user_name  => ENV['a3smtpuser'],
    :password   => ENV['a3smtppass'],
    :enable_ssl => true
  end

  get '/' do
    @title = 'The Locker Room'
    erb :index
  end

  #****INFO SECTION****
  get '/faq' do
    @title = 'FAQ'
    erb :faq
  end

  get '/about' do
    @title = 'About'
    erb :about
  end

  get '/contact' do
    @title = 'Contact Us'
    erb :contact
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

  #****LOGIN ETC****
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
      db.exec ("INSERT INTO users (fname, lname, address, city, state, zipcode, email, phone, encrypted_password,name) VALUES ('#{fname}', '#{lname}', '#{address}','#{city}', '#{state}', '#{zipcode}', '#{email}','#{phone}', '#{hash}','#{fname} #{lname}')" )
      erb :success, :locals => {:message => "You have successfully registered.", :message1 => " "}
    end
  end

  post '/submit' do
    erb :submit1
  end

  post '/facebook' do
    @title = 'Facebook Login'
    name= params[:name]
    email = params[:email]
    check_email = db.exec("SELECT * FROM users WHERE email = '#{email}'")
    if check_email.count < 1
      db.exec ("INSERT INTO users (open_sso_data, name, email) VALUES ('facebook', '#{name}','#{email}' )" )
    end
    session[:user] = name
    session[:email] = email
    redirect '/'
  end

  post '/google' do
    name = params[:gname]
    email = params[:gemail]
    check_email = db.exec("SELECT * FROM users WHERE email = '#{email}'")
    if check_email.count < 1
      db.exec ("INSERT INTO users (open_sso_data, name, email) VALUES ('google', '#{name}','#{email}')" )
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
      error = erb :login, :locals => {:message => "Invalid email and password combination",:user => session[:user]}
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
      erb :index
    else
      erb :login, :locals => {:message => "Invalid username and password combination",:user => session[:user]}
    end
  end

  get '/logout' do
    session[:user] = nil
    session[:usertype] = nil
    session[:email] = nil
    redirect '/'
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

  post '/subscribe' do
    email= params[:email]
    check_email = db.exec("SELECT * FROM mailing_list WHERE email = '#{email}'")
    if check_email.num_tuples.zero? == false
      erb :mailing_list, :locals => {:message => "You have already joined our mailing list"}
    else
      subscribe=db.exec("insert into mailing_list(email)VALUES('#{email}')")
      erb :mailing_list, :locals => {:message => "Thanks, for joining our mailing list."}
    end
  end

  #****PRODUCTS****
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

  get '/category_waynesburg' do
    @title = 'Waynesburg University'
    erb :category_waynesburg
  end

  #****FUNDRAISERS****

  get '/campaigns' do
    @title = 'Spirit Wear Campaigns'
    campaigns = db.exec("SELECT campaign_name, start_date, end_date, contact_name, contact_email FROM campaigns")
    date = DateTime.now
    sorted_campaigns = sort_campaigns(campaigns, date)
    erb :campaigns, :locals => {:active_campaigns => sorted_campaigns[:active_campaigns], :future_campaigns => sorted_campaigns[:future_campaigns], :past_campaigns => sorted_campaigns[:past_campaigns]}
  end

  post '/campaigns' do
    session[:campaign_name] = params[:campaign_name]
    end_date = params[:end_date]
    items = db.exec("SELECT item FROM campaign_items WHERE campaign_name='#{session[:campaign_name]}'")
    erb :campaign_order, :locals => {:campaign_name => session[:campaign_name], :end_date => end_date, :items => items}
  end

  #****ORDERING****

  post '/product_details' do
    url = params[ :url]
    size_price = db.exec("SELECT size, price, personalization FROM products2 WHERE product_url = '#{url}' ORDER BY size Asc")
    product_info = db.exec("SELECT product_name, product_description, order_information, product_url, personalization, colors FROM products2 WHERE product_url = '#{url}' LIMIT 1")

    puts "this is product_info: #{product_info}"
    puts "this is size_price: #{size_price}"
    erb :product_details, :locals => {:product_info => product_info, :size_price => size_price}
  end

  post '/add_to_cart' do
    @title = 'Shopping Cart'
    name = params[:productName]
    url = params[:productURL]
    size = params[:size]
    quantity = params[:quantity].to_i
    color = params[:color]
    price = params[:price].to_f  + 0.75 #hardcoded convenience fee addition
    line1 = params[:youth_name] || ""
    line2 = params[:youth_number] || ""
    line3 = params[:adult_name] || ""
    line4 = params[:adult_number] || ""
    path = ENV['domain']
    #additional personalization fee
    if line1.length > 0 || line3.length > 0
      price += 3.00
    end
    if line2.length > 0 || line4.length > 0
      price += 2.00
    end

    erb :shop_cart, :locals => {:name => name ,:price => price,
                                :quantity => quantity,:size => size,:line1 => line1,:line2 => line2,:line3 => line3,
                                :line4 => line4, :url => url, :domain => path, :campaign_name => session[:campaign_name],:color => color}
  end

  post '/view_cart' do
    path = ENV['domain'] + "/campaigns"
    erb :view_cart, :locals => {:domain => path}
  end

  #****ADMIN FUNCTIONALITY****
  get '/admin_page' do
    @title = 'Admin Page'
    mailing_list = db.exec("SELECT email FROM mailing_list")
    mailing_list = mailing_list.values.join(", ")
    erb :admin_page,:locals =>{:mailing_list => mailing_list}
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

end
