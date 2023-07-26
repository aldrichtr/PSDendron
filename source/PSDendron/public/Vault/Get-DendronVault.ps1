
function Get-DendronVault {
    <#
    .SYNOPSIS
        Return the Vaults in the given Dendron workspace
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
        [string[]]$Path,

        # Include seed vaults in the output
        [Parameter(
        )]
        [switch]$IncludeSeeds
    )
    begin {
        Write-Debug "-- Begin $($MyInvocation.MyCommand.Name) --"
    }
    process {
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            if ([string]::IsNullorEmpty($env:DENDRON_WS)) {
                Write-Debug 'No Path given and env:DENDRON_WS not set. Using current location'
                $Path = Get-Location
            } else {
                Write-Debug 'No Path given Using env:DENDRON_WS'
                $Path = ($env:DENDRON_WS -split ';')
            }
        }
        foreach ($p in $Path) {
            Write-Debug "Looking for vaults in $p"
            try {
                $item = Get-Item $p -ErrorAction Stop
            } catch {
                Write-Warning "$p is not a valid path`n$_"
            }

            if ($item.PSIsContainer) {
                if ($item | Test-DendronWorkspace) {
                    $root = $item
                } else {
                    Write-Verbose "Trying to resolve workspace from $($item.FullName)"
                    $root = $item | Resolve-DendronWorkspace
                }
            } else {
                $root = $item | Resolve-DendronWorkspace
            }
        }

        if ($root) {
            try {
                Write-Debug "Getting dendron config in $root"
                $root_item = Get-Item $root
                $config = $root_item | Get-DendronConfiguration

                Write-Debug '  Loaded configuration.  Reading vaults:'

                foreach ($v in $config.workspace.vaults) {
                    if ($v.ContainsKey('seed')) {
                        Write-Debug "  $($v.name) is a seed vault"
                        if ($PSBoundParameters.ContainsKey('IncludeSeeds')) {
                            Write-Debug '   seeds should be included in output'
                            $seed_path = (Join-Path $root_item -ChildPath 'seeds' -AdditionalChildPath $v.seed)
                            $vault_item = Get-Item (Join-Path $seed_path $v.fsPath)
                        }
                    } elseif ($v.selfContained) {
                        Write-Debug "  $($v.name) is a self-contained vault, using default 'notes' folder"
                        # https://wiki.dendron.so/notes/o4i7a81j778jyh7wql0nacb/
                        $vault_item = Get-Item (Join-Path -Path $root_item -ChildPath 'notes')
                    } else {
                        $vault_item = Get-Item (Resolve-Path (Join-Path $root_item $v.fsPath))
                    }

                    [PSCustomObject]@{
                        PSTypeName    = 'Dendron.Vault'
                        Name          = $v.name
                        Sync          = $v.sync
                        SelfContained = $v.selfContained
                        Content       = $vault_item
                        Path          = $vault_item.FullName
                        Remote        = @{
                            Url  = $v.remote.url
                            Type = $v.remote.type
                        }
                    } | Write-Output
                }
            } catch {
                #Write-Error "There was an error getting the vaults for workspace $Path`n$_"
                $PSCmdlet.ThrowTerminatingError($_)
            }
        } else {
            Write-Error "$Path does not appear to be a dendron workspace"
        }
    }
    end {
        Write-Debug "-- End $($MyInvocation.MyCommand.Name) --"
    }
}
