class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar

  belongs_to :team, optional: true

  enum :role, { user: 1, admin: 2, super_admin: 3 }, validate: { allow_nil: true }

  def super_admin?
    role == 'super_admin'
  end

  def admin?
    role == 'admin' || super_admin?
  end

  def regular_admin?
    role == 'admin'
  end

  def regular_user?
    role == 'user' 
  end

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
