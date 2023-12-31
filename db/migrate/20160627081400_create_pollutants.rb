class CreatePollutants < ActiveRecord::Migration[5.0]
  def change
    create_table :pollutants do |t|
      t.string :name
      t.string :name_html
      t.string :short_name
      t.string :unit
      t.string :unit_html
      t.string :selector
      t.decimal :year_limit_spain, precision: 8, scale: 2
      t.decimal :year_limit_oms, precision: 8, scale: 2
      t.text :description
      t.timestamps
    end

    add_column :logs, :pollutant_id, :integer, after: :value, null: false
    add_index :logs, :pollutant_id, :unique => false
  end
end
