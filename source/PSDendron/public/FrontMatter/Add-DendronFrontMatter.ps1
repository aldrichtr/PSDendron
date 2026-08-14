
function Add-DendronFrontMatter {
    <#
    .SYNOPSIS
        Adds the default keys to the frontmatter of the given file
    .DESCRIPTION
        In dendron, a note has four fields that are added to all files when they are created:
        - id (a nanoid id)
        - title
        - desc
        - updated
        - created
    .LINK
        Set-DendronFrontMatter
        Remove-DendronFrontMatter
    #>
    [CmdletBinding(
        SupportsShouldProcess
    )]
    param(
        # Path to files to add FrontMatter to
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string[]]$Path,

        # Replace existing frontmatter if it exists
        [Parameter(
        )]
        [switch]$Force
    )
    begin {
        Write-Debug "-- Begin $($MyInvocation.MyCommand.Name)"
    }
    process {
        foreach ($file in $Path) {
            $fm = $file | Get-DendronFrontMatter -ErrorAction SilentlyContinue
            if (($fm) -and (-not($Force))) {
                Write-Error "$file already has frontmatter"
            } else {
                $item = Get-Item $file

                $front_matter = [ordered]@{
                    id       = New-DendronContentId
                    title    = ($item.BaseName -split '\.')[-1]
                    created  = ($item.CreationTime | ConvertTo-DendronTimestamp)
                    modified = (Get-Date | ConvertTo-DendronTimestamp)
                }
                Write-Verbose "Adding frontmatter id: $($front_matter.id) title $($front_matter.title) to $($item.basename) "
                $content = $item | Get-Content
                '---', ($front_matter | ConvertTo-Yaml), '---', "`n", $content | Set-Content $item
            }
        }
    }
    end {
        Write-Debug "-- End $($MyInvocation.MyCommand.Name)"
    }
}
