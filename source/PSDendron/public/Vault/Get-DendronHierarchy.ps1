
using namespace System.Collections

function Get-DendronHierarchy {
	<#
	.SYNOPSIS
		Return a tree-like structure of the content in the given vault
	#>
	[CmdletBinding()]
	param(
		# Specifies a path to one or more locations.
		[Parameter(
		Position = 0,
		ValueFromPipeline,
		ValueFromPipelineByPropertyName
		)]
		[Alias('PSPath')]
		[string]$Path
	)
	begin {
		Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
		# Structure used for final output
		$tree = [ordered]@{
			root = [ordered]@{}
		}
		$root = $tree['root']

		# initial structure used to collect content for sorting
		$entities = @{}
		$domains = [ArrayList]::new()
		$maxLevel = 0
	}
	process {
		if ($Path | Test-Path) {
			$mdFiles = Get-ChildItem -Path $Path -Filter "*.md"

			$total = $mdFiles.Count
			$count = 0

			Write-Progress -Activity "Importing Content" -Status ""
			Write-Debug "Importing content"
			$Path
			| Get-DendronContent
			| ForEach-Object {
				$percent = ($count / $total) * 100
				Write-Progress -Activity "Importing Content" -Status "%$percent" -PercentComplete $percent
				if ($_.Level -gt $maxLevel) {
					$maxLevel = $_.Level
				}

				if ($_.Level -eq 1) {
					[void]$domains.Add($_.Hierarchy)
					$entities[$_.Name] = $_
				}
				$count++
			}

			[void]$domains.Sort()

			$total = $domains.Count
			$count = 0
			foreach ($domain in $domains) {
				$percent = ($count / $total) * 100
				Write-Progress -Activity "Creating Domains" -Status "%$percent" -PercentComplete $percent
			   [void]$root.Add($domain, $entities[$domain])
			}

			for ($i=2;$i -le $maxLevel; $i++) {
				$entities.Values
				| Where-Object { $_.Level -eq $i }
				| Foreach-Object {
					Write-Progress -Activity "Sorting $($_.Hierarchy)"
					# split the hierarchy so we can "walk" the tree to it's rightful spot
					$parts = $_.Parent -split '\.'
					$parentNode = $root
					foreach ($part in $parts) {
						if ($null -ne $parentNode[$part]) {
							$parentNode = $parentNode[$part]
						}
					}
					[void]$parentNode.Add($_.Hierarchy, $entities[$_.Hierarchy])
				}
			}
		}
		$tree

	}
	end {
		Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
	}
}
