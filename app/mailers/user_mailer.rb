class UserMailer < ApplicationMailer
    def password_reset_pin(user, pin)
        @user = user
        @pin = pin
        mail to: user.email, subject: "Mã xác thực đặt lại mật khẩu của bạn"
    end
end
