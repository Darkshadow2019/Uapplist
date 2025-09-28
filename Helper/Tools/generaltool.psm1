# General Tool By D@rkshadow

function GeneralTool {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("Enable", "Disable", "Status")]
        [string]$Action
    )

    $FirewallRuleName = "Block Inbound RDP"
    $ServiceName = "TermService"

    # Nested helper functions
    function Write-ToolStatus {
        param([string]$Message, [string]$Type = "info")
        
        $symbols = @{
            info = "[i]"
            success = "[+]"
            error = "[X]"
            warning = "[!]"
        }
        
        $colors = @{
            info = "Cyan"
            success = "Green"
            error = "Red"
            warning = "Yellow"
        }
        
        Write-Host "$($symbols[$Type]) $Message" -ForegroundColor $colors[$Type]
    }

    function Disable-RDPInternal {
        Write-ToolStatus "Starting configuration to disable RDP access..." "info"
        
        try {
            # Create firewall rule to block RDP
            $existingRule = Get-NetFirewallRule -DisplayName $FirewallRuleName -ErrorAction SilentlyContinue
            if (-not $existingRule) {
                New-NetFirewallRule -DisplayName $FirewallRuleName -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Block -Enabled True
                Write-ToolStatus "Firewall rule created to block RDP." "success"
            } else {
                Set-NetFirewallRule -DisplayName $FirewallRuleName -Enabled True
                Write-ToolStatus "Existing firewall rule enabled to block RDP." "success"
            }
            
            # Disable and stop Terminal Service
            Set-Service -Name $ServiceName -StartupType Disabled
            Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
            Write-ToolStatus "Remote Desktop Service has been disabled and stopped." "success"
            
            Write-ToolStatus "RDP has been successfully disabled." "success"
            
        } catch {
            Write-ToolStatus "Error disabling RDP: $($_.Exception.Message)" "error"
        }
    }

    function Enable-RDPInternal {
        Write-ToolStatus "Starting configuration to enable RDP access..." "info"
        
        try {
            # Remove or disable firewall rule
            $existingRule = Get-NetFirewallRule -DisplayName $FirewallRuleName -ErrorAction SilentlyContinue
            if ($existingRule) {
                Set-NetFirewallRule -DisplayName $FirewallRuleName -Enabled False
                Write-ToolStatus "Firewall rule disabled to allow RDP." "success"
            } else {
                Write-ToolStatus "No blocking firewall rule found." "info"
            }
            
            # Enable and start Terminal Service
            Set-Service -Name $ServiceName -StartupType Automatic
            Start-Service -Name $ServiceName -ErrorAction SilentlyContinue
            Write-ToolStatus "Remote Desktop Service has been enabled and started." "success"
            
            Write-ToolStatus "RDP has been successfully enabled." "success"
            
        } catch {
            Write-ToolStatus "Error enabling RDP: $($_.Exception.Message)" "error"
        }
    }

    function Get-RDPStatusInternal {
        Write-ToolStatus "Checking current RDP status..." "info"
        
        # Check service status
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($service) {
            Write-ToolStatus "Terminal Service: $($service.Status) (Startup: $($service.StartType))" "info"
        }
        
        # Check firewall rule
        $firewallRule = Get-NetFirewallRule -DisplayName $FirewallRuleName -ErrorAction SilentlyContinue
        if ($firewallRule) {
            Write-ToolStatus "Firewall Rule: $($firewallRule.Enabled)" "info"
        } else {
            Write-ToolStatus "No blocking firewall rule found." "info"
        }
    }

    # Main execution inside GeneralTool
    Write-ToolStatus "RDP Management Tool" "info"
    Write-ToolStatus "Action: $Action" "info"
    Write-Host ""

    # Perform the requested action
    switch ($Action) {
        "Disable" { Disable-RDPInternal }
        "Enable" { Enable-RDPInternal }
        "Status" { Get-RDPStatusInternal }
    }

    Write-ToolStatus "Operation completed." "info"
}
Read-Host -Prompt "Press any key to continue or CTRL+C to quit" | Out-Null
## main_script.ps1

# Include the function (or put it in the same file)
# . .\GeneralTool.ps1  # If function is in separate file
# Use the function
# GeneralTool -Action Disable
