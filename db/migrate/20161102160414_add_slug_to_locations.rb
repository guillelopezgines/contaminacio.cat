class AddSlugToLocations < ActiveRecord::Migration[5.0]
  def up
    add_column :locations, :slug, :string, after: :code, null: false
    Location.all.each do |location|
      location.slug = location.name.parameterize
      location.save
    end
  end

  def down
    remove_column :locations, :slug
  end
end
