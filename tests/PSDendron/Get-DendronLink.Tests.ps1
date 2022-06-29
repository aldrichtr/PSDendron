

Describe 'Testing public function Get-DendronLink' -Tag @('unit', 'get', 'dendronlink', 'link') {
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
            $wiki_link = $file | Get-DendronLink
        }

        It "Should be of Type '<Type>'" {
            @($wiki_link.psobject.TypeNames)[0] | Should -Be $Type
        }

        It "Should have the From '<From>'" {
            $wiki_link.From | Should -Be $From
        }

        It "Should have the Line '<Line>'" {
            $wiki_link.Line | Should -Be $Line
        }

        It "Should have the DisplayName '<DisplayName>'" {
            $wiki_link.DisplayName | Should -Be $DisplayName
        }

        It "Should have the To '<To>'" {
            $wiki_link.To | Should -Be $To
        }

        It "Should have the Anchor '<Anchor>'" {
            $wiki_link.Anchor | Should -Be $Anchor
        }

        It "Should have the Offset '<Offset>'" {
            $wiki_link.Offset | Should -Be $Offset
        }

        It "Should have the Range '<Range>'" {
            $wiki_link.Range | Should -Be $Range
        }
    }
}
