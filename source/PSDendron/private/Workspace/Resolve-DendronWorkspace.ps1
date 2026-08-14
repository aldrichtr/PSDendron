
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
            Write-Debug "No Depth given, using default : $defaultDepth"
            $Depth = $defaultDepth
        }

        if (-not ($PSBoundParameters.ContainsKey('Path'))) {
            Write-Debug "No Path given, using current location"
            $Path = Get-Location
            | Select-Object -ExpandProperty Path
            Write-Debug "- Current Location is '$Path'"
        }

        if ($Path -is [string]) {
            if ($Path | Test-Path) {
                Write-Debug "Path is a valid path"
                try {
                    $PathInfo = (Get-Item -Path $Path)
                    Write-Debug "PathInfo is now $($PathInfo.GetType().FullName) : '$($PathInfo.FullName)'"
                }
                catch {
                    throw "Could not get Path $Path`n$_"
                }
            } else {
                throw "Invalid Path given '$Path'"
            }
        } else {
            $PathInfo = $Path
        }

        if (-not ($PathInfo.PSIsContainer)) {
            $PathInfo = $PathInfo.Directory
        }

        Write-Debug "Starting in $($PathInfo.FullName)"
        Write-Verbose "Looking for workspace root with a maximum depth of $Depth"

        for ($i = 0; $i -lt $Depth; $i++) {
            if (Test-DendronWorkspace $PathInfo.FullName) {
                Write-Verbose "Dendron workspace found at level $i '$($PathInfo.Name)'"
                $wsFound = $true
                break
            } else {
                $PathInfo = $PathInfo.Parent
                Write-Debug "Not found at depth $Depth, looking in $($PathInfo.Name)"
            }
        }
        if ( -not $wsFound) {
            throw "workspace root not found in $Depth levels"
        }
        $PathInfo
    }
    end {
    }
}
