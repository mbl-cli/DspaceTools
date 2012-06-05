#!/usr/bin/env ruby
require "fileutils"

FileUtils.rm_rf("./data") if File.directory? "./data"
Dir.mkdir("./data")

# grab all the .xml files
Dir.glob("*.xml").each do |xml_file|
  count_string = File.basename(xml_file, ".xml")
  f = open(xml_file)
  metadata_content = f.readlines
  f.close
  file_names = metadata_content.pop.strip.split("|") 
  # FileUtils.rm_r(count_string) if File.directory? count_string
  Dir.mkdir("./data/#{count_string}")
  w = open("./data/#{count_string}/dublin_core.xml", "w")
  metadata_content.each { |l| w.write(l) }
  w.close
  File.unlink(xml_file)
  w = open("./data/#{count_string}/contents", "w")
  file_names.each do |content_file|
    FileUtils.cp(content_file, "./data/#{count_string}/")
    w.write("%s\tbundle:ORIGINAL\n" % content_file) 
  end
  w.close
end
