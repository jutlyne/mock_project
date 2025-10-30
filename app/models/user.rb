class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar

  belongs_to :team, optional: true

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
end
