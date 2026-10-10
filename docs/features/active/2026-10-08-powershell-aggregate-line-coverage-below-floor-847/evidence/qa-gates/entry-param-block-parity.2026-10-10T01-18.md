# Entry Param-Block Parity (Issue #847, AC-04)

Timestamp: 2026-10-10T01-18
Task: [P7-T13]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "P7-T13 param-block parity"), the AST comparison is replaced by `git diff --unified=0 BASE_SHA -- <entry>` hunk headers, which show that no hunk starts within lines 1..N, plus a manual param-block comparison of `git show BASE_SHA:<entry>` against the worktree file. Acceptance values (`DIFFERENCES=0` and `PREFIX_DIFFERENCES=0` per script) are unchanged.
Command: (1) `git diff --unified=0 460cd755de560b733be0c471d1d144e553fbe0e5 -- scripts/dev-tools/bootstrap-host.ps1 scripts/dev-tools/verify-host.ps1 scripts/dev-tools/publish-sideloaded-extension.ps1 | grep -E '^(diff --git|@@)'`; (2) `git show 460cd755de560b733be0c471d1d144e553fbe0e5:<entry>` (bootstrap lines 1-20, verify lines 1-5, publish lines 20-53); (3) `git grep -n -E -e '^\)$' -e '^param\(' -e '^\[CmdletBinding' -- <three entries>` (worktree param-block boundaries).
EXIT_CODE: 0
Output Summary:
- scripts/dev-tools/bootstrap-host.ps1 (N=18): hunk old-side starts 23, 67, 69, 81, 89, 369; minimum 23 > 18 -> PREFIX_DIFFERENCES=0. The param block spans worktree lines 2-18 (`[CmdletBinding()]` at 2, `param(` at 3, `)` at 18), entirely inside the unchanged prefix -> DIFFERENCES=0.
- scripts/dev-tools/verify-host.ps1 (N=3): hunk old-side starts 8, 13, 15, 323; minimum 8 > 3 -> PREFIX_DIFFERENCES=0. Param block `[CmdletBinding()]` (line 2) and `param()` (line 3), inside the prefix -> DIFFERENCES=0.
- scripts/dev-tools/publish-sideloaded-extension.ps1 (N=51): hunk old-side starts 56, 58, 362, 368, 372, 376, 396, 402; minimum 56 > 51 -> PREFIX_DIFFERENCES=0. Param block spans lines 23-51 (`[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]` at 23, `param(` at 24, `)` at 51), inside the prefix, including both default expressions -> DIFFERENCES=0.
- Result: PASS (AC-04).

## Derivation

A `git diff --unified=0` hunk header `@@ -a[,b] +c[,d] @@` covers base lines starting at `a` (for a pure insertion, `-a,0` inserts after base line `a`). When every hunk's base start exceeds N, base lines 1..N appear unchanged as worktree lines 1..N. Line counts on the new side are equal up to that point, so the prefix comparison has no differing index. The param block of each script ends at or before line N, so its attributes, parameter names, types, default expressions, and parameter attributes are byte-identical between BASE_SHA and the worktree. The element-by-element param-block lists are therefore equal.

## Param-block lists (identical at BASE_SHA and in the worktree)

bootstrap-host.ps1:
- `[CmdletBinding()]`
- Name=Apply;Type=System.Management.Automation.SwitchParameter;Default=<none>;Attributes=[Parameter()]|[switch]
- Name=EnableAutoResumeAfterReboot;Type=System.Management.Automation.SwitchParameter;Default=<none>;Attributes=[Parameter()]|[switch]
- Name=WorkspaceRoot;Type=System.String;Default=<none>;Attributes=[Parameter()]|[string]
- Name=RepoRoot;Type=System.String;Default=<none>;Attributes=[Parameter()]|[string]
- Name=SkipProjectPoetryInstall;Type=System.Management.Automation.SwitchParameter;Default=<none>;Attributes=[Parameter()]|[switch]

verify-host.ps1:
- `[CmdletBinding()]`
- (no parameters)

publish-sideloaded-extension.ps1:
- `[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]`
- Name=RepoRoot;Type=System.String;Default=(Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path;Attributes=[Parameter()]|[ValidateNotNullOrEmpty()]|[string]
- Name=CodeCommand;Type=System.String;Default="";Attributes=[Parameter()]|[AllowEmptyString()]|[string]
- Name=UseInsiders;Type=System.Management.Automation.SwitchParameter;Default=<none>;Attributes=[Parameter()]|[switch]
- Name=VsixOutputDir;Type=System.String;Default=(Join-Path $RepoRoot "artifacts\vsix");Attributes=[Parameter()]|[ValidateNotNullOrEmpty()]|[string]
- Name=SkipNpmCi;Type=System.Management.Automation.SwitchParameter;Default=<none>;Attributes=[Parameter()]|[switch]
- Name=SkipCompile;Type=System.Management.Automation.SwitchParameter;Default=<none>;Attributes=[Parameter()]|[switch]
- Name=SkipInstall;Type=System.Management.Automation.SwitchParameter;Default=<none>;Attributes=[Parameter()]|[switch]
- Name=Force;Type=System.Management.Automation.SwitchParameter;Default=<none>;Attributes=[Parameter()]|[switch]

Note: the lists were transcribed manually from the `git show` output (the amendment's route); the type-constraint attribute is listed as written in source.
