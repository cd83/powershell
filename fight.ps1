$boromir = @{
    "Name" = "Boromir";
    "Strength" = 10;
    "Block" = 50;
    "HP" = 50
    "Kills" = 0
}

$orc = @{
    "Name" = "Orc";
    "Strength" = 10;
    "Block" = 20;
    "HP" = Get-Random -minimum 3 -maximum 8
}

function fight ( $attacker, $defender ) {

    # Need to generate a new attacker here    

    while ( $attacker.HP -gt 0 ) {
        $attackerRoll = Get-Random -Minimum 1 -Maximum $attacker.Strength
        $defenderRoll = Get-Random -Minimum 1 -Maximum $defender.Strength

        Write-Host
        Write-Host $attacker.Name "with" $attacker.HP "HP attacks" $defender.Name "!"

        $attackDamage = $attackerRoll - $defenderRoll

        # Here is where the combat logic begins
        if ( $attackerRoll -gt $defenderRoll) {
            if ( roll $defender.Block ) {
                Write-Host $defender.Name "blocks the attack!"
            } else {
                Write-Host $attacker.Name "hits" $defender.Name "for $attackDamage"
                $defender.HP -= $attackDamage
                if ( $defender.HP -le 0 ) {
                    if ( $defender.Name -eq "Boromir" ) {
                        break
                    } else {
                        $boromir.Kills += 1
                        break
                    }
                }
            }        
        } elseif ( $defenderRoll -gt $attackerRoll ) {
            $attackDamage = $attackDamage * -1
            if ( roll $attacker.Block ) {
                Write-Host $defender.Name "Parries and counterattacks, but" $attacker.Name "blocks the attack!"
            } else {
                Write-Host $defender.Name "Parries and counterattacks" $attacker.Name "for $attackDamage"
                $attacker.HP -= $attackDamage
                if ( $attacker.HP -le 0 ) {
                    if ( $attacker.Name -eq "Boromir" ) {
                        break
                    } else {
                        $boromir.Kills += 1
                        break
                    }
                }
            }
        } else {
            Write-Host "The attack was blocked (even rolls)"
        }
        Write-Host
    }
}

# This function performs a roll from 1 to 100
# The $stat input is the stat you are rolling for a pass or a fail
# For example: "roll $boromir.CritStat" will roll to see if Boromir crits his opponent
function roll ( $stat ) {
    $roll = Get-Random -Minimum 0 -Maximum 101
    if ( $roll -ge (100 - $stat) ) {
        return $true
    } else {
        return $false
    }
}

# Header
# Boromir's stats
function header() {
    # Prints the header
        Write-Host
        Write-Host " Level:" $boromir.Level"    Boromir    Health:" $boromir.HP
        Write-Host "-----------------------------------"
        Write-Host
        Write-Host " % to Block:" $boromir.Block "     % to Parry:" $boromir.Parry
        Write-Host
        Write-Host " % to Dodge:" $boromir.Dodge "      % to Crit:" $boromir.Crit
        Write-Host
        Write-Host "            Orcs Slain:" $boromir.Kills
}

while ( $boromir.HP -gt 0 ) {
    clear
    header
    fight -attacker $orc -defender $boromir
    #start-sleep -s 1
}