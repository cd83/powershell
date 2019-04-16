<#
.Synopsis
Simple test for modules and versioning
#>
Function ZZZGet-MyModuleTest {
    [cmdletbinding()]
    Param(
        [Parameter(mandatory=$false)]
        [String]$ModuleVar
    )
    
    Begin {
        Write-Host "Starting $($MyInvocation.Mycommand)"  
    } #begin
    
    Process {
        Invoke-SQL -server 'localhost' -database 'common' -sqlCommand 'select 1'
        Write-Host "Doing $($MyInvocation.Mycommand). $ModuleVar"
    } #process
    
    End {
        Write-Host "Ending $($MyInvocation.Mycommand)"
    } #end
 
} #end function