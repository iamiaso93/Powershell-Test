<#
.SYNOPSIS
Invoke-Command Lets you run commands on local an remote computers.
.DESCRIPTION
The Invoke-Command cmdlet runs commands on a local or remote computer and returns all output from the commands,
including errors.
.PARAMETER -Command
Specifying which command to run
.PARAMETER -AsJob
Setting up a background job
.PARAMETER -JobName
Command to Specify the name of the Job
.PARAMETER -Session 
Specifying the Session followed by the Session Name#>
[CmdletBinding()]
param ([Parameter(Mandatory=$True)]
[string]$Computername)
param ([Parameter(Mandatory=$False)]
[string] $Env:USERPROFILE)
Write-Verbose "Connecting to $Computername"
$DateTime =Get-Date
Clear-Host
Set-Location "C:\Powershell Test"
$Session = New-PSSession -ComputerName $Computername
Invoke-Command -Command {Test-NetConnection -ComputerName one.one.one.one -InformationLevel Detailed} -AsJob -JobName -RemTestNet -Session $Session
<#Using the Command on a Remote computer and testing the connection with detailed information#>
Write-Verbose "Running the test on $Computername"
Start-Sleep -Seconds 10
<#Creating a Wait time to allow the remote command to complete#>
Write-Verbose "Receiving test results"
Write-Verbose "Generating results file"
Receive-Job -Name -RemTestNet | Out-File JobResults.txt
Write-Verbose "Opening results"
Start-Process notepad -FilePath "C:\PowerShell Test\JobResults.txt"
Write-Verbose "Finished running tests"
Add-Content -Path .\RemTestNet.txt -Value ($DateTime, $Computername)
Add-Content -Path .\RemTestNet.txt -Value (Get-Content -Path .\JobResults.txt)
Get-Content -Path .\RemTestNet.txt
Remove-Item .\JobResults.txt
Remove-PSSession -Session $Session