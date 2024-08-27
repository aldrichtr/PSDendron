
Function Resolve-DendronWorkspace {
    <#
    .SYNOPSIS
        Recursively search up the directory to find the root of the workspace
    #>
    [CmdletBinding()]
    param(
        # Optionally give another directory to start in
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # Optionally limit how many levels to check
        [Parameter(
            Position = 0
        )]
        [int]$Depth
    )
    begin {
        Write-Debug "Begin $($MyInvocation.MyCommand.Name)"
        $wsFound = $false
        $defaultDepth = 4
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('Depth'))) {
            $Depth = $defaultDepth
        }

        if (-not ($PSBoundParameters.ContainsKey('Path'))) {
            $Path = Get-Location
            | Select-Object Path
        }

        if ($Path -is [string]) {
            $Path = Get-Item $Path
        }

        if ($Path.PSIsContainer) {
            $Path = $Path
        } else {
            $Path = $Path.Directory
        }

        Write-Debug "Starting in $Path"
        Write-Verbose "Looking for workspace root with a maximum depth of $Depth"

        for ($i = 0; $i -lt $Depth; $i++) {
            if (Test-Dendronworkspace $Path) {
                Write-Verbose "Dendron workspace found at level $i '$($Path.Name)'"
                $wsFound = $true
                break
            } else {
                $Path = $Path.Parent
                Write-Debug "Not found at depth $Depth, looking in $($Path.Name)"
            }
        }
        if ( -not $wsFound) {
            throw "workspace root not found in $Depth levels"
        }
        $Path
    }
    end {
    }
}
