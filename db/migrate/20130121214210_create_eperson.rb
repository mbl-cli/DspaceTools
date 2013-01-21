exit if settings.environment != :test

class CreateEperson < ActiveRecord::Migration
  def up
    execute("
     CREATE TABLE `eperson` (
      `eperson_id` int(11) NOT NULL,
      `email`      varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `password`   varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `firstname`  varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `lastname`   varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `can_log_in` tinyint default 1,
      `require_certificate` tinyint default 0,
      `self_registered` tinyint default 1,
      `last_active` datetime,
      `sub_frequency` int(11) NOT NULL,
      `phone`      varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `language`      varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      PRIMARY KEY (`eperson_id`),
      UNIQUE KEY `idx_api_keys_2` (`email`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci 
    ")
  end
  
  def down
    drop_table :eperson
  end
end
