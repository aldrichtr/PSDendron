
function Get-DendronConfiguration {
    <#
    .SYNOPSIS
        Get the configuration for the given dendron workspace
    .DESCRIPTION
        `Get-DendronConfiguration` reads the dendron.yml file of the given workspace and returns an object
        representing the keys.
    .EXAMPLE
        Get-DendronConfiguration .
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
        $default_config_filename = 'dendron.yml'
    }
    process {
        if (-not($PSBoundParameters['Workspace'])) {
            $PSItem = (Get-Location).ToString()
        }

        Write-Debug "Looking for $default_config_filename in $PSItem"

        if (Test-Path(Join-Path -Path $PSItem -ChildPath $default_config_filename)) {
            $config_file = Join-Path -Path $PSItem -ChildPath $default_config_filename
        } else {
            Write-Debug "Not found.  Trying to resolve workspace from $PSItem"
            try {
                $root = $PSItem | Resolve-DendronWorkspace
                $config_file = Join-Path $root $default_config_filename
            } catch {
                Write-Error "Could not find $default_config_filename at $PSItem."
            }
        }

        try {
            $yaml_content = Get-Content $config_file | ConvertFrom-Yaml
            $yaml_content['PSTypeName'] = 'Dendron.Workspace.Configuration'
            $dendron_config = [PSCustomObject]$yaml_content
        } catch {
            Write-Error "Error parsing $config_file`n$_"
        }

    }
    end {
        $dendron_config
    }
}
