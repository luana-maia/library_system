class BookSerializer < ActiveModel::Serializer
  attributes :id, :title, :author, :isbn, :genre, :total_copies, :available_copies, :created_at
end
