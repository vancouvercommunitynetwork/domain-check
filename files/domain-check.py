#!/usr/local/bin/python

import logging
import sys
import csv # allows handle CSV files
import codecs # UTF-8 encoded BOM. in order to get rid of \xef\xbb\xbf in a list read from a file
import socket
# import dns.resolver #import the DNS resolver module

# Write log messages to a log file and the console at the same time:
logger = logging.getLogger('/home/notroot/Desktop/Domain-check/domain-check.py')
LOG_FILENAME = '/home/notroot/Desktop/Domain-check/logging.log'

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


# Read file and store the information as a list:

LINUX_domainListPath = '/home/notroot/Desktop/Domain-check/domains.csv'
LINUX_domainListPath_2 = '/home/notroot/Desktop/Domain-check/domains_2.csv'
# WIN_domainListPath = 'C:/Users/%username%/Desktop/Domain-check/domains.csv'     


with codecs.open(LINUX_domainListPath, "r", encoding="utf-8-sig") as domainList: # Open/read CSV file and assign it to a variable (store in memory as a variable), "r"- stands for READ MODE, "w"- stands for WRITE MODE
    domainListReader = csv.reader(domainList) # Open just imported a new CSV file (domainList) and put all data in to domainListReader variable
    newDomainList = [] # Create an empty list in order to store every single row from the domainListReader variable, this allows to access to individual values from the list
    for row in domainListReader: # Start loop >>> saving value from the domainListReader in to newDomainLis
        if len (row) != 0:
            newDomainList = newDomainList + [row]
domainList.close() # close the file

print(newDomainList) # Display output from the console - debug purposes only.

# List of questions in order to put a new information and update the CSV file:

# domainName = socket.gethostbyname('ikostan.com')
#clientEmail = raw_input("Enter client email: ") 

# Write in to SCV file:
with codecs.open(LINUX_domainListPath_2, "a", encoding="utf-8-sig") as domainList: # Write in to CSV file, "a"- stands for APPEND MODE
    domainListWriter = csv.writer(domainList)
    domainListWriter.writerow([domainName]) # import a new info in to CSV file
domainList.close() # close the file

print(newDomainList) # Display output from the console - debug purposes only.

