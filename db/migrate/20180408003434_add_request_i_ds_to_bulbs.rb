class AddRequestIDsToBulbs < ActiveRecord::Migration[5.1]
  def change
    add_column :bulbs, :request_id, :string
  end
end
