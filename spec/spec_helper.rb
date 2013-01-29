ENV["RACK_ENV"] = 'test'

require "rack/test"
require "webmock/rspec"
require "base64"
require "factory_girl"
require_relative "../application.rb"

module RSpecMixin
  include Rack::Test::Methods
  def app() DSpaceCsvUi end
end

RSpec.configure do |c| 
  c.include RSpecMixin 
  c.mock_with :rr
end

unless defined?(SPEC_CONSTANTS)
  FG = FactoryGirl
  HTTP_DIR = File.join(File.dirname(__FILE__), "http")
  FILE_DIR = File.join(File.dirname(__FILE__), "files")
  UPLOAD_1 = File.join(FILE_DIR, "upload.zip")
  UPLOAD_2 = File.join(FILE_DIR, "upload_dir.zip")
  UPLOAD_LATIN1 = File.join(FILE_DIR, "upload_latin1.zip")
  UPLOAD_MANY_DIRS = File.join(FILE_DIR, "upload_many_dirs.zip")
  UPLOAD_NOT_ZIP = File.join(FILE_DIR, "UploadTest.csv")
  UPLOAD_NO_CSV = File.join(FILE_DIR, "no_csv.zip")
  UPLOAD_DIR_NO_CSV = File.join(FILE_DIR, "dir_no_csv.zip")
  UPLOAD_BAD_CSV = File.join(FILE_DIR, "bad_csv.zip")
  UPLOAD_MISSED_FILE = File.join(FILE_DIR, "missed_file.zip")
  UPLOAD_EXTRA_FILE = File.join(FILE_DIR, "extra_file.zip")
  UPLOAD_TYPO_IN_FILENAME_FIELD = File.join(FILE_DIR, "typo_in_filename_field.zip")
  UPLOAD_NO_TITLE_FIELD = File.join(FILE_DIR, "no_title_field.zip")
  UPLOAD_NO_RIGHTS_FIELD = File.join(FILE_DIR, "no_rights_field.zip")
  UPLOAD_TWO_FILENAME_FIELDS = File.join(FILE_DIR, "two_filename_fields.zip")
  PARAMS_1 = {"file" => {:tempfile => open(UPLOAD_1), :filename => "upload.zip"}}
  SPEC_CONSTANTS = true
end

#FG.find_definitions
