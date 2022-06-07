@{
    Staging = @{
        Path = 'stage'
    }
    Plaster = @{
        Path = 'build/PlasterTemplates'
    }
    Artifact = @{
        Path = 'out'
    }
    Project = @{
        Modules = @{
            Root = @{
                Name = 'PSDendron'
                Path = 'source\PSDendron'
                Module = 'source\PSDendron\PSDendron.psm1'
                Manifest = 'source\PSDendron\PSDendron.psd1'
                Types = @(
                    'enum'
                    'classes'
                    'private'
                    'public'
                )
                CustomLoadOrder = ''
            }
        }
        Name = 'PSDendron'
        Type = 'single'
        Path = 'C:\Users\taldrich\projects\github\PSDendron'
    }
    Docs = @{
        Path = 'docs'
    }
    Build = @{
        Tasks = 'build/Tasks'
        Path = 'build'
        Tools = 'build/Tools'
        Config = 'build/Config'
        Rules = 'build/Rules'
    }
    Source = @{
        Path = 'source'
    }
    Tests = @{
        Config = @{
            Coverage = './.buildtool/pester.config.codecoverage.psd1'
            Performance = './.buildtool/pester.config.performancetests.psd1'
            Analyzer = './.buildtool/pester.config.analyzertests.psd1'
            Unit = './.buildtool/pester.config.unittests.psd1'
        }
        Path = 'tests'
    }
    Clean    = @{
        Targets = @(
            @{
                Path    = 'stage/*'
                Recurse = $True
                Force   = $True
            }
            @{
                Path    = 'out/*'
                Recurse = $True
                Force   = $True
            }
        )

    }
}
