class ChangelogGuidRequestId < ActiveRecord::Migration[5.1]
  def change
    rename_column :changelogs, :guid, :request_id
  end
end
