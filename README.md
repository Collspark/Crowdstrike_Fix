
CrowdStrike Bad Update Fix
This script addresses the issue caused by a bad CrowdStrike update by deleting a specific problematic file on multiple servers. The script processes a list of IP addresses, connects to each server, and attempts to delete the specified file.

How It Works
The script Invoke-ContinuousDeletion.ps1 performs the following steps:

Reads a list of IP addresses from a text file.
Processes the IP addresses in batches, with a maximum of 5 concurrent jobs.
Connects to each server and deletes the file C-00000291*18.sys located in the C:\Windows\System32\drivers\CrowdStrike directory.
Waits for all jobs in the batch to complete or until a timeout of 60 seconds is reached.
Logs the progress and handles any errors encountered during the file deletion process.
Requirements
PowerShell 5.0 or later
Appropriate permissions to delete files on the target servers
Usage
Clone this repository to your local machine:

sh
Copy code
git clone https://github.com/yourusername/crowdstrike-bad-update-fix.git
cd crowdstrike-bad-update-fix
Prepare a text file containing the list of IP addresses, one per line:

python
Copy code
10.xx.x.xx
10.xx.x.xx
...
Modify the path to your text file in the script or place the file at C:\temp\NewList.txt.

Run the PowerShell script:

powershell
Copy code
.\Invoke-ContinuousDeletion.ps1
