class CreateLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :likes do |t|
      t.belongs_to :post, foreign_key: true
      t.string :user_name, null: false

      t.timestamps
    end
  end
end
