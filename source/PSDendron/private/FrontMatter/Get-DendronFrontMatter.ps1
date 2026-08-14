
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
        $yamlPattern = '(?sm)---(.*?)---'
    }
    process {
        $fileContents = Get-Content $Path -Raw
        $null = $fileContents -match $yamlPattern
        if ($Matches.Count -gt 0) {
            $yamlContent = $Matches.1
            Write-Verbose "yaml front matter $yamlContent"
            try {
                $frontMatter = $yamlContent | ConvertFrom-Yaml
                $frontMatter['PSTypeName'] = 'Dendron.Note.FrontMatter'
                $frontMatter.created = $frontMatter.created | ConvertFrom-DendronTimestamp
                $frontMatter.updated = $frontMatter.updated | ConvertFrom-DendronTimestamp
            } catch {
                Write-Error "Error parsing frontmatter:`n$yamlContent`n$_"
            }
        } else {
            Write-Error "$Path does not contain frontmatter"
        }
    }

    end {
        ([PSCustomObject]$frontMatter)
    }
}
