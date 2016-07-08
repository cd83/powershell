<#

Boromir Simulator by Chris Lee

Attack flow: (from Orc's viewpoint)

Check if blocked (y/n)

if blocked: Orc does no damage - skip to Boromir's attack 

if not blocked:	Check if Dodged (y/n)

if dodged: Orc does no damage - Boromir gains +X to next attack 

if not dodged: Check if Parried (y/n)

if parried: Orc does no damage and loses next turn

if not parried: Orc does regular attack damage

#>


clear
Write-Host "
                                             _______________________
   _______________________-------------------                       `\
 /:--__                                                              |
||< > |                                   ___________________________/
| \__/_________________-------------------                        |
|                                                                 |
|                   BOROMIR SIMULATOR 2016                        |
 |                                                                 |
 |      Three Rings for the Elven-kings under the sky,             |
  |        Seven for the Dwarf-lords in their halls of stone,       |
  |      Nine for Mortal Men doomed to die,                         |
  |        One for the Dark Lord on his dark throne                 |
  |      In the Land of Mordor where the Shadows lie.               |
   |       One Ring to rule them all, One Ring to find them,         |
   |       One Ring to bring them all and in the darkness bind them  |
   |     In the Land of Mordor where the Shadows lie.                |
   |                                              _________________ _|_
  |  ___________________-------------------------                      `\
  |/`--_                                                                 |
  ||[ ]||                                            ___________________/
   \===/___________________--------------------------
   
                          
                         [ Press any key to begin ]

"

# Wait for user to hit a key to begin
$wait = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Sets up initial variables for Boromir's hit points, kills, and hit beginning crit chance
$boromir = @{
    "Level" = 1
    "HP" = 100;
    "Kills" = 0;
    "CritStat" = 5;
    "BlockStat" = 50;
    "DodgeStat" = 20;
    "ParryStat" = 20
}

# Start at Level 1
$Level = 1

# As long as Boromir is alive, fight Orcs
function battle {
    While ( $boromir.HP -gt 0) {

        clear

        header 

        # Increase level
        if ($boromir.Kills -ge 10) {
            $Level += 1
        }

        # Generates a new Orc
        switch( $level ) {
            1 { $orc = @{
                "HP" = Get-Random -Minimum 2 -Maximum 7;
                "Level" = 1;
                }
            }
            2 { $orc = @{
                "HP" = Get-Random -Minimum 5 -Maximum 11;
                "Level" = 2;
                }
            }
        }

        $orcHPMin = 10 * $Level / 2
        $orcHPMax = 20 * $Level / 2
        $orc = @{
            "HP" = Get-Random -Minimum $orcHPMin -Maximum $orcHPMax
        }

        

        Write-Host
        Write-Host -foreground red "A level" $Level "Orc with" $orc.HP "hit points attacks!"
        Write-Host
        Start-Sleep -s 2

        While ( $orc.HP -ge 0 ) {

            # The Orc attacks first

            # The attacking Orc's minimum attack is its level
            # Its maximum attack is its level X 10 divided by 2
            $orcAttackMin = $Level
            $orcAttackMax = $Level * 10 / 2
            $orcAttack = Get-Random -Minimum $orcAttackMin -Maximum $orcAttackMax

            # Test for Boromir block
            if ( roll $boromir.BlockStat ) {
                Write-Host "Boromir blocks the attack!"

            } else { # If Boromir fails block roll, Orc attacks Boromir
                Write-Host -foreground red "The Orc hits Boromir for $orcAttack damage!"
                Start-Sleep -s 2
                Write-Host
                # Subtract the Orcs attack damage from Boromir's health
                $boromir.HP = $boromir.HP - $orcAttack
                
                # If Boromir's hit points is less than 0, break from script (he dies)
                if ( $boromir.HP -le 0 ) {
                    break
                }

                Write-Host "Boromir has" $boromir.HP "hit points."
            }
            Write-Host
            Start-Sleep -s 2
            
            # This is where Boromir attacks
            
            # Calculate Boromir's attack
            $boromirAttackMin = $boromir.Level
            $boromirAttackMax = $boromir.Level * 10 / 2
            
            if ( $crit ) {
                $boromirAttackMin = $boromirAttackMin * 2
                $boromirAttackMax = $boromirAttackMax * 3
                Write-Host -foreground yellow "CRITICAL STRIKE!!!"
            }
                
            $boromirAttack = Get-Random -Minimum $boromirAttackMin -Maximum $boromirAttackMax

            # The actual attack
            if ( $boromirAttack -ne 0) {

                # Calculates instakill
                if ( $boromirAttack -gt $orc.HP ) {
                    Write-Host "Boromir smashes the Orc for $boromirAttack damage, killing it instantly, lopping his head off!"
                    # Each time Boromir decapitates an Orc, his crit chance goes up by 1 point, up to a maximum of 5 points.
                    $boromir.CritStat += 1
                    Write-Host -foreground cyan "Boromir's chance to crit is increased by 1"
                    Start-Sleep -s 4
                    Write-Host
                    $boromir.Kills += 1
                    break
                }   

                Write-Host "Boromir attacks the Orc and does $boromirAttack damage."
                Start-Sleep -s 2
                Write-Host
                $orc.HP = $orc.HP - $boromirAttack

            } else {
                Write-Host "Boromor misses!"
                Write-Host
                Start-Sleep -s 2
            }

            if ( $orc.HP -le 0 ) {
                Write-Host "Boromir has killed the Orc!"
                Start-Sleep -s 4
                Write-Host
                $boromir.Kills += 1
                break
                
            } Else {
                Write-Host -foreground red "The Orc has" $orc.HP "hit points, and attacks again."
                Start-Sleep -s 2
                Write-Host
            }
        }
    }

    gameOver
    
}

#### Supporting functions here

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


# This function is the fight
function fight ( $attacker, $defender ) {
    <#

    Attacker attacks

    Defender defends

    #>
}


# Header
# Boromir's stats
function header() {
    # Prints the header
        Write-Host
        Write-Host " Level:" $boromir.Level"    Boromir    Health:" $boromir.HP
        Write-Host "-----------------------------------"
        Write-Host
        Write-Host " % to Block:" $boromir.BlockStat "     % to Parry:" $boromir.ParryStat
        Write-Host
        Write-Host " % to Dodge:" $boromir.DodgeStat "      % to Crit:" $boromir.CritStat
        Write-Host
        Write-Host "            Orcs Slain:" $boromir.Kills
}


# Final Results
function gameOver ( ) {
    Clear

    # Have to set the $boromir.Kills from an object parameter to a variable for the switch statement
    $tally = $boromir.Kills

    switch( $boromir.Kills ) {
            0 {"Boromir has failed in his quest.

Frodo and the ring were taken to the Dark Lord.

All was lost.

The age of Man had come to an end.
"}
            1 {"Boromir has died, killing only 1 Orc,

which was anti-climactic.
"}
            default {"Boromir has died, but he died with honor.

Frodo and Sam have escaped with the ring.

In the end, Boromir killed $tally Orcs.
"}
    }
}

battle