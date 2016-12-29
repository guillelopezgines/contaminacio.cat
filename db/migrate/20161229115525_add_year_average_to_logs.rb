class AddYearAverageToLogs < ActiveRecord::Migration[5.0]
  def change
    add_column :logs, :annual_sum, :decimal, precision: 8, scale: 2, after: :location_id, default: nil
    add_column :logs, :annual_registers, :integer, after: :annual_sum, default: nil
  end
end
