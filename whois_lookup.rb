#!/home/john/.rvm/rubies/ruby-2.1.3/bin/ruby
require 'rubygems'
require 'whois'
require 'net/dns'

# Script configuration
BIND_FILE = "named.conf"

#-------------------------------------------------------------#
# Get a list of nameservers from a dns query                  #
#-------------------------------------------------------------#

def get_dns_nameservers(domain_name)

	dns_ns_list = []
	dns_query = Resolver(domain_name.to_s, Net::DNS::NS)
	dns_query.each_nameserver do |ns|
		ns.chomp!('.')
		dns_ns_list.push(ns) 
	end

	return dns_ns_list

end

#-------------------------------------------------------------#
# Get a list of nameservers from a whois record               #
#-------------------------------------------------------------#

def get_whois_nameservers(domain_name)

	whois_ns_list = []
	whois_query = Whois.whois(domain_name.to_s)
	whois_query.nameservers.each { |ns| whois_ns_list.push(ns.name) }

	return whois_ns_list

end


#-------------------------------------------------------------#
# Compare differences between nameservers                     #
#-------------------------------------------------------------#

def	compare_nameservers(domain_name)

	whois_list = get_whois_nameservers(domain_name)	
	puts "whois:" + whois_list.to_s
	dns_list = get_dns_nameservers(domain_name)
	puts "dns:  " +  dns_list.to_s

end

#-------------------------------------------------------------#
#                           Main                              #
#-------------------------------------------------------------#

file = File.new(BIND_FILE, "r")

while (line = file.gets)
		split_lines = line.split
		if split_lines[0] == "zone"
			domain_name = split_lines[1].chomp('"').reverse.chomp('"').reverse
			#p domain_name
			compare_nameservers(domain_name)
		end
	
end

file.close


#
# Resolv::DNS.new(:nameserver => ['210.251.121.21'],
#                :search => ['ruby-lang.org'],
#                :ndots => 1)
#
