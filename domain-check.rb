#!/usr/bin/ruby
require 'rubygems'
require 'whois'
require 'net/dns'

# Script configuration
DEBUG = FALSE
DOMAIN_NAMES_FILE = "list_of_domains"
DOMAINS_TO_COMPARE = %w(vancouvercommunity.net vcn.bc.ca)
IP_TO_COMPARE = "207.102.64"
WHOIS_LIB_TIMEOUT = 10


NS_OFF = FALSE
DNS_OFF = FALSE
RETRY_NUM = 2 # Number of retries
RETRY_TIMER = 2 # Pause between retries

#-------------------------------------------------------------#
# Compare ip addresses for domain name with vcn ip            #
#                                                             #
# return                                                      #
#   ip_results[:has_ip] = does domain have a vcn ip addr      #
#   ip_results[:list] = list of ips associated with domain    #
#-------------------------------------------------------------#

def domain_has_ip?(domain_name)

  retries = RETRY_NUM
  has_ip = FALSE
  list_of_ips = []
  retry_error = FALSE

  begin


    packet = Resolver(domain_name.to_s)
    packet.each_address do |ip|
      if ip.to_s.start_with? IP_TO_COMPARE
        has_ip = TRUE
      end

      list_of_ips.push(ip)

    end

  rescue

    if retries > 0
      retries -= 1
      sleep(RETRY_TIMER)
      retry
    else
      print " error "
      retry_error = TRUE
    end

  end

  ip_results = { :has_ip => has_ip, :list => list_of_ips,
                 :retry_error => retry_error}

  return ip_results


end

#-------------------------------------------------------------#
# Get a list of nameservers from a whois record               #
#-------------------------------------------------------------#

def get_name_servers(domain_name)

  has_error = FALSE
  retries = RETRY_NUM
  whois_ns_list = []

  begin

    client = Whois::Client.new
    client.timeout = WHOIS_LIB_TIMEOUT
    domain_lookup = client.lookup(domain_name.to_s)
    domain_lookup.nameservers.each { |ns| whois_ns_list.push(ns.name) }

  rescue
    if retries > 0

      retries -= 1
      sleep(RETRY_TIMER)
      retry

    else

      print " error "
      has_error = TRUE
    end

  end

  ns_results = { :list => whois_ns_list, :has_error => has_error }
  return ns_results

end

#-------------------------------------------------------------#
# Strip and compare nameservers with vcn.bc.ca and reports if #
# there is a match                                            #
#-------------------------------------------------------------#

def domain_has_ns?(name_servers)

  domain_has_ns = FALSE

  name_servers.each do |ns|

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
      <tr><td>Domain</td><td>Has VCN IP?</td>
      <td>IP Addresses</td>
      <td>Has VCN Name Server?</td>
      <td>Name Servers</td>
</tr>
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
# Print Domain                                                #
#-------------------------------------------------------------#
def print_domain(domain)

  print " <tr><td>#{domain.chomp}</td>\n"

end

#-------------------------------------------------------------#
# Prints DNS IP Information                                   #
#-------------------------------------------------------------#
def print_dns(domain)

  print "<td>"

  if DNS_OFF == FALSE

    ip_results = domain_has_ip?(domain.to_s.chomp)

    if ip_results[:retry_error] == FALSE
      if ip_results[:has_ip] != TRUE
        print " no "
      else
        print " yes "
      end
    end

  else

    print " off "

  end

  print "</td>\n<td>"



  if DNS_OFF == FALSE

    ip_results[:list].each do |ip|
      puts ip
    end

  else

    print " off "

  end

  print "</td></tr>"

end



#-------------------------------------------------------------#
# Prints name server information                              #
#-------------------------------------------------------------#
def print_ns(domain)

  print "</td>\n<td>"

  if NS_OFF == FALSE

    ns_results = get_name_servers(domain)

    if ns_results[:has_error] == FALSE
      if !domain_has_ns?(ns_results[:list])
        print " no "
      else
        print " yes "
      end
    end

  else

    print " off "

  end

  print "</td>\n<td>"

  if NS_OFF == FALSE

      ns_results[:list].each do |ns|
      print ns + "<br />"
    end

  else
      print " off "

  end

end

#-------------------------------------------------------------#
#                           Main                              #
#-------------------------------------------------------------#

file = File.new(DOMAIN_NAMES_FILE, "r")

print_table_head

while (domain = file.gets)

  print_domain(domain)
  print_dns(domain)
  print_ns(domain)

end

print_table_end

file.close
