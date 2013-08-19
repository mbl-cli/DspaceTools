exit if settings.environment != :test

class CreateCommunities2item < ActiveRecord::Migration
  def up
     execute("CREATE TABLE `communities2item` (
      `id` int(11) NOT NULL auto_increment,
      `community_id` int(11) NOT NULL,
      `item_id` int(11) NOT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci")
  end

  def down
    drop_table :communities2item
  end
end
