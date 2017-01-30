# Quick script to rename a file to a and copy it to b
# used for Azure Resource Manager templates

$subfolders = (Get-ChildItem -Recurse | ?{ $_.PSIsContainer } | Select-Object -ExpandProperty FullName)

foreach ($i in $subfolders) {
    mv $i\azuredeploy.properties.json $i\a.json -ErrorAction SilentlyContinue
    cp $i\a.json $i\b.json
    #cp $i\a.json $i\c.json

    $file = Get-Content $i\a.json -raw | ConvertFrom-Json
    $file.parameters.updateGroup | % {if($_.value -eq 'a'){$_.value="a"}}
    $file | ConvertTo-Json -Depth 20 | Set-Content $i\a.json

    #$file = Get-Content $i\b.json -raw | ConvertFrom-Json
    #$file.parameters.updateGroup | % {if($_.value -eq 'a'){$_.value="b"}}
    #$file | ConvertTo-Json -Depth 20 | Set-Content $i\b.json

    # just have to beautify the files
    
    #Remove-Item $i\c.json
}