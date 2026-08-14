
function Get-DendronContent {
    <#
    .SYNOPSIS
        Get the content of a dendron note file
    .EXAMPLE
        # Get content from a file
        PS> Get-DendronContent .\root.md
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

        # The type of note to get
        [Parameter(
        )]
        [DendronNoteType]$Type,

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
            Write-Verbose '  No path given.  Looking up vault in current directory'
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
                            $content = $item | Get-DendronContentInfo
                            if ((-not ($PSBoundParameters.ContainsKey('Type'))) -or
                                ($Type -like [DendronNoteType]::Unknown)) {
                                Write-Debug '** No Type info given **'
                                $content
                            } else {
                                Write-Debug "** Type info is $Type and content type is $($content.Type)"
                                if ($content.Type -like $Type) {
                                    Write-Debug '   - Matches'
                                    $content
                                } else {
                                    Write-Debug '   - Does not Match'
                                }
                            }
                        } else {
                            Write-Debug '  Not a markdown document'
                        }

                        continue
                    }
                    'DirectoryInfo' {
                        Write-Debug '  Directory given.  Getting content'
                        $options = @{}
                        $ignoredFields = @('Type')
                        foreach ($field in $PSBoundParameters.Keys) {
                            Write-Debug "- Evaluating $field"
                            if ($ignoredFields -notcontains $field) {
                                Write-Debug '  - Adding'
                                $options[$field] = $PSBoundParameters.field
                            } else {
                                Write-Debug '  - Ignoring'
                            }
                        }

                        if (($PSBoundParameters.ContainsKey('Type')) -or
                            ($null -ne $Type)) {
                            $contentType = $Type
                        } else {
                            $contentType = [DendronNoteType]::Unknown
                        }
                        Write-Debug "    - Path $($item.FullName)"
                        Write-Debug "    - Include $Include"
                        Write-Debug "    - Exclude $Exclude"
                        Write-Debug "    - Filter  $Filter"
                        Write-Debug "    - Type    $contentType"
                        Get-ChildItem -Path $item.FullName @options
                        | Get-DendronContent -Type $contentType
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
