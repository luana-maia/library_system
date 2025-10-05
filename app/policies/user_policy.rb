class UserPolicy < ApplicationPolicy
  def show?; user.present? && (user.admin? || user.id == record.id); end
  def update?; user.present? && (user.admin? || user.id == record.id); end
  def destroy?; user&.admin? && user.id != record.id; end
  def index?; user&.admin?; end
  def create?; user&.admin?; end

  class Scope < Scope
    def resolve
      user&.admin? ? scope.all : scope.where(id: user.id)
    end
  end
end
