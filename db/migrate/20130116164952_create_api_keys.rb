class CreateApiKeys < ActiveRecord::Migration
  set :database, "mysql2://root:@localhost/dspace_api"
  def up
    create_table :api_keys do |t|
      t.integer :eperson_id
      t.string  :app_name
      t.string  :public_key
      t.string  :private_key
      t.timestamps
    end

    add_index :api_keys, :eperson_id, :name => 'idx_api_keys_1'
    add_index :api_keys, :public_key, :name => 'idx_api_keys_2', :unique => true
  end

  def down
    drop table :api_keys
  end
end
