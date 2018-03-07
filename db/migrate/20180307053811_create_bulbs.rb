class CreateBulbs < ActiveRecord::Migration[5.1]
  def change
    create_table :bulbs do |t|
      t.integer :hue
      t.integer :saturation
      t.integer :brightness

      t.timestamps
    end
  end
end
