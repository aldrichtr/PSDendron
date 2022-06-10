

Describe 'Testing public function Get-DendronLink' -Tag @('unit', 'get', 'dendronlink', 'link') {
    Context 'When the link is valid <Link>' -ForEach @(
        @{
            Link    = '[[txt.name]]'
            Name    = $null
            Target  = 'txt.name'
            Heading = $null
            Span    = $null
        },
        @{
            Link    = '[[this is a name|txt.name]]'
            Name    = 'this is a name'
            Target  = 'txt.name'
            Heading = $null
            Span    = $null
        },
        @{
            Link    = '[[this is a name|txt.name#Heading]]'
            Name    = 'this is a name'
            Target  = 'txt.name'
            Heading = 'Heading'
            Span    = $null
        }
        @{
            Link    = '[[this is a name|txt.name#Heading,1:#*]]'
            Name    = 'this is a name'
            Target  = 'txt.name'
            Heading = 'Heading'
            Span    = '1:#*'
        }
    ) {
        BeforeAll {
            $wiki_link = $Link | Get-DendronLink
        }

        It "Should have the name '<Name>'" {
            $wiki_link.Name | Should -Be $Name
        }

        It "Should have the target '<Target>'" {
            $wiki_link.Target | Should -Be $Target
        }

        It "Should have the target '<Heading>'" {
            $wiki_link.Heading | Should -Be $Heading
        }

        It "Should have the target '<Span>'" {
            $wiki_link.Span | Should -Be $Span
        }
    }
}
