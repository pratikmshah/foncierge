class CreateSaves < ActiveRecord::Migration[5.0]
  def change
    create_table :saves do |t|
      t.string :title
      t.string :url
      t.text :excerpt

      t.timestamps
    end
  end
end
