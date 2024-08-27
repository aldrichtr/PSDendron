using namespace System.Management.Automation.Language

BeforeDiscovery {
    if (Get-Module 'TestHelpers') {
        $sourceFile = Get-SourceFilePath $PSCommandPath
    } else {
        throw 'TestHelpers module is not loaded'
    }
    if (-not (Test-Path $sourceFile)) {
        throw "Could not find $sourceFile from $PSCommandPath"
    }
    $analyzerRules = Get-ScriptAnalyzerRule -Severity Error, Warning
    | Where-Object {
        $_.RuleName -notmatch '(^PSDSC)|Manifest'
    }
    try {
        $analysis = Invoke-ScriptAnalyzer -Path $sourceFile -IncludeRule $analyzerRules
    } catch {
        throw "There was an error analyzing $sourceFile`n$_"
    }
    $dataDirectory = Get-TestDataPath
}

$options = @{
    Tag  = @( 'unit', 'Task', 'Get', 'DendronTask')
    Name = 'GIVEN the public function Get-DendronTask'
    Foreach = $sourceFile
}
Describe @options {

    Context 'WHEN The function is sourced in the current environment' -Tag @('parse') {
        BeforeAll {
            $sourceFile = $_
            if ($sourceFile | Test-Path) {
                $content = (Get-Content $sourceFile -Raw)
                $tokens      = $null
                $parseErrors = $null
                $results = [Parser]::ParseInput($content, [ref]$tokens, [ref]$parseErrors)
                $predicate = { param($Ast) $ast -is [FunctionDefinitionAst] }
                $functionAst = $results.Find($predicate, $false)
            }
        }

        It 'THEN it should parse without error' {
            $parseErrors | Should -BeNullOrEmpty
        }
        It 'THEN it should load without error' {
            (Get-Command 'Get-DendronTask') | Should -Not -BeNullOrEmpty
        }

        It 'THEN it should contain a function' {
            $functionAst | Should -Not -BeNullOrEmpty
        }

        It 'THEN the function name should match the file name' {
            $functionAst.Name | Should -BeLike ($sourceFile | Split-Path -LeafBase)
        }
    }

    Context 'WHEN the <rule.RuleName> rule is tested' -Tag @('pssa') -ForEach $analyzerRules {
        BeforeAll {
            # Rename automatic variable to rule to make it easier to work with
            $rule = $_
        }

        It 'THEN it should pass' {
            $analysis | Should -Pass $rule
        }
    }
    <# --=-- #>
    Context 'When the task is valid <task>' -ForEach @(
        @{
            Task    = '- [ ] A simple task'
            Level    = 1
            Status  = ' '
            Title   = 'A simple task'
        }
        @{
            Task    = '- [x] A simple task'
            Level    = 1
            Status  = 'x'
            Title   = 'A simple task'
        }
        @{
            Task    = '  - [ ] A simple task'
            Level    = 2
            Status  = ' '
            Title   = 'A simple task'
        }
    ) {
        BeforeAll {
            $dendron_task = $Task | Get-DendronTask
        }

        It "Should have the Level '<Level>'" {
            $dendron_task.Level | Should -Be $Level
        }

        It "Should have the status '<Status>'" {
            $dendron_task.Status | Should -Be $Status
        }

        It "Should have the target '<Title>'" {
            $dendron_task.Title | Should -Be $Title
        }
    }
    <# --=-- #>
}
