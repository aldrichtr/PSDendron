
function Get-DendronTaskNote {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # Filter to apply to filenames
        [Parameter(
        )]
        [string]$Filter,

        # Pattern to use to include files
        [Parameter(
        )]
        [string]$Include,

        # Pattern to use to exclude files
        [Parameter(
        )]
        [string]$Exclude
    )
    begin {
        Write-Debug "-- Begin $($MyInvocation.MyCommand.Name)"
    }
    process {
        try {
            $config = (Get-DendronConfiguration).workspace.task
            $task_domain = $config.name
            #TODO: This does not allow for filtering tasks by date
            if (-not([system.string]::IsNullOrEmpty($config.dateFormat))) {
                $date_path = $config.dateFormat -replace 'y+', '*' -replace 'M+' , '*' -replace 'd+', '*'
                $task_domain += $date_path
                $task_domain += '.'
                Write-Debug "  Adding date to the filter: $task_domain"
            }

            if (-not($PSBoundParameters.ContainsKey('Filter'))) {
                $PSBoundParameters['Filter'] = "$($task_domain)*.md"
            }

            Get-DendronContent @PSBoundParameters | Write-Output

        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    end {
        Write-Debug "-- End $($MyInvocation.MyCommand.Name)"
    }
}
