exit if settings.environment != :test

class CreateGroup < ActiveRecord::Migration
  def up
    execute("
     CREATE TABLE `epersongroup` (
      `eperson_group_id` int(11) NOT NULL,
      `name`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      PRIMARY KEY (`eperson_group_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci 
    ")
  end
  
  def down
    drop_table :epersongroup
  end
end
