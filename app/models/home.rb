class Home < MailForm::Base
    attribute :name,      :validate => true
    attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
    attribute :message
    attribute :nickname,  :captcha  => false
  
    # Declare the e-mail headers. It accepts anything the mail method
    # in ActionMailer accepts.
    def headers
      {
        :subject => "Contact Form Inquiry",
        :to => "mayurichaudhari57@gmail.com",
        :from => %("#{name}" <#{email}>)
      }
    end
  end