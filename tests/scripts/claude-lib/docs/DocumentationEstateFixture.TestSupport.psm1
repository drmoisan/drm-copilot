<#
.SYNOPSIS
    Test support for issue #1038: the in-memory fixture repository of the documentation-estate
    end-to-end suite.

.DESCRIPTION
    Holds the fixture text and builds the stateful in-memory command context:
    - $DocumentationEstateRevision1 and $DocumentationEstateRevision2 are two fixed, distinct
      40-character lowercase hexadecimal revisions.
    - Get-DocumentationEstateFixtureFile returns the path-to-text map at revision R1: the docs
      profile at docs/documentation-estate/docs-profile.json (one reference directory mode, one page
      owner, docs_complete with max_stale_pages 0, allow_deferred false and the required parity
      dimension 'exists') and one Python source that declares command A ('fixture-tool sync') as an
      argparse add_parser statement written over several lines (D-4).
    - Get-DocumentationEstateRevision2Edit returns the R2 source text: one line inside A's line
      range (its help keyword) changed with A's declaration unchanged, and command B
      ('fixture-tool export') added as the same construct.
    - New-DocumentationEstateFixtureContext wraps New-DocsTestContext of Docs.TestSupport.psm1
      (D-2: its WriteText updates the path-to-text map, so later ReadText, TestFile and ListFile
      calls see the write) with a fixed UtcNow and its InvokeProcess fake, whose calls are recorded
      in ProcessCallLog.
    No file is read or written and no process starts.

.NOTES
    Issue #1038. Requires PowerShell 7.4 or later.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -ErrorAction Stop

Set-Variable -Name DocumentationEstateRevision1 -Value '1038a1b2c3d4e5f60718293a4b5c6d7e8f901038'
Set-Variable -Name DocumentationEstateRevision2 -Value '2038f1e2d3c4b5a60918273645a5b4c3d2e12038'

function Get-DocumentationEstateProfileText {
    <#
    .SYNOPSIS
        Returns the docs profile JSON text of the fixture repository (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return @'
{
  "$schema": "urn:drm-copilot:docs:1.0.0:docs-profile",
  "schema_version": "1.0.0",
  "artifact_kind": "docs-profile",
  "id": "fixture-repository.docs-profile",
  "extensions": {},
  "repository": { "id": "fixture-repository" },
  "audiences": [ { "id": "maintainers", "description": "People who change and release the fixture repository." } ],
  "documentation_roots": [ { "id": "docs-root", "path": "docs", "audience_ids": [ "maintainers" ] } ],
  "surface_selection": {
    "element_kinds": [ "cli-command", "cli-option" ],
    "source_roots": [ "src" ],
    "exclusions": []
  },
  "page_owners": [ { "path_or_glob": "docs/reference/**", "owner": "docs-team" } ],
  "diataxis_policy": {
    "modes": [ "tutorial", "how-to", "reference", "explanation" ],
    "required_front_matter": [ "owner", "last_reviewed", "audience", "diataxis_mode", "surface_refs" ],
    "directory_modes": [ { "path_or_glob": "docs/reference", "mode": "reference" } ]
  },
  "completion_gates": {
    "docs_complete": {
      "required_dispositions_complete": true,
      "allow_deferred": false,
      "max_stale_pages": 0,
      "required_parity_dimensions": [ "exists" ]
    },
    "integration_pr_gate": { "enabled": false }
  },
  "artifact_paths": {
    "inventory_snapshot": "docs/documentation-estate/surface-inventory-snapshot.json",
    "coverage_ledger": "docs/documentation-estate/docs-coverage-ledger.json",
    "parity_matrix": "docs/documentation-estate/docs-parity-matrix.json",
    "evidence_pins": "docs/documentation-estate/docs-evidence-pins.json",
    "validation_receipt": "docs/documentation-estate/docs-validation-receipt.json"
  }
}
'@
}

function Get-DocumentationEstateSourceText {
    <#
    .SYNOPSIS
        Returns the Python source of the fixture repository at R1, or at R2 with -Revision2 (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([switch] $Revision2)

    $syncHelp = if ($Revision2) { 'Synchronize the fixture records and report the changes.' } else { 'Synchronize the fixture records.' }
    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in @(
            'import argparse'
            ''
            ''
            'def build_parser():'
            '    parser = argparse.ArgumentParser(prog="fixture-tool")'
            '    sub = parser.add_subparsers(dest="command")'
            '    sub.add_parser('
            '        "sync",'
            "        help=""$syncHelp"","
            '    )'
        )) { $lines.Add($line) }
    if ($Revision2) {
        foreach ($line in @(
                '    sub.add_parser('
                '        "export",'
                '        help="Export the fixture records.",'
                '    )'
            )) { $lines.Add($line) }
    }
    $lines.Add('    return parser')
    return (($lines -join "`n") + "`n")
}

function Get-DocumentationEstateFixtureFile {
    <#
    .SYNOPSIS
        Returns the path-to-text map of the fixture repository at revision R1.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    return @{
        'docs/documentation-estate/docs-profile.json' = (Get-DocumentationEstateProfileText)
        'src/fixture_tool/cli.py'                     = (Get-DocumentationEstateSourceText)
    }
}

function Get-DocumentationEstateRevision2Edit {
    <#
    .SYNOPSIS
        Returns @{ Path; Text } for the R2 edit of the fixture source.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    return @{ Path = 'src/fixture_tool/cli.py'; Text = (Get-DocumentationEstateSourceText -Revision2) }
}

function New-DocumentationEstateFixtureContext {
    <#
    .SYNOPSIS
        Returns @{ Context; Files; WriteLog; ProcessCallLog; Revisions } for one stateful in-memory context.
    .PARAMETER Files
        The path-to-text map the context starts from.
    .PARAMETER RevisionMap
        Optional ref-to-revision map for ResolveRevision; Revisions in the result is that table, so a
        scenario can move HEAD between steps (issue #1169).
    .PARAMETER AncestorMap
        Optional map for TestAncestor, keyed by the revision pair '<first>..<second>' (issue #1169).
    .PARAMETER ChangedPathMap
        Optional map for ListChangedPath, keyed by the revision pair '<first>..<second>' (issue #1169).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Files,
        [AllowNull()] [System.Collections.IDictionary] $RevisionMap,
        [AllowNull()] [System.Collections.IDictionary] $AncestorMap,
        [AllowNull()] [System.Collections.IDictionary] $ChangedPathMap
    )

    return New-DocsTestContext -File $Files -UtcNow ([datetime]::new(2026, 3, 1, 12, 0, 0, [System.DateTimeKind]::Utc)) -RevisionMap $RevisionMap -AncestorMap $AncestorMap -ChangedPathMap $ChangedPathMap
}

Export-ModuleMember -Function Get-DocumentationEstateFixtureFile, Get-DocumentationEstateRevision2Edit, New-DocumentationEstateFixtureContext -Variable DocumentationEstateRevision1, DocumentationEstateRevision2
