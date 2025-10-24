class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Email invalid" }
  validate :email_must_be_unique

  def generate_and_save_reset_pin
    pin = rand(100000..999999) 
    
    update_columns(
      password_reset_pin: pin, 
      password_reset_sent_at: Time.zone.now
    )
    
    return pin
  end

  def pin_expired?
    password_reset_sent_at < 5.minutes.ago
  end

  def send_password_reset_email(pin)
    UserMailer.password_reset_pin(self, pin).deliver_later
  end

  private

  def email_must_be_unique
    existing_user = User.find_by(email: email)
    if existing_user && existing_user.id != id
      errors.add(:email, "đã tồn tại")
    end
  end
end
