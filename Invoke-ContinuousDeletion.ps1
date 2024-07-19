function Invoke-ContinuousDeletion {
    param (
        [string[]]$IpAddresses
    )

    $maxConcurrentJobs = 5  # Define the maximum number of concurrent jobs
    $maxTimeoutSeconds = 60  # Maximum timeout for each job in seconds

    $remainingIpAddresses = $IpAddresses  # Initialize the remaining IP addresses to process

    while ($remainingIpAddresses.Count -gt 0) {
        $batchSize = [Math]::Min($remainingIpAddresses.Count, $maxConcurrentJobs)
        $batch = $remainingIpAddresses[0..($batchSize - 1)]
        $remainingIpAddresses = if ($batchSize -lt $remainingIpAddresses.Count) { 
                                    $remainingIpAddresses[$batchSize..($remainingIpAddresses.Count - 1)] 
                                } else { 
                                    @() 
                                }

        Write-Host "Starting batch processing for $($batch.Count) IP addresses..."

        $startTime = Get-Date

        foreach ($line in $batch) {
            Write-Host "Starting job for IP address: $line"

            Start-Job -ScriptBlock {
                param ($line)

                $fileToDelete = "\\$line\c`$\Windows\System32\drivers\CrowdStrike\C-00000291*18.sys"

                try {
                    # Perform deletion
                    del $fileToDelete -Force
                    Write-Output "File $fileToDelete deleted successfully on $line."
                } catch {
                    try {
                        del $fileToDelete
                    } catch {
                        Write-Error "Failed to delete file ${fileToDelete} on ${line}: $_"
                    }
                }
            } -ArgumentList $line
        }

        # Wait for all jobs in the current batch to complete, or timeout
        $timeoutReached = $false
        $timeout = $startTime.AddSeconds($maxTimeoutSeconds)

        while ((Get-Job | Where-Object { $_.State -eq 'Running' }).Count -gt 0 -and !$timeoutReached) {
            if ([DateTime]::Now -gt $timeout) {  # Compare dates using `-gt` for greater than
                $timeoutReached = $true
            }
            Write-Host "Waiting for jobs to complete..."
            Start-Sleep -Seconds 10
        }

        if ($timeoutReached) {
            Write-Host "Timeout reached while waiting for jobs to complete."
            # Stop all running jobs
            Get-Job | Where-Object { $_.State -eq 'Running' } | Stop-Job -Force
        } else {
            Write-Host "All jobs in the batch completed."
        }

        # Check for job errors
        $failedJobs = Get-Job | Where-Object { $_.State -eq 'Failed' }
        if ($failedJobs.Count -gt 0) {
            Write-Host "Some jobs failed. Stopping script."
            Write-Debug "Failed jobs: $($failedJobs | Format-Table -Property Id, Name, State, HasMoreData, Location, Command)"
            break
        }

        # Cleanup: Remove all completed jobs
        Get-Job | Remove-Job -Force
    }

    Write-Host "All IP addresses processed."
}

# Now define the list of IP addresses in a variable
$ipAddresses = Get-Content -Path "C:\temp\NewList.txt"

# Invoke the continuous deletion function
Invoke-ContinuousDeletion -IpAddresses $ipAddresses
