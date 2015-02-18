#!/usr/bin/ruby
require 'rubygems'
require 'whois'
require 'net/dns'

# Script configuration
DEBUG = FALSE
DOMAIN_NAMES_FILE = "list_of_domains"
DOMAINS_TO_COMPARE = %w(google.ca yahoo.com)
IP_TO_COMPARE = "207.102.64"
WHOIS_LIB_TIMEOUT = 10


NS_OFF = TRUE
DNS_OFF = FALSE

#-------------------------------------------------------------#
# Compare ip addresses for domain name with vcn ip            #
#                                                             #
# return                                                      #
#   ip_results[:has_ip] = does domain have a vcn ip addr      #
#   ip_results[:list] = list of ips associated with domain    #
#-------------------------------------------------------------#

def domain_has_ip?(domain_name)


  has_ip = FALSE
  list_of_ips = []  

  packet = Resolver(domain_name.to_s)
  packet.each_address do |ip|
    if ip.to_s.start_with? IP_TO_COMPARE
      has_ip = TRUE 
    end    

    list_of_ips.push(ip)

  end

  ip_results = { :has_ip => has_ip, :list => list_of_ips}

  return ip_results


end

#-------------------------------------------------------------#
# Get a list of nameservers from a whois record               #
#-------------------------------------------------------------#

def get_name_servers(domain_name)



  whois_ns_list = []
  client = Whois::Client.new
  client.timeout = WHOIS_LIB_TIMEOUT
  domain_lookup = client.lookup(domain_name.to_s)
  domain_lookup.nameservers.each { |ns| whois_ns_list.push(ns.name) }

  return whois_ns_list

end

#-------------------------------------------------------------#
# Strip and compare nameservers with vcn.bc.ca and report if  #
# there is a match                                            #
#-------------------------------------------------------------#

def domain_has_ns?(name_servers)

  domain_has_ns = FALSE

  name_servers.each do |ns|

#   if ns.split('.', 2).last.to_s == DOMAIN_TO_COMPARE 
  if DOMAINS_TO_COMPARE.include? ns.split('.', 2).last.to_s
     domain_has_ns = TRUE
    end

  end

  return domain_has_ns

end

#-------------------------------------------------------------#
# Print table head                                            #
#-------------------------------------------------------------#

def print_table_head

start_html = <<eos
<head><title>VCN Domain Check Script 1.0 - Results</title></head>
  <body>
    <table border="1">
      <tr><td>Domain</td><td>Has VCN IP?</td><td>Has VCN Name Server?</td><td>Name Servers</td><td>IP Addresses</td></tr>
eos

print start_html

end

#-------------------------------------------------------------#
# Print table end                                             #
#-------------------------------------------------------------#

def print_table_end

puts "  </table></body></html>"

end

#-------------------------------------------------------------#
#                           Main                              #
#-------------------------------------------------------------#

file = File.new(DOMAIN_NAMES_FILE, "r")

print_table_head

while (domain = file.gets)

  print " <tr><td>#{domain.chomp}</td>"


  print "<td>" 

	if DNS_OFF == FALSE

		ip_results = domain_has_ip?(domain.to_s.chomp)

		if ip_results[:has_ip] != TRUE
			print " no "
		else
			print " yes "
		end

	else
		
		print " off "	

	end

	print "</td><td>"



	if NS_OFF == FALSE

		name_servers = get_name_servers(domain)

		if !domain_has_ns?(name_servers)
			print " no "
		else
			print " yes "
		end

	else

		print " off " 

	end

  print "</td><td>"
 
	if NS_OFF == FALSE
 
		name_servers.each do |ns|
			print ns + "<br />"
		end

	else
			print " off "

	end


  print "</td><td>"

	if DNS_OFF == FALSE

		ip_results[:list].each do |ip|
			puts ip
		end

	else
		
		print " off "

	end

  print "</td></tr>"

end


print_table_end

file.close

