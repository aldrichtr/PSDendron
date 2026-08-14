
function Get-DendronTaskNote {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # Filter to apply to filenames
        [Parameter(
            Position = 0
        )]
        [string]$Filter,

        # Pattern to use to include files
        [Parameter(
        )]
        [string]$Include,

        # Pattern to use to exclude files
        [Parameter(
        )]
        [string]$Exclude
    )
    begin {
        Write-Debug "-- Begin $($MyInvocation.MyCommand.Name)"
    }
    process {
        try {
            if (-not ($PSBoundParameters.ContainsKey('Path'))) {
                $ws = Get-DendronWorkspace -Default
                if ($null -ne $ws) {
                    $vaults = $ws | Get-DendronVault
                    foreach ($vault in $vaults) {
                        $Path = $PSBoundParameters['Path'] = $vault.Path
                        Write-Debug "Getting tasks at path $($PSBoundParameters.Path)"
                        Get-DendronContent @PSBoundParameters -Type Task
                    }
                }
            }


        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    end {
        Write-Debug "-- End $($MyInvocation.MyCommand.Name)"
    }
}
