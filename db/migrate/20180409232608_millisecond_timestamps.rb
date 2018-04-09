class MillisecondTimestamps < ActiveRecord::Migration[5.1]
    def change
        change_column :changelogs, :created_at, :datetime, limit: 3
        change_column :changelogs, :updated_at, :datetime, limit: 3
    end
end
