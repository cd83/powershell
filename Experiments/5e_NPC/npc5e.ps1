param([int]$NumberToDo = 1)

################################################################

	function Lookup-Ideal($i) {
		$fname = $i + " Ideal.txt"
		$ideal = Get-Content $fname | Get-Random
		return $ideal
	}

################################################################

$attributes = @( "STR:", "DEX:", "CON:", "INT:", "WIS:", "CHA:" )

################################################################

for ($npcindex = 1; $npcindex -le $NumberToDo; $npcindex++) {

	$gender = Get-Content .\Gender.txt | Get-Random
	$namefile = "{0}.txt" -f $Gender
	$npcname = Get-Content $namefile | Get-Random
	Write-Output "Name: $npcname"

	$race = Get-Content .\Race.txt | Get-Random
	Write-Output "Race: $race"
	Write-Output "Gender: $gender"

	foreach ($attribute in $attributes) {
		$attr = (Get-Random -Minimum 1 -Maximum 7) + (Get-Random -Minimum 1 -Maximum 7) + (Get-Random -Minimum 1 -Maximum 7)
		Write-Output "$attribute $attr"
	}

	$appearance = Get-Content "Appearance.txt" | Get-Random
	Write-Output "Appearance: $appearance"

	$talent = Get-Content "Talents.txt" | Get-Random
	Write-Output "Talent: $talent"
	$mannerism = Get-Content "Mannerisms.txt" | Get-Random
	Write-Output "Mannerism: $mannerism"
	$interactiontrait = Get-Content "Interaction Traits.txt" | Get-Random
	Write-Output "Interaction trait: $interactiontrait"
	$alignment = Get-Content "Alignment.txt" | Get-Random
	Write-Output "Alignment: $alignment"

	$a,$b = $alignment.split(' ',2)


	$ideals = @()

	# Ignore true part of "True Neutral"
	if ($a -ne "True") {
		$ideals += Lookup-Ideal $a
	}

	$ideals += Lookup-Ideal $b
	$ideals += Lookup-Ideal "Other"

	$idealstr = $ideals -Join ", "
	Write-Output "Ideals: $idealstr"

	$bond = Get-Content "Bonds.txt" | Get-Random
	Write-Output "Bond: $bond"

	$flaw = Get-Content "Flaws.txt" | Get-Random
	Write-Output "Flaw: $flaw"

	Write-Output ""
}