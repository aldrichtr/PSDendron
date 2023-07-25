
function New-DendronContentId {
    <#
    .SYNOPSIS
        Create a dendron compliant id
    .DESCRIPTION
        `New-DendronContentId` generates an id using the same algorithm that dendron does.  This uses the
        nanoid/non-secure npm library with a custom alphabet
    .NOTES
        Uses the Nanoid nuget package
        see https://github.com/dendronhq/dendron/blob/master/packages/common-all/src/uuid.ts
    #>
    [CmdletBinding()]
    param(

    )
    begin {
        $short_length = 12
        $long_length = 23
        $custom_alpha = "0123456789abcdefghijklmnopqrstuvwxyz"

        #$asbly = (Get-Item (Join-Path (Split-Path (Get-Package nanoid).Source) "lib/netstandard2.1/nanoid.dll"))
        #Add-Type -Path $asbly
    }
    process {

        $id = [Nanoid.Nanoid]::Generate($custom_alpha, $long_length)
    }
    end {
        $id
    }
}
