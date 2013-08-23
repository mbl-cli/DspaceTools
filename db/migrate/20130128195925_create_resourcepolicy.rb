class CreateResourcepolicy < ActiveRecord::Migration
  def up
    if Sinatra::Base.settings.environment == :test
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
  end
  
  def down
    drop_table :resourcepolicy
  end
end
