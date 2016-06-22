Param
(
    [Parameter(Mandatory=$true,
        Position=0,
        HelpMessage="Source folder")]
    [string]$source,
    [Parameter(Mandatory=$false,
        Position=1,
        HelpMessage="Destination folder")]
    [string]$destination
)

robocopy $source $destination /MIR 