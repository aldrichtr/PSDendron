
function Get-DendronWorkspace {
    <#
    .SYNOPSIS
        Retrieve Dendron workspaces that are stored in the configuration.
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'ByName'
    )]
    param(
        # Name of the workspace
        [Parameter(
            ParameterSetName = 'ByName'
        )]
        [string]$Name,

        # Return the Default workspace.
        [Parameter(
            ParameterSetName = 'AsDefault'
        )]
        [switch]$Default
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $config = Import-Configuration
    }
    process {
        if ($null -ne $config.Workspaces) {
            if ($Default) {
                $ws = $config.Workspaces
                | Where-Object { $_.Default }
                | Select-Object -First 1
                $ws['PSTypeName'] = 'Dendron.WorkspaceItem'
                [PSCustomObject]$ws
            } else {
                foreach ($workspace in $config.Workspaces) {
                    if ((-not ($PSBoundParameters.ContainsKey('Name'))) -or
                    ($Name -like $workspace.Name)) {
                        $workspace['PSTypeName'] = 'Dendron.WorkspaceItem'
                        [PSCustomObject]$workspace
                    }
                }
            }
        }

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
