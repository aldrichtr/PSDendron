
function Export-PSDendronConfiguration {
    <#
    .SYNOPSIS
        Write the configuration to a file
    #>
    [CmdletBinding()]
    param(
        # The configuration to export
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [hashtable]$Configuration,

        # Specifies a path to one or more locations.
        [Parameter(
        Position = 0
        )]
        [Alias('PSPath')]
        [string]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('Path'))) {
            $Path = Resolve-PSDendronConfigurationPath
        }
        $Configuration | ConvertTo-Yaml | Set-Content $Path
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
