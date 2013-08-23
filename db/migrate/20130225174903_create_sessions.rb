class CreateSessions < ActiveRecord::Migration
  Sinatra::Base.set :database, "mysql2://root:@localhost/dspace_api"
  def up
    create_table :sessions do |t|
      t.text :session_id
      t.text :data
    end
    
    add_index :sessions, :session_id, :length => {:session_id => 100}, :name => 'idx_sessions_1'
  end
  
  def down
    drop table :sessions
  end
end
