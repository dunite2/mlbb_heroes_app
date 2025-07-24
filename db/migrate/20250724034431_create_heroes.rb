class CreateHeroes < ActiveRecord::Migration[7.2]
  def change
    create_table :heroes do |t|
      t.string :name
      t.string :role
      t.string :specialty
      t.integer :difficulty
      t.string :lane
      t.text :description
      t.string :image_url

      t.timestamps
    end
  end
end
