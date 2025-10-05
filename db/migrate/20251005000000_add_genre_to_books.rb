class AddGenreToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :genre, :string
    add_index :books, :genre
  end
end