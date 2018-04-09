class AddProcessedToChangelog < ActiveRecord::Migration[5.1]
  def change
    add_column :changelogs, :processed, :boolean
  end
end
