exit if settings.environment != :test

class CreateResourcepolicy < ActiveRecord::Migration
  def up
     execute("CREATE TABLE `resourcepolicy` (
      `policy_id` int(11) NOT NULL,
      `resource_type_id` int(11) NOT NULL,
      `resource_id` int(11) NOT NULL,
      `action_id` int(11) NOT NULL,
      `eperson_id` int(11) DEFAULT NULL,
      `epersongroup_id` int(11) DEFAULT NULL,
      `start_date` datetime,
      `end_date` datetime,
      PRIMARY KEY (`policy_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci")
  end
  
  def down
    drop_table :resourcepolicy
  end
end
