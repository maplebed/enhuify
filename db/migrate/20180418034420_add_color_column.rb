class AddColorColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :changelogs, :color, :string
  end
end
