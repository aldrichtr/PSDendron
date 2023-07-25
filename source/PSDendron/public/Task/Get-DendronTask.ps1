
function Get-DendronTask {
    <#
    .SYNOPSIS
        Return tasks defined in the given markdown
    .DESCRIPTION
        `Get-DendronTask` looks for GFM task lines defined in the markdown provided as input.
    .LINK
        Get-DendronContent
    .EXAMPLE
        Get-DendronContent "daily.journal.2022.06.18.md" | Get-DendronTask

        Level 1
        Status x
        Title A task in my daily journal
        Line 15
    #>
    [CmdletBinding()]
    param(
        # The markdown content
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$Markdown
    )
    begin {
        Write-Debug "-- Begin $($MyInvocation.MyCommand.Name)"
        $task_pattern = '^(?<spaces>\s*)- \[(?<status>.)\]\s+(?<title>.*)$'
    }
    process {
        foreach ($line in $Markdown) {
            Write-Debug "parsing '$line'"
            if ($line -match $task_pattern) {
                Write-Debug 'matches task'
                $task = [PSCustomObject]@{
                    Level  = ($Matches.spaces.Length / 2) + 1
                    Status = ($Matches.status)
                    Title  = $Matches.title
                }
                Write-Output $task
            }
        }
    }
    end {
        Write-Debug "-- End $($MyInvocation.MyCommand.Name)"
    }
}
