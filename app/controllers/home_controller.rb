
class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    @contact = Home.new(params[:home])
  end

  def create
    @contact = Home.new(params[:home])
    @contact.request = request
    respond_to do |format|
      if @contact.deliver
        # re-initialize Home object for cleared form
        
        format.html { render '/home/index.html.erb'}
        format.js   { flash.now[:success] = @message = "Thank you for your message. I'll get back to you soon!" }
      else
        format.html { render '/home/index.html.erb' }
        format.js   { flash.now[:error] = @message = "Message did not send." }
      end
    end
  end
  def home
    home = params.require([:name,:email,:message])
  end
end