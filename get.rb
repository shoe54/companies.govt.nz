require 'optparse'
require 'net/http'
require 'socksify/http'

options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: get.rb [options]"

	opts.on("-r", "--resource Resource", "Type of resource to retrieve (companies)") do |r|
		options[:resource] = r
	end

	opts.on("-s", "--start Id", "Starting Id") do |s|
		options[:startId] = s
	end

	opts.on("-e", "--end Id", "Last Id") do |e|
		options[:lastId] = e
	end

	opts.on("-d", "--delay Seconds", "Delay between Ids in seconds") do |d|
		options[:delay] = d
	end

	opts.on("-p", "--proxy Addr:Port", "Proxy (address:port)") do |p|
		options[:proxyAddr], options[:proxyPort] = p.split(':')
	end

	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
		options[:verbose] = v
	end
end.parse!

if options[:resource] == nil
	print 'Enter Resource: '
    options[:resource] = gets.chomp
end

if options[:startId] == nil
	print 'Enter Starting Id: '
    options[:startId] = gets.chomp
end

if options[:lastId] == nil
	print 'Enter Last Id: '
    options[:lastId] = gets.chomp
end

if options[:delay] == nil
	print 'Enter Delay: '
    options[:delay] = gets.chomp
end

if (options[:resource] == "companies")
	idRange = (options[:startId].to_i..options[:lastId].to_i)
	idRange.each do |id|
		urlpath = "/companies/app/ui/pages/companies/#{id}"
		filepath = "./getresults/companies"
		if options[:proxyAddr] != nil
			http = Net::HTTP::SOCKSProxy(options[:proxyAddr], options[:proxyPort])
		else
			http = Net::HTTP
		end
		http.start("www.business.govt.nz") do |http|
			puts "GETting http://www.business.govt.nz#{urlpath} and storing in #{filepath}"
    		resp = http.get(urlpath)
    		if resp.code == "500"
    			open("#{filepath}/#{id}.500", "w") do |file|
	        		file.write("")
	    		end
	    	else
    			open("#{filepath}/#{id}.html", "w") do |file|
	        		file.write(resp.body)
	    		end
	    		# Get Addresses
	    		resp = http.get(urlpath + "/addresses")
    			open("#{filepath}/addresses/#{id}.html", "w") do |file|
	        		file.write(resp.body)
	    		end
	    		# Get Directors
	    		resp = http.get(urlpath + "/directors")
    			open("#{filepath}/directors/#{id}.html", "w") do |file|
	        		file.write(resp.body)
	    		end
	    		# Get Shareholdings
	    		resp = http.get(urlpath + "/shareholdings")
    			open("#{filepath}/shareholdings/#{id}.html", "w") do |file|
	        		file.write(resp.body)
	    		end
	    		# Get Documents
	    		resp = http.get(urlpath + "/documents")
    			open("#{filepath}/documents/#{id}.html", "w") do |file|
	        		file.write(resp.body)
	    		end
	    	end
		end
		sleep(options[:delay].to_i)
	end
end

#if options[:proxyAddr] != nil
#	http = Net::HTTP::SOCKSProxy(options[:proxyAddr], options[:proxyPort])
#	http.start("whatismyipaddress.com") do |http|
#    	resp = http.get("/")
#   		open("ip.html", "w") do |file|
#       		file.write(resp.body)
#    	end
#	end
#end
