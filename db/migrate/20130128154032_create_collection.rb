exit if settings.environment != :test

class CreateCollection < ActiveRecord::Migration
  def up
    execute("CREATE TABLE `collection` (
      `collection_id` int(11) NOT NULL,
      `name`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `short_description`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `introductory_text`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `logo_bitstream_id`       int(11),
      `template_item_id`       int(11),
      `provenance_description`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `license`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `copyright_text`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `side_bar_text`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `sidebar_text`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `workflow_step_1`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `workflow_step_2`       varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `submitter` int(11) DEFAULT NULL,
      `admin` int(11) DEFAULT NULL,
      PRIMARY KEY (`collection_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci")
  end
  
  def down
  end
end
