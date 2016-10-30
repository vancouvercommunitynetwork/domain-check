#!/usr/local/bin/python

import sys
import os
import random
import csv      # allows handle CSV files
import codecs   # UTF-8 encoded BOM. in order to get rid of \xef\xbb\xbf in a list read from a file
import socket   # Low-level networking interface
import numpy    #Data manipulation
import shutil   #High-level file operations

# System variables:
# currentDirectory = os.getcwd()                            # get current working directory
# 'domains.csv'                                             # Filename for domain/url list
# 'ip_list.csv'                                             # Filename for ip list
# file_path = os.path.join(os.getcwd(), domainList_file)    # Path to domains.cs
# file_path = os.path.join(os.getcwd(), ipList_file)        # Path to ip_list.csv
# file_path = os.path.join(os.getcwd(), template_file)      # Path to template.csv


def get_file_path(fileName):
    currentDirectory = os.getcwd() # get current working directory
    file_path = os.path.join(os.getcwd(), fileName)  #Path to domains.cs
    print("\nFile name: " + fileName + "\nFile directory: " + file_path + "\n")
    return file_path

domainList_file = get_file_path('domains.csv')  #Domain list file
ipList_file = get_file_path('ip_list.csv')      #IP list file
template_file = get_file_path('template.csv')    #empty template file

shutil.copyfile(template_file, ipList_file)                   #Copy clean template file to ipList_file
print '\nA new list is created under: ', ipList_file, '\n'

# Read from csv file function:
def read_csv(domainList_file):
    domains = {} # smart list of domain names - it has an index starts from 1
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
                print domainName, ' > ', domainIP
    return domains
    csvFile.Close()

domains = read_csv(domainList_file) #call read_csv function

n = len(domains) #A total number of domain names in the list
print '\nA total number of domain names: ', n, '\n'

# Write to csv file function:
def write_csv(ipList_file):
    with codecs.open(ipList_file,'a','utf-8-sig') as csvFile2: #Open file
        writer = csv.writer(csvFile2) #Read file
        i = 1 #start index from 1
        for row in domains: #start loop
            domainIP = socket.gethostbyname(domains[i]) #Get IP
            writer.writerow([domains[i], domainIP])     #write domain name and ip address
            i += 1 #increase index by 1
    csvFile2.close() # close the file
    
domains = write_csv(ipList_file) #call write_csv function

