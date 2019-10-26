class AddDistrictHandleToLocations < ActiveRecord::Migration[5.0]
  def up
    add_column :locations, :district_handle, :string, null: true
    remove_index :locations, :district
    add_index :locations, :district_handle, :unique => false

    Location.schools.each do |location|
      location.district_handle = location.district.parameterize
      location.save
    end
  end

  def down
    remove_column :locations, :district_handle
    add_index :locations, :district, :unique => false
    remove_index :locations, :district_handle
  end
end
