<#

.AUTHOR
  Nicholas Palumbo

.SYNOPSIS
  Ping IP addresseses in CSV file.
  
.DESCRIPTION
  This PowerShell script will Ping all of the IP addresses in a given CSV file.
    
.EXAMPLE
  Ping-IPList c:\IPaddressList.csv
   
#>

Param(
  [Parameter(Mandatory=$true, position=0)]
  [string[]]$csvfile
)

$ip = "IP address"
$value = "Reply"


Write-Host "Reading file" $csvfile
$csv = Import-Csv $csvfile

Write-Host "Starting List Ping:"
$output = foreach( $row in $csv) {
	
	# Check for a NULL value
	if (!$row.($ip)) { 

		# Found NULL IP

	# Check if value given is in IP address format
	} elseif (-Not [bool]($row.($ip) -as [ipaddress])) {

		# Check if the IP is actually a subnet with a range '/'
		if ($row.($ip).contains("/")) {

			# Found Subnet, NOT single IP
			$row.($value) = "/"
			Write-Host $row.($ip) "Subnet needs checked." -foreground yellow
		
		} else {

			# Unknown Value
			$row.($value) = "?"
			Write-Host $row.($ip) "Unknown Value (NOT IP format)"
		}

	} else {

		# test connection of single IP. Wait for 1 reply and hide result
		if (Test-Connection -ComputerName $row.($ip) -count 1 -quiet) {

			$row.($value) = "Y"
			Write-Host $row.($ip) "Ping succeeded." -foreground green

    		} else {

			$row.($value) = "N"
			Write-Host $row.($ip) "Ping failed." -foreground red

    		}
	}
	# output $row in each loop so it can be added to final output
	$row
    
}
$output | Export-Csv $csvfile -NoTypeInformation
Write-Host "List Ping Done."
