class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :code
      t.string :name
      t.string :city
      t.timestamps

      t.index :code, unique: true
    end

    if (table_exists? :locations)
      if Location.all.length == 0
        Location.create code: '08019043', name: 'Eixample', city: 'Barcelona'
        Location.create code: '08301004', name: 'Viladecans', city: 'Viladecans'
      end
    end

  end
end