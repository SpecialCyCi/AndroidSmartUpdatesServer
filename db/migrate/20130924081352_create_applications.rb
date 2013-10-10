class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.string :app_name
      t.string :package_name
      t.text :description
      t.integer :user_id

      t.timestamps
    end
  end
end
