 param([Parameter(Mandatory)][String]$path)
     Get-ChildItem -Path $path -Directory -Recurse -Include bin, obj | 
      Remove-Item -Recurse -Force -Confirm:$False