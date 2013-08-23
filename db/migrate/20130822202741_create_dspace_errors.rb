class CreateDspaceErrors < ActiveRecord::Migration
  Sinatra::Base.set :database, "mysql2://root:@localhost/dspace_api"
  def up
    create_table :dspace_errors do |t|
      t.integer  :eperson_id
      t.integer  :collection_id
      t.text     :error
      t.timestamps
    end
  end
  
  def down
    drop table :dspace_errors
  end
end
