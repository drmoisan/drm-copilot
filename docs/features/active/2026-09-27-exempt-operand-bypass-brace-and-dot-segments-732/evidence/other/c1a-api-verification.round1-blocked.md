# C1a API Verification (issue #738, consumer of #824)

Timestamp: 2026-10-09T02-52
Task: [P0-T9]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/r-api.sh (R-API over .claude/hooks/hook-command-invocation.ps1 and .claude/hooks/hook-command-scanner.ps1)
EXIT_CODE: 0
DIFF_COMMAND: git diff --quiet origin/epic/enforcement-hook-precision-integration -- .claude/hooks/hook-command-invocation.ps1 .claude/hooks/hook-command-scanner.ps1 .codex/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-scanner.ps1
UNCHANGED_FROM_INTEGRATION_EXIT: 0

## R-API output (verbatim)

```text
API: .claude/hooks/hook-command-invocation.ps1 | Get-CommandLineTransparentWrapperName | params:  | outputtype: [string[]]
API: .claude/hooks/hook-command-invocation.ps1 | Get-CommandLineGlobalOption | params: CommandWord:String | outputtype: [pscustomobject]
API: .claude/hooks/hook-command-invocation.ps1 | Test-CommandLineTokenLiteral | params: Token:String | outputtype: [bool]
API: .claude/hooks/hook-command-invocation.ps1 | Test-CommandLineAllWordPresent | params: Text:String,Word:String[] | outputtype: [bool]
API: .claude/hooks/hook-command-invocation.ps1 | Skip-CommandLineOption | params: Token:String[],StartIndex:Int32,Option:PSObject | outputtype: [pscustomobject]
API: .claude/hooks/hook-command-invocation.ps1 | Get-CommandLineStructuralWalk | params: Token:String[],CommandWord:String,SubcommandPath:String[],Option:PSObject | outputtype: [pscustomobject]
API: .claude/hooks/hook-command-invocation.ps1 | Get-CommandLineInvocationOperand | params: Token:String[],StartIndex:Int32,Option:PSObject,ArgumentInjected:Boolean | outputtype: [pscustomobject]
API: .claude/hooks/hook-command-invocation.ps1 | ConvertTo-CommandLineIndeterminateMatch | params: Record:PSObject,Reason:String | outputtype: [pscustomobject]
API: .claude/hooks/hook-command-invocation.ps1 | Get-CommandLineInvocation | params: CommandText:String,CommandWord:String,SubcommandPath:String[] | outputtype: [pscustomobject[]]
API: .claude/hooks/hook-command-invocation.ps1 | Resolve-CommandLineInvocation | params: CommandText:String,CommandWord:String,SubcommandPath:String[] | outputtype: [pscustomobject]
API: .claude/hooks/hook-command-invocation.ps1 | Test-CommandLineInvocation | params: CommandText:String,CommandWord:String,SubcommandPath:String[] | outputtype: [bool]
API: .claude/hooks/hook-command-invocation.ps1 | Test-CommandLineMention | params: CommandText:String,CommandWord:String,SubcommandPath:String[] | outputtype: [bool]
API: .claude/hooks/hook-command-scanner.ps1 | Get-CommandLineWrapperName | params:  | outputtype: [string[]]
API: .claude/hooks/hook-command-scanner.ps1 | ConvertTo-CommandLineToken | params: Segment:String | outputtype: [string[]]
API: .claude/hooks/hook-command-scanner.ps1 | Get-CommandLineSegmentCommandWord | params: Token:String[] | outputtype: [string]
API: .claude/hooks/hook-command-scanner.ps1 | ConvertTo-CommandLineSegmentRecord | params: RawText:String,MaskedText:String,TokenText:String,HasLiveSubstitution:Boolean,Unbalanced:Boolean,Delimiter:String | outputtype: [pscustomobject]
API: .claude/hooks/hook-command-scanner.ps1 | Test-CommandLineSegmentRawScan | params: Segment:Object | outputtype: [bool]
API: .claude/hooks/hook-command-scanner.ps1 | Read-CommandLineSegment | params: CommandText:String | outputtype: [pscustomobject[]]
RECORD_KEYS: ConvertTo-CommandLineSegmentRecord | RawText MaskedText Tokens CommandWord IsWrapperLed HasLiveSubstitution Unbalanced ScanText Delimiter TokenText
INVOCATION_DOTSOURCES_SCANNER: True
GIT_WITH_ARGUMENT: -C -c --git-dir --work-tree --namespace
GIT_STANDALONE: -p --paginate --no-pager --literal-pathspecs --no-optional-locks --bare --exec-path
IF_STATEMENTS_IN_RESOLVE: 1
WRAPPER_MATCHER_CANDIDATE_COUNT: 0
C1A_TOKEN_PROBE: not-run
```

