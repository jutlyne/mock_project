class UserForm
  include ActiveModel::Model
  
  attr_accessor :name, :email, :password, :avatar, :team_id

  validates :name, 
    presence: { message: " can't be blank." },
    length: { maximum: 50, message: " must be less than 50 characters." }

  validates :email,
    presence: { message: " can't be blank." },
    format: { with: URI::MailTo::EMAIL_REGEXP, message: " format is invalid." }
    
  validates :password,
    presence: { message: " can't be blank.", if: :new_record? },
    length: { 
      minimum: 8, 
      maximum: 72,
      message: " must be between 8 and 72 characters.",
      if: -> { password.present? }
    }

  validates :team_id, 
    presence: { message: " must be selected." }

  validate :email_is_unique
  validate :avatar_file_is_valid

  def avatar_file_is_valid
    return if avatar.nil? 

    if avatar.respond_to?(:size) && avatar.size > 5.megabytes
      errors.add(:avatar, " size must be less than 5MB.")
    end

    if avatar.respond_to?(:content_type) && 
       !['image/png', 'image/jpeg', 'image/jpg'].include?(avatar.content_type)
      errors.add(:avatar, " format must be JPEG or PNG.")
    end
  rescue NoMethodError 
    errors.add(:avatar, " is invalid.") 
  end

  def initialize(params = {}, user = nil)
    @user = user || User.new
    
    load_user_attributes if user&.persisted?
    super(params)
  end

  def attributes
    {
      'name'     => name,
      'email'    => email,
      'password' => password,
      'avatar'   => avatar,
      'team_id'  => team_id
    }.stringify_keys
  end

  def save
    return false unless valid? 

    user_attributes = attributes.except('avatar')
    @user = User.new(user_attributes)
    
    if @user.save
      @user.avatar.attach(avatar) if avatar.present?
      true
    else
      copy_errors_from_user
      false
    end
  end

  def update
    return false unless valid? 
    
    user_attributes = attributes.except('avatar')
    user_attributes.delete('password') if user_attributes['password'].blank? && @user.persisted?
    self.errors.add('password', 'error.message')

    if @user.update(user_attributes)
      @user.avatar.attach(avatar) if avatar.present?
      true
    else
      copy_errors_from_user
      false
    end
  end

  def load_user_attributes
    self.name    = @user.name
    self.email   = @user.email
    self.team_id = @user.team_id
  end

  attr_reader :user

  private

  def new_record?
    @user.nil? || !@user.persisted?
  end

  def copy_errors_from_user
    @user.errors.each do |error|
      self.errors.add(error.attribute, error.message)
    end
  end

  def email_is_unique
    return unless email.present? && errors[:email].empty?
    
    query = User.where(email: email)
    query = query.where.not(id: @user.id) if @user.persisted?
    
    if query.exists?
      errors.add(:email, " has already been taken.")
    end
  end
end