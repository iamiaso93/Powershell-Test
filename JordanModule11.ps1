function  Test-CloudFlare {
    param (
        [Parameter(ValueFromPipeline=$True,
            Mandatory=$True) ]
            [Alias('CN','Name')]
            [string[]]$Computername,
        [Parameter(Mandatory=$false)]
            [ValidateSet('Text','Host','CSV')]
            [string]$Output = 'Host',
        [Parameter(Mandatory=$False)]
            [string] $Env:USERPROFILE

    ) #Param
    foreach ($Computer in $Computername) {
        $Session = New-PSSession -ComputerName $Computername
        Enter-PSSession $Session
        $DateTime = Get-Date
        $TestCF = Test-NetConnection -ComputerName one.one.one.one -InformationLevel Detailed
        $Props = @{
            'Computername' = $Computername
            'PingSuccess' = $TestCF.TcpTestSucceeded
            'NameResolve' = $TestCF.NameResolutionSucceded
            'ResolvedAddresses' = $TestCF.ResolvedAddresses}
        $OBJ = New-Object -TypeName PSObject -Property $Props
        Exit-PSSession
        Remove-PSSession -Session $Session
}
#Foreach
switch ($Output) {
    "Host" {  
        $OBJ }
    
    "Text" {
    
        #Receives the job results
        Write-Verbose "Receiving test results"
        $OBJ| Out-File .\JobResults.txt
    
    
    
    
        Write-Verbose "Generating results file"
        Add-Content -Path "$Path.\RemTestNet.txt" -Value "Computer Tested: $Computername"
        Add-Content -Path "$Path.\RemTestNet.txt" -Value "Date/Time Tested: $DateTime"
        Add-Content -Path "$Path.\RemTestNet.txt" -Value (Get-Content -Path .\JobResults.txt)
        notepad "$Path.\RemTestNet.txt"
        Remove-Item .\JobResults.txt
    }
    "CSV" {
        Write-Verbose "Opening results"
        $OBJ | Export-Csv -Path .\TestResults.csv
    }
    }#Switch
}#Function