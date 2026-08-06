class CreateBodyMeasurements < ActiveRecord::Migration[8.1]
  def change
    create_table :body_measurements do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false

      # All measurements in centimeters
      t.decimal :neck
      t.decimal :bust
      t.decimal :under_bust
      t.decimal :waist
      t.decimal :high_hip
      t.decimal :full_hip
      t.decimal :shoulder
      t.decimal :shoulder_to_waist
      t.decimal :back_width
      t.decimal :arm_length
      t.decimal :sleeve_length
      t.decimal :wrist
      t.decimal :bicep
      t.decimal :forearm
      t.decimal :thigh
      t.decimal :knee
      t.decimal :calf
      t.decimal :inseam
      t.decimal :outseam
      t.decimal :torso_length
      t.decimal :head

      t.timestamps
    end

    add_index :body_measurements, [ :user_id, :date ]
  end
end
