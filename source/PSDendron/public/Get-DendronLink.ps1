
function Get-DendronLink {
    <#
    .SYNOPSIS
        Get the "wiki" links from the files specified
    .DESCRIPTION
        `Get-DendronLink` retrieves the links in the given content and returns `Dendron.Content` objects representing the target files
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
        [string[]]$Markdown
    )
    begin {
        Write-Debug "-- Begin $($MyInvocation.MyCommand.Name)"
#     $link_pattern = @'
# (?x)                                # Allow whitespace and comments
# \[\[                                # two open brackets starts a wiki link
# (?<name>.*?)\s*                     # followed by a string of text denoting the name
# \|?
# \s*(?<target>[^\]\#]*)
# (?<head>\#\w+)?
# ,?
# (?<sp_from>\d+)?:?(?<sp_to>.*)?
# \]\]
# '@

        $link_pattern = '\[\[(?<link>.*)\]\]'
    }
    process {
        foreach ($line in $Markdown) {
            if ($line -match $link_pattern) {
                Write-Debug "'$line' is a wikilink"
                $link = $Matches.link
                if ($link.IndexOf('|') -ge 0) {
                    $name, $target = $link -split '\|'
                    Write-Debug "This link has an alternate name '$name'"
                } else {
                    $target = $link
                }

                Write-Debug "The target is '$target'"
                if ($target.IndexOf('#') -ge 0) {
                    Write-Debug "The target includes a heading"
                    if ($target -match '(?<t>.*?)#(?<h>.*)$') {
                        $head = $Matches.h
                        $target = $Matches.t
                    }

                    if($head.IndexOf(',') -ge 0) {
                        $head, $span = $head -split ','
                    }
                }




                $wiki_link = [PSCustomObject]@{
                    PSTypeName = 'Dendron.Link'
                    Name       = $name
                    Target     = $target
                    Heading    = $head
                    Span       = $span
                }
                $wiki_link | Write-Output
            }
        }
    }
    end {
        Write-Debug "-- End $($MyInvocation.MyCommand.Name)"
    }
}
