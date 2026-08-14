
function Get-DendronJournalNote {
    <#
    .SYNOPSIS
        Get the Dendron.ContentInfo for the given date
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'ByDate'
    )]
    param(
        # The workspace to use.  Default workspace used if none provided
        [Parameter(
        )]
        [string]$Workspace,

        # The date to use for the journal note
        [Parameter(
            ParameterSetName = 'ByDate'
        )]
        [datetime]$Date,

        # Get today's note
        [Parameter(
            ParameterSetName = 'Current'
        )]
        [switch]$Current
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('Workspace'))) {
            $ws = Get-DendronWorkspace -Default
        } else {
            $ws = Get-DendronWorkspace -Name $Workspace
        }
        if ($null -eq $ws) {
            throw 'Could not get dendron workspace'
        }

        $config = $ws | Get-DendronWorkspaceConfiguration
        if ($null -ne $config.workspace.journal) {
            $jrnlConfig = $config.workspace.journal
            $journalHierarchy = (@($jrnlConfig.dailyDomain, $jrnlConfig.name) -join '.')
            Write-Debug "Journal hierarchy is $journalHierarchy"
        }

        if ($Current) {
            $Date = (Get-Date)
        }

        if ($null -eq $Date) {
            $filter = $journalHierarchy # all journal notes
        } else {
            $filter = (@($journalHierarchy, (Get-Date $Date -Format 'yyyy.MM.dd')) -join '.')
        }
        Write-Debug "Looking for journal notes with filter $filter"
        Get-DendronContent -Filter "$filter.md"

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
