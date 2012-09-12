module DSpaceCSV
  class Transformer
    VALID_HEADERS = DSpaceCSV::Conf.valid_fields

    attr_reader :expander, :path, :errors

    def initialize(expander)
      @errors = []
      @expander = expander
      @path = File.join(@expander.uploader.path, 'dspace')
      @csv_data = parse_csv
      check_integrity
      transform if @errors.empty?
    end

    private 

    def check_integrity
      success = has_exactly_one_filename_field
      if success
        #success = all_files_exist && no_extra_files
      end
      success 
    end

    def has_exactly_one_filename_field
      res = @csv_data.headers.select {|f| f == "Filename"}
      if res.empty?
        @errors << "No Filename field"
      elsif res.size > 1
        @errors << "More than one Filename fields"
      end
      @errors.empty? ? true : false
    end

    def get_csv_file
      csv_file = Dir.entries(@expander.path).select {|e| e.match(/\.csv$/)}[0]
      raise DSpaceCSV::CsvError.new("Cannot find file with .csv extension") unless csv_file
      csv_file
    end

    def parse_csv
      csv_file = get_csv_file
      begin
        csv_string = open(File.join(@expander.path, csv_file), "r:utf-8").read.gsub(/\r\n?/, "\n")
        options = {:col_sep => ",", :row_sep => "\n", :headers => true}
        CSV.parse(csv_string, options)
      rescue CSV::MalformedCSVError
        raise DSpaceCSV::CsvError.new("Cannot parse CSV file")
      end
    end

    def transform
      count = -1
      @csv_data.each do |row|
        count += 1
        path = File.join(@path, "%04d" % count) 
        FileUtils.mkdir_p(path)
        file = open(File.join(path, 'dublin_core.xml'), 'w:utf-8')
        file.puts build_xml_string(row)
        copy_files(row['Filename'], path)
        file.close
      end
    end

    def build_xml_string(data)
      Nokogiri::XML::Builder.new do |xml|
        xml.dublin_core do
          data.each do |header, value|
            next if header == "Filename" || value.nil? || value.empty?
            element, qualifier = header.strip.downcase.split
            qualifier = "none" if qualifier.nil?
            xml.dcvalue(:element => element, :qualifier => qualifier) do
              xml.text value
            end
          end
        end
      end.to_xml
    end
    
    def copy_files(filenames, path)
      contents = open(File.join(path, "contents"), "w:utf-8")
      filenames.split("|").each do |f|
        FileUtils.cp(File.join(@expander.path, f), path)
        contents.write("%s\tbundle:ORIGINAL\n" % f)
      end
      contents.close
    end

  end
end

