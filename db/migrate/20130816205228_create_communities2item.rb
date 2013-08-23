class CreateCommunities2item < ActiveRecord::Migration
  def up
     if Sinatra::Base.settings.environment == :test
       execute("CREATE TABLE `communities2item` (
        `id` int(11) NOT NULL auto_increment,
        `community_id` int(11) NOT NULL,
        `item_id` int(11) NOT NULL,
        PRIMARY KEY (`id`)
       ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci")
     end
  end

  def down
    drop_table :communities2item
  end
end
