
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
        [string[]]$Workspace
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
                $config = $root | Get-DendronConfiguration
                $root_item = Get-Item $root

                foreach ($v in $config.workspace.vaults) {
                    $vault_item = Get-Item (Resolve-Path (Join-Path $root_item $v.fsPath))

                    # https://wiki.dendron.so/notes/o4i7a81j778jyh7wql0nacb/
                    if ($v.selfContained) {
                        $vault_item = Get-Item (Join-Path -Path $vault_item -ChildPath 'notes')
                    }

                    $vault = [PSCustomObject]@{
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
                    }
                    Write-Output $vault
                }
            } catch {
                Write-Error "There was an error getting the vaults for workspace $Workspace`n$_"
            }
        } else {
            Write-Error "$Workspace does not appear to be a dendron workspace"
        }
    }
    end {
        Write-Debug "-- End $($MyInvocation.MyCommand.Name) --"
    }
}
