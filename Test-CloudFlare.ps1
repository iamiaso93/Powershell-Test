<#
.SYNOPSIS
Tests a connection to CloudFlare DNS.
.DESCRIPTION
This command will test a single computer's or multiple computer network connection to CloudFlare's one.one.one.one DNS Server.
.Parameter Computername
The name or IP address of the remote computer.
.Parameter Path
The name of the folder where results will be saved. The default location is the current user's home directory
.Parameter Output
-Host
-Test
-CSV
Setting the output of the files
.EXAMPLE 
Test-CloudFlare -Computername '192.168.1.44' -output Text

Oututs the computer name to a text

.EXAMPLE
Test-CloudFlare -Computername DC1

Test connectivity to CloudFlare DNS on the target computer

.EXAMPLE
Test-CloudFlare -Computername PC1 -Path C:\Folder

Test the connectivity to CloudFlare and changes the location of the result files

.NOTES

Author: Jordan Hagan
Last Edit: 2020-11-13
Version 1.2 - Added exception handling to ForEach loop
            - Changed the object to use [pscustomobject] accelerator
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [string[]]$Computername,
    [Parameter(Mandatory=$False)]
    [string]$Path = "$Env:USERPROFILE",
    [Parameter(Mandatory=$True)]
    [string]$Output = "Host"
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
switch ($Output) {
"Host" {  
    Receive-Job RemTestNet
}
"Text" {

    #Receives the job results
    Write-Verbose "Receiving test results"
    Receive-Job -Name RemTestNet | Out-File .\RemTestNet.txt




    Write-Verbose "Generating results file"
    Add-Content .\RemTestNet.txt -Value "Computer Tested: $Computername"
    Add-Content .\RemTestNet.txt -Value "Date/Time Tested: $DateTime"
    Add-Content .\RemTestNet.txt -Value (Get-Content -Path .\JobResults.txt)
    notepad .\RemTestNet.txt
    Remove-Item .\JobResults.txt
}
 "CSV" {
    Write-Verbose "Opening results"
    Receive-Job -Name RemTestNet | Export-Csv -Path .\RemTestNet.csv
}
default {"$Output isn't a valid option"}
}
#Closes the session to the remote Computer and then deletes JobResults.txt
Remove-PSSession -Session $Session

Write-Verbose "Finished running test."