
function Get-DendronContent {
    <#
    .SYNOPSIS
        Get the content of a dendron note file
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path
    )
    begin {
    }
    process {
        foreach ($p in $Path) {
            try {
                $item = Get-Item $p -ErrorAction Stop
                switch (($item.GetType()).Name) {
                    'FileInfo' {
                        if ($item.Extension -eq '.md') {
                            $item | Get-DendronContentInfo | Write-Output
                        }
                        continue
                    }
                    'DirectoryInfo' {
                        Get-ChildItem $item.FullName | Get-DendronContent
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
