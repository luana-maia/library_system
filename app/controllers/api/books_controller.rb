module Api
  class BooksController < BaseController
    def index
      scope = policy_scope(Book)
      scope = scope.search(params[:q]) if params[:q].present?
      books = scope.order(created_at: :desc).page(params[:page])
      render json: books, each_serializer: BookSerializer, meta: pagination_meta(books)
    end

    def show
      book = Book.find(params[:id])
      authorize book
      render json: book
    end

    def create
      book = Book.new(book_params)
      authorize book
      if book.save
        render json: book, status: :created
      else
        render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      book = Book.find(params[:id])
      authorize book
      if book.update(book_params)
        render json: book
      else
        render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      book = Book.find(params[:id])
      authorize book
      book.destroy
      head :no_content
    end

    private

    def book_params
      params.require(:book).permit(:title, :author, :isbn, :genre, :total_copies, :available_copies)
    end

    def pagination_meta(scope)
      { page: scope.current_page, total_pages: scope.total_pages, total_count: scope.total_count }
    end
  end
end
