
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
    begin {
        $yamlPattern = '(?sm)---(?<fm>.*?)---(?<body>.*)'
        $script:DendronIndex = @{}
    }
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
            $level = $parts.Count
            $domain = $parts[0] # the first member

            $node = $parts[-1] # the last member

            $hierarchy = ($parts -join '.')

            # The parent is the "node" above this one
            #! It may or may not be an existing file though
            [void]$parts.Remove($node)
            $parent = ($parts -join '.')
            #endregion File

            #region Markdown

            $content = Get-Content $file -Raw
            $null = $content -match $yamlPattern
            if ($Matches.Count -eq 3) {
                $fmContent = $Matches.fm
                $bodyContent = $Matches.body
            } else {
                Write-Error "Could not find frontmatter in $($fileInfo.Name)"
            }

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
                # --- File information
                FullName  = $fileInfo.FullName
                Path      = $fileInfo.FullName
                Name      = $fileInfo.BaseName
                # --- Hierarchy information
                Level     = $level
                Node      = $node
                Domain    = $domain
                Parent    = $parent
                Hierarchy = $hierarchy
                # --- Content information
                Hash      = $hash
                Type      = [DendronNoteType]::Unknown
                Content   = @{
                    Full        = ($content -split '\n')
                    Body        = $bodyContent
                    Frontmatter = $fmContent
                }
                Tokens    = $tokens
                Headings  = $headings
                Links     = [ArrayList]::new()
                Tags      = [ArrayList]::new()
                Traits    = [ArrayList]::new()
                Custom    = @{}
            }

            Write-Verbose 'Extracting dendron links'
            foreach ($link in ($fileInfo | Get-DendronLink)) {
                [void]$note.Links.Add($link)
            }

            #region frontmatter
            try {
                Write-Verbose 'Extracting Frontmatter'

                $front = $fmContent | ConvertFrom-Yaml

                foreach ($prop in $front.GetEnumerator()) {
                    switch ($prop.Name) {
                        # --- dendron default fields
                        'id' { $note['Id'] = $prop.Value }
                        'title' { $note['Title'] = $prop.Value }
                        'desc' { $note['Description'] = $prop.Value }
                        'created' { $note['Created'] = $prop.Value | ConvertFrom-DendronTimestamp }
                        'updated' { $note['Updated'] = $prop.Value | ConvertFrom-DendronTimestamp }
                        # --- dendron optional task fields
                        'status' { $note['Status'] = $prop.Value ?? '' }
                        'priority' { $note['Priority'] = $prop.Value ?? '' }
                        'due' { $note['Due'] = $prop.Value ?? '' }
                        'owner' { $note['Owner'] = $prop.Value ?? '' }
                        'issueID' { $note['IssueID'] = $prop.Value ?? '' }
                        # --- dendron optional site (publishing) fields
                        ## - Pull out Order for sorting
                        'nav_order' { $note['Order'] = $prop.Value }
                        # 'published' { $note['Published'] = $prop.Value }
                        # 'noindex' { $note['Noindex'] = $prop.Value }
                        # 'canonicalUrl' { $note['CanonicalUrl'] = $prop.Value }
                        # 'nav_exclude' { $note['Exclude'] = $prop.Value }
                        # 'nav_exclude_children' { $note['ExcludeChildren'] = $prop.Value }
                        # 'permalink' { $note['Permalink'] = $prop.Value }
                        # 'has_collection' { $note['HasCollection'] = $prop.Value }
                        # 'sort_by' { $note['SortBy'] = $prop.Value }
                        # 'sort_order' { $note['SortOrder'] = $prop.Value }
                        # 'skipLevels' { $note['SkipLevels'] = $prop.Value }
                        # --- dendron optional
                        'config' { $note['Config'] = $prop.Value }
                        'color' { $note['Color'] = $prop.Value }
                        'image' { $note['Image'] = $prop.Value }
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
            if ($script:DendronIndex.ContainsKey($note.Id)) {
                $note['DuplicateOf'] = $script:DendronIndex[$note.Id]
            } else {
                $script:DendronIndex[$note.Id] = $note.Path
            }

            if (($note.ContainsKey('Status')) -and
                (($note.ContainsKey('Priority')) -or
                ($note.ContainsKey('IssueID')))) {
                    Write-Debug "- Note type: Task"
                $note.Type = [DendronNoteType]::Task
            } elseif ($note.Traits.Count -gt 0) {
                if ($note.Traits -contains 'journalNote') {
                    Write-Debug "- Note type: Journal"
                    $note.Type = [DendronNoteType]::Journal
                }
            } else {
                Write-Debug "- Note type: Note"
                $note.Type = [DendronNoteType]::Note
            }
            $note['PSTypeName'] = 'Dendron.Content.NoteInfo'
            [PSCustomObject]$note
        }
    }
    end {
    }
}
