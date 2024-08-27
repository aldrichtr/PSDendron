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
    Tag  = @( 'unit', 'Content', 'Get', 'DendronLink')
    Name = 'GIVEN the public function Get-DendronLink'
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
            (Get-Command 'Get-DendronLink') | Should -Not -BeNullOrEmpty
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
    Context 'When the link is a valid <Description>' -ForEach @(
        @{
            Description = 'Wiki link'
            Link        = '[[txt.name]]'
            Type        = 'Dendron.WikiLink'
            From        = 'wiki.link.test'
            Line        = 1
            To          = 'txt.name'
            DisplayName = $null
            Vault       = $null
            Anchor      = $null
            Offset      = 0
            Range       = $null
        },
        @{
            Description = 'Note Reference'
            Link        = '![[txt.name]]'
            Type        = 'Dendron.NoteReference'
            From        = 'wiki.link.test'
            Line        = 1
            To          = 'txt.name'
            DisplayName = $null
            Vault       = $null
            Anchor      = $null
            Offset      = 0
            Range       = $null
        },
        @{
            Description = 'Wiki link with display name'
            Link        = '[[this is a name|txt.name]]'
            Type        = 'Dendron.WikiLink'
            From        = 'wiki.link.test'
            Line        = 1
            To          = 'txt.name'
            DisplayName = 'this is a name'
            Vault       = $null
            Anchor      = $null
            Offset      = 0
            Range       = $null
        },
        @{
            Description = 'Wiki link with display name and anchor'
            Link        = '[[this is a name|txt.name#Anchor]]'
            Type        = 'Dendron.WikiLink'
            From        = 'wiki.link.test'
            Line        = 1
            To          = 'txt.name'
            DisplayName = 'this is a name'
            Vault       = $null
            Anchor      = 'Anchor'
            Offset      = 0
            Range       = $null
        }
        @{
            Description = 'Wiki link with display name, anchor, offset and range'
            Link        = '[[this is a name|txt.name#Anchor,1:#*]]'
            Type        = 'Dendron.WikiLink'
            From        = 'wiki.link.test'
            Line        = 1
            To          = 'txt.name'
            DisplayName = 'this is a name'
            Anchor      = 'Anchor'
            Offset      = 1
            Range       = '*'
        }
    ) {
        BeforeEach {
            $file = Join-Path $TestDrive 'wiki.link.test.md'
            $Link | Set-Content $file
            $wikiLink = $file | Get-DendronLink
        }

        It "Should be of Type '<Type>'" {
            @($wikiLink.psobject.TypeNames)[0] | Should -Be $Type
        }

        It "Should have the From '<From>'" {
            $wikiLink.From | Should -Be $From
        }

        It "Should have the Line '<Line>'" {
            $wikiLink.Line | Should -Be $Line
        }

        It "Should have the DisplayName '<DisplayName>'" {
            $wikiLink.DisplayName | Should -Be $DisplayName
        }

        It "Should have the To '<To>'" {
            $wikiLink.To | Should -Be $To
        }

        It "Should have the Anchor '<Anchor>'" {
            $wikiLink.Anchor | Should -Be $Anchor
        }

        It "Should have the Offset '<Offset>'" {
            $wikiLink.Offset | Should -Be $Offset
        }

        It "Should have the Range '<Range>'" {
            $wikiLink.Range | Should -Be $Range
        }
    }
    <# --=-- #>
}
