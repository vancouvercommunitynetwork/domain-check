#!/usr/local/bin/python

import sys
import os
import logging
import random
import csv      # Allows handle CSV files
import codecs   # UTF-8 encoded BOM. in order to get rid of \xef\xbb\xbf in a list read from a file
import socket   # Low-level networking interface
import numpy    # Data manipulation
import shutil   # High-level file operations
import whois    # Whois querying and parsing of domain registration information.

# System variables:
# currentDirectory = os.getcwd()                            # get current working directory
# 'domains.csv'                                             # Filename for domain/url list
# 'ip_list.csv'                                             # Filename for ip list
# 'logging.log'                                             # Filename for logs
# 'vcn_ip_range.csv'                                        # Filename for list with VCN IP range
# 'invalid_ip.csv'                                          # Filename for invalid ips list
# file_path = os.path.join(os.getcwd(), domainList_file)    # Path to domains.cs
# file_path = os.path.join(os.getcwd(), ipList_file)        # Path to ip_list.csv
# file_path = os.path.join(os.getcwd(), template_file)      # Path to template.csv
# file_path = os.path.join(os.getcwd(), ipList_file)        # Path to vcn_ip.range.csv
# INVALID_IP = os.path.join(os.getcwd(),'invalid_ip.csv')   # List with invalid ips


def get_file_path(fileName):
    currentDirectory = os.getcwd() # get current working directory
    file_path = os.path.join(os.getcwd(), fileName)  #Path to CSV file
    print("\nFile name: " + fileName + "\nFile directory: " + file_path + "\n")
    return file_path

domainList_file = get_file_path('domains.csv')    #Domain list file
ipList_file = get_file_path('ip_list.csv')        #IP list file
template_file = get_file_path('template.csv')     #empty template file
LOG_FILENAME = get_file_path('logging.log')       #log file
VCN_IP_RANGE = get_file_path('vcn_ip_range.csv')  #List with vcn ips
#INVALID_IP  = get_file_path('invalid_ip.csv')     #List with invalid ips
#VALID_IP  = get_file_path('valid_ip.csv')     #List with invalid ips


shutil.copyfile(template_file, ipList_file)                   #Copy clean template file to ipList_file
print '\nA new CSV file is created under: ', ipList_file, '\n'

# Write log messages to a log file and the console at the same time:
logger = logging.getLogger(LOG_FILENAME)
#LOG_FILENAME = '/home/notroot/Desktop/Domain-check/logging.log'

logging.basicConfig(filename=LOG_FILENAME, 
                    level=logging.INFO, 
                    format='%(asctime)s - %(levelname)s - %(message)s', 
                    datefmt='%Y-%m-%d %H:%M:%S')

logging.debug('This is a debug message')
logging.info('This is an info message')
logging.warning('This is a warning message')
logging.error('This is an error message')
logging.critical('This is a critical error message')
# End logging.


# Create a full list of VCN ips:
def create_vcn_ip_csv(VCN_IP_RANGE):
    VCN_ip_list = {}
    ip = 1 #start index from 1
    with codecs.open(VCN_IP_RANGE,'w','utf-8-sig') as csvVCNip: #Open file
        writer = csv.writer(csvVCNip)   #Read file
        startIP = '207.102.64.'
        while ip < 255:
            IPstr = str(ip)             #convert integer to string
            vcnIP = startIP + IPstr
            writer.writerow([vcnIP])    #write generated ip address
            VCN_ip_list[ip] = vcnIP
            ip += 1                     #increase index by 1
    return VCN_ip_list
    csvVCNip.close()                    #close the file
    
VCN_ip_list = create_vcn_ip_csv(VCN_IP_RANGE) #call create_vcn_ip_csv function

num = len(VCN_ip_list) #A total number of ips in the list
print '\nA total number of IP to validate: ', num, '\n'


# Read from csv file function:
def read_csv(domainList_file):
    domains = {} # smart list of domain names - it has an index starts from 1
    ip_list = {}
    i = 0
    with codecs.open(domainList_file, 'rU', 'utf-8-sig') as csvFile: #Open file
        reader = csv.reader(csvFile)                           #Read file
        print '\nConverting domain names to IP addresses:\n'
        for row in reader:
            if not "Domain_name" in row:                       #Print all except "Domain name" label
                domainName = row[0]                            #Print each row from CSV file - only from domain name column: row[0]
                i += 1                                         #indexing
                domains[i] = domainName
                domainIP = socket.gethostbyname(domains[i])    #Get website IP
                ip_list[i] = domainIP
                print domainName, ' > ', domainIP
    return domains
    return ip_list
    csvFile.Close()

domains = read_csv(domainList_file) #call read_csv function in order to create smart domains list
ip_list = read_csv(domainList_file) #call read_csv function in order to create smart IPs list

n = len(domains) #A total number of domain names in the list
I = len(ip_list) #A total number of IPs in the list

print '\nA total number of domain names in the test list: ', n, '\n'
print '\nA total number of IPs in the test list: ', I, '\n'


# Write to csv file function:
def write_csv(ipList_file):
    with codecs.open(ipList_file,'a','utf-8-sig') as csvFile2: #Open file
        writer = csv.writer(csvFile2) #Read file
        i = 1                         #start index from 1
        for row in domains:           #start loop
            domainIP = socket.gethostbyname(domains[i]) #Get IP
            isValid = 0
            with codecs.open(VCN_IP_RANGE,'r','utf-8-sig') as csvFile3:
                reader = csv.reader(csvFile3)
                for row in reader:
                    if row[0] == domainIP: #verify if domain IP is in VCN range
                        print 'Found valid IP: ' + domains[i] + ': '+ row[0] + " matches " + domainIP
                        isValid = 1
            csvFile3.close() #close the file
            if isValid == 0:
                writer.writerow([domains[i], domainIP, 'invalid'])     #Invalid IP - write domain name, ip address and INVALID comment
            else:
                writer.writerow([domains[i], domainIP, 'valid'])     #write domain name and ip address, ip address and VALID comment
            i += 1      #increase index by 1
    csvFile2.close()    #close the file
    
domains = write_csv(ipList_file) #call write_csv function

#THE END