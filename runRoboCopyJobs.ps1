# Define Robocopy jobs as script blocks
$robocopyJobs = @(
    {robocopy "M:\Test\Dir1" "N:\Test\Dir1" /mir /MT:64 /e /zb /r:0 /w:0 /copy:dat /xo /is /xd "$RECYCLE.BIN" /np /log:"D:\Fuji\Logs\Test_Dir1\Dir1-MT64-20231229-073258.log"},
    {robocopy "M:\Test\Dir999" "N:\Test\Dir2" /mir /MT:64 /e /zb /r:0 /w:0 /copy:dat /xo /is /xd "$RECYCLE.BIN" /np /log:"D:\Fuji\Logs\Test_Dir2\Dir2-MT64-20231229-073300.log"}

    # Add more Robocopy commands as needed
)

# Set the maximum number of concurrent jobs
$maxConcurrentJobs = 25

# Function to start a job from the queue
function Start-JobFromQueue {
    param([scriptblock]$jobScriptBlock)
    Start-Job -ScriptBlock $jobScriptBlock
}

# Start the timer
$startTime = Get-Date


# Queue for jobs
$jobQueue = [System.Collections.Generic.Queue[scriptblock]]::new()

# Enqueue all jobs
$robocopyJobs.ForEach({ $jobQueue.Enqueue($_) })

# List to keep track of running jobs
$runningJobs = @()

# Start initial batch of jobs
for ($i = 0; $i -lt $maxConcurrentJobs -and $jobQueue.Count -gt 0; $i++) {
    $runningJobs += Start-JobFromQueue -jobScriptBlock $jobQueue.Dequeue()
}

# Monitor and manage jobs
do {
    # Check for any completed jobs and remove them from the list
    foreach ($job in $runningJobs) {
        if ($job.State -ne 'Running') {
            $runningJobs = $runningJobs | Where-Object { $_.Id -ne $job.Id }
            $job | Receive-Job
            Remove-Job -Job $job

            # Start a new job from the queue if available
            if ($jobQueue.Count -gt 0) {
                $runningJobs += Start-JobFromQueue -jobScriptBlock $jobQueue.Dequeue()
            }
        }
    }

    # Sleep for a bit before checking again
    Start-Sleep -Seconds 5
} while ($runningJobs.Count -gt 0)

# Stop the timer and calculate the elapsed time
$endTime = Get-Date
$elapsedTime = $endTime - $startTime

# All jobs are completed at this point

# Output the total execution time
Write-Host "Total Execution Time: $($elapsedTime.Hours):$($elapsedTime.Minutes):$($elapsedTime.Seconds)"
