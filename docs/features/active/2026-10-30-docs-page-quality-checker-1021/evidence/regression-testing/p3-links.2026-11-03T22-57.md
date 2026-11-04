# P3 Links, Anchors and Slugs - Issue #1021

Timestamp: 2026-11-03T22-57
Task: [P3-T1]
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1 issue-1021-p3-links.txt` (PowerShell 7 `Invoke-Pester` with the repository run settings over the branch-current suite; `Run.PassThru`)
EXIT_CODE: 0
Output Summary: TOTAL=44 PASSED=44 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0. Property-test seed: 20261030 (25 rounds). CI: CI-PESTER.

## Scope

- Module `.claude/lib/docs/DocsPageLinks.psm1` (331 lines, so no `DocsPageAnchors.psm1` split): `Get-DocsPageSlug`, `Get-DocsPageAnchor`, `Get-DocsPageLink`, `Resolve-DocsPageLinkTarget`, `Get-DocsPageExternalTarget`, `Get-DocsPageLinkFinding`; imports `DocsFinding.psm1` and `DocsPageMarkdown.psm1` by literal joins.
- Suite `tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1`: slug steps (links and images reduced, tags removed, Unicode letters and combining marks kept by code point, punctuation and symbols removed, `_` kept, double spaces not collapsed); duplicates `-1`, `-2`, `-3` skipping a taken value; explicit `<a id>` and `<a name>` anchors with code-span, comment and fence instances ignored; inline, image (including an image nested in link text), `<...>` destination and definition forms; skipped scheme, drive-letter scheme, `//` and empty targets; percent-decoding of path and fragment; root-relative, escaping, directory (`README.md`, `index.md`, page-directory prefix) and `-ExistingPath` resolution; `DOCS_PAGE_LINK_BROKEN` with `related_paths`; `DOCS_PAGE_LINK_ESCAPES_REPOSITORY`; `DOCS_PAGE_ANCHOR_MISSING`; `DOCS_PAGE_LINK_ANCHOR_MISSING` with the target page in `related_paths`; fragments on non-page targets not checked; links and anchors in fences, comments, code spans and generated-block markers produce nothing; self-links produce no edge.
- Property test (seeded `[System.Random]` 20261030, seed and round printed through `-Because`): anchors are unique per page and recomputation gives the same slugs.
- First run: 44 of 44 passed.
