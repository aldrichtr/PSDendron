@{
    #---------------------------------------------------------------------------
    #region Module Info

    ModuleVersion = '0.1.10'
    Description = 'PowerShell module for interacting with Dendron'
    GUID = 'fca09d88-bbcb-4329-871e-eb9d8a83b0cb'
    # HelpInfoURI = ''

    #endregion Module Info
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    #region Module Components

    RootModule = 'PSDendron.psm1'
    # ScriptsToProcess = @()
    # TypesToProcess = @()
    # FormatsToProcess = @()
    # NestedModules = @()
    # ModuleList = ''
    # FileList = @()

    #endregion Module Components
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    #region Public Interface

    CmdletsToExport = '*'
    FunctionsToExport = '*'
    VariablesToExport = '*'
    AliasesToExport = '*'
    # DSCResourcesToExport = @()
    # DefaultCommandPrefix = ''

    #endregion Public Interface
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    #region Requirements

    # CompatiblePSEditions = @()
    # PowerShellVersion = ''
    # PowershellHostName = ''
    # PowershellHestVersion = ''
    RequiredModules = @(
        @{
            ModuleName = 'Configuration'
            GUID = 'e56e5bec-4d97-4dfd-b138-abbaa14464a6'
            ModuleVersion = '1.6.0'
        }
    )
    RequiredAssemblies = @('Assemblies\nanoid.dll')
    # ProcessorArchitecture = ''
    # DotNetFrameworkVersion = ''
    # CLRVersion = ''

    #endregion Requirements
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    #region Author

    Author = 'Tim Aldrich'
    CompanyName = 'aldrichtr'
    Copyright = '(c) Tim Aldrich. All rights reserved.'

    #endregion Author
    #---------------------------------------------------------------------------

    PrivateData = @{
        PSData = @{
        #---------------------------------------------------------------------------
        #region Project

        # Tags = @()
        LicenseUri = 'https://github.com/aldrichtr/PSDendron/blob/main/LICENSE'
        ProjectUri = 'https://github.com/aldrichtr/PSDendron'
        IconUri = ''
        PreRelease = ''
        RequireLicenseAcceptance = ''
        ExternalModuleDependencies = @()
        # ReleaseNotes = ''

        #endregion Project
        #---------------------------------------------------------------------------

        } # end PSData
    } # end PrivateData
} # end hashtable
