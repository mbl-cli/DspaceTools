class CreateCommunity < ActiveRecord::Migration
  def up
    if Sinatra::Base.settings.environment == :test
      execute("CREATE TABLE `community` (
        `community_id` int(11) NOT NULL,
        `name`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
        `short_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
        `introductory_text` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
        `logo_bitstream_id` int(11),
        `copyright_text` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
        `side_bar_text` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
        `admin` int(11) DEFAULT NULL,
        PRIMARY KEY (`community_id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci")
    end
  end

  def down
    drop_table :community
  end
end

