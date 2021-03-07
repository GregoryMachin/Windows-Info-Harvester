# Parameter help description


Function Copy-Logs
{
    <#
        .Description 
        Copy-Logs is used to copy log files, it also creates missing directories. 
        
        .PARAMETER $SourceLogsPath
            Provides the path to the source files.

        .PARAMETER $OutputPath
            Provides the location where files are to be coppied to. 

    #>
    Param(
        [string] $SourceLogsPath,    
        [string] $OutputPath 
    )


    if (Test-Path -Path $SourceLogsPath)
    {# if the directory exits then we want to copy files.
        Write-Output "Source logs directory found: $SourceLogsPath"
        Write-Output "Creating directory: $OutputPath"
        #Create the directory for the log files. 
        mkdir -Path $OutputPath
        #Copy files to the new location
        Copy-Item "$SourceLogsPath\" "$OutputPath" -Recurse 
    }else {
    Write-Output "Source Directorty not found: $SourceLogsPath"
        
    }
}
Function get-SCCMLogs
{

    Param(
        [string] $SCCMLogsPath = "windows\CCM\Logs", 
        [string] $SourceRootPath = "C:",   
        [string] $OutputPath      
    )   
    
    $SCCMLogsPath = "$SourceRootPath\$SCCMLogsPath"
    Write-Output $SCCMLogsPath
    $Subfolder = "Windows_CCM_Logs"
    $OutputPathFinal = "$OutputPath\$Subfolder"
    Copy-Logs -SourceLogsPath $SCCMLogsPath -OutputPath $OutputPathFinal
}   
Function get-WindowsLogsDir
{
    Param(
        [string] $WindowsLogsDirPath = "Windows\Logs", 
        [string] $SourceRootPath = "C:",
        [string] $OutputPath
    )   
 

    $WindowsLogsDirPath = "$SourceRootPath\$WindowsLogsDirPath\"
    $Subfolder = "Windows_Logs"
    $OutputPathFinal = "$OutputPath\$Subfolder"
    Copy-Logs -SourceLogsPath $WindowsLogsDirPath -OutputPath $OutputPathFinal
    
}
Function get-WindowsWindowsUpgradeLogs
{
    Param(
        [string[]] $WindowsUpgradeLogsDirPath = @('\$WINDOWS.~BT\Sources\Panther','$Windows.~WS\Sources\Panther'),
        [string] $SourceRootPath = "C:",
        [string] $OutputPath
    )   
 
    foreach ($CurrentPath in  $WindowsUpgradeLogsDirPath){
        Write-Output "Processing path: $CurrentPath"
       
        $WindowsLogsDirPath = "$SourceRootPath\$CurrentPath\"

        $targetroot = (get-item $WindowsLogsDirPath).Parent.Parent
        Write-Output "$targetroot"
        $Subfolder = "Windows_Upgrade_Logs"
        
        $OutputPathFinal = "$OutputPath\$Subfolder\$targetroot"
        
        Copy-Logs -SourceLogsPath $WindowsLogsDirPath -OutputPath $OutputPathFinal
    } 
}
Function get-EventLogs
{
    Param(
        [string] $EventLogsPath = "Windows\System32\winevt", 
        [string] $SourceRootPath = "C:",   
        [string] $OutputPath
    )   
    $EventLogsPath = "$SourceRootPath\$EventLogsPath"
    $Subfolder = "Windows_System32_winevt"
    $OutputPathFinal = "$OutputPath\$Subfolder"
    Copy-Logs -SourceLogsPath $EventLogsPath -OutputPath $OutputPathFinal
}
Function get-WindowsUpdatesLogs
{
    Param(
        [string] $WindowsUpdatesLogs = "Windows\logs\WindowsUpdate",
        [string] $SourceRootPath = "C:",    
        [string] $OutputPath
    )   
 

    $WindowsUpdatesLogs = "$SourceRootPath\$WindowsUpdatesLogs\"
    $Subfolder = "Windows_logs_WindowsUpdate"
    $OutputPathFinal = "$OutputPath\$Subfolder"
    Copy-Logs -SourceLogsPath $WindowsUpdatesLogs -OutputPath $OutputPathFinal
    Write-Output "Writing human readbale log: $OutputPathFinal\WindowsUpdate.log"
    Get-WindowsUpdateLog -ETLPath "$OutputPathFinal\WindowsUpdate" -LogPath "$OutputPathFinal\WindowsUpdate.log"

}
Function get-MemoryDumps
{
    Param(
        [string] $OutputPath,
        [string] $SourceRootPath = "C:"

    )   
 
    $MemoryDump = "$SourceRootPath\windows\Memory.dmp"
    $MiniDump = "$SourceRootPath\windows\Minidump"

    if (Test-Path -Path $MemoryDump )
    {
        $Subfolder = "Windows_Memory_Dumps"
        $OutputPathFinal = "$OutputPath\$Subfolder"
        Copy-Logs -SourceLogsPath $MemoryDump -OutputPath $OutputPathFinal
    }


    if (Test-Path -Path  $MiniDump )
    {
        $Subfolder = "Windows_Memory_Dumps"
        $OutputPathFinal = "$OutputPath\$Subfolder"
        Copy-Logs -SourceLogsPath $MiniDump -OutputPath $OutputPathFinal
    }


}

