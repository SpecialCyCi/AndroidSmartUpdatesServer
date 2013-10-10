class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string  :version_name
      t.integer :version_code
      t.text :description
      t.attachment :apk
      t.integer :user_id
      t.integer :application_id

      t.timestamps
    end
  end
end
