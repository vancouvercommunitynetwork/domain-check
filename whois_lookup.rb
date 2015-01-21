#!/home/john/.rvm/rubies/ruby-2.1.3/bin/ruby
require 'rubygems'
require 'whois'
#require 'net/dns'

# Script configuration
DEBUG = FALSE
DOMAIN_NAMES_FILE = "list_of_vcn_domains"
DOMAIN_TO_COMPARE = "vcn.bc.ca"


#-------------------------------------------------------------#
# Get a list of nameservers from a whois record               #
#-------------------------------------------------------------#

def get_name_servers(domain_name)

	whois_ns_list = []
  #Whois::Client.new(timeout: 1) # note: figure out timeout
	whois_query = Whois.whois(domain_name.to_s)
	whois_query.nameservers.each { |ns| whois_ns_list.push(ns.name) }

	return whois_ns_list

end

#-------------------------------------------------------------#
# Strip and compare nameservers with vcn.bc.ca and report if  #
# there is a match                                            #
#-------------------------------------------------------------#

def compare_name_servers(name_servers, domain_name)

  domain_has_ns = FALSE

  if DEBUG == TRUE
    puts "DOMAIN: " + domain_name
  end

  name_servers.each do |ns|

    if DEBUG == TRUE
      puts "split name server to compare: " + ns.split('.', 2).to_s
    end

    if ns.split('.', 2).last.to_s == DOMAIN_TO_COMPARE 
      domain_has_ns = TRUE
    end

  end

  if domain_has_ns == FALSE
    puts domain_name.to_s.chomp + " does not have vcn name servers"
  end

end

#-------------------------------------------------------------#
#                           Main                              #
#-------------------------------------------------------------#

file = File.new(DOMAIN_NAMES_FILE, "r")

while (domain_name = file.gets)
	name_servers = get_name_servers(domain_name)
  compare_name_servers(name_servers, domain_name)    
end

file.close




