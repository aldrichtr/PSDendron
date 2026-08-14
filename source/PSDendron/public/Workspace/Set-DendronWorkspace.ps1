
function Set-DendronWorkspace {
    <#
    .SYNOPSIS
        Set values for the given workspace
    #>
    [CmdletBinding(
        SupportsShouldProcess
    )]
    param(
        # The name of the workspace to set parameters on
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Name,

        # The name to change the workspace to
        [Parameter(
        )]
        [string]$NewName,

        # The path to change the workspace to
        [Parameter(
        )]
        [string]$Path,

        # Whether this workspace is default or not
        [Parameter(
        )]
        [bool]$Default
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $config = Import-Configuration

        if ($null -ne $config.Workspaces) {
            if ($Name -in $config.Workspaces.Name) {
                $workspace = $config.Workspaces
                | Where-Object {
                    $_.Name -like $Name
                }
            }
        }

        if ($null -eq $workspace) {
            throw "Workspace $Name is not in the Configuration"
        }

        if ($PSBoundParameters.ContainsKey('NewName')) {
            $workspace['Name'] = $NewName
        }

        if ($PSBoundParameters.ContainsKey('Path')) {
            $workspace['Path'] = $Path
        }

        if ($PSBoundParameters.ContainsKey('Default')) {
            $workspace['Default'] = $Default
        }

        if ($PSCmdlet.ShouldProcess("$Name", "Update information")) {
            Get-Module PSDendron | Export-Configuration $config -Scope User
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
