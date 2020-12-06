<#
.SYNOPSIS
Tests a connection to CloudFlare DNS.
.DESCRIPTION
This command will test a single computer's or multiple computer network connection to CloudFlare's one.one.one.one DNS Server.
.Parameter Computername
The name or IP address of the remote computer.
.Parameter Path
The name of the folder where results will be saved. The default location is the current user's home directory
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [string[]]$Computername,
    [Parameter(Mandatory=$False)]
    [string]$Path = "$Env:USERPROFILE"
)

Clear-Host
Set-Location $Path
$DateTime = Get-Date

#Creates a new session to the remote PC
$Session = New-PSSession -ComputerName $Computername

Write-Verbose "Connecting to $Computername"

#Remotely runs Test-NetConnection to one.one.one.one on PC as a background job
Invoke-Command -Command {Test-NetConnection -ComputerName one.one.one.one -InformationLevel Detailed} -session $Session -asjob -jobname RemTestNet

Write-Verbose "Running the test on $Computername"

#Pauses script for 10 seconds to allow Test-Netconnection to complete
Start-Sleep -Seconds 10

#Receives the job results
Write-Verbose "Receiving test results"
Receive-Job -Name RemTestNet | Out-File .\JobResults.txt


Write-Verbose "Generating results file"
Add-Content .\RemTestNet.txt -Value "Computer Tested: $Computername"
Add-Content .\RemTestNet.txt -Value "Date/Time Tested: $DateTime"
Add-Content .\RemTestNet.txt -Value (Get-Content -Path .\JobResults.txt)

Write-Verbose "Opening results"
Notepad .\RemTestNet.txt

#Closes the session to the remote Computer and then deletes JobResults.txt
Remove-PSSession -Session $Session
Remove-Item .\JobResults.txt

Write-Verbose "Finished running test."