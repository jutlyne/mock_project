class UserPolicy
  attr_reader :current_user, :user_record

  def initialize(current_user, user_record)
    @current_user = current_user
    @user_record = user_record
  end

  def index?
    true
  end

  def new?
    create?
  end
  
  def create?
    current_user.admin?
  end

  def edit?
    update?
  end

  def update?
    return true if current_user.super_admin?

    return true if current_user == user_record

    return user_record.regular_user? if current_user.regular_admin?

    false
  end

  def destroy?
    return true if current_user.super_admin?

    return false if current_user.regular_user?

    current_user.regular_admin? && user_record.regular_user?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all 
    end
  end
end