class ChangelogRemoteIdToIp < ActiveRecord::Migration[5.1]
  def change
    rename_column :changelogs, :remote_id, :remote_ip
  end
end
