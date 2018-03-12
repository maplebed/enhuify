class CreateChangelogs < ActiveRecord::Migration[5.1]
  def change
    create_table :changelogs do |t|
      t.string :remote_id
      t.string :guid

      t.timestamps
    end
  end
end
