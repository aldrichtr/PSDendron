

Describe 'Testing public function Get-DendronTask' -Tag @('unit', 'get', 'dendronTask', 'task') {
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
}
