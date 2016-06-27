class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :code
      t.string :name
      t.string :city
      t.decimal :latitude, precision: 8, scale: 6
      t.decimal :longitude, precision: 8, scale: 6
      t.boolean :enabled, default: true
      t.timestamps

      t.index :code, unique: true
    end

  end
end