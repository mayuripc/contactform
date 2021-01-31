 README

This README would normally document whatever steps are necessary to get the
application up and running.
Contact Form details mail to email address
Add Language support using Rails API

This is a complete, step-by-step tutorial showing how to create a fully functional contact form in production in rails 5. Rather than reinvent things, the following borrows from the best available documentation and tutorials (most notably, this tutorial on making a contact form in development). The finished contact form can be viewed here.

This tutorial uses:

    heroku for deployment,
    gmail for the mailer, and
    github for version control

It would be a good idea to create a new gmail account to use for your mailer now, if you haven't already. If you haven't yet got a heroku account and installed the heroku CLI, it would be easiest to do so now.
Steps

    Make a new rails app and cd into it:

rails new contactform --database=postgresql
cd contactform

The --database=postgresql option tells your app to use posgresql, which will prevent various database errors when deploying to heroku. If you forget this option, it's always possible to adjust your gemfile later to specify use of postgres in production.

    Create a new github repository (do so in the browser), and let your newly created app know about it:

git init
git add . 
git commit -m "First commit to github repo"
git remote add origin https://github.com/stevecondylios/name_of_new_repository.git
git push -u origin master

    Add the following gems to your gemfile:

gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'
gem 'mail_form'
gem 'jquery-rails', '~> 4.1', '>= 4.1.1'
gem 'dotenv-rails', groups: [:development, :test]

    Install the gems with: bundle install

    In your app's root directory (i.e. inside /contactform), create a new file called ".env". Inside this new file, simply add the following text (and nothing else), replacing your_gmail_email_address and your_gmail_password with your mailer's gmail address and password respectively (note: no quotations are used):

