class CreateLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :logs do |t|
      t.integer :value
      t.datetime :registered_at
      t.timestamps
    end
  end
end
