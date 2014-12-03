require 'optparse'
require 'rubygems'
require 'nokogiri'

options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: populateSpreadsheet.rb [options]"

	opts.on("-r", "--resource Resource", "Type of resource to populate (companies)") do |r|
		options[:resource] = r
	end

	opts.on("-s", "--start Id", "Starting Id") do |s|
		options[:startId] = s
	end

	opts.on("-e", "--end Id", "Last Id") do |e|
		options[:lastId] = e
	end

	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
		options[:verbose] = v
	end
end.parse!

if options[:resource] == nil
	print 'Enter Resource: '
    options[:resource] = gets.chomp
end

if (options[:resource] == "companies")
	#idRange = (options[:startId].to_i..options[:lastId].to_i)

	Dir.glob("getresults/companies/*.html") do |filename|
		id = File.basename filename, "html"
		if (options[:startId].nil? || id.to_i >= options[:startId].to_i) && (options[:lastId].nil? || id.to_i <= options[:lastId].to_i)
			puts "processing #{filename}, id is #{id}"
			page = Nokogiri::HTML(open(filename))   
			lastUpdated = page.css('div#maincol div.rightPanel').css("span.panelNote")[0].text.split("\u00a0").last
			nzbn = page.xpath("//label[@for='nzbn']/..")[0].text.split("\n").last
			incorporationDate = page.xpath("//label[@for='incorporationDate']/..")[0].text.split("\n").last
			companyStatus = page.xpath("//label[@for='companyStatus']/..")[0].text.split("\r\r\n")[2]
			entityType = page.xpath("//label[@for='entityType']/..")[0].text.split("\r\r\n")[2]
			countryOfOriginNode = page.xpath("//label[@for='countryOfOrigin']/..")
			if countryOfOriginNode.any? then countryOfOrigin = countryOfOriginNode[0].text.split("\r\r\n")[2] end
			constitutionFiled = page.xpath("//label[@for='constitutionFiled']/..")[0].text.split[2]
			fraReportingMonthNode = page.xpath("//label[@for='fraReportingMonth']/..")
			if fraReportingMonthNode.any? then fraReportingMonth = fraReportingMonthNode[0].text.split("\r\r\n")[2] end
			arFilingMonthNode = page.xpath("//label[@for='arFilingMonth']/..")
			if arFilingMonthNode.any? then arFilingMonth = arFilingMonthNode[0].text.split("\r\r\n")[2] end
			puts "#{lastUpdated.inspect} #{nzbn.inspect} #{incorporationDate.inspect} #{companyStatus.inspect} #{entityType.inspect} #{countryOfOrigin.inspect} #{constitutionFiled.inspect} #{fraReportingMonth.inspect} #{arFilingMonth.inspect}"
			#puts page.class   # => Nokogiri::HTML::Document	
		end
	end
end


