#Switches Monitors to 1080p For Sunshine Server

param (
    [switch]$Undo,
    [switch]$OnlyMonitor3,
    [switch]$Print,
    [switch]$OpenTool
)

$scriptFolder = $PSScriptRoot

$monitorToolRoot = "$scriptFolder\..\resources\MultiMonitorTool"
$monitorToolPath = "$monitorToolRoot\MultiMonitorTool.exe"
$monitorConfigsPath = "$monitorToolRoot\configs"
$monitor3OnlyConfig = "only_monitor_3.cfg"
$undoConfig= "undo.cfg"

function Main {
    if($OpenTool){
        & $monitorToolPath
    }
    elseif ($OnlyMonitor3) {
        LoadMonitorConfig -config_name $monitor3OnlyConfig -Print:$Print
    } elseif ($Undo) {
        # Running Twice Because Main Monitor will not always be detected immediately 
        LoadMonitorConfig -config_name $undoConfig -Print:$Print
        Start-Sleep 2
        LoadMonitorConfig -config_name $undoConfig -Print:$Print
    } else {
        Write-Host "Invalid Action"
    }
}

function LoadMonitorConfig {
    param (
        [string]$config_name,
        [switch]$Print
    )
    
    $Command = "$monitorToolPath /LoadConfig ""$monitorConfigsPath\$config_name"""
    
    if ($Print) {
        Write-Host $Command
    } else {
        Invoke-Expression $Command
    }
}

Main