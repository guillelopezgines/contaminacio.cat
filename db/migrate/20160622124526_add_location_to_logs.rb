class AddLocationToLogs < ActiveRecord::Migration[5.0]
  def change
    add_column :logs, :location_id, :integer, after: :value, null: false
    add_index :logs, :location_id, :unique => false
  end
end
