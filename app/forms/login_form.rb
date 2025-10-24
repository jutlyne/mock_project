class LoginForm
  include ActiveModel::Model

  attr_accessor :email, :password

  validates :email,
    presence: { message: " can't be blank." },
    format: { with: URI::MailTo::EMAIL_REGEXP, message: " format is invalid." }
  validates :password,
    presence: { message: " can't be blank." },
    length: { 
      minimum: 8, 
      maximum: 72,
      message: " must be between 8 and 72 characters." 
    }
end
