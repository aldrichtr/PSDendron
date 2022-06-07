

Function Test-DendronWorkspace {
    <#
    .SYNOPSIS
        Test for a Dendron workspace in the given directory
    .DESCRIPTION
        To validate that the directory is a Dendron workspace, validate that:
        - there is a 'dendron.code-workspace' file
        - the file has 'settings.dendron.rootdir'
        - there is a 'dendron.yml' file
        - the file has a workspace key
    #>
    [CmdletBinding()]
    param(    # Optionally give another directory to start in
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path
    )
    begin {
        Write-Debug "-- begin $($MyInvocation.MyCommand.Name)"
        $codespace_file = 'dendron.code-workspace'
        $config_file    = 'dendron.yml'
        $isDendron      = $false
        $hasCodespace   = $false
        $hasConfig      = $false
    }
    process {
        #region Path
        Write-Debug "  Path $Path is $($Path.GetType())"
        if ($Path -is [string]) {
            $location = Get-Item $Path
            if ($location -is [System.IO.FileInfo]) {
                $location = $location.Directory
            }
        } elseif ($Path -is [System.IO.DirectoryInfo]) {
            $location = $Path
        } elseif ($Path -is [System.IO.FileInfo]) {
            $location = $Path.Directory
        }
        Write-Debug "  Looking in $($location.GetType()) $($location.FullName) for Dendron workspace information"

        #endregion Path

        #region Config files
        if (Test-Path (Join-Path $location -ChildPath $codespace_file)) {
            Write-Debug "Found $codespace_file"
            $cs = Get-Content (Join-Path $location -ChildPath $codespace_file) | ConvertFrom-Json -AsHashtable
            $hasCodespace = ($cs.settings.keys -contains 'dendron.rootDir')
        }
        if (Test-Path (Join-Path $location -ChildPath $config_file)) {
            Write-Debug "Found $config_file"
            $cf = Get-Content (Join-Path $location -ChildPath $config_file) | ConvertFrom-Yaml
            $hasConfig = ($cf.Keys -contains 'workspace')
        }

        Write-Debug "Codespace found: $hasCodespace Config found: $hasConfig"
        $isDendron = ($hasCodespace -and $hasConfig)

        #endregion Config files
    }
    end {
        Write-Debug "-- end $($MyInvocation.MyCommand.Name)"
        return $isDendron
    }
}
