# Function to show a FolderBrowserDialog and return the selected path
function Get-FolderPath {
    param (
        [string]$Description
    )

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = $Description
    $result = $folderBrowser.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $folderBrowser.SelectedPath
    } else {
        return $null
    }
}

# Prompt for the source directory using FolderBrowserDialog
$Description = "Select the source directory for robocopy jobs"
$SourcePath = Get-FolderPath -Description $Description

# Exit if no folder is selected
if ([string]::IsNullOrWhiteSpace($SourcePath)) {
    Write-Host "No source folder selected. Exiting script."
    Exit
}

# Prompt for the destination directory using FolderBrowserDialog
$Description = "Select the destination directory for robocopy jobs"
$DestinationPath = Get-FolderPath -Description $Description

# Exit if no folder is selected
if ([string]::IsNullOrWhiteSpace($DestinationPath)) {
    Write-Host "No destination folder selected. Exiting script."
    Exit
}

# Extract the folder name from the SourcePath
$folderName = Split-Path $SourcePath -Leaf

# Set the path for the batch file with a timestamp and folder name
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BatchFile = "D:\Fuji\RobocopyJobs_${folderName}_$timestamp.txt"

# Option to include exclusion of "$RECYCLE.BIN" directory
$ExcludeRecycleBin = $true

# Function to create robocopy jobs based on directory structure
function Create-RobocopyJobs {
    param (
        [string]$Path,
        [string]$Destination,
        [string]$BatchFilePath,
        [bool]$ExcludeRecycleBin
    )

    # Get top-level directories
    $Directories = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue

    foreach ($Directory in $Directories) {
        # Construct destination path
        $destPath = Join-Path -Path $Destination -ChildPath $Directory.Name

        # Create a unique log directory for each robocopy job
        $logDirectory = "D:\Fuji\Logs\" + $folderName + "_" + $Directory.Name
        if (-not (Test-Path $logDirectory)) {
            New-Item -ItemType Directory -Path $logDirectory | Out-Null
        }

        # Generate a timestamped log file name in the unique directory
        $logFileName = $logDirectory + "\" + $Directory.Name + "-MT64-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".log"

        # Build the robocopy command with 'start' for asynchronous execution
        $robocopyCmd = "start robocopy `"$($Directory.FullName)`" `"$destPath`" /mir /MT:64 /e /zb /r:0 /w:0 /copy:dat /xo /is"

        if ($ExcludeRecycleBin) {
            $robocopyCmd += ' /xd "$RECYCLE.BIN"'
        }

        $robocopyCmd += " /np /log:`"$logFileName`""

        # Write the robocopy command to the batch file
        $robocopyCmd | Out-File -FilePath $BatchFilePath -Append
    }
}

# Create robocopy jobs in the batch file
Create-RobocopyJobs -Path $SourcePath -Destination $DestinationPath -BatchFilePath $BatchFile -ExcludeRecycleBin $ExcludeRecycleBin

# Completion message
Write-Host "Robocopy jobs for $SourcePath to $DestinationPath have been created in $BatchFile"
