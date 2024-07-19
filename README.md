CrowdStrike Bad Update Fix
This script addresses the issue caused by a bad CrowdStrike update by deleting a specific problematic file on multiple servers. The script processes a list of IP addresses, connects to each server, and attempts to delete the specified file.

How It Works
The script Invoke-ContinuousDeletion.ps1 performs the following steps:

Reads a list of IP addresses from a text file.
Processes the IP addresses in batches, with a maximum of 5 concurrent jobs.
Connects to each server and deletes the file C-00000291*18.sys located in the C:\Windows\System32\drivers\CrowdStrike directory.
Waits for all jobs in the batch to complete or until a timeout of 60 seconds is reached.
Logs the progress and handles any errors encountered during the file deletion process.
