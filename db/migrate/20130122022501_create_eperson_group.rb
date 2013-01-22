exit if settings.environment != :test

class CreateEpersonGroup < ActiveRecord::Migration
  def up
    execute("
     CREATE TABLE `epersongroup2eperson` (
      `id` int(11) NOT NULL,
      `eperson_group_id` int(11) NOT NULL,
      `eperson_id` int(11) NOT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci 
    ")
  end
  
  def down
  end
end
