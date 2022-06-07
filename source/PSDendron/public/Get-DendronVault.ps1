
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
        [Alias("PSPath")]
        [string[]]$Workspace
    )
    begin {
    }
    process {
        if (-not($PSBoundParameters['Workspace'])) {
            $PSItem = (Get-Location).ToString()
            Write-Debug "No path provided looking in $PSItem"
        }
        Write-Debug "Looking for vaults in $PSItem"

        if (Test-DendronWorkspace $PSItem) {
            $root = $PSItem
        } else {
            $root = $PSItem | Resolve-DendronWorkspace
        }

        if ($root) {
            try {
                Write-Debug "Getting dendron config in $root"
                $config = $root | Get-DendronConfiguration
                $config.workspace.vaults | % {
                    $vault = [PSCustomObject]@{
                        PSTypeName    = 'Dendron.Vault'
                        Name          = $_.name
                        Content       = Get-Item (Join-Path $root $_.fsPath)
                        Path          = (Join-Path $root $_.fsPath)
                        SelfContained = $_.selfContained
                        Remote        = @{
                            Url  = $_.remote.url
                            Type = $_.remote.type
                        }
                        Sync          = $_.sync
                    }
                    # https://wiki.dendron.so/notes/o4i7a81j778jyh7wql0nacb/
                    if ($_.selfContained) {
                        $vault.Content = (Join-Path $vault.Path 'notes')
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
    }
}
