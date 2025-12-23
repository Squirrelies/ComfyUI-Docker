Import-Module "${PSScriptRoot}\CommonFunctions" -DisableNameChecking

Start-Process -FilePath "Docker.exe" -ArgumentList "compose rm -sf" -Wait -NoNewWindow
Start-Process -FilePath "Docker.exe" -ArgumentList "compose create --no-build" -Wait -NoNewWindow
