<#

Boromir Simulator by Chris Lee

.TODO
Horn of Gondor
Boromir blows the Horn of Gondor, increasing his crit chance by 50%

Crit Chance to actual percentage

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

# Sets up initial variables for Boromi's hit points, kills, and hit beginning crit chance
$bHP = 50
$bK = 0
$bACritChance = 10

# As long as Boromir is alive, fight Orcs
While ( $bHP -gt 0) {

    clear

    # Generates a new Orc
    $oHP = Get-Random -Minimum 5 -Maximum 21

    # Prints the header
    switch( $bK ){
        0 {"
Boromir has $bHP hit points and has not killed any Orcs yet.

The battle begins..."}
        1 {"
Boromir has $bHP hit points and has killed 1 Orc."}
        default {"
Boromir has $bHP hit points and has killed $bK Orcs."}
    }

    Write-Host
    Write-Host -foreground red "An Orc with $oHP hit points attacks Boromir!"
    Write-Host
    Start-Sleep -s 2

    While ( $oHP -ge 0 ) {

        # The attacking Orc's minimum attack is half of its health +1
        # Its maximum attack is its health +2
        $oAmin = [int]($oHP/2)+1
        $oAmax = $oHP + 2
        $oA = Get-Random -Minimum $oAmin -Maximum $oAmax

        # Boromir has a 50% chance to block all attacks
        # Test for Boromir block
        $bB = Get-Random -Maximum 2
        if ( $bB -gt 0 ) {
            Write-Host "Boromir blocks the attack!"

        } else {
            Write-Host -foreground red "The Orc hits Boromir for $oA damage!"
            Start-Sleep -s 2
            Write-Host
            # Subtract the Orcs attack damage from Boromir's health
            $bHP = $bHP - $oA
            
            # If Boromir's hit points is less than 0, break from script (he dies)
            if ( $bHP -le 0 ) {
                break
            }

            Write-Host "Boromir has $bHP hit points."
        }
        Write-Host
        Start-Sleep -s 2
        
        # This is where Boromir attacks

        # Test for critical strike
        $critTest = Get-Random -Minimum 0 -Maximum 100
        if ( $critTest -ge (100 - $bACritChance) ) {
            $crit = $true
        }
        
        # Calculate Boromir's attack
        $bAmin = 0
        $bAmax = [int](($oHP)/2)+1
        
        if ( $crit ) {
            $bAmin = [int]($oHP)/2
            $bAmax = [int]($oHP)*2
            Write-Host -foreground yellow "CRITICAL STRIKE!!!"
        }
            
        $bA = [int](Get-Random -Minimum $bAmin -Maximum $bAmax)

        # The actual attack
        if ( $bA -ne 0) {

            # Calculates instakill
            if ( $bA -gt $oHP ) {
                Write-Host "Boromir smashes the Orc for $bA damage, killing it instantly, lopping his head off!"
                # Each time Boromir decapitates an Orc, his crit chance goes up by 1 point, up to a maximum of 5 points.
                $bACritChance += 5
                Write-Host -foreground cyan "Boromir's chance to crit is increased by 5"
                Start-Sleep -s 4
                Write-Host
                $bK += 1
                break
            }   

            Write-Host "Boromir attacks the Orc and does $bA damage."
            Start-Sleep -s 2
            Write-Host
            $oHP = $oHP - $bA

        } else {
            Write-Host "Boromor misses!"
            Write-Host
            Start-Sleep -s 2
        }

        if ( $oHP -le 0 ) {
            Write-Host "Boromir has killed the Orc!"
            Start-Sleep -s 4
            Write-Host
            $bK += 1
            break
            
        } Else {
            Write-Host -foreground red "The Orc has $oHP hit points, and attacks again."
            Start-Sleep -s 2
            Write-Host
        }

    }
    
}

Clear

switch( $bK ) {
        0 {"Boromir has failed in his quest.

Frodo and the ring were taken to the Dark Lord.

All was lost.

The age of Man had come to an end.
"}
        1 {"Boromir has died, killing only 1 Orc,

which was anti-climactic.
"}
        50 {"

"}
        default {"Boromir has died, but he died with honor.

Frodo and Sam have escaped with the ring.

In the end, Boromir killed $bK Orcs.
"}
}