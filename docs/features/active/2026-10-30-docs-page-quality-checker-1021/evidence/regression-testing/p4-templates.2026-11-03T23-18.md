# P4 Templates and Init Rows - Issue #1021

Timestamp: 2026-11-03T23-18
Task: [P4-T4], [P4-T5]
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1 issue-1021-p4-tpl.txt`; `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1 issue-1021-p4-pc.txt` (PowerShell 7 `Invoke-Pester` with the repository run settings over each branch-current suite; `Run.PassThru`)
EXIT_CODE: 0
Output Summary: `DocsPageTemplates.Tests.ps1` TOTAL=9 PASSED=9 FAILED=0; `DocsProfileCommands.Tests.ps1` TOTAL=22 PASSED=22 FAILED=0. Both FAILED_BLOCKS=0, FAILED_CONTAINERS=0. CI: CI-PESTER.

## Templates ([P4-T4])

Five files under `.claude/lib/docs/templates/page-check/` with the content of spec `### Base configuration data (D4: optional, data only)`: `markdownlint.json` (the spec object), `vale.ini` (`StylesPath = .vale/styles`, `MinAlertLevel = warning`, `Vocab = Project`, `[*.md]` with `BasedOnStyles = Vale, DocsBase`, no `Packages` key), `vale/DocsBase/HeadingPunctuation.yml` (`extends: existence`, `scope: heading`), `vale/DocsBase/Placeholders.yml` (`extends: existence`, tokens `TODO`, `TBD`, `FIXME`) and `vale/Project/accept.txt` (0 bytes). No consumer vocabulary, consumer identifier or repository name.

## Rows ([P4-T5])

`git diff --unified=0 MERGE_BASE -- .claude/lib/docs/DocsProfileCommands.psm1` holds one hunk, `@@ -44,0 +45,5 @@ function Get-DocsInitTemplate`: five rows directly under `# --- 1021: page-check configuration ---` (OQ-A default), each `[pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/<file>'; Destination = '<destination>' }` with a repository-relative string `Source` (the merged 1020 row form recorded in `1020-precondition` `## Init template Source and TestFile`; never a `$PSScriptRoot` join) and the spec destinations.

## 1020 tests (dispositions from `1020-test-dispositions`)

| Test | Disposition and reason |
|---|---|
| `creates the profile with mode create under -Write` | updated: the five default rows add five `ReadText` calls and five writes, so the in-memory context now supplies the committed text of the five template sources (read read-only in `BeforeAll`) and the write-log count is the profile plus one write per default row (six) |
| `overwrites the profile with mode overwrite under -Write -Force` | updated: the write loop reads the five sources, so the in-memory context now supplies them alongside the existing profile |
| `exits 1 with DOCS_INIT_TARGET_EXISTS and writes nothing when the target exists` | unchanged, re-run: one finding, first planned write the profile |
| `returns a starter profile accepted by ConvertFrom-DocsProfileText for <_> and writes nothing without -Write` | unchanged, re-run: a dry run calls only `TestFile` |
| `returns only rows whose Source is repository-relative under .claude/lib/docs/templates/` | unchanged, re-run: the new rows satisfy it |
| `carries the 1021 and 1034 anchors in order with no placeholder-numbered anchor` | unchanged, re-run |

## New suite `DocsPageTemplates.Tests.ps1`

Every row line between the 1021 and 1034 anchors has a `Source` starting `.claude/lib/docs/templates/page-check/` that names a committed file, with the spec destination; `accept.txt` has length 0; both Vale styles use `extends: existence` and none uses `substitution` or `spelling`; no template contains `drm-copilot`; `markdownlint.json` parses with `ConvertFrom-DocsJsonText` and equals the spec object under `ConvertTo-DocsCanonicalJson`; the `vale.ini` keys; `init` without `-Write` lists the five destinations in `planned_writes` and the write log is empty; `init -Write` writes each destination with the text of its template source (the empty vocabulary as the empty string) through the in-memory context.
