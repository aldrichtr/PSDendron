
function New-DendronNote {
    <#
    .SYNOPSIS
        Create a new note in a dendron vault
    .DESCRIPTION
        `New-DendronNote` creates a new markdown file in the specified vault with a proper name and the proper front
        matter.
    .EXAMPLE
        Get-DendronVault | New-DendronNote "daily journal $(Get-Date -Format 'yyyy.MM.dd')"

        # daily.journal.2022.06.07.md created in the vault
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The vault to create the note in
        [Parameter(
            ValueFromPipeline
        )]
        [PSTypeName('Dendron.Vault')]$Vault,

        # Name of file to create
        # space (' '), underscore ('_') will be
        # converted to dot ('.')
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Optionally provide a description
        [Parameter(
        )]
        [Type]$Description,

        # Optionally provide tags
        [Parameter(
        )]
        [string[]]$Tags,

        # Optional hashtable of additional frontmatter
        [Parameter(
        )]
        [hashtable]$FrontMatter

    )
    begin {
        Write-Debug "-- begin $($MyInvocation.MyCommand.Name)"
        $note_ext = '.md'
    }
    process {
        if (-not($PSBoundParameters['Vault'])) {
            try {
                $Vault = Get-DendronVault
                switch ($Vault.Count) {
                    0 {Write-Error "Could not find a Vault to create Note in"}
                    1 {continue}
                    Default {
                        Write-Error "Multiple Vaults found.  Please specify a vault to add note to"
                    }
                }
            }
            catch {
                Write-Error "Not in a Dendron workspace.  Please provide a vault to create the note in"
            }
        }

        Write-Debug "Converting '$Name' to proper dot hierarchy"
        $new_name = $Name -replace ' |_', '.'
        Write-Debug "Name: $new_name"
        $title = @($new_name -split '\.')[-1]
        Write-Debug "title set to $title"
        $id = New-DendronContentId
        $now = Get-Date
        $created = $modified = $now | ConvertTo-DendronTimestamp
        $file_path = Join-Path $Vault.Content -ChildPath "$new_name$note_ext"
        $front_matter = [ordered]@{
            id      =  $id
            title   =  $title
            desc    =  $Description
            updated =  $modified
            created =  $created
        }
        if ($PSBoundParameters.ContainsKey('FrontMatter')) {
            foreach ($key in $FrontMatter.Keys) {
                $front_matter[$key] = $FrontMatter[$key]
            }
        }

        if ($Tags.Count -gt 0) { $front_matter['tags'] = $Tags }

        try {
            $file = New-Item -ItemType File -Path $file_path  -ErrorAction Stop
            "---", ($front_matter | ConvertTo-Yaml), "---" | Add-Content $file
        } catch {
            Write-Error "Could not create $file_path`n$_"
        }


        Write-Output "Creating '$file_path' with frontmatter:`n$($front_matter | ConvertTo-Yaml)`n"
    }
    end {
        Write-Debug "-- end $($MyInvocation.MyCommand.Name)"
    }
}
