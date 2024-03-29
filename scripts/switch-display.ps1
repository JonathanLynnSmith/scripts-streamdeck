param (
    [switch]$OpenTool,
    [switch]$Undo,
    [switch]$OnlyMonitor3
)


function GenerateMonitorConfig {
    param (
        [string]$Name,
        [switch]$Primary,
        [int]$BitsPerPixel,
        [int]$Width,
        [int]$Height,
        [int]$DisplayFrequency,
        [int]$DisplayOrientation,
        [int]$PositionX,
        [int]$PositionY
    )

    $config = "Name=$Name"
    if ($Primary) { $config += " Primary=1" }
    $config += " BitsPerPixel=$BitsPerPixel"
    $config += " Width=$Width"
    $config += " Height=$Height"
    $config += " DisplayFrequency=$DisplayFrequency"
    $config += " DisplayOrientation=$DisplayOrientation"
    $config += " PositionX=$PositionX"
    $config += " PositionY=$PositionY"

    return $config
}

$MaxEnableAllRange = 3
$resourcesPath = "$PSScriptRoot\..\resources\"
$monitorToolPath = "$resourcesPath\MultiMonitorTool\MultiMonitorTool.exe"

$lgMonitorId = "MONITOR\GSM774B\{4d36e96e-e325-11ce-bfc1-08002be10318}\0002"
$lenovoMonitorId = "MONITOR\LEN61AF\{4d36e96e-e325-11ce-bfc1-08002be10318}\0001"
$dellMonitorId = "MONITOR\DELA0B5\{4d36e96e-e325-11ce-bfc1-08002be10318}\0003"

$lgDefaultConfig = GenerateMonitorConfig -Name $lgMonitorId -Primary -BitsPerPixel 32 -Width 3440 -Height 1440 -DisplayFrequency 144 -PositionX 0 -PositionY 0
$lenovoDefaultConfig = GenerateMonitorConfig -Name $lenovoMonitorId -BitsPerPixel 32 -Width 1440 -Height 2560 -DisplayFrequency 59 -DisplayOrientation 1 -PositionX -1440 -PositionY 0
$dellDefaultConfig = GenerateMonitorConfig -Name $dellMonitorId -BitsPerPixel 32 -Width 1920 -Height 1080 -DisplayFrequency 60 -PositionX 3440 -PositionY 349


function Main{
    if ($OpenTool) {
        OpenMonitorTool
    }
    elseif ($OnlyMonitor3) {
        DisableMonitors -MonitorIds $lenovoMonitorId, $lgMonitorId
    }
    elseif ($Undo) {
        EnableAllMonitors
        SetMonitors -Configs $dellDefaultConfig, $lenovoDefaultConfig, $lgDefaultConfig
    }
    else {
        Write-Host "Invalid Action"
    }
}

function DisableMonitors {
    param (
        [string[]]$MonitorIds
    )

    Write-Host "Disabling Monitor(s)"
    $quotedConfigs = $MonitorIds | ForEach-Object { "`"$_`"" }
    RunCommand -Command "$monitorToolPath /disable $quotedConfigs"
}

function EnableMonitors {
    param (
        [string[]]$MonitorIds
    )
    Write-Host "Enabling Monitor(s)"
    $quotedConfigs = $MonitorIds | ForEach-Object { "`"$_`"" }
    RunCommand -Command "$monitorToolPath /enable $quotedConfigs"
}

function EnableAllMonitors {
    $allMonitorIDS = @()
    for ($i = 1; $i -lt $MaxEnableAllRange -or $i -eq $MaxEnableAllRange; $i++) {
        $allMonitorIDS += "\\.\DISPLAY$i"
    }
    EnableMonitors -MonitorIds $allMonitorIDS
}

function SetMonitors {
    param (
        [string[]]$Configs
    )
    Write-Host "Setting Monitor Configuration"
    $quotedConfigs = $Configs | ForEach-Object { "`"$_`"" }
    RunCommand -Command "$monitorToolPath /SetMonitors $quotedConfigs"
}

function OpenMonitorTool {
    RunCommand -Command $monitorToolPath
}

function RunCommand {
    param (
        [string]$Command
    )
    Write-Host "--------------------
--> $Command
"

    Invoke-Expression $Command
    Start-Sleep 1
    Invoke-Expression $Command
}

Write-Host ""
Main
