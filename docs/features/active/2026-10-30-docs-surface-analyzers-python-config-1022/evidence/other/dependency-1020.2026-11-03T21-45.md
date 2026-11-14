# [P0-T2] Dependency on 1020 verification (issue #1022)

Timestamp: 2026-11-03T21-45
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p0t2-dependency-1020.ps1 -WorktreeRoot <item worktree>
EXIT_CODE: 0
Output Summary: 43 PASS, 0 MISMATCH. Every item of spec `## Dependency on 1020` is present on the branch after the 1020 merge; no 1022 file existed when the helper ran. The branch-current D1 digest equals the 1020 golden vector.

## MERGE_BASE derivation

- Command: `git fetch origin epic/documentation-estate-tooling-integration` then `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`
- Result: `MERGE_BASE` equals the current `HEAD` of the item branch (the branch starts at the integration tip that contains the merged 1020 work). Every later scope diff is anchored on `MERGE_BASE`.

## Recorded values

| Name | Value |
|---|---|
| `ANCHOR_LABEL` | `1022`. Registry anchor text: `# --- 1022: Python and configuration analyzers ---` (in `$script:DocsAnalyzerRow`). Dispatch anchor text: `# --- 1022: inventory ---`. The other registry anchors are `# --- 1033: TypeScript and .NET analyzers ---` and `# --- 1031: Python-native analyzers ---` (untouched by 1022). |
| `METHOD_FIELD` | `AnalysisMethod` (row grammar `[pscustomobject]@{ Id; Version; AnalysisMethod; ElementKinds; Module; Function }`); `Get-DocsAnalysisMethod` returns `native`, `scanner`; 1022 rows carry `AnalysisMethod = 'scanner'`. |
| `ENVELOPE_ROUTE` | `Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText <text> -ComposedSchemaSet (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas`. Verified: the committed `examples/docs/v1/docs-command-envelope.example.json` text returns 0 findings. The function returns a wrapped collection (`, $findings`), so a consumer reads `.Count` on the returned value or flattens it through the pipeline before counting. |
| `CAPTURE_CODES` | over-bound: `DOCS_INPUT_TOO_LARGE`; undecodable: `DOCS_INPUT_NOT_UTF8`. Both are emitted by `New-DocsCapturedInput` with `analyzer_id` `docs-capture`, severity `warning`, `blocking` `false`, and `text` `$null`. |
| `DIGEST_RULE` | Recorded verbatim below from 1020 `#### Declaration-lines digest (D5)`. |
| `CORE_TAIL` | `last`. The final 1020 docs entry `.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json` is the final `paths` element of `CORE` (17 docs entries). [P5-T2] therefore expects 18 added and 1 deleted. |
| In-memory context `ReadBytes` call record | none. `New-DocsTestContext` returns `@{ Context; Files; WriteLog; ProcessCallLog }`; there is no `ReadBytes` call record, so [P4-T4] builds a recording `ReadBytes` wrapper in the test. |
| D1 self-check | `Get-DocsDeclarationSha256 -Text <D1 text> -LineRange @(2, 3)` on the branch returns `4b1f1972e4baea3016f1021a3cfe9ca6e6076ca82a0ae05a9b26de11403e24ea`, equal to the D1 row of 1020 `evidence/other/golden-identity-vectors.2026-11-03T11-51.md`. |

### DIGEST_RULE (verbatim, 1020 spec `#### Declaration-lines digest (D5)`)

`ConvertTo-DocsDeclarationText -Text <string> [-LineRange <int[]>]` (pure) returns the canonical declaration text:

1. Remove one leading U+FEFF if present.
2. Replace every CRLF with LF, then every remaining CR with LF.
3. If the text ends with LF, remove exactly one trailing LF. Split on LF into lines numbered from 1. The empty text has zero lines.
4. With `-LineRange @(start, end)`: require `1 <= start <= end <= <line count>`, otherwise throw `DOCS_DIGEST_RANGE_INVALID` naming the range. Select lines `start` through `end` inclusive. Without `-LineRange` (permitted only for `architecture-component`): select every line.
5. Return the selected lines, each followed by exactly one LF. No trimming, no tab or whitespace change and no Unicode normalization is applied. Zero selected lines give the empty string.

