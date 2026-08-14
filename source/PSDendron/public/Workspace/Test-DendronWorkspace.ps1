function Test-DendronWorkspace {
    <#
    .SYNOPSIS
        Test whether the given path is a Dendron Workspace
    #>
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $configFile = 'dendron.yml'
    }
    process {
        $pathInfo = Get-Item $Path
        if ($pathInfo.PSIsContainer) {
            $possibleConfig = (Join-Path $Path $configFile)
        } else {
            $possibleConfig = (Join-Path ($Path | Split-Path -Parent) $configFile)
        }

        ($possibleConfig | Test-Path)
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
