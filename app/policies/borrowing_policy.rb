class BorrowingPolicy < ApplicationPolicy
  def index?; user.present?; end
  def show?; user.present? && (record.user_id == user.id || user.admin? || user.librarian?); end
  def create?; user.present? && user.student?; end
  def update?; false; end
  def destroy?; user&.admin?; end
  def return_book?; show?; end

  class Scope < Scope
    def resolve
      if user&.admin? || user&.librarian?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
