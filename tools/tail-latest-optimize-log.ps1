param (
    [string]$QueueDir = ".\..\pbgui\opt_v7_queue"
)

# Check if the queue directory exists
if (-Not (Test-Path $QueueDir)) {
    Write-Error "The directory '$QueueDir' does not exist."
    exit
}

# Get the most recently modified log file in the directory
$latestLogFile = Get-ChildItem -Path $QueueDir -Filter "*.log" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1

if (-Not $latestLogFile) {
    Write-Error "No log files found in the directory '$QueueDir'."
    exit
}

# Tail the most recently modified log file without locking it
Write-Output "Tailing file: $($latestLogFile.FullName)"
Get-Content -Path $latestLogFile.FullName -Wait -Tail 0