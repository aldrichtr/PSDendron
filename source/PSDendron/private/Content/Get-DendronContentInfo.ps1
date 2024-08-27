
using namespace System.Collections

function Get-DendronContentInfo {
    <#
    .SYNOPSIS
        Return the ContentInfo properties of the given file
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingBrokenHashAlgorithms',
        '',
        Justification = 'We are only using MD5 to verify the file has not changed'
    )]
    [CmdletBinding()]
    param(
        # The path to the dendron content
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path
    )
    begin {}
    process {
        foreach ($file in $Path) {
            Write-Verbose "Parsing $file"

            #region File
            $fileInfo = Get-Item $file
            if (-not($fileinfo.Extension -like '.md')) {
                Write-Verbose "$file is not a content file, skipping"
                continue
            }

            $hash = $file
            | Get-FileHash -Algorithm MD5
            | Select-Object -ExpandProperty Hash

            $parts = [System.Collections.ArrayList]@()


            $fileInfo.BaseName -split '\.'
            | ForEach-Object {
                [void]$parts.Add($_)
                | Out-Null
            }
            $domain = $parts[0] # the first member
            $level = $parts.Count

            $node = $parts[-1] # the last member

            $hierarchy = ($parts -join '.')

            [void]$parts.Remove($node)

            # The parent is the "node" above this one
            #! It may or may not be an existing file though
            $parent = ($parts -join '.')
            #endregion File

            #region Markdown

            $content = Get-Content $file

            Write-Verbose 'Parsing markdown tokens'
            $tokens = $content
            | ConvertFrom-Markdown
            | Select-Object -ExpandProperty Tokens

            Write-Verbose 'Extracting Heading information'
            $headings = $tokens
            | Where-Object {
                $_.Parser -is [Markdig.Parsers.HeadingBlockParser]
            } | ForEach-Object {
                $h = $_
                $heading = [PSCustomObject]@{
                    Level      = $h.Level
                    Title      = $h.Inline.Content
                    Line       = $h.Line
                    HeaderChar = $h.HeaderChar
                }
                $heading
            }
            Write-Verbose "  Found $($headings.count) headings"

            #endregion Markdown

            $note = @{
                FullName   = $fileInfo.FullName
                Name       = $fileInfo.BaseName
                Level      = $level
                Hash       = $hash
                Node       = $node
                Domain     = $domain
                Parent     = $parent
                Hierarchy  = $hierarchy
                Content    = ($content -split '\n')
                Tokens     = $tokens
                Headings   = $headings
                Links      = [ArrayList]::new()
                Tags       = [ArrayList]::new()
                Traits     = [ArrayList]::new()
                Custom     = @{}
            }

            Write-Verbose "Extracting dendron links"
            foreach ($link in ($fileInfo | Get-DendronLink)) {
                [void]$note.Links.Add($link)
            }

            #region frontmatter
            try {
                Write-Verbose 'Extracting Frontmatter'
                $front = $file | Get-DendronFrontMatter

                foreach ($prop in $front.psobject.properties) {
                    switch ($prop.Name) {
                        'id' { $note['Id'] = $prop.Value }
                        'title' { $note['Title'] = $prop.Value }
                        'desc' { $note['Description'] = $prop.Value }
                        'created' { $note['Created'] = $prop.Value }
                        'updated' { $note['Updated'] = $prop.Value }
                        'tags' {
                            foreach ($tag in $prop.Value) {
                                [void]$note.Tags.Add($tag)
                            }
                        }
                        'tag' { [void]$note.Tags.Add($prop.Value) }
                        'traitIds' {
                            foreach ($trait in $prop.Value) {
                                [void]$note.Traits.Add($trait)
                            }
                        }
                        'nav_order' { $note['Order'] = $prop.Value }
                        default {
                            $note.Custom[$prop.Name] = $prop.Value
                        }
                    }
                    Write-Debug "Adding $($prop.Name) = $($prop.Value) to Note"
                }
            } catch {
                Write-Error "Error parsing frontmatter in $file`n$_"
            }
            #endregion frontmatter

            $note['PSTypeName'] = 'Dendron.Content.NoteInfo'
            [PSCustomObject]$note
        }
    }
    end {
    }
}
