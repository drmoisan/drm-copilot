# C1a API Verification (issue #738, consumer of #824)

Timestamp: 2026-10-09T03-06
Task: [P0-T9] (plan v1.5, re-run after the round-1 blocker)
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/r-api.sh (R-API steps 0 to 3 over .claude/hooks/hook-command-invocation.ps1, .claude/hooks/hook-command-scanner.ps1, and .claude/hooks/hook-command-payload.ps1)
EXIT_CODE: 0
DIFF_COMMAND: git diff --quiet origin/epic/enforcement-hook-precision-integration -- .claude/hooks/hook-command-invocation.ps1 .claude/hooks/hook-command-scanner.ps1 .claude/hooks/hook-command-payload.ps1 .claude/hooks/hook-command-payload-powershell.ps1 .claude/hooks/hook-command-invocation-operands.ps1 .claude/hooks/hook-command-heredoc.ps1 .codex/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-scanner.ps1 .codex/hooks/hook-command-payload.ps1 .codex/hooks/hook-command-payload-powershell.ps1 .codex/hooks/hook-command-invocation-operands.ps1 .codex/hooks/hook-command-heredoc.ps1
UNCHANGED_FROM_INTEGRATION_EXIT: 0

## R-API output (verbatim)

```text
PRIOR_BLOCKED_RECORD: docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/evidence/other/c1a-api-verification.round1-blocked.md exists=True sha256=3FD88ED5A8BEC0994E19D3355288D9C4A11B097BA026B8F821275892F9E353E0
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
API: .claude/hooks/hook-command-payload.ps1 | ConvertTo-CommandLineLeafWord | params: Word:String | outputtype: [string]
API: .claude/hooks/hook-command-payload.ps1 | Test-CommandLineWordPresent | params: RawText:String,Word:String | outputtype: [bool]
API: .claude/hooks/hook-command-payload.ps1 | ConvertTo-CommandLineNormalizedText | params: CommandText:String | outputtype: [string]
API: .claude/hooks/hook-command-payload.ps1 | Split-CommandLinePosixWord | params: Text:String | outputtype: [string[]]
API: .claude/hooks/hook-command-payload.ps1 | Skip-CommandLineTransparentWrapper | params: Token:String[],Except:String | outputtype: [pscustomobject]
API: .claude/hooks/hook-command-payload.ps1 | Get-CommandLineWrapperPayload | params: Word:String[] | outputtype: [pscustomobject]
API: .claude/hooks/hook-command-payload.ps1 | Get-CommandLineSubstitutionBody | params: Text:String | outputtype: [string[]]
API: .claude/hooks/hook-command-payload.ps1 | Add-CommandLineInvocationRecord | params: Context:Hashtable,Depth:Int32,Origin:String,Wrapper:String,Dialect:String,RootIndex:Int32,RootRawText:String,RawText:String,Tokens:String[],CommandWord:String,Literal:Boolean,Unbalanced:Boolean,Delimiter:String,ArgumentInjected:Boolean,SubstitutionPresence:String | outputtype: [pscustomobject]
API: .claude/hooks/hook-command-payload.ps1 | Add-CommandLineWrapperExpansion | params: Context:Hashtable,Record:PSObject,Word:String[] | outputtype: none
API: .claude/hooks/hook-command-payload.ps1 | Test-CommandLinePosixTokenLiteral | params: Token:String[] | outputtype: [bool]
API: .claude/hooks/hook-command-payload.ps1 | Add-CommandLinePosixRecord | params: Context:Hashtable,Text:String,Depth:Int32,Origin:String,Wrapper:String,RootIndex:Int32,RootRawText:String,ArgumentInjected:Boolean | outputtype: none
API: .claude/hooks/hook-command-payload.ps1 | Read-CommandLineInvocationSegment | params: CommandText:String,MaxDepth:Int32 | outputtype: [pscustomobject[]]
API: .claude/hooks/hook-command-payload.ps1 | Test-CommandLinePayloadInert | params: Record:Object[],RootIndex:Int32 | outputtype: [bool]
RECORD_KEYS: .claude/hooks/hook-command-scanner.ps1 | ConvertTo-CommandLineSegmentRecord | RawText MaskedText Tokens CommandWord IsWrapperLed HasLiveSubstitution Unbalanced ScanText Delimiter TokenText
RECORD_KEYS: .claude/hooks/hook-command-payload.ps1 | Skip-CommandLineTransparentWrapper | Index SkippedWrapper
RECORD_KEYS: .claude/hooks/hook-command-payload.ps1 | Get-CommandLineWrapperPayload | Wrapper Kind Payload Words Opaque OpaqueReason
RECORD_KEYS: .claude/hooks/hook-command-payload.ps1 | Add-CommandLineInvocationRecord | Index RootIndex Depth Origin Wrapper Dialect RawText RootRawText Tokens CommandWord Literal Unbalanced Opaque OpaqueReason Delimiter PresenceText ArgumentInjected
MATCH_KEYS: ConvertTo-CommandLineIndeterminateMatch | Status Reason Segment OperandIndex GlobalOptions Operands OperandsComplete
MATCH_KEYS: Get-CommandLineInvocation | Status Reason Segment OperandIndex GlobalOptions Operands OperandsComplete
INVOCATION_DOTSOURCES: hook-command-scanner.ps1 hook-command-payload.ps1 hook-command-payload-powershell.ps1 hook-command-invocation-operands.ps1
ITERATOR_RECORD_HAS_WRAPPER_FLAGS: False
WRAPPER_MATCHER_CANDIDATE: Get-CommandLineInvocation | params: CommandText,CommandWord,SubcommandPath | outputtype: [pscustomobject[]]
GIT_WITH_ARGUMENT: -C -c --git-dir --work-tree --namespace
GIT_STANDALONE: -p --paginate --no-pager --literal-pathspecs --no-optional-locks --bare --exec-path
GIT_TERMINAL: --version -v --help -h --html-path --man-path --info-path --exec-path
C1A_PROBE: P1 | segments=1 | IsWrapperLed=True | HasLiveSubstitution=False | add=0 none | commit=0 none
C1A_PROBE: P2 | segments=1 | IsWrapperLed=True | HasLiveSubstitution=False | add=1 Structural/ | commit=0 none
C1A_PROBE: P3 | segments=1 | IsWrapperLed=False | HasLiveSubstitution=True | add=1 Structural/ | commit=0 none
C1A_PROBE: P4 | segments=1 | IsWrapperLed=True | HasLiveSubstitution=False | add=0 none | commit=0 none
C1A_PROBE: P5 | segments=1 | IsWrapperLed=True | HasLiveSubstitution=False | add=1 Structural/ | commit=0 none
```

