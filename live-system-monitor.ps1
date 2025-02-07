<#
.SYNOPSIS
    Live System Resource Monitor Dashboard
.DESCRIPTION
    A professional-grade PowerShell script that provides real-time monitoring of system resources
    including CPU, Memory, Disk usage, and top CPU-consuming processes with a visual interface.
.NOTES
    Author: IT Samurai Teacher
    YouTube: https://www.youtube.com/@ITSamuraiTeacher
    Website: https://samuraiteacher.com
    Version: 1.0.0
    Created: February 2025
.LINK
    Tutorial Video: https://www.youtube.com/@ITSamuraiTeacher
    GitHub: https://github.com/YourUsername/live-system-monitor
#>

# Script Configuration
$script:CONFIG = @{
    RefreshRate = 2  # Update interval in seconds
    BarSize = 25     # Size of progress bars
    DriveToMonitor = 'C:'  # Drive to monitor
}

# Function: Set console colors
function Show-ConsoleColors {
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "White"
    Clear-Host
}

# Function: Write colored output
function Write-ColorOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color -NoNewline
}

# Function: Create visual progress bar
function Write-ProgressBar {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Percentage,
        [int]$BarSize = $script:CONFIG.BarSize
    )
    
    $filled = [math]::Round(($BarSize * $Percentage) / 100)
    $empty = $BarSize - $filled
    
    # Choose color based on percentage thresholds
    $color = switch($Percentage) {
        {$_ -gt 90} { "Red" }     # Critical level
        {$_ -gt 70} { "Yellow" }  # Warning level
        default { "Green" }        # Normal level
    }
    
    Write-ColorOutput "[" "White"
    Write-ColorOutput ("■" * $filled) $color
    Write-ColorOutput ("-" * $empty) "DarkGray"
    Write-ColorOutput "] $Percentage%" "White"
}

# Function: Collect system metrics
function Get-LiveSystemMetrics {
    # Get CPU Usage
    $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    
    # Get Memory Usage
    $os = Get-Ciminstance Win32_OperatingSystem
    $memoryTotal = $os.TotalVisibleMemorySize / 1MB
    $memoryFree = $os.FreePhysicalMemory / 1MB
    $memoryUsed = $memoryTotal - $memoryFree
    $memoryPercentage = [math]::Round(($memoryUsed / $memoryTotal) * 100, 2)
    
    # Get Disk Usage
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$($script:CONFIG.DriveToMonitor)'"
    $diskTotal = $disk.Size / 1GB
    $diskFree = $disk.FreeSpace / 1GB
    $diskUsed = $diskTotal - $diskFree
    $diskPercentage = [math]::Round(($diskUsed / $diskTotal) * 100, 2)
    
    # Get Top CPU Processes
    $topProcesses = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5

    return @{
        CPU = [math]::Round($cpu, 2)
        MemoryUsed = [math]::Round($memoryUsed, 2)
        MemoryTotal = [math]::Round($memoryTotal, 2)
        MemoryPercentage = $memoryPercentage
        DiskUsed = [math]::Round($diskUsed, 2)
        DiskTotal = [math]::Round($diskTotal, 2)
        DiskPercentage = $diskPercentage
        TopProcesses = $topProcesses
    }
}

# Function: Display live dashboard
function Show-LiveDashboard {
    $iterations = 0
    
    while ($true) {
        $metrics = Get-LiveSystemMetrics
        Show-ConsoleColors
        
        # Header with Attribution
        Write-ColorOutput "`n╔══════════════════════════════════════════════════════════╗`n" "Cyan"
        Write-ColorOutput "║           LIVE SYSTEM MONITOR - IT SAMURAI TEACHER        ║`n" "Cyan"
        Write-ColorOutput "║        youtube.com/@ITSamuraiTeacher | samuraiteacher.com ║`n" "Yellow"
        Write-ColorOutput "╠══════════════════════════════════════════════════════════╣`n" "Cyan"
        
        # CPU Section
        Write-ColorOutput "║  CPU Usage:    " "Cyan"
        Write-ProgressBar $metrics.CPU
        Write-ColorOutput "`n" "White"
        
        # Memory Section
        Write-ColorOutput "║  Memory Usage: " "Cyan"
        Write-ProgressBar $metrics.MemoryPercentage
        Write-ColorOutput "  ($([math]::Round($metrics.MemoryUsed, 2))GB / $([math]::Round($metrics.MemoryTotal, 2))GB)`n" "Gray"
        
        # Disk Section
        Write-ColorOutput "║  Disk Usage:   " "Cyan"
        Write-ProgressBar $metrics.DiskPercentage
        Write-ColorOutput "  ($([math]::Round($metrics.DiskUsed, 2))GB / $([math]::Round($metrics.DiskTotal, 2))GB)`n" "Gray"
        
        # Process Section Header
        Write-ColorOutput "╠══════════════════════════════════════════════════════════╣`n" "Cyan"
        Write-ColorOutput "║  TOP CPU PROCESSES                                       ║`n" "Cyan"
        Write-ColorOutput "╠══════════════════════════════════════════════════════════╣`n" "Cyan"
        
        # Process List
        foreach ($process in $metrics.TopProcesses) {
            $cpuUsage = [math]::Round($process.CPU, 2)
            $memoryMB = [math]::Round($process.WorkingSet / 1MB, 2)
            Write-ColorOutput "║  " "Cyan"
            Write-ColorOutput ("{0,-30}" -f $process.ProcessName) "Yellow"
            Write-ColorOutput " CPU: " "Gray"
            Write-ColorOutput ("{0,6:N2}%" -f $cpuUsage) "White"
            Write-ColorOutput " MEM: " "Gray"
            Write-ColorOutput ("{0,8:N2} MB" -f $memoryMB) "White"
            Write-ColorOutput " ║`n" "Cyan"
        }
        
        # Footer
        Write-ColorOutput "╚══════════════════════════════════════════════════════════╝`n" "Cyan"
        
        # Update counter
        $iterations++
        Write-ColorOutput "  Refresh Count: " "Gray"
        Write-ColorOutput "$iterations" "White"
        Write-ColorOutput " | Press Ctrl+C to exit`n" "Gray"
        
        Start-Sleep -Seconds $script:CONFIG.RefreshRate
    }
}

# Script Entry Point
Clear-Host
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Live System Monitor - v1.0.0           ║" -ForegroundColor Cyan
Write-Host "║     Created by IT Samurai Teacher         ║" -ForegroundColor Yellow
Write-Host "║     youtube.com/@ITSamuraiTeacher         ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "`nInitializing..." -ForegroundColor Cyan
Start-Sleep -Seconds 2
Show-LiveDashboard
