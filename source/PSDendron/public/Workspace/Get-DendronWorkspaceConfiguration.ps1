
function Get-DendronWorkspaceConfiguration {
    <#
    .SYNOPSIS
        Get the configuration for the given dendron workspace
    .DESCRIPTION
        `Get-DendronConfiguration` reads the dendron.yml file of the given workspace and returns an object
        representing the keys.
    .EXAMPLE
        Get-DendronConfiguration .
    #>
    [Alias('Get-DendronConfiguration')]
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

        # Return a HashTable instead of a `[Dendron.Workspace.Configuration]`
        [Parameter(
        )]
        [switch]$AsHashTable
    )
    begin {
        $defaultConfigFilename = 'dendron.yml'
    }
    process {
        if (-not($PSBoundParameters['Path'])) {
            $Path = (Get-Location | Select-Object -ExpandProperty Path)
        }

        Write-Debug "Looking for $defaultConfigFilename in $Path"

        # --------------------------------------------------------------------------------
        #region Resolve config file path

        $possibleConfig = (Join-Path (Convert-Path $Path) $defaultConfigFilename)
        if (Test-Path $possibleConfig) {
            $configFile = $possibleConfig
        } else {
            Write-Debug "Not found.  Trying to resolve workspace from $Path"
            try {
                $root = $Path | Resolve-DendronWorkspace
                $configFile = Join-Path $root $defaultConfigFilename
            } catch {
                Write-Error "Could not find $defaultConfigFilename at $Path."
            }
        }

        #endregion Resolve config file path
        # --------------------------------------------------------------------------------

        # --------------------------------------------------------------------------------
        #region Convert yaml

        try {
            $yamlcontent = Get-Content $configfile | ConvertFrom-Yaml
            if ($ashashtable) {
                $yamlcontent
            } else {
                $yamlcontent['pstypename'] = 'dendron.workspace.configuration'
                [pscustomobject]$yamlcontent
            }
        } catch {
            Write-Error "error parsing configfile`n$_"
        }

        #endregion Convert yaml
        # --------------------------------------------------------------------------------
    }
    end {
    }
}