`Get-DocsDeclarationSha256 -Text <string> [-LineRange <int[]>]` (pure) returns `Get-DocsSha256Hex -Text (ConvertTo-DocsDeclarationText -Text $Text -LineRange $LineRange)`: the lowercase hex SHA-256 of the UTF-8 bytes, without BOM, of the canonical declaration text.

## Items (one line per item)

```
PASS | ConvertFrom-DocsJsonText | parameters: Text
PASS | ConvertTo-DocsCanonicalJson | parameters: Value
PASS | ConvertTo-DocsJsonText | parameters: Value, Indented
PASS | Get-DocsSha256Hex | parameters: Text
PASS | Get-DocsBytesSha256Hex | parameters: Bytes
PASS | New-DocsFinding | parameters: Code, Severity, Message
PASS | New-DocsCommandResult | parameters: ExitCode
PASS | Get-DocsOrderedFinding | parameters: Finding
PASS | Test-DocsArtifactText | parameters: ArtifactKind, JsonText, ComposedSchemaSet, ArtifactPath
PASS | Read-DocsSchemaSet | parameters:
PASS | Get-DocsComposedSchemaSet | parameters: SchemaSet
PASS | Get-DocsElementKind | parameters:
PASS | Test-DocsRelativePath | parameters: Path
PASS | Test-DocsFullRevision | parameters: Revision
PASS | Get-DocsStableId | parameters: Prefix, Value
PASS | Get-DocsElementId | parameters: Kind, Path, Declaration
PASS | New-DocsSurfaceElement | parameters: Kind, Path, Declaration, Name, AnalyzerId, AnalysisMethod, SourceText, ParentId, LineRange, Property, Extension
PASS | ConvertFrom-DocsSurfaceElement | parameters: Record
PASS | New-DocsDiagnostic | parameters: Code, Path, Message, AnalyzerId, Severity, Blocking
PASS | ConvertTo-DocsDeclarationText | parameters: Text, LineRange
PASS | Get-DocsDeclarationSha256 | parameters: Text, LineRange
PASS | Get-DocsAnalyzerRegistration | parameters: ScannerRow, NativeRow
PASS | Test-DocsAnalyzerRegistration | parameters: Registration
PASS | Select-DocsAnalyzerRegistration | parameters: Registration, ElementKind, AnalyzerId, NativeAvailable
PASS | New-DocsCapturedInput | parameters: Path, Bytes, MaxBytes
PASS | Invoke-DocsAnalyzer | parameters: Registration, CapturedInput, Selection, ImportModule
PASS | ConvertFrom-DocsProfileText | parameters: Text
PASS | New-DocsSurfaceElement has no digest parameter | digest-like parameters: none
PASS | New-DocsCommandResult -ExitCode 2 with one DOCS_CLI_ARGUMENTS finding | ExitCode=2 Findings=1 members=Command,ExitCode,Findings,Result,Line code=DOCS_CLI_ARGUMENTS
PASS | In-memory command context members (Docs.TestSupport.psm1 New-DocsTestContext) | members: RepositoryRoot, ReadText, ReadBytes, TestFile, ListFile, WriteText, UtcNow, InvokeProcess
INFO | ReadBytes call record in the in-memory context | none (returned keys: WriteLog, ProcessCallLog, Context, Files)
PASS | Command context members in Invoke-DocsCommand.ps1 | all six members assigned
PASS | Dispatch-table row form | [pscustomobject]@{ Name = 'init'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfileCommands.psm1'); Function = 'Invoke-DocsInitCommand'; Option = @{ RepositoryId = 'value'; Profile = 'value'; Write = 'switch'; Force = 'switch' } }
PASS | Snapshot schema $defs/element analysis_method with native and scanner | required and property present: True; common analysis-method enum: native, scanner
PASS | Registry row grammar method field (METHOD_FIELD) | METHOD_FIELD = AnalysisMethod
PASS | Get-DocsAnalysisMethod values | native, scanner
PASS | schemas/docs/v1/docs-command-envelope.schema.json exists | <worktree>/schemas/docs/v1/docs-command-envelope.schema.json
PASS | ENVELOPE_ROUTE: Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' accepts the committed example | findings: 0
PASS | Registry 1022 anchor (ANCHOR_LABEL) | # --- 1022: Python and configuration analyzers ---
PASS | Dispatch 1022 anchor (ANCHOR_LABEL) | # --- 1022: inventory ---
INFO | Other registry anchors (untouched by 1022) | # --- 1033: TypeScript and .NET analyzers --- ; # --- 1031: Python-native analyzers ---
PASS | CAPTURE_CODES (over-bound, undecodable) | over-bound=DOCS_INPUT_TOO_LARGE (severity warning, blocking False, analyzer docs-capture); undecodable=DOCS_INPUT_NOT_UTF8 (severity warning, blocking False, analyzer docs-capture); text null for both
PASS | ConvertTo-DocsDeclarationText D1 canonical text | digest 4b1f1972e4baea3016f1021a3cfe9ca6e6076ca82a0ae05a9b26de11403e24ea
PASS | Invoke-DocsAnalyzer digest rejection test exists | DocsAnalyzerRegistry.Tests.ps1 It 'rejects output whose source_sha256 differs from the recomputed digest'
PASS | Invoke-DocsAnalyzer recomputes Get-DocsDeclarationSha256 | DocsAnalyzerRegistry.psm1 references Get-DocsDeclarationSha256
INFO | CORE_TAIL | last (final 1020 docs entry '.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json'; final paths element '.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json'; docs entries: 17)
SUMMARY | PASS=43 MISMATCH=0
```

