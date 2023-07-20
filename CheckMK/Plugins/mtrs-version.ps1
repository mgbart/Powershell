function Out-CheckkMK-String {
    param (
        [Parameter(Mandatory)]
		[string]$Name,
        [Parameter(Mandatory)]
		[string]$Value,
        [Parameter(Mandatory)]
		[int]$Status
    )

    [string]$returnstring = "$Status" + ' "' + $Name + '"' + " - " + "$Value"

    return $returnstring
}


try {$app = Get-AppxPackage -AllUsers *SkypeRoom*
    $version = $app.version
    $status = 0
}
catch {
    $version = "Not Available"
    $status = 3
}
finally {
    Out-CheckkMK-String -Name "MTRS Version" -Value $version -Status $status
}
