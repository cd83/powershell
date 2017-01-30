$critChance = 10 # Read-Host "Enter Crit Chance"

function roll() {
    $chance = Get-Random -Minimum 0 -Maximum 100
    return $chance
}

roll

$roll


function calculateStats($toon, $level) {
    $rollPrime = roll / roll
    $rollPrime
    

    # ability to dodge attack
    $dodge = roll /($level * [math]::Sqrt( $rollPrime ));

    # ability to mitigate a strike
    $parry = roll;

    # ima bout to hit dat ass
    $Attack = roll;

    # crit chance dawg
    $critical = roll;


    write-host "
I am a $toon with dodgeStat == $dodge
I am a $toon with ParryStat == $parry
I am a $toon with Attack == $Attack
I am a $toon with Crital == $Critical"
}

calculateStats "orc" 1