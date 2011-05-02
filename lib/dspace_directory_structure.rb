#!/bin/ruby
require "fileutils"

count = 0

Dir.glob("*.xml").each do |xml_file|
    count_string = sprintf("%04d", count)
    FileUtils.rm_r(count_string) if File.directory? count_string
    Dir.mkdir(count_string)
    FileUtils.mv(xml_file, count_string)
    file = File.basename(xml_file, ".xml")
    Dir.glob("#{file}.*").each do |content_file|
        FileUtils.mv(content_file, count_string)
    end
    contents = File.new("#{count_string}/contents", 'w')
    Dir.entries(count_string).each do |file_name|
       next if file_name == "."
       next if file_name == ".."
       next if file_name == "contents"
       next if file_name =~ /.xml$/
       contents.puts("#{file_name}\t bundle:ORIGINAL") 
    end
    count += 1
end
