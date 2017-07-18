#!/usr/bin/env python
import json, urllib2, hashlib, re, os, sys

# Get the current working directory
cwd = os.path.dirname(os.path.abspath(__file__))

# First we need to get the version data
data = json.loads(urllib2.urlopen('https://www.tenable.com/plugins/os.json').read())

# If the user just requested what the current Nessus version is, spit it out and bail.
if len(sys.argv) > 1 and sys.argv[1] == 'version':
	print data['version']
	exit(0)

# Now we need to find the RHEL7 Nessus package formt he JSON file.
for opsys in data['categories']:
	if opsys['name'] == 'Linux':
		for package in opsys['files']:
			if package['type'] == 'nessus' and package['os'] == 'es7':
				nessus = package

# Nexts lets get the download token from the page
token = re.findall(
	r'<div id="timecheck" class="hidden">([\w\d]+)</div>', 
	urllib2.urlopen('https://www.tenable.com/products/nessus/select-your-operating-system').read()
)[0]

# Now lets download the file and save it to a known location
with open(os.path.join(cwd, 'Nessus.rpm'), 'wb') as rpm:
	rpm.write(urllib2.urlopen(
		'http://downloads.nessus.org/nessus3dl.php?file={}&licence_accept=yes&t={}'.format(
			nessus['file'],
			token
		)).read())

# And lastly, lets verify that the download worked
filehash = hashlib.sha256()
with open(os.path.join(cwd, 'Nessus.rpm')) as rpm:
	filehash.update(rpm.read())
if filehash.hexdigest() != nessus['sha256']:
	print 'Download Verification Failed!'
	exit(1)
else:
	print 'Nessus Version: {}\nDownloaded RPM: {}'.format(data['version'], nessus['file'])