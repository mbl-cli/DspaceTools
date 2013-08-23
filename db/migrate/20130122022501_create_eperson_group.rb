class CreateEpersonGroup < ActiveRecord::Migration
  def up
    if Sinatra::Base.settings.environment == :test
      execute("
       CREATE TABLE `epersongroup2eperson` (
        `id` int(11) NOT NULL,
        `eperson_group_id` int(11) NOT NULL,
        `eperson_id` int(11) NOT NULL,
        PRIMARY KEY (`id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci 
      ")
    end
  end
  
  def down
  end
end
