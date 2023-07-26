
function Get-DendronContentInfo {
    <#
    .SYNOPSIS
        Return the ContentInfo properties of the given file
    #>
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
            $parts = $hierarchy = [System.Collections.ArrayList]@('root')
            $fileInfo.BaseName -split '\.' | Foreach-Object { $hierarchy.Add($_) | Out-Null }
            $domain = $hierarchy[1] # the first member after 'root'
            $node = $parts[-1]
            $parts.Remove($node)
            $parent = $parts[-1]
            #endregion File

            #region Markdown

            $content = Get-Content $file
            Write-Verbose "Parsing markdown tokens"
            $tokens = $content | ConvertFrom-Markdown | Select-Object -ExpandProperty Tokens
            Write-Verbose "Extracting Heading information"
            $headings = $tokens | Where-Object {
                    $_.Parser -is [Markdig.Parsers.HeadingBlockParser]
                } | Foreach-Object {
                    $h = $_
                    $heading = [PSCustomObject]@{
                        Level = $h.Level
                        Title = $h.Inline.Content
                        Line  = $h.Line
                        HeaderChar = $h.HeaderChar
                    }
                    $heading
                }
            Write-Verbose "  Found $($headings.count) headings"

            #endregion Markdown

            $note = [PSCustomObject]@{
                PSTypeName = 'Dendron.Content.Note'
                FullName   = $fileInfo.FullName
                BaseName   = $fileInfo.BaseName
                Node       = $node
                Domain     = $domain
                Parent     = $parent
                Hierarchy  = ($hierarchy -join '.')
                Content    = ($content -split '\n')
                Tokens     = $tokens
                Headings   = $headings
            }

            #region frontmatter
            try {
                Write-Verbose "Extracting Frontmatter"
                $front = $file | Get-DendronFrontMatter
                foreach ($prop in $front.psobject.properties) {
                    Write-Debug "Adding $($prop.Name) = $($prop.Value) to Note"
                    $note | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.value
                }
            }
            catch {
                Write-Error "Error parsing frontmatter in $file`n$_"
            }
            #endregion frontmatter

            Write-Output $note
        }
    }
    end {
    }
}
