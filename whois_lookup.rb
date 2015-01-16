#!/home/john/.rvm/rubies/ruby-2.1.3/bin/ruby
require 'rubygems'
require 'whois'
#require 'net/dns'

# Script configuration
DOMAIN_NAMES_FILE = "list_of_vcn_domains"
DOMAIN_TO_COMPARE = "vcn.bc.ca"


#-------------------------------------------------------------#
# Get a list of nameservers from a whois record               #
#-------------------------------------------------------------#

def get_name_servers(domain_name)

	whois_ns_list = []
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

  name_servers.each do |ns|
    # Note: make hash of vcn.bc.ca and do check in the future
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




