
Function Get-DendronFrontMatter {
    <#
    .SYNOPSIS
        Return a hashtable of the front matter in the file specified
    #>
    [CmdletBinding()]
    param(
        # Path to the file to read
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [ValidateScript(
            {
                if (-Not ($_ | Test-Path)) {
                    throw "$_ does not exist"
                }
                return $true
            }
        )]
        [Alias('PSPath')]
        [string]
        $Path
    )

    begin {
        Write-Debug "Begin $($MyInvocation.MyCommand.Name)"
        $yaml_pattern = '(?sm)---(.*?)---'
    }
    process {
        $file_contents = Get-Content $Path -Raw
        $null = $file_contents -match $yaml_pattern
        if ($Matches.Count -gt 0) {
            $yaml_content = $Matches.1
            Write-Verbose "yaml front matter $yaml_content"
            try {
                $front_matter = $yaml_content | ConvertFrom-Yaml
                $front_matter['PSTypeName'] = 'Dendron.Note.FrontMatter'
                $front_matter.created = $front_matter.created | ConvertFrom-DendronTimestamp
                $front_matter.updated = $front_matter.updated | ConvertFrom-DendronTimestamp
            } catch {
                Write-Error "Error parsing frontmatter:`n$yaml_content`n$_"
            }
        } else {
            Write-Error "$Path does not contain frontmatter"
        }
    }

    end {
        ([PSCustomObject]$front_matter)
    }
}
