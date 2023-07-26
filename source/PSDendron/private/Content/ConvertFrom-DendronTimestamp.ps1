
function ConvertFrom-DendronTimestamp {
    <#
    .SYNOPSIS
        Convert a timestamp in dendron content to a powershell DateTime object
    .DESCRIPTION
        `ConvertFrom-DendronTimestamp` converts a timestamp in Dendron content to a [System.DateTime].  Dendron
        Records times in "milliseconds since the (unix) epoch (01.01.1970)".
    .EXAMPLE
        ConvertFrom-DendronTimestamp 1654548340369

        Monday, June 6, 2022 20:45:40
    #>
    [CmdletBinding()]
    param(
        # The dendron timestamp to convert
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline
        )]
        [string]$Timestamp
    )
    begin {
        $epoch = Get-Date "01.01.1970"
    }
    process {
        $ts = $epoch + ([System.TimeSpan]::FromMilliseconds($Timestamp))
    }
    end {
        $ts.ToLocalTime()
    }
}
