
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
        foreach ($p in $Path) {
            Write-Debug "Parsing $p"
            #region File
            $fileInfo = Get-Item $p
            if (-not($fileinfo.Extension -like '.md')) {
                Write-Verbose "$p is not a content file, skipping"
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
            $raw_content = Get-Content $p -Raw
            $content = $raw_content -replace '(?sm)---.*?---', ''
            $tokens = $content | ConvertFrom-Markdown | Select-Object -ExpandProperty Tokens
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
            $front = $p | Get-DendronFrontMatter
            foreach ($p in $front.psobject.properties) {
                $note | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.value
            }
            #endregion frontmatter

            Write-Output $note
        }
    }
    end {
    }
}
