# PSDendron

Project Info| &nbsp;
--- | ---
Name | PSDendron
Version | Pre-release
Status | Active

## Synopsis
A PowerShell module for working with [dendron](https://www.dendron.so) workspaces

## Description

Dendron is a vscode extension for managing information using a [hierarchical
model](https://blog.dendron.so/notes/3dd58f62-fee5-4f93-b9f1-b0f0f59a9b64/).

PSDendron provides cmdlets to work with these notes and the associated configuration files, folder structure, naming
standard and metadata.

## Notes

As this is a *very early*  pre-release, this information is subject to change.


Currently, PSDendron supports the following objects:

**Workspace**
Although not exposed as an object at this time, PSDendron has two private functions for working with a `Workspace`
- [x] **Test-DendronWorkspace** : Test if the given path is a Dendron workspace root
- [x] **Resolve-DendronWorkspace** : Recurse up the filesystem to the root of the workspace and return it

Additionally, one public function

- [x] **Get-DendronConfiguration** : Return an object from the dendron.yml file (the workspace configuration)

**Vault**

- [x] **Get-DendronVault** : List the Vaults in the given Workspace

**Content**

In this context, Content refers to all of the markdown files in the given vault.

- [x] **Get-DendronContent** : Return an object representing each file provided

Get-DendronContent has several supporting functions

- [x] **Get-DendronContentInfo** : Converts an individual markdown file into a `Dendron.Content` object
- [x] **Get-DendronFrontMatter** : Parse the yaml frontmatter of a given file and return the fields for inclusion in
  the `Dendron.Content` object
- [x] **ConvertTo-DendronTimestamp** : Convert a timestamp from a `[DateTime]` to "milliseconds since the Unix
  Epoch"
- [x] **ConvertFrom-DendronTimestamp** : Convert a timestamp from a "milliseconds since the Unix
  Epoch" to a `[DateTime]`

Also, there are two functions for parsing specific items from the Markdown content

- [x] **Get-DendronLink** : Parse Markdown provided as input for "wiki style" dendron links. This function can parse
  the target, alternate name, header, and "content span" from a link
- [x] **Get-DendronTask** : Parse Markdown provided as input for GFM style tasks

Finally, a rudimentary content creation function

- [x] **New-DendronNote** : Create a new markdown file in the given vault.

It has one supporting function to create the nanoid in keeping with the dendron standard

- [x] **New-DendronContentId** : Uses the [nanoid.net](https://github.com/codeyu/nanoid-net) assembly to create a compatible id for markdown files.



## Example
```powershell
cd \
git clone https://github.com/dendronhq/dendron-docs
cd dendron-docs
```

**Get-DendronVault**

![get-dendronvault](/docs/images/get-dendronvault.png)


## Example

**Get-DendronContent**

![get-dendroncontent](/docs/images/get-dendroncontent.png)

## Example

**Get-DendronLink**

![get-dendronlink](/docs/images/get-dendronlink.png)

## Example

**Get-DendronTask**

![get-dendrontask](/docs/images/get-dendrontask.png)
