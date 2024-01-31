param (
    [switch]$OpenTool,
    [switch]$Undo,
    [switch]$HD,
    [switch]$QHD
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

$resourcesPath = "$PSScriptRoot\..\resources\"
$monitorToolPath = "$resourcesPath\MultiMonitorTool\MultiMonitorTool.exe"

$lgMonitorId = "MONITOR\GSM774B\{4d36e96e-e325-11ce-bfc1-08002be10318}\0002"
$lenovoMonitorId = "MONITOR\LEN61AF\{4d36e96e-e325-11ce-bfc1-08002be10318}\0001"
$dellMonitorId = "MONITOR\DELA0B5\{4d36e96e-e325-11ce-bfc1-08002be10318}\0003"

$lgDefaultConfig = GenerateMonitorConfig -Name $lgMonitorId -Primary -BitsPerPixel 32 -Width 3440 -Height 1440 -DisplayFrequency 144 -PositionX 0 -PositionY 0
$lgHDConfig = GenerateMonitorConfig -Name $lgMonitorId -Primary -BitsPerPixel 32 -Width 1920 -Height 1080 -DisplayFrequency 144 -PositionX 0 -PositionY 0
$lgQHDConfig = GenerateMonitorConfig -Name $lgMonitorId -Primary -BitsPerPixel 32 -Width 2560 -Height 1440 -DisplayFrequency 144 -PositionX 0 -PositionY 0

$lenovoDefaultConfig = GenerateMonitorConfig -Name $lenovoMonitorId -BitsPerPixel 32 -Width 1440 -Height 2560 -DisplayFrequency 59 -DisplayOrientation 1 -PositionX -1440 -PositionY 0
$lenovoDisableConfig = GenerateMonitorConfig -Name $lenovoMonitorId -Primary -BitsPerPixel 32 -Width 0 -Height 0 -DisplayFrequency 60 -PositionX 0 -PositionY 0

$dellDefaultConfig = GenerateMonitorConfig -Name $dellMonitorId -BitsPerPixel 32 -Width 1920 -Height 1080 -DisplayFrequency 60 -PositionX 3440 -PositionY 349
$dellDisableConfig = GenerateMonitorConfig -Name $dellMonitorId -Primary -BitsPerPixel 32 -Width 0 -Height 0 -DisplayFrequency 60 -PositionX 0 -PositionY 0

function SetMonitors {
    param (
        [string[]]$Configs
    )

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

    Write-Host $Command
    Invoke-Expression $Command
    Start-Sleep 1
    Invoke-Expression $Command
}

if ($OpenTool) {
    OpenMonitorTool
}
elseif ($QHD) {
    SetMonitors -Configs $lgQHDConfig, $lenovoDisableConfig, $dellDisableConfig
}
elseif ($HD) {
    SetMonitors -Configs $lgHDConfig, $disableConfig, $disableConfig
}
elseif ($Undo) {
    SetMonitors -Configs $lgDefaultConfig, $lenovoDefaultConfig, $dellDefaultConfig
}
else {
    Write-Host "Invalid Action"
}