GMAIL_EMAIL=your_gmail_email_address
GMAIL_PASSWORD=your_gmail_password

    Add a single line at the end of your .gitignore file. The line should simply say: .env. This will tell github not to track your your .env file (it would be bad if it did, since this file contains your mailer's credentials). Here's what it should look like (note the only change to this file is on line 27):

    In app/assets/javascripts/application.js, there will be a section with javascript libraries (usually 4 lines of code all beginning with "//="). Replace these lines of code with these ones:

//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require_tree .

    Now create a controller with index action:

rails g controller Home index

Open app/views/home/index.html.erb and replace what's there with this:

<!-- app/views/home/index.html.erb -->

<h1>This is my one page app!</h1>
  <div id="contact">
    <%= render 'contact_form' %>
  </div>

    Inside app/views/home/ create a file called _contact_form.html.erb (note the leading underscore indicating that this is a partial - a piece of code which will be called and rendered from the view)

<!-- app/views/home/_contact_form.html.erb -->

<%= form_for @contact, url: home_index_path, remote: true do |f| %>
    <div class="col-md-6">
        <%= f.label :name %></br>
        <%= f.text_field  :name, required: true, class: "contact-form-text-area" %></br>

        <%= f.label :email %></br>
        <%= f.text_field :email, required: true, class: "contact-form-text-area" %></br>

      <%= f.label :message %></br>
      <%= f.text_area :message, rows: 8, cols: 40, required: true, class: "contact-form-text-area",
                        placeholder: "Send me a message"%></br>

      <div class= "hidden">
        <%= f.label :nickname %>
        <%= f.text_field :nickname, :hint => 'Leave this field blank!' %>
      </div>

      <%= f.submit 'Send Message', class: 'btn btn-primary' %>
    </div>
  <% end %>
  <div class="col-md-6" id="flash-message">
    <%= render 'flash' %>
  </div>

    Create a second partial called _flash.html.erb containing this:

<!-- app/views/home/_flash.html.erb -->

<% flash.each do |message_type, message| %>
    <%= content_tag(:div, message, class: "alert alert-#{message_type}") %>
<% end %>

    Create a file called create.js.erb containing this:

// app/views/home/create.js.erb

// Test for ajax success
console.log("This is the create.js.erb file");
// Render flash message
$('#contact').html("<%= j render 'contact_form' %>");
$('#flash-message').html("<%= j render 'flash' %>").delay(3000).fadeOut(4000);

    Make app/config/routes.rb look like this:

# app/config/routes.rb

Rails.application.routes.draw do
 
root      'home#index'
resources :home, only: [:index, :new, :create]
 
end

    And make the home_controller.rb file look like this:

# app/controllers/home_controller.rb

class HomeController < ApplicationController
  def index
    @contact = Home.new(params[:home])
  end

  def create
    @contact = Home.new(params[:home])
    @contact.request = request
    respond_to do |format|
      if @contact.deliver
        # re-initialize Home object for cleared form
        @contact = Home.new
        format.html { render 'index'}
        format.js   { flash.now[:success] = @message = "Thank you for your message. I'll get back to you soon!" }
      else
        format.html { render 'index' }
        format.js   { flash.now[:error] = @message = "Message did not send." }
      end
    end
  end
end

    Create a file named home.rb in app/models/, then add the following and change your_email@your_domain.com to the email address you want the contact form to send to (e.g. your personal email address) - keep the double quotations

# app/models/home.rb

class Home < MailForm::Base
  attribute :name,      :validate => true
  attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message
  attribute :nickname,  :captcha  => true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      :subject => "Contact Form Inquiry",
      :to => "your_email@your_domain.com",
      :from => %("#{name}" <#{email}>)
    }
  end
end

    Give our form some basic styling by adding the following to app/assets/stylesheets/home.scss:

// app/assets/stylesheets/home.scss

@import "bootstrap-sprockets";
@import "bootstrap";

body {
  background-color: black;
  color: white;
}
.contact-form-text-area {
  color: black;
}
.hidden { display: none; }
.alert-error {
background-color: #f2dede;
border-color: #eed3d7;
color: #b94a48;
text-align: left;
font-size: .8em;
}

.alert-alert {
background-color: #f2dede;
border-color: #eed3d7;
color: #b94a48;
text-align: left;
font-size: .8em;
}

.alert-success {
background-color: #dff0d8;
border-color: #d6e9c6;
color: #468847;
text-align: center;
font-size: .8em;
}

.alert-notice {
background-color: #dff0d8;
border-color: #d6e9c6;
color: #468847;
text-align: left;
font-size: .8em;
}

    Add the following in config/environments/development.rb (if you're unsure where to place it, create some space between the very last 'end' in the file, and place it there):

# config/environments/development.rb

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors= true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'gmail.com',
    user_name:            ENV["GMAIL_EMAIL"],
    password:             ENV["GMAIL_PASSWORD"],
    authentication:       'plain',
    enable_starttls_auto: true  }

NOTE: Do not substitute GMAIL_EMAIL and GMAIL_PASSWORD in the above - leave them exactly as they are in the code above, as they are environment variables that are provided to the rails app from the .env file created in step 5.

    Now create the postgres database with rake db:create

    By default, gmail will block apps it is not familiar with, including yours. So now is the time to toggle your gmail settings to allow less secure apps

The contact form is now ready to use in development. Start the server with rails s and go to localhost:3000 in your browser. Your conctact form should be visible. Enter some dummy responses and click "Send Message". You should receive an email with the contents of the contact form.
Moving the contact form from development into production

    Create a new heroku app with:

heroku create new_app_name
or just set the existing app for git
heroku git:appname.git

    Substitute new_app_name for the name of your newly created app in two places in the following, then add the code to config/environments/production (as with development, place this code just inside the very last 'end' in the file):

# config/environments/production

config.action_mailer.default_url_options = { :host => 'new_app_name.herokuapp.com' }  
config.action_mailer.delivery_method = :smtp  
config.action_mailer.perform_deliveries = true  
config.action_mailer.raise_delivery_errors = false  
config.action_mailer.default :charset => "utf-8"  
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'gentle-inlet-00322.herokuapp.com',
  user_name:            ENV["GMAIL_EMAIL"],
  password:             ENV["GMAIL_PASSWORD"],
  authentication:       'plain',
  enable_starttls_auto: true  }

NOTE: As in development, leave GMAIL_EMAIL and GMAIL_PASSWORD exactly as they are in the above code.

    In July 2019, Heroku updated the bundler requirement, so we simply need to upgrade bundler locally (or else we'll get an error message when pushing to Heroku)

Simply run

gem install bundler -v 2.0.2
bundle update --bundler

    Now commit your app into your github repository and also to heroku:

git add . 
git commit -m "App ready for first deployment"
git push
git push heroku master

    Now your app is on the heroku server, but it's not live just yet, there are a couple more steps to go. Install your gems and set up the database:

heroku run bundle install
heroku run rake db:migrate

    Lastly, since github and heroku do not have access to the .env file with your environment variables, we need provide heroku with them (otherwise it will not be able to login to your mailer's email account to send you the emailed contact form). Replace your_gmail_email_address and your_gmail_password with your mailer's credentials (note no quotations) and copy the line into the terminal:

heroku config:set GMAIL_EMAIL=GMAIL_EMAIL GMAIL_PASSWORD=GMAIL_PASSWORD

You're done!

Go to your heroku app's url (http://gentle-inlet-00322.herokuapp.com 
