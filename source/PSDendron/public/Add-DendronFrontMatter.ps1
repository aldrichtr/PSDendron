
function Add-DendronFrontMatter {
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
                $now = Get-Date | ConvertTo-DendronTimestamp
                $front_matter = [ordered]@{
                    id       = New-DendronContentId
                    title    = ($item.BaseName -split '\.')[-1]
                    created  = $now
                    modified = $now
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
