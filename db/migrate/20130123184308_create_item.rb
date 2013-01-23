exit if settings.environment != :test

class CreateItem < ActiveRecord::Migration
  def up
     execute("CREATE TABLE `item` (
      `item_id` int(11) NOT NULL,
      `submitter_id`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `in_archive` varchar(255) NOT NULL DEFAULT 't',
      `withdrawn` varchar(255) NOT NULL DEFAULT 'f',
      `last_modified` datetime,
      `owning_collection` int(11) NOT NULL,
      PRIMARY KEY (`item_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci")
  end
  
  def down
    drop_table :item
  end
end
