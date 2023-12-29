# Project EchoCopy
Project EchoCopy was developed to streamline the process of transferring vast amounts of data within Azure File Shares. This project specifically targets scenarios involving the copying of hundreds of terabytes, encompassing millions of files across thousands of directories. While Azure Data Box is typically the go-to solution for such extensive data transfer tasks, Project EchoCopy is designed for situations where Azure Data Box is not a viable option.

This PowerShell script is designed to manage and execute multiple file copy jobs using Robocopy, a robust file copy utility for Windows. Here's a detailed breakdown of what the script does:

Defining Robocopy Jobs: The $robocopyJobs array holds script blocks, each containing a Robocopy command to copy files from one directory to another. These script blocks specify source and destination directories, options for copying, and log file paths. For example:

/mir: Mirrors the source directory to the destination.
/MT:64: Uses 64 threads for the copy operation.
/e: Copies all subdirectories, including empty ones.
/zb: Uses restartable mode; if access denied, uses backup mode.
/r:0 and /w:0: Specifies no retries and no wait time if a file can't be copied.
/copy:dat: Copies data, attributes, and timestamps.
/xo and /is: Excludes older files and includes same files.
/xd: Excludes directories (like $RECYCLE.BIN).
/np: Turns off progress display.
/log: Specifies the path for the log file.
Setting Maximum Concurrent Jobs: $maxConcurrentJobs is set to 25, indicating that up to 25 Robocopy jobs can run concurrently.

Start-JobFromQueue Function: This function is defined to start a job from the job queue using PowerShell's Start-Job cmdlet.

Initializing Variables:

$startTime: Records the start time of the script execution.
$jobQueue: A queue to manage the Robocopy job script blocks.
$runningJobs: An array to keep track of currently running jobs.
Enqueuing Jobs: All the Robocopy jobs defined in $robocopyJobs are enqueued into $jobQueue.

Starting Initial Batch of Jobs: The script starts the first batch of jobs (up to $maxConcurrentJobs) by dequeuing from $jobQueue and executing them.

Monitoring and Managing Jobs:

The script enters a loop where it continuously monitors the running jobs.
Completed jobs are removed from $runningJobs, and their output is received. These jobs are then removed from the job pool.
If there are jobs in the queue, new jobs are started to maintain the maximum concurrent jobs.
The script sleeps for 5 seconds before repeating the monitoring process.
Finalizing and Reporting:

Once all jobs are completed, the script stops the timer and calculates the total elapsed time.
It then outputs the total execution time in hours, minutes, and seconds.
Overall, this script effectively manages multiple file copy tasks concurrently, using a queue-based approach to limit the number of simultaneous operations, which can be particularly useful for large-scale file transfer operations.
