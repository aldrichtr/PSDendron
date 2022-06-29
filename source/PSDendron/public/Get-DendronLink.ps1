
function Get-DendronLink {
    <#
    .SYNOPSIS
        Get the "wiki" links from the files specified
    .DESCRIPTION
        `Get-DendronLink` retrieves the links in the given content and returns `Dendron.Graph.Edge` objects
        representing the directed edge between two nodes (files)

        Additionally, a link can be a "Note Reference", which provides additional metadata for use in transclusion.
    .NOTES
       See https://wiki.dendron.so/notes/f1af56bb-db27-47ae-8406-61a98de6c78c/
    .LINK
        Get-DendronContent
    .EXAMPLE
        Get-DendronLink my.notes
    #>
    [CmdletBinding()]
    param(
        # Markdown content
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path
    )
    begin {
        Write-Debug "-- Begin $($MyInvocation.MyCommand.Name)"

        $DENDRON_DELIMITER = 'dendron://'

        $link_pattern = @(
            '(?<nref>!)?', # If the link starts with a '!' it is a Note Reference
            [regex]::Escape('[['), # Wikilink start
            '(?<link>.*?)', # Everything inside is the link part, further processed below
            [regex]::Escape(']]')           # Wikilink end
        ) -join ''

        $cross_vault_pattern = @(
            [regex]::Escape($DENDRON_DELIMITER),
            '(?<vault>\w+)', # Extract the vault alias
            [regex]::Escape('/'),
            '(?<link>.*?)'
        ) -join ''
    }
    process {
        foreach ($file in $Path) {
            if (-not(Test-Path $file)) {
                Write-Error "'$file' is not a valid path"
                next
            }

            $line_num = 1
            $from = (Get-Item $file).BaseName
            foreach ($line in (Get-Content $file)) {

                if ($line -match $link_pattern) {
                    Write-Debug "'$line' is a wikilink"
                    if (-not($Matches.ContainsKey('nref'))) {
                        Write-Verbose "line $line_num : Note Reference found"
                        $type = 'Dendron.WikiLink'
                    } else {
                        $type = 'Dendron.NoteReference'
                    }
                    $link = $Matches.link

                    <#------------------------------------------------------------------
                      If there is an alias / displayname
                    ------------------------------------------------------------------#>
                    if ($link.IndexOf('|') -ge 0) {
                        $alias, $target = $link -split '\|'
                        Write-Debug " - This link has an alias '$alias'"
                    } else {
                        $target = $link
                    }

                    # now process the target

                    <#------------------------------------------------------------------
                     Check for a cross-vault link
                    ------------------------------------------------------------------#>
                    if ($target -match $cross_vault_pattern) {
                        $vault = $Matches.vault
                        $target = $Matches.link
                        Write-Debug " - This link is a cross-vault link to '$vault'"
                    }

                    <#------------------------------------------------------------------
                      If there is an anchor
                    ------------------------------------------------------------------#>

                    if ($target.IndexOf('#') -eq 0) {
                        Write-Debug " - The target is the same file"
                        $fname = $from
                    }
                    if ($target.IndexOf('#') -ge 0) {
                        Write-Debug ' - The target includes an anchor'
                        if ($target -match '(?<t>[^#]+?)#(?<a>.*)') {
                            $fname = $Matches.t ?? ''
                            $anchor = $Matches.a
                            Write-Debug "   - to '$fname'"
                            Write-Debug "   - anchor is '$anchor'"


                            <#------------------------------------------------------------------
                              Range reference
                            ------------------------------------------------------------------#>
                            if ($anchor.IndexOf(':')) {
                                $start , $end    = $anchor -split ':#'

                                Write-Debug " - The anchor is a range reference from '$start' to '$end'"
                            } else {
                                $start = $anchor
                            }

                            if ($start.IndexOf(',')) {
                                $start, $offset = $start -split ','
                                Write-Debug " - The range contains an offset of '$offset'"
                            }
                        }
                    } else {
                        $fname = $target
                        Write-Debug " - This link to '$fname' does not have an anchor"
                    }

                    <#------------------------------------------------------------------
                Put it all together now
                ------------------------------------------------------------------#>

                    $wiki_link = [PSCustomObject]@{
                        PSTypeName  = $type
                        Vault       = $vault
                        From        = $from
                        Line        = $line_num
                        DisplayName = $alias
                        To          = $fname
                        Anchor      = $start
                        Offset      = $offset ?? 0
                        Range       = $end
                    }

                    $wiki_link | Write-Output
                }
                $line_num++
            }
        }
    }
    end {
        Write-Debug "-- End $($MyInvocation.MyCommand.Name)"
    }
}
