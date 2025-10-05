module Api
  class DashboardController < BaseController
    def summary
      render json: {
        books_count: Book.count,
        users_count: User.count,
        active_borrowings: Borrowing.active.count,
        overdue_borrowings: Borrowing.overdue.count,
        available_books: Book.where('available_copies > 0').count
      }
    end

    def availability
      top_borrowed = Borrowing.group(:book_id).order(Arel.sql('count_all desc')).limit(5).count.keys
      books = Book.where(id: top_borrowed).map { |b| BookSerializer.new(b) }
      low_stock = Book.where('available_copies < ?', 2).limit(5).map { |b| BookSerializer.new(b) }
      render json: { top_borrowed: books, low_stock: low_stock }
    end
  end
end
