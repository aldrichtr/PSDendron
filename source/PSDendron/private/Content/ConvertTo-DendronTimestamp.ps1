
function ConvertTo-DendronTimestamp {
    <#
    .SYNOPSIS
        Convert a PowerShell DateTime object to a timestamp in dendron content.
    .DESCRIPTION
        `ConvertTo-DendronTimestamp` converts a [System.DateTime] to a timestamp in Dendron.  Dendron
        records times in UTC as "milliseconds since the (unix) epoch (01.01.1970)".
    .EXAMPLE
        ConvertTo-DendronTimestamp (Get-Date "2022.06.06 16:45:40")

        1654548340369
    .NOTES
        ConvertTo-DendronTimestamp converts the given time to UTC if it is not already!!
    #>
    [CmdletBinding()]
    param(
        # The dendron timestamp to convert
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline
        )]
        [datetime]$Time
    )
    begin {
    }
    process {
        $ts = [System.DateTimeOffset]::new($Time.ToUniversalTime())
    }
    end {
        $ts.ToUnixTimeMilliseconds()
    }
}
