# echoCopy
# createRoboCopyJobs.ps1

This PowerShell script is designed to manage and execute multiple Robocopy jobs concurrently, optimizing the copy process for efficiency. Here's a detailed breakdown of its components and functionality:

1. **Define Robocopy Jobs**: 
   - `$robocopyJobs`: This array stores multiple script blocks. Each block represents a Robocopy command, which is used for copying and mirroring directories. The script includes two example Robocopy commands, each specifying different source and destination directories, with a set of common flags and a logging path.

2. **Set Maximum Concurrent Jobs**:
   - `$maxConcurrentJobs`: Defines the maximum number of Robocopy jobs that can run concurrently. In this script, it's set to 25.

3. **Function to Start a Job**:
   - `Start-JobFromQueue`: A function that takes a script block as a parameter and starts a background job with that script block.

4. **Initialize Timer and Job Queue**:
   - `$startTime`: Records the start time of the entire operation.
   - `$jobQueue`: A queue to store the Robocopy job script blocks, ensuring they are processed in order.

5. **Enqueue Robocopy Jobs**:
   - The script blocks in `$robocopyJobs` are enqueued into `$jobQueue`.

6. **Manage Running Jobs**:
   - `$runningJobs`: An array to keep track of currently running jobs.
   - The script starts the initial batch of jobs based on the lesser of `$maxConcurrentJobs` or the number of jobs in the queue.
   
7. **Monitor and Manage Jobs Loop**:
   - The script enters a loop where it continuously checks the state of running jobs.
   - Completed jobs are removed from the `$runningJobs` array, their output is received, and they are properly removed from the job list.
   - If there are jobs remaining in the queue and the number of running jobs is below the maximum, new jobs are dequeued and started.
   - The script pauses for 5 seconds between each loop iteration to avoid excessive resource consumption.

8. **Calculate and Display Execution Time**:
   - After all jobs are completed, the script stops the timer and calculates the total execution time.
   - The total execution time is displayed in a `HH:MM:SS` format.

This script efficiently manages multiple file copy operations using Robocopy, allowing for simultaneous job execution, thus speeding up the overall process. It's particularly useful in scenarios where large numbers of files need to be copied or mirrored across directories or drives.
