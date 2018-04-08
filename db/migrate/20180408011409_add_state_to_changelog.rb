class AddStateToChangelog < ActiveRecord::Migration[5.1]
  def change
    add_column :changelogs, :bulb_id, :int
    add_column :changelogs, :hue, :string
    add_column :changelogs, :saturation, :string
    add_column :changelogs, :brightness, :string
  end
end
