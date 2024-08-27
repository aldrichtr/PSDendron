
function Get-SourceFilePath {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
        Position = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if (-not ($PSBoundParameters.ContainsKey('Path'))) {
            $callStack = Get-PSCallStack
            $caller = $callStack[1]
            $Path = $caller.ScriptName
            Write-Debug "No path given, caller script is $Path"
        }

        $testFileName = Split-Path $Path -LeafBase

        Write-Debug "TestFileName is $testFileName"
        if (-not ([string]::IsNullorEmpty($testFileName))) {
            $sourceName = $testFileName -replace '\.Tests', ''
            if ($null -ne (Get-Command 'Get-SourceItem')) {
                $sourceItem = Get-SourceItem
                | Where-Object Name -Like $sourceName
                | Select-Object -First 1
                Write-Debug "stitch found source name $sourceName"
                Write-Debug "- source item $($sourceItem.Path)"
            }
        } else {
            $PSCmdlet.ThrowTerminatingError($_)
        }

        if ([string]::IsNullorEmpty($sourceItem)) {
            $getChildItemSplat = @{
                Path = (Join-Path (Get-Location) 'source')
                Filter = $sourceName
                Recurse = $true
            }
            Write-Debug "Looking for source file"
            $found = Get-ChildItem @getChildItemSplat
            if ($null -eq $found) {
                throw "Could not find $sourceName"
            } else {
                $sourceItem = $found
            }
        }

        if ($null -ne $sourceItem) {
            $sourceItem.Path | Write-Output
        } else {
            throw "Could not find source item for $sourceName"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function Get-TestDataPath {
    <#
    .SYNOPSIS
        Return the data directory associated with the test
    #>
    [CmdletBinding()]
    param( )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $callStack = Get-PSCallStack
        $caller = $callStack[1]
        if ($caller.ScriptName -like $callStack[0].ScriptName) {
            $caller = $callStack[2]
        }

        $dataDirectory = ($caller.ScriptName -replace '\.Tests\.ps1', '.Data')
        if (-not ([string]::IsNullorEmpty($dataDirectory))) {
            $dataDirectory | Write-Output
        } else {
            throw "Could not determine the data directory"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function Resolve-Dependency {
    <#
    .SYNOPSIS
        Attempt to find the file for the resource requested
    .DESCRIPTION
        Provide a means for a test to lookup the path to a needed function, class , etc.
    .EXAMPLE
        $myTest = 'Test-MyItem' | Resolve-Dependency
        if ($null -ne $myTest) {
            . $myTest
        }
    #>
    [CmdletBinding()]
    param(
        # Name of the function or resource
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Name
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $sourceItem = Get-SourceItem | Where-Object Name -Like $Name -ErrorAction SilentlyContinue
        if ($null -ne $sourceItem) {
            $sourceItem.Path
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function Get-TestData {
    [CmdletBinding()]
    param(
        # The filter to apply (as a script block)
        [Parameter(
        )]
        [scriptblock]$Filter
    )

    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $dataDir = Get-TestDataPath
        if (-not ([string]::IsNullorEmpty($dataDir))) {
            if (-not ([string]::IsNullorEmpty($Filter))) {
                Get-ChildItem -Path $dataDir
                | Where-Object $Filter
            } else {
                Get-ChildItem -Path $dataDir
            }
        } else {
            throw "Could not find data Directory for $((Get-PSCallStack)[1].ScriptName) "
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

<#
.SYNOPSIS
    Custom assertion for PSScriptAnalyzer tests
.DESCRIPTION
    `FollowRule` is a convenience function for Pester tests using the PSSA.
    While there are many patterns that can be used to analyze a code block and
    wrap it in a Pester "It block", this function makes the "Should" assertion
    more like a natural-language test. So, rather than something like:
    ``` powershell
    if ($analysis.RuleName -contains $rule) {
        # gather failures
    }
    $failures.Count | Should -Be 0
    ```
    A much more succinct test looks like:
    ``` powershell
    $analysis | Should -Pass $rule
    ```
    Additionally, this assertion "pretty formats" the error messages a bit.
    A Pester Should function will output 'Expected foo but got bar' followed by
    a very poorly formatted dump of the rule output.
    `FollowRule` does a decent job of collecting the relevant properties of the
    DiagnosticRecord properties.  It will print:
    ```
    Rule violation: <rule name>
    <rule message>
    <file:line:column>
    <file:line:column>
    <file:line:column>
    ```
.NOTES
    this function gets added to Pester using the `Add-AssertionOperator` which
    is in this file below the function
.EXAMPLE
     $analysis | Should -Pass $rule
#>
Function FollowRule {
    [CmdletBinding()]
    param(
        $ActualValue,
        $PSSARule,
        $CallerSessionState,
        [Switch]$Negate
    )
    begin {
        $AssertionResult = [PSCustomObject]@{
            Succeeded      = $false
            FailureMessage = ""
        }
    }
    process {
        if ( $ActualValue.RuleName -contains $PSSARule.RuleName) {
            $AssertionResult.Succeeded = $false
            $AssertionResult.FailureMessage = @"
`n$($PSSARule.Severity) - $($PSSARule.CommonName)
$($ActualValue.Message)
$($PSSARule.SuggestedCorrections)
"@
            # there may be several
            # lines that do not Rule$rule the rule, collect them all into one
            # error message
            $ActualValue | Where-Object {
                $_.RuleName -eq $PSSARule.RuleName
            } | ForEach-Object {
                $AssertionResult.FailureMessage += "'{0}' at {1}:{2}:{3}`n" -f
                $_.Extent.Text,
                $_.Extent.File,
                $_.Extent.StartLineNumber,
                $_.Extent.StartColumnNumber
            }
        } else {
            $AssertionResult.Succeeded = $true
        }
    }
    end {
        if ($Negate) {
            $AssertionResult.Succeeded = -not($AssertionResult.Succeeded)
        }
        $AssertionResult
    }
}

Add-AssertionOperator -Name 'Pass' -Test $Function:FollowRule
