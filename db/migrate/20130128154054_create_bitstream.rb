class CreateBitstream < ActiveRecord::Migration
  def up
    if Sinatra::Base.settings.environment == :test
      execute("CREATE TABLE `bitstream` (
        `bitstream_id` int(11) NOT NULL,
        `bitstream_format_id` int(11) NOT NULL,
        `name` varchar(255) NOT NULL,
        `size_bytes` int(11) NOT NULL,
        `checksum` varchar(255) NOT NULL,
        `checksum_algorithm` varchar(255) NOT NULL,
        `description` varchar(255),
        `user_format_description` varchar(255),
        `source` varchar(255),
        `internal_id` int(11) NOT NULL,
        `deleted` varchar(255) NOT NULL DEFAULT 'f',
        `store_number` int(11) NOT NULL,
        `sequence_id` int(11) NOT NULL,
        PRIMARY KEY (`bitstream_id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci")
    end
  end

  def down
    drop_table :bitstream
  end
end
