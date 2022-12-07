
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
        [string[]]$Workspace,

        # Include seed vaults in the output
        [Parameter(
        )]
        [switch]$IncludeSeeds
    )
    begin {
        Write-Debug "-- Begin $($MyInvocation.MyCommand.Name) --"
    }
    process {
        if (-not($PSBoundParameters['Workspace'])) {
            $Workspace = Get-Location
            Write-Verbose "No workspace specified using $Workspace"
        }
        foreach ($p in $Workspace) {
            Write-Debug "Looking for vaults in $p"
            try {
                $item = Get-Item $p -ErrorAction Stop
                switch (($item.GetType()).Name) {
                    'FileInfo' {
                        $root = $item | Resolve-DendronWorkspace
                        continue
                    }
                    'DirectoryInfo' {
                        if ($item | Test-DendronWorkspace) {
                            $root = $item
                        } else {
                            $root = $item | Resolve-DendronWorkspace
                        }
                        continue
                    }
                }
            } catch {
                Write-Warning "$p is not a valid path`n$_"
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
                            Write-Debug "   seeds should be included in output"
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
                #Write-Error "There was an error getting the vaults for workspace $Workspace`n$_"
                $PSCmdlet.ThrowTerminatingError($_)
            }
        } else {
            Write-Error "$Workspace does not appear to be a dendron workspace"
        }
    }
    end {
        Write-Debug "-- End $($MyInvocation.MyCommand.Name) --"
    }
}
