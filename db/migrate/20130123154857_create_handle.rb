exit if settings.environment != :test

class CreateHandle < ActiveRecord::Migration
  def up
    execute("
     CREATE TABLE `handle` (
      `handle_id` int(11) NOT NULL,
      `handle`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `resource_type_id` int(11) NOT NULL,
      `resource_id` int(11) NOT NULL,
      PRIMARY KEY (`handle_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci 
    ")
    add_index :handle, :handle, :unique => true
  end

  def down
    drop_table :handle
  end
end
