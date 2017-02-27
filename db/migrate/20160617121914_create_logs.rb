class CreateLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :logs do |t|
      t.decimal :value, precision: 8, scale: 2
      t.datetime :registered_at
      t.timestamps
    end
  end
end
