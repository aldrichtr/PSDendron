
using namespace System.Collections

function Add-DendronWorkspace {
    <#
    .SYNOPSIS
        Add a location to the list of workstations
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # Friendly name of this workspace
        [Parameter(
        )]
        [string]$Name,

        # List of tags associated with the workstation
        [Parameter(
        )]
        [string[]]$Tags
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $config = Import-Configuration
    }
    process {
        if ($null -ne $config) {
            if ($null -eq $config.Workspaces) {
                $config['Workspaces'] = @()
            }
        } else {
            $config = @{ Workspaces = @() }
        }

        try {
            $wsPath = Resolve-DendronWorkspace $Path
        } catch {
            throw $_
        }

        if (-not ($PSBoundParameters.ContainsKey('Name'))) {
            $Name = $wsPath | Split-Path -Leaf
        }

        $workspaces = [ArrayList]::new()

        foreach ($ws in $config.Workspaces) {
            [void]$workspaces.Add($ws)
        }

        [void]$workspaces.Add(
            @{
                Path = (Resolve-Path $Path).Path
                Name = ($Path | Split-Path -Leaf)
                Tags = $Tags ?? @()
            }
        )
        $config['Workspaces'] = $workspaces

        Get-Module PSDendron | Export-Configuration $config -Scope User
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
