#
# Module manifest for module 'AnalyzerRules'
#
# Generated by: Timothy Aldrich
#
# Generated on: 2023-05-03
#

@{

    # Script module or binary module file associated with this manifest.
    # RootModule = ''

    # Version number of this module.
    ModuleVersion     = '0.0.1'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = 'ab3b906a-640f-48e2-b78e-cd98d64a907a'

    # Author of this module
    Author            = 'Timothy Aldrich'

    # Company or vendor of this module
    CompanyName       = 'aldrichtr'

    # Copyright statement for this module
    Copyright         = '(c) Timothy Aldrich. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Custom rules for PSScriptAnalyzer'

    # Minimum version of the PowerShell engine required by this module
    # PowerShellVersion = ''

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules     = @(
        @{
            ModuleName    = 'AnalyzerHelpers'
            ModuleVersion = '0.1.0'
            GUID          = '57565b17-5b7f-4b3d-8def-d55e0bf71075'
        }
        @{
            ModuleName    = 'AnalyzerRules'
            ModuleVersion = '0.0.1'
            GUID          = 'ab3b906a-640f-48e2-b78e-cd98d64a907a'
        }
        @{
            ModuleName    = 'FormatAndStyle'
            ModuleVersion = '0.1.0'
            GUID          = '5f613430-ae06-424a-a339-5389f32ad979'
        }
        @{
            ModuleName    = 'CommentBasedHelp'
            ModuleVersion = '0.0.1'
            GUID          = 'e7dcfedf-7828-428b-81ee-caec56e3abfc'
        }
        @{
            ModuleName    = 'Performance'
            ModuleVersion = '0.0.1'
            GUID          = 'dc2f8c29-9b5b-4030-87e1-4f6682bafd97'
        }

    )
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = '*'

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = '*'

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = '*'

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = 'utility', 'pssa'

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/aldrichtr/custom-pssa-rules/blob/main/LICENSE.md'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/aldrichtr/custom-pssa-rules'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = ''

            # Prerelease string of this module
            Prerelease = '0.1.0-beta1'

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable


    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}
