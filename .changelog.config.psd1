@{
    Header = @"
# Changelog

All notable changes to this project will be documented in this file.
"@

    Footer = ""


    CurrentVersion = 'unreleased'

    # Baseuri to view your commit details
    ProjectBaseUri = 'https://github.com/aldrichtr/stitch'

    TagPattern = 'v(.*)$'

    Format = @{

        <#
        {desc} entry.Description
        {type} entry.Type
        {scope} entry.Scope
        {title} entry.Title
        {sha} entry.ShortSha
        {ft.name} entry.Footers.Name
        {author} entry.Author.Name
        {email} entry.Author.Email
    #>
        Release = '## [{name}] - {date yyyy-MM-dd}'
        Group   = '### {name}'
        Entry = '- {sha} {desc} ({author})'
        BreakingChange = '- {sha} **breaking change** {desc} ({author})'
    }

    <#
    These are the "chunks" that might be searched.  They are all properties of the output of
    `ConvertFrom-ConventionalCommit`

    - Message: The entire git message
    - Title: The first line of the message
    - Body: Ignore the first line and look for message
    - Footer: A specific footer (Footers are key => value pairs)
    If it is a conventional commit, these are also available
    - Type: The extracted type : an array of 0 or more matches
    - Description: Everything to the right of the : in the Title
    - Scope: The extracted scope : an array of 0 or more matches
    - Breaking: Either a '!' in the Title or a BREAKING CHANGE footer :
    -
    #>
    Groups = @{
        Fixes = @{
            Type  = @('fix', 'bug', 'bugfix' , '🐛' )
            DisplayName = 'Bug Fixes'
            Sort = 2
        }
        Features = @{
            Type = @('feat', '✨')
            Title = @(
                '^[aA]dd',
                '^update'
            )
            DisplayName = 'New Features and improvements'
            Sort = 1
        }
        Doc = @{
            Type = @('doc(s)?')
            DisplayName = "Documentation"
            Sort = 3
        }
        Other = @{
            Type = @(
                'build',
                'task'
            )
            DisplayName = 'Other'
            Sort = 4
        }
        Omit = @{
            Title = @(
                'RE:',
                'Update azure-pipelines.yml for Azure Pipelines',
                'bump version',
                '🙊',
                'Merged in',
                '^Merge pull request'
            )
        }
    }
}
