
function Set-DendronFrontMatter {
    <#
    .SYNOPSIS
        Add or update an existing field's value in the given file
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = 'Value'
    )]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Mandatory,
            Position = 2,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # The name of the field to set
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [string]$Name,

        # The value of the field to set
        [Parameter(
            Mandatory,
            Position = 1,
            ParameterSetName = 'Value'
        )]
        [object]$Value,

        # The new name of the field
        [Parameter(
            Mandatory,
            Position = 1,
            ParameterSetName = 'NewName'
        )]
        [string]$NewName

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        # TODO: What if we provide a hashtable of values, better to open and write the file once
        $info = $Path | Get-DendronContentInfo
        if ($null -ne $info) {
            $fm = $info.Content.FrontMatter | ConvertFrom-Yaml
            if ($PSBoundParameters.ContainsKey('Value')) {
                    if ($Value -is [datetime]) {
                        $Value = $Value | ConvertTo-DendronTimestamp
                    }
                    $fm[$Name] = $Value
            } elseif ($PSBoundParameters.ContainsKey('NewName')) {
                if ($fm.ContainsKey($Name)) {
                    $currentValue = $fm[$Name]
                    [void]$fm.Add($NewName, $currentValue)
                    [void]$fm.Remove($Name)
                } else {
                    throw "'$Name' key does not exist in frontmatter"
                }
            }
            $newContent = (@(
                "---",
                ($fm | ConvertTo-Yaml),
                "---",
                $info.Content.Body
            ) -join [System.Environment]::NewLine)
            if ($PSCmdlet.ShouldProcess($Name , 'Set frontmatter field')) {
                $newContent | Set-Content $Path
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
