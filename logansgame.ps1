$playerName = Read-Host "What is your name?"


if ( $playerName -eq "Jeff" ) {
    Write-Host "You are Jeff the evil roomba."
} else {
    Write-Host "Congratulations! Your name is $playerName! You win!"
}


