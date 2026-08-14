
function Get-PSDendronConfiguration {
    <#
    .SYNOPSIS
        Return the combined Configurations of the Default, Machine, and User Configurations
    .LINK
        Configuration module from Joel Bennett
    #>
    [CmdletBinding()]
    param(
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Import-Configuration
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
