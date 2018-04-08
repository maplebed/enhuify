class AddSuccessToChangelog < ActiveRecord::Migration[5.1]
  def change
    add_column :changelogs, :succeeded, :boolean
  end
end
