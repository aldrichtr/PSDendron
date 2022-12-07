
function New-DendronTaskNote {
    [CmdletBinding()]
    param(
        # The vault to create the note in
        [Parameter(
            ValueFromPipeline
        )]
        [PSTypeName('Dendron.Vault')]$Vault,

        # Name of file to create
        # space (' '), underscore ('_'), and dash ('-') will be
        # converted to dot ('.')
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Optionally provide a description
        [Parameter(
        )]
        [Type]$Description,

        # The status of the task
        [Parameter(
        )]
        [string]$Status,

        # The priority of the task
        [Parameter(
        )]
        [string]$Priority,

        # The due date of the task
        [Parameter(
        )]
        [datetime]$Due,

        # The owner of the task
        [Parameter(
        )]
        [string]$Owner,

        # Optionally provide tags
        [Parameter(
        )]
        [string[]]$Tags,

        # Optional hashtable of additional frontmatter
        [Parameter(
        )]
        [hashtable]$FrontMatter
    )
    begin {
        Write-Debug "-- Begin $($MyInvocation.MyCommand.Name)"

    }
    process {
        if (-not($PSBoundParameters.ContainsKey('FrontMatter'))) {
            # create the table if it doesn't exist, so we can fill it with task
            # specific properties
            $FrontMatter = @{}
        }
        if ($PSBoundParameters.ContainsKey('Status')) {
            $FrontMatter['status'] = $Status
            $PSBoundParameters.Remove('Status')
        } else {
            $FrontMatter['status'] = $Status
        }
        if ($PSBoundParameters.ContainsKey('Priority')) {
            $FrontMatter['priority'] = $Priority
            $PSBoundParameters.Remove('Priority')
        } else {
            $FrontMatter['priority'] = ''
        }

        if ($PSBoundParameters.ContainsKey('Due')) {
            $FrontMatter['due'] = ($Due | ConvertTo-DendronTimestamp)
            $PSBoundParameters.Remove('Due')
        } else {
            $FrontMatter['due'] = ''
        }

        if ($PSBoundParameters.ContainsKey('Owner')) {
            $FrontMatter['owner'] = $Owner
            $PSBoundParameters.Remove('Owner')
        } else {
            $FrontMatter['owner'] = ''
        }

        $task_name = "task $(Get-Date -Format 'yyyy MM dd') $(($Name -split ' ') -join '-')"
        $PSBoundParameters.Name = $task_name
        New-DendronNote @PSBoundParameters -FrontMatter $FrontMatter | Write-Output
    }
    end {
        Write-Debug "-- End $($MyInvocation.MyCommand.Name)"
    }
}
