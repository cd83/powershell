$block = 50
$parry = 50
$dodge = 50
$crit = 50

function roll ( $stat ) {
    $roll = Get-Random -Minimum 0 -Maximum 101
    if ( $roll -ge (100 - $stat) ) {
        return $true
    } else {
        return $false
    }
}

if ( roll $block ) {
    Write-Host "blocked"
    $roll
}

if ( roll $parry ) {
    Write-Host "parried"
    $roll
}

if ( roll $dodge ) {
    Write-Host "dodged"
    $roll
}

if ( roll $crit ) {
    Write-Host "crit"
    $roll
}