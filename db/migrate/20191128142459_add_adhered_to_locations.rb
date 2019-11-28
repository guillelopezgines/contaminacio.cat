class AddAdheredToLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :adhered, :boolean, default: false, null: false
  end
end
