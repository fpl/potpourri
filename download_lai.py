#!/usr/bin/env python3
#
# This script is used to download LAI 10m.
# Note that this depends on a my hda package for ECMWF provided package.
#

from hda import Client, Configuration
from pathlib import Path
import json

# Default location expected by hda package
hdarc = Path(Path.home() / '.hdarc')

# Create it only if it does not already exists
if not hdarc.is_file():
	import getpass
	USERNAME = input('Enter your username: ')
	PASSWORD = getpass.getpass('Enter your password: ')

	with open(Path.home() / '.hdarc', 'w') as f:
		f.write(f'user:{USERNAME}\n')
		f.write(f'password:{PASSWORD}\n')

# This is to make logging verbose
import logging
logging.getLogger().addHandler(logging.StreamHandler())
logging.getLogger().setLevel(logging.INFO)

hda_client = Client()
# The JSON query loaded in the "query" variable
# This is the obsolete version presented in the webapp, but it is still
# supported.
query = {
	"datasetId": "EO:EEA:DAT:CLMS_HRVPP_VI",
	"boundingBoxValues": [
	{
		"name": "bbox",
		"bbox": [
	      	15.027444,
	      	41.03043,
	      	16.282455,
	      	41.982819
		]
	}
	],
	"dateRangeSelectValues": [
	{
		"name": "temporal_interval",
		"start": "2024-03-31T00:00:00.000Z",
		"end": "2024-12-31T00:00:00.000Z"
	}
	],
	"stringChoiceValues": [
	{
		"name": "productType",
		"value": "LAI"
	}
	]
}

# Ask the result for the query passed in parameter
matches = hda_client.search(query)

# List the results
print(matches)

#print(len(hda_client.datasets()))

#json_formatted_str = json.dumps(hda_client.datasets(limit=1))
#print(json_formatted_str)

# Download results in a directory (e.g. '/tmp')
# Create the directory if it doesn't exist since version 1.14 of hda
matches.download(download_dir="/ocean/queue/LAI")

exit(0);
