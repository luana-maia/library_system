module Api
  class BorrowingsController < BaseController
    def index
      borrowings = policy_scope(Borrowing).includes(:book).order(created_at: :desc).page(params[:page])
      render json: borrowings, each_serializer: BorrowingSerializer, meta: pagination_meta(borrowings)
    end

    def overdue
      borrowings = policy_scope(Borrowing).overdue.includes(:book).order(due_at: :asc)
      render json: borrowings, each_serializer: BorrowingSerializer
    end

    def create
      borrowing = Borrowing.new(borrowing_params.merge(user: current_user))
      authorize borrowing
      if borrowing.save
        render json: borrowing, status: :created
      else
        render json: { errors: borrowing.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def return_book
      borrowing = Borrowing.find(params[:id])
      authorize borrowing, :show?
      borrowing.mark_returned!
      render json: borrowing
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def borrowing_params
      params.require(:borrowing).permit(:book_id)
    end

    def pagination_meta(scope)
      { page: scope.current_page, total_pages: scope.total_pages, total_count: scope.total_count }
    end
  end
end
