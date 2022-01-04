<#
        Requirements : Look through all machines on the network to see any machines that have not signed on for xx number of days

        Written by : Josh Wallace

        Date : 18/02/2021
#>

# Define variables, constants and functions
$Days = 21
$OutPutFile = <#File#>
$NewOU = <#New OU if needed#>

cls
# Script start

#Checking if AD Module is installed
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Host "AD Module exists, continuing to run"
} 
else {
    Write-Host "AD Module does not exist, Please install Remote Server Administration Tools (RSAT) and Try again"
    Pause
    Exit 10
}

# Get Desktops 

$Desk = Get-adcomputer -filter * -searrchscope 2 -Searchbase <#Machine OU#> `
-Properties cn,Description,lastlogontimestamp,extensionAttribute2, extensionAttribute4,extensionAttribute5 `
| ? [(((Get-date)- ([datetime]::FromFileTime($_.lastlogontimestamp))).TotalDays -gt $Days)]

$LostDesk = $Desk | Select `
@{Exp=($_.cn);label="Computer Name"}, `
@{Exp=($_.extensionAttribute2);label="Model"}, `
@{Exp=($_.Description);label="Description"}, `
@{Exp=($_.extensionAttribute4);label="Last user ID"}, `
@{Exp=($_.extensionAttribute5);label="Last Location"}, `
@{Exp=([datetime]::FromFileTime($_.lastlogontimestamp));label="Last Seen Date"}
#@{Exp=($UserName = $_.extensionAttribute4.Split("\"));(Get-aduser $UserName[1].Name);label="Name"}

# Create report of desktops
$LostDesk | Export-Csv $OutPutFile -NoTypeInformation -Delimiter ","

# Move reported machines to seprarate OU
$Desk | Move-ADObject -TargetPath $NewOU

<#              ONLY TO BE USED IF LAPTOPS AND DESKTOPS ARE IN SEPRATE OU

    

# Get Laptops
$Lap = Get-adcomputer -filter * -searrchscope 2 -Searchbase #Machine OU `
-Properties cn,Description,lastlogontimestamp,extensionAttribute2, extensionAttribute4,extensionAttribute5 `
| ? [(((Get-date)- ([datetime]::FromFileTime($_.lastlogontimestamp))).TotalDays -gt $Days)]

$LostLap = $Lap | Select `
@{Exp=($_.cn);label="Computer Name"}, `
@{Exp=($_.extensionAttribute2);label="Model"}, `
@{Exp=($_.Description);label="Description"}, `
@{Exp=($_.extensionAttribute4);label="Last user ID"}, `
@{Exp=($_.extensionAttribute5);label="Last Location"}, `
@{Exp=([datetime]::FromFileTime($_.lastlogontimestamp));label="Last Seen Date"}
@{Exp=($UserName = $_.extensionAttribute4.Split("\"));(Get-aduser $UserName[1]).Name);label="Name"}

# Create report for desktops
$LostLap | Export-Csv $OutPutFile -NoTypeInformation -Delimiter ","

#>