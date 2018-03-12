class AddActionToChangelog < ActiveRecord::Migration[5.1]
  def change
    add_column :changelogs, :action, :string
  end
end
