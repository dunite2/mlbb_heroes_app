class AddImageUrlToHeroes < ActiveRecord::Migration[7.2]
  def change
    add_column :heroes, :image_url, :string
  end
end
