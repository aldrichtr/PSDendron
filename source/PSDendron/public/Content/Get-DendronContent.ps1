
function Get-DendronContent {
    <#
    .SYNOPSIS
        Get the content of a dendron note file
    #>
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
        if (-not($PSBoundParameters.ContainsKey('Path'))) {
            Write-Verbose "  No path given.  Looking up vault in current directory"
            $Path = (Get-DendronVault).Path
        }
        foreach ($p in $Path) {
            try {
                $item = Get-Item $p -ErrorAction Stop
                Write-Debug "  Path $($item.Name) given"
                switch (($item.GetType()).Name) {
                    'FileInfo' {
                        Write-Debug '  Getting contentinfo for file'
                        if ($item.Extension -eq '.md') {
                            $item | Get-DendronContentInfo | Write-Output
                        }
                        continue
                    }
                    'DirectoryInfo' {
                        Write-Debug '  Directory given.  Getting content'
                        Write-Debug "    - Path $($item.FullName)"
                        Write-Debug "    - Include $Include"
                        Write-Debug "    - Exclude $Exclude"
                        Write-Debug "    - Filter  $Filter"
                        Get-ChildItem -Path $item.FullName @PSBoundParameters | Get-DendronContent
                        continue
                    }
                }
            } catch {
                Write-Warning "$p is not a valid path`n$_"
            }
        }
    }
    end {}

}
