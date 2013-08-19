exit if settings.environment != :test

class CreateBitstreamFormat < ActiveRecord::Migration
  def up
    execute("CREATE TABLE `bitstreamformatregistry` (
      `bitstream_format_id` int(11) NOT NULL,
      `mimetype` varchar(255) NOT NULL,
      `short_description` varchar(128),
      `description` text,
      `support_level` int(11) default 1,
      `internal` varchar(255),
      PRIMARY KEY (`bitstream_format_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci")
  end

  def down
    drop_table :bitstreamformatregistry
  end
end