Function Get-SystemInfo 
{
    Param(
        [string] $OutputPath
    )  

$GetSystemInfoCSV = "$OutputPath\Get-SystemInfo.csv"
Get-SystemInfo | Export-Csv -Path $GetSystemInfoCSV
$GetDiskCSV = "$OutputPath\Get-Disk.csv"
Get-Disk | Export-Csv -Path $GetDiskCSV
}

function Get-InstalledSoftware 
{
    Param(
        [string] $OutputPath
    ) 

    $GetAppxPackageCSV = "$OutputPath\Get-AppxPackage.CSV"
    Get-AppxPackage | export-csv -Path $GetAppxPackageCSV
    
    #Get-WmiObject Win32_Product -ComputerName localhost | Select-Object -Property *
}


Function Get-SCCMWindowsLogs
{
    Param(
        [ValidateSet("SCCM","Windows_logs","EventLogs","Windows_updates","MemoryDumps","WindowsUpgrade","Everything")]
        [String[]] $WhichLogs,
        [string] $OutputPath = "C:\temp",
        [string[]] $ComputerName = $env:computername
    )
BEGIN {

}
PROCESS {
$Timestamp = $(get-date -f MM-dd-yyyy_HH_mm_ss)

$OutputPathFinal = "$OutputPath\$ComputerName"

if (Test-Path $OutputPathFinal) 
{
    Write-Output "Directory $OutputPath\$ComputerName already exists create new directory with timestamp"
    $OutputPathFinal = "$OutputPathFinal-$Timestamp"  
}

mkdir -Path $OutputPathFinal

Write-Output "Output directory will be $OutputPathFinal"

foreach ($log in $WhichLogs) 
{

    Switch ($log)
    {

        'SCCM'              { Get-SCCMLogs -OutputPath $OutputPathFinal } 
        'Windows_logs'      { Get-WindowsLogsDir -OutputPath $OutputPathFinal }
        'EventLogs'         { Get-EventLogs -OutputPath $OutputPathFinal }
        'Windows_updates'   { Get-WindowsUpdatesLogs -OutputPath $OutputPathFinal }
        'MemoryDumps'       { Get-MemoryDumps -OutputPath $OutputPathFinal }
        'WindowsUpgrade'    { Get-WindowsWindowsUpgradeLogs -OutputPath $OutputPathFinal }
        "Everything"        {  
                                Get-SCCMLogs -OutputPath $OutputPathFinal 
                                Get-WindowsLogsDir  -OutputPath $OutputPathFinal
                                Get-EventLogs -OutputPath $OutputPathFinal
                                Get-WindowsUpdatesLogs -OutputPath $OutputPathFinal
                                Get-MemoryDumps -OutputPath $OutputPathFinal
                            }
        Default { Write-output "-WhichLogs entry missing or invalid"}
    }#Switch

  

        
}#Foreach
}#PROCESS
END {

}
}#Function Get-SCCMWindowsLogs