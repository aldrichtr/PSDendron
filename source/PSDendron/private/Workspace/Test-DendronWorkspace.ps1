
using namespace System
using namespace System.Management.Automation

function Test-DendronWorkspace {
    <#
    .SYNOPSIS
        Test for a Dendron workspace in the given directory
    .DESCRIPTION
        To validate that the directory is a Dendron workspace, validate that:
        - there is a 'dendron.code-workspace' file
        - the file has 'settings.dendron.rootdir'
        - there is a 'dendron.yml' file
        - the file has a workspace key
    #>
    [CmdletBinding()]
    param(    # Optionally give another directory to start in
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path
    )
    begin {
        Write-Debug "-- begin $($MyInvocation.MyCommand.Name)"
        $codespaceFile = 'dendron.code-workspace'
        $codespaceRequired = 'dendron.rootDir'
        $configFile    = 'dendron.yml'
        $configRequired = 'workspace'
        $isDendron      = $false
        $hasCodespace   = $false
        $hasConfig      = $false
    }
    process {
        #region Path
        Write-Debug "  Path $Path is $($Path.GetType())"
        if ($Path -is [string]) {
            $location = Get-Item $Path
            if ($location -is [System.IO.FileInfo]) {
                $location = $location.Directory
            }
        } elseif ($Path -is [System.IO.DirectoryInfo]) {
            $location = $Path
        } elseif ($Path -is [System.IO.FileInfo]) {
            $location = $Path.Directory
        }
        Write-Debug "  Looking in $($location.GetType()) $($location.FullName) for Dendron workspace information"

        #endregion Path

        #region Config files
        if (Test-Path (Join-Path $location -ChildPath $codespaceFile)) {
            Write-Debug "Found $codespaceFile"
            try {
                $cs = Get-Content (Join-Path $location -ChildPath $codespaceFile) | ConvertFrom-Json -AsHashtable
                $hasCodespace = ($cs.settings.keys -contains $codespaceRequired)
            } catch {
                $PSCmdlet.ThrowTerminatingError(
                    [ErrorRecord]::new(
                        [Exception]::new(
                            "There was an error parsing $codespaceFile`n$($_.ToString())"
                            ),
                        $null,
                        $_.CategoryInfo.Category,
                        $null
                        )
                    )
                }

            }
            if (Test-Path (Join-Path $location -ChildPath $configFile)) {
            Write-Debug "Found $configFile"
            try {

                $cf = Get-Content (Join-Path $location -ChildPath $configFile) | ConvertFrom-Yaml
                $hasConfig = ($cf.Keys -contains $configRequired)
            }
            catch {
                $PSCmdlet.ThrowTerminatingError(
                    [ErrorRecord]::new(
                        [Exception]::new(
                            "There was an error parsing $configFile`n$($_.ToString())"
                            ),
                        $null,
                        $_.CategoryInfo.Category,
                        $null
                        )
                    )
            }
        }

        Write-Debug "Codespace found: $hasCodespace Config found: $hasConfig"
        $isDendron = ($hasCodespace -and $hasConfig)

        #endregion Config files
    }
    end {
        Write-Debug "-- end $($MyInvocation.MyCommand.Name)"
        return $isDendron
    }
}
