 #!/usr/bin/python
 # -*- coding: utf-8 -*-

try:
	import requests
except ImportError:
	print('requests module is missing')
	print('Install through: \nsudo easy_install pip\npip install requests')
	raise Exception('requests module missing')

import argparse
import urllib
import json
import random
import string
import re
import os

parser = argparse.ArgumentParser(prog='PROG')
parser.add_argument('-i', '--input', required=True, help='plain text input')
args = parser.parse_args()

print(args.input)


# Create the verses list
juzlist = []
with open(args.input) as fp:
	for line in fp.readlines():
		if "۞" in line:
			matchObj = re.search( r"([0-9+\|])+([0-9+\|])", line)
	 		# juzlist.append(line)
	 		# print(line)
	 		if matchObj:
	 			split  = matchObj.group().split('|', 2)
   				print "matchObj.group() : ", matchObj.group()
   				print "split : ", split
   				# juzlist.append(matchObj)
			else:
   				print "No match!!"
print(len(juzlist))