## Selections

SEGMENT_READER: Read-CommandLineSegment
SEGMENT_FIELDS: RawText Tokens CommandWord IsWrapperLed HasLiveSubstitution Unbalanced
GIT_OPTION_TABLE: Get-CommandLineGlobalOption
WRAPPER_GIT_MATCHER: none (R-API printed no WRAPPER_MATCHER_CANDIDATE line)

## Done-condition evaluation

- Diff against the integration branch exits 0: met.
- `API:` line for `Read-CommandLineSegment` with a `CommandText` parameter: met.
- `API:` line for `Get-CommandLineGlobalOption` with a `CommandWord` parameter: met.
- One `RECORD_KEYS:` line contains all six SEGMENT_FIELDS names: met (`ConvertTo-CommandLineSegmentRecord`).
- `GIT_WITH_ARGUMENT` contains `-C`, `-c`, `--git-dir`, `--work-tree`: met.
- Exactly one `WRAPPER_MATCHER_CANDIDATE` with `RawText`, `CommandWord`, `SubcommandPath` params: NOT met (0 candidates).
- C1a probe result `False`: NOT met (probe not run because no single candidate exists).

C1A-API-BLOCKER: exactly one WRAPPER_MATCHER_CANDIDATE exists inside Resolve-CommandLineInvocation (observed 0; the merged function's only if statement is `if ($null -eq $first)`)
C1A-API-BLOCKER: C1A_TOKEN_PROBE returns False (observed not-run)

## Cause (read-only observation, for plan revision)

The R-API derivation targets the pre-#824 shape of `Resolve-CommandLineInvocation`. At commit 06d166e0 (before C1a) that function contained
`if (($segment.IsWrapperLed -or $segment.HasLiveSubstitution) -and (Test-CommandLineRawContainment -RawText ... -CommandWord ... -SubcommandPath ...))`.
The merged C1a (5abb5568) removed `Test-CommandLineRawContainment`; `Resolve-CommandLineInvocation` now delegates to `Get-CommandLineInvocation`, which reads records through `Read-CommandLineInvocationSegment` (`.claude/hooks/hook-command-payload.ps1`, params `CommandText,MaxDepth`) and classifies each match `Structural` or `Indeterminate` with a `Reason`. No function with the `RawText`/`CommandWord`/`SubcommandPath` signature exists in the merged API.

Informational probe (not a selection; no successor name is chosen by the executor), `Get-CommandLineInvocation -CommandWord git -SubcommandPath add`:

```text
INFO_PROBE: Get-CommandLineInvocation git add | nohup echo digit addition | matches=0 |
INFO_PROBE: Get-CommandLineInvocation git add | nohup git -C /x add a.ps1 | matches=1 | Structural/
INFO_PROBE: Get-CommandLineInvocation git add | git add "$(echo a.ps1)" | matches=1 | Structural/
INFO_PROBE: Get-CommandLineInvocation git add | timeout 60 pytest | matches=0 |
INFO_API: .claude/hooks/hook-command-payload.ps1 | Read-CommandLineInvocationSegment | params: CommandText,MaxDepth
```

The probe also shows that the merged matcher classifies `nohup git -C /x add a.ps1` and `git add "$(echo a.ps1)"` as `Structural`, so section 4 rule R4 (`wrapper-git`) and unit rows U08 and U09 assume a wrapper classification that the merged API no longer reports in that form. A plan revision of [P0-T9] (WRAPPER_GIT_MATCHER derivation and probe), section 4 R4, section 5.5 C06, and section 5.7 U08 and U09 is required.

Output Summary: BLOCKED. Five of seven [P0-T9] conditions are met; the wrapper-matcher derivation finds 0 candidates in the merged `Resolve-CommandLineInvocation`, so the C1a probe cannot run. Per [P0-T9], the plan stops before any edit and no successor name is chosen.
