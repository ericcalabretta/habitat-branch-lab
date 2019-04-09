$URL = "https://api.bintray.com/content/habitat/stable/windows/x86_64/hab-%24latest-x86_64-windows.zip?bt_package=hab-x86_64-windows"
Invoke-Webrequest -uri $URL -OutFile habitat.zip
Expand-Archive habitat.zip -DestinationPath C:\
Rename-Item C:\hab-0.78.0-20190313120028-x86_64-windows\ -NewName "habitat"

[System.Environment]::SetEnvironmentVariable("Path", $($env:PATH + ";C:\habitat;"), "Machine")
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 