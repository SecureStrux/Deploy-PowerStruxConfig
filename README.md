# Deploy-PowerStruxConfig

`Deploy-PowerStruxConfig` is a PowerShell script designed to deploy the `PowerStruxWAConfig.txt` configuration file to a specified local or remote computer.

## Prerequisites

- **Execution Policy**:  
  The PowerShell execution policy must be set to `RemoteSigned` or less restrictive. You can set it by running the following command in PowerShell:

  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope Process
  ```
- **Network Access**:  
  For remote execution, the machine running the script must be able to communicate over the network with the target system (i.e., no firewall or network restrictions should block the communication). Required ports include:
  - SMB (445/tcp)

- **Access to `C$` Share**:  
  The script attempts to access `C$\` on remote systems (e.g., `\\$ComputerName\c$`). The user executing the script must have access to the `C$` administrative share on the remote system.
 
## Parameters

### `ComputerName`
- **Type**: `String`
- **Description**: Specifies the target computer's hostname. Default is `localhost`.
- **Example**: `"RemoteServer"`

### `ConfigFile`
- **Type**: `String`
- **Description**: Specifies the file path of the PowerStruxWA configuration file (PowerStruxWAConfig.txt) to deploy.
- **Example**: `"C:\Path\To\PowerStruxWAConfig.txt"`

### Example 1: Running Locally
```powershell
Deploy-PowerStruxConfig -ConfigFile "C:\Path\To\PowerStruxWAConfig.txt"
```
This will deploy the PowerStrux configuration file located at `C:\Path\To\PowerStruxWAConfig.txt` to the local machine.
   
### Example 2: Running Remotely on a Single Machine
```powershell
Deploy-PowerStruxConfig -ComputerName "Host01" -ConfigFile "C:\Path\To\PowerStruxWAConfig.txt"
```
This will deploy the PowerStrux configuration file located at `C:\Path\To\PowerStruxWAConfig.txt` to `Host01`.

### Example 3: Running Remotely on a Multiple Machines
To target multiple systems, you can create a file named `target-hosts.txt`, which contains a list of hostnames (one per line). Then, use the following command to loop through each hostname and execute the function:

1. Create a `target-hosts.txt` file
 - Example file contents:
   ```
   Host01
   Host02
   Host03
   ```
2. Execute the loop within the open PowerShell session:
    ```powershell
    Get-Content 'C:\Path\To\target-hosts.txt' | ForEach-Object {
        Deploy-PowerStruxConfig -ComputerName $_ -ConfigFile "C:\Path\To\PowerStruxWAConfig.txt"
    }
    ```
This command reads each hostname from the `target-hosts.txt` file and passes it to the `Deploy-PowerStruxConfig` function for execution. The script will deploy the PowerStrux configuration file located at `C:\Path\To\PowerStruxWAConfig.txt` to `Host01`, `Host02`, and `Host03`.
