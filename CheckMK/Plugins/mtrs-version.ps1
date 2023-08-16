function Out-CheckkMK-SimpleValue {
    param (
        [Parameter(Mandatory)]
		[string]$Name,
        [Parameter(Mandatory)]
		[string]$Value,
        [Parameter(Mandatory)]
		[int]$Status
    )

    [string]$returnstring = "$Status" + ' "' + $Name + '"' + " - " + $Value

    return $returnstring
}

# Get MTRS Version

try {$app = Get-AppxPackage -AllUsers *SkypeRoom*
    $version = $app.version
    $status = 0
}
catch {
    $version = "Not Available"
    $status = 3
}
finally {
    Out-CheckkMK-SimpleValue -Name "MTRS Version" -Value $version -Status $status
}



$LogName = "Skype Room System"

# Get Event Log (At App Start)
$restartEvent = Get-WinEvent -FilterHashtable @{ LogName=$logname; ID=4000;} -ErrorAction SilentlyContinue | Select-Object -First 1
$restartMsg =  $restartEvent.Message -replace '{"' -replace '"}','"' -replace '":"', '="' -replace '","',"`"`n"
$restartMsg = ConvertFrom-StringData -StringData $restartMsg

if (($restartMsg.Alias -eq $null) -or ($restartMsg.Alias -eq "")) {
    $status = 2
}
else {
    $status = 0
}

Out-CheckkMK-SimpleValue -Name "MTRS Account" -Value (($restartMsg.Alias).Replace("`"","")) -Status $status


# Heartbeat status
$heartbeatEvent = Get-WinEvent -FilterHashtable @{ LogName=$logname; ID=2000,2001;} -ErrorAction SilentlyContinue | Select-Object -First 1

if ($heartbeatEvent.Id -eq 2000) {$status = 0} #Healthy
elseif ($heartbeatEvent.Id -eq 2001) {$status = 2} #Error
else {$status = 3} # Unknown


$heartbeatMsg =  $heartbeatEvent.Message -replace '{"' -replace '"}','"' -replace '":"', '="' -replace '","',"`"`n"
$heartbeatMsg = ConvertFrom-StringData -StringData $heartbeatMsg
Out-CheckkMK-SimpleValue -Name "MTRS Heartbeat" -Value (($heartbeatMsg.Description).Replace("`"","")) -Status $status

# Hardware status
$hardwareEvent = Get-WinEvent -FilterHashtable @{ LogName=$logname; ID=3000,3001;} -ErrorAction SilentlyContinue | Select-Object -First 1

if ($hardwareEvent.Id -eq 3000) {$status = 0} #Healty
elseif ($hardwareEvent.Id -eq 3001) {$status = 2} #Error
else {$status = 3} # Unknown


$hardwareMsg =  $hardwareEvent.Message -replace '{"' -replace '"}','"' -replace '":"', '="' -replace '","',"`"`n"
$hardwareMsg = ConvertFrom-StringData -StringData $hardwareMsg
Out-CheckkMK-SimpleValue -Name "MTRS Hardware" -Value (($hardwareMsg.Description).Replace("`"","")) -Status $status