## Selections

SEGMENT_READER: Read-CommandLineSegment
SEGMENT_FIELDS: RawText Tokens CommandWord IsWrapperLed HasLiveSubstitution Unbalanced
GIT_OPTION_TABLE: Get-CommandLineGlobalOption
WRAPPER_GIT_MATCHER: Get-CommandLineInvocation
WRAPPER_GIT_MATCHER_USE: match count only, any Status (section 4 R4)

## Done-condition evaluation

- `PRIOR_BLOCKED_RECORD` reports `exists=True`, and the preserved file carries `Timestamp: 2026-10-09T02-52` (grep count 1): met.
- Diff against the integration branch exits 0: met.
- `API:` lines for `Read-CommandLineSegment` (CommandText, scanner), `Get-CommandLineGlobalOption` (CommandWord), `Get-CommandLineInvocation` (CommandText, CommandWord, SubcommandPath), and `Read-CommandLineInvocationSegment` (CommandText, MaxDepth, payload file): met.
- `RECORD_KEYS` for `ConvertTo-CommandLineSegmentRecord` contains all six SEGMENT_FIELDS names: met.
- `MATCH_KEYS` for `Get-CommandLineInvocation` contains `Status`, `Reason`, `Segment`: met.
- `INVOCATION_DOTSOURCES` contains `hook-command-scanner.ps1` and `hook-command-payload.ps1`: met.
- `GIT_WITH_ARGUMENT` contains `-C`, `-c`, `--git-dir`, `--work-tree`: met.
- Exactly one `WRAPPER_MATCHER_CANDIDATE`, naming `Get-CommandLineInvocation`: met.
- Five `C1A_PROBE` lines equal the probe table (P1 1/True/False/0/0; P2 1/True/False/1/0; P3 1/False/True/1/0; P4 1/True/False/0/0; P5 1/True/False/1/0): met. P1 confirms the token-aware C1a condition (`add=0` although `digit` and `addition` contain the substrings).
- `ITERATOR_RECORD_HAS_WRAPPER_FLAGS: False` and `GIT_TERMINAL` recorded, not asserted.

Output Summary: PASS. Every [P0-T9] condition is met; the selections are Read-CommandLineSegment, Get-CommandLineGlobalOption, and Get-CommandLineInvocation (match count only). No blocker line is recorded.
