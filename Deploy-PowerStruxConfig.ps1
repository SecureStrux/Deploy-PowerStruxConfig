Function Deploy-PowerStruxConfig {

    <#
    .SYNOPSIS
    Deploys the configuration file 'PowerStruxWAConfig.txt' to a local or remote computer.

    .PARAMETER ComputerName
    Specifies the target computer to deploy the configuration file. If not specified, it defaults to the
    local system (`localhost`).
    Valid Input: Any valid computer name or IP address.

    .PARAMETER ConfigFile
    Specifies the full path to the configuration file (`PowerStruxWAConfig.txt`).

    .EXAMPLE
    Deploy-PowerStruxConfig -ConfigFile "C:\path\to\PowerStruxWAConfig.txt"
    Deploy the configuration file to the local system.

    .EXAMPLE
    Deploy-PowerStruxConfig -ComputerName "Host01" -ConfigFile "C:\path\to\PowerStruxWAConfig.txt"
    Deploy the configuration file to a remote system named 'Host01'.

    #>

    param (
        [Parameter(Mandatory = $false)]
        $ComputerName = "localhost",

        [Parameter(Mandatory = $true)]
        $ConfigFile
    )

    # Ensure that the configuration file is named 'PowerStruxWAConfig.txt'
    if ((Split-Path -Leaf $ConfigFile) -ne "PowerStruxWAConfig.txt") {

        Write-Host "The configuration file must be named 'PowerStruxWAConfig.txt'. Exiting the script." -ForegroundColor Red
        Write-Host ""
        return

    }

    Write-Host "Checking for elevated privileges..."

    # Check if the current user has administrative privileges.
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        
        Write-Host "The script was not executed with admin privileges. Please rerun the script as an administrator." -ForegroundColor Red
        Write-Host ""
        return 
    
    }
    else {

        Write-Host "Complete!" -ForegroundColor Green
        Write-Host ""

    }

    # Create an array of local identifiers (IP addresses, computer name, and localhost).
    $arrIsLocalHost = @()
    $arrIsLocalHost += Get-NetIPAddress | Select-Object -ExpandProperty IPAddress
    $arrIsLocalHost += $env:COMPUTERNAME
    $arrIsLocalHost += "localhost"

    # Check if the target computer is local or remote.
    if ($arrIsLocalHost.Contains($ComputerName)) {

        Write-Host "Script operations will be performed against the local system."
        Write-Host ""

        # Define the installation path for the local computer.
        $installPath = "C:\Program Files\WindowsPowerShell\Modules\ReportHTML"
    }
    else {

        Write-Host "Script operations will be performed remotely against $ComputerName."
        Write-Host ""
        
        Write-Host "Testing remote connectivity to port 445 (SMB) on $ComputerName."

        # Test remote connectivity on port 445 (SMB) to the target computer.
        if (!(Test-NetConnection -ComputerName $ComputerName -Port 445)) {

            Write-Host "Remote connectivity test failed on $ComputerName. The system may be offline, or SMB (445/tcp) may not be available." -ForegroundColor Red
            Write-Host ""  
            return

        }

        Write-Host "Complete!" -ForegroundColor Green
        Write-Host ""

        # Define the installation path for the remote computer.
        $installPath = "\\$ComputerName\c$\Program Files\WindowsPowerShell\Modules\ReportHTML"

    }

    Write-Host "Testing access to $installPath."

    # Check if the installation path exists.
    if (Test-Path -Path $installPath) {

        Write-Host "Complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Copying $ConfigFile to $installPath."

        try {

            # Attempt to copy the config file to the target installation path.
            Copy-Item -Path $ConfigFile -Destination $installPath -ErrorAction Stop

        }
        catch {

            Write-Host "Error copying $ConfigFile to $installPath. Error: $_" -ForegroundColor Red  # Display error if copy fails
            Write-Host ""
            return  # Exit the function if the copy operation fails

        }

        Write-Host "Complete!" -ForegroundColor Green
        Write-Host ""

        # Construct the full path to the copied config file.
        $configFilePath = Join-Path $installPath 'PowerStruxWAConfig.txt'

        Write-Host "Confirming that $ConfigFile was successfully copied to $installPath."
        
        # Check if the file was copied successfully.
        if (Test-Path -Path $configFilePath) {

            Write-Host "Complete!" -ForegroundColor Green
            Write-Host ""

        }
        else {

            Write-Host "The configuration file was not copied correctly." -ForegroundColor Red  # Error message if file wasn't copied
            Write-Host ""
            return

        }

    }
    else {

        Write-Host "The script was not able to access $installPath." -ForegroundColor Red  # Error message if path is inaccessible
        Write-Host ""
        return  # Exit early if the installation path is unavailable

    }

}
