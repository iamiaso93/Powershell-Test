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
        $DateTime = Get-Date
        $TestCF = Test-NetConnection -ComputerName one.one.one.one -InformationLevel Detailed
    try {
        $Params = @{
            'ComputerName'=$Computer
            'ErrorAction'='Stop'
        }
        $Session = New-PSSession -ComputerName @Params
        Enter-PSSession $Session
        Exit-PSSession
        Remove-PSSession -Session $Session
       $OBJ = [PSCustomObject]@{
        'Computername' = $Computername
        'PingSuccess' = $TestCF.TcpTestSucceededcls
        'NameResolve' = $TestCF.NameResolutionSucceded
        'ResolvedAddresses' = $TestCF.ResolvedAddresses
        }

    }#try
    catch {
        Write-Host "Remote connection to $Computername failed." -ForegroundColor Red
    }#Catch

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

New-ModuleManifest -Path JordanModule13.psd1 -root ./JordanModule13.psm1