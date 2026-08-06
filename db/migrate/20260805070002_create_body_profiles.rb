class CreateBodyProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :body_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :gender
      t.decimal :height_cm

      t.timestamps
    end
  end
end