## Additional item found while verifying `New-DocsDiagnostic` (recorded 2026-11-03T22-00)

```
MISMATCH | Diagnostic code grammar consumed by every 1022 diagnostic | New-DocsDiagnostic validates -Code against $script:DocsSurfaceCodePattern '^[A-Z][A-Z0-9_]*$(?![\s\S])' and throws DOCS_IDENTITY_INPUT_INVALID otherwise; schemas/docs/v1/common.schema.json $defs/diagnostic.code carries "pattern": "^[A-Z][A-Z0-9_]*$"; the committed snapshot example uses the code DOCS_EXAMPLE_NOTICE and the 1020 capture diagnostics use DOCS_INPUT_TOO_LARGE and DOCS_INPUT_NOT_UTF8. The 1022 spec `## Precision Limit` (Common rules) states that codes follow the identifier grammar ^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$ "inherited by the docs diagnostic.code", and the plan's CORPUS_CODES, [P1-T1] (declaration-invalid, duplicate-declaration), [P1-T2] to [P1-T6], [P2-T1], [P2-T2] and [P4-T6] assert the 32 lowercase codes verbatim. The 1020 spec `### Docs common $defs` diagnostic row states no code pattern; the discovery v2 inventory-snapshot $defs/diagnostic.code is the lowercase identifier definition that the 1022 research cited. On the executed 1020, no lowercase 1022 code can be built with New-DocsDiagnostic, and a snapshot carrying one fails Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot'.
SUMMARY (with the additional item) | PASS=43 MISMATCH=1
```

Consequence: [P0-T2] is left unchecked and execution stops after the Phase 0 baseline with `BLOCKED: 1020 dependency not met`. No 1020 file is edited. The resolution belongs to the coordinator: either the 1020 common schema and `New-DocsDiagnostic` adopt the identifier grammar for `diagnostic.code` (the discovery v2 shape the 1022 research cited), or the 1022 spec and plan are revised to uppercase codes (for example `PYTHON_LEXER_UNTERMINATED`), which changes every asserted code literal in `CORPUS_CODES`, both corpus files and every per-row test.

## Notes for later tasks

- The 1020 capture diagnostics are non-blocking `warning` with `analyzer_id` `docs-capture` (a 1020 decision). Spec `## Precision Limit` lists those two rows as "owned by 1020"; 1022 records them as emitted and does not re-classify them.
- `New-DocsDiagnostic` accepts `-Severity information`; 1022 keeps `env-file-not-captured` as a non-blocking `warning` per spec decision 2.
- `Test-DocsArtifactText` needs a composed schema set; the command suite composes it once in `BeforeAll` from `Get-DocsTestSchemaText`.
