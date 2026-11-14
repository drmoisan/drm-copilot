# Contract reconciliation C1..C10 ([P0-T4])

Timestamp: 2026-11-03T21-46
Command: Read tool over the merged 1020 modules (`.claude/lib/docs/DocsSurface.psm1`, `DocsAnalyzerRegistry.psm1`, `DocsJson.psm1`), `schemas/docs/v1/common.schema.json`, the merged 1020 `spec.md` (`### DocsSurface.psm1 (pure)`, `#### Declaration-lines digest (D5)`, `### DocsAnalyzerRegistry.psm1`, `## Decisions Later Children Must Honor`), 1020 `plan.2026-10-30T16-08.md` `[P4-T1]`, `tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1`, `tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1`, 1022 `spec.md` `### Inventory command and snapshot builder`, 1023 `spec.md` `### Scanner precision limits (D3)` and `### #1022 and #1033 (PowerShell scanners) for precision-limit diagnostics`; plus the [P0-T3] run (`upstream-contract-check.2026-11-03T21-45.md`) and grep over the 1020 and 1022 suites and specs
EXIT_CODE: 0
Output Summary: ten rows C1..C10 recorded. One divergent upstream decision adopted (C7: the merged 1020 enforces the diagnostic code grammar `^[A-Z][A-Z0-9_]*$` in `New-DocsDiagnostic` and in `schemas/docs/v1/common.schema.json`, so every diagnostic code of this feature is spelled in uppercase with `_` separators; the mapping from each spec code is mechanical and listed below). C2: no fallback function is created. C3: every `-Selection` key is ABSENT. C6: anchor found as expected, 1020 suite search result NONE. No scope change.

## Rows

| ID | Upstream outcome (as merged) | Adopted value | Tasks affected |
|---|---|---|---|
| C1 | `DocsSurface.psm1` `New-DocsSurfaceElement` has the mandatory parameter `-AnalysisMethod` validated against `Get-DocsAnalysisMethod` (`native`, `scanner`); the element record carries the field `analysis_method`; `ConvertFrom-DocsSurfaceElement` requires it. `Invoke-DocsAnalyzer` rejects output by returning `@{ Elements = @(); Diagnostics = @(); Findings = @(<DOCS_ANALYZER_OUTPUT_INVALID ...>) }` (a returned finding, no thrown error); the checks are: kind within `ElementKinds`, `analyzer_id` equal to row `Id`, `analysis_method` equal to row `AnalysisMethod`, `ConvertFrom-DocsSurfaceElement` passes, captured text exists for `path`, and `source_sha256` equals `Get-DocsDeclarationSha256` over the captured text and `line_range`. | Field `analysis_method`; parameter `-AnalysisMethod`; value `scanner`; rejection form: returned `Findings` with code `DOCS_ANALYZER_OUTPUT_INVALID` and empty `Elements` | Phase 3 common paragraph, P3-T1..P4-T3, P5-T2, P6-T4 |
| C2 | `DocsSurface.psm1` exports `ConvertTo-DocsDeclarationText -Text [-LineRange]` and `Get-DocsDeclarationSha256 -Text [-LineRange]` with the five-step rule of `#### Declaration-lines digest (D5)`; `New-DocsSurfaceElement -SourceText` is the only digest path (a caller cannot supply a digest). | 1020 exports both: `DocsScannerCommon.psm1` creates neither `Get-DocsScannerDeclarationText` nor `Get-DocsDeclarationSha256` (no fallback, no seeded digest property test in P1-T2; the digest properties are proven over 1020's functions by P6-T4). Digest field `source_sha256`; range field `line_range` `{start, end}` (`[long]`). | P1-T2, P6-T4 |
| C3 | 1022 is not executed on this branch (no `DocsInventory.psm1` in `.claude/lib/docs`). The re-prepared 1022 `spec.md` step 7 "Invoke each selected row with `Invoke-DocsAnalyzer`, passing the full captured-input list" defines no `-Selection` key, and 1020 types `-Selection` as `[AllowNull()] [object]`. | `source_roots`: ABSENT; `repository_id`: ABSENT; `revision`: ABSENT; `registered_analyzer_ids`: ABSENT. Every key stays optional and `-Selection` may be `$null` or a non-dictionary; an absent `source_roots` gives repository-relative module paths, absent `repository_id` or `revision` gives the non-blocking unverified diagnostics, absent `registered_analyzer_ids` triggers the in-function registry import. | P1-T2, P5-T1, P5-T2 |
| C4 | `New-DocsCapturedInput -Path -Bytes [-MaxBytes]`: default `$script:DocsAnalyzerDefaultMaxBytes = 1048576`; `ConvertFrom-DocsUtf8Bytes` strips one leading UTF-8 BOM (EF BB BF) before strict decoding; an oversize input carries diagnostic code `DOCS_INPUT_TOO_LARGE` and an undecodable one `DOCS_INPUT_NOT_UTF8`, each with `analyzer_id` `docs-capture`, severity `warning`, and `text` `$null`. | Default bound 1048576 (test oversize input: 1048577 bytes); BOM rule: one leading U+FEFF removed by 1020 before the analyzer sees `text`; analyzer re-emission: captured `DOCS_INPUT_TOO_LARGE` becomes `INPUT_OVER_BOUND` and captured `DOCS_INPUT_NOT_UTF8` becomes `INPUT_UNDECODABLE`, blocking, under the analyzer's own identifier (spelling per C7). | P1-T1, P1-T2, P6-T3 |
| C5 | `New-DocsDiagnostic -Code -Path -Message -AnalyzerId [-Severity <error\|warning\|information>] [-Blocking <bool>]`; `-Severity warning` gives `blocking` `$false`; no extensions parameter; the returned ordered record already carries `extensions = [ordered]@{}` (empty ordered map). | `New-DocsScannerPrecisionLimitDiagnostic` calls `New-DocsDiagnostic -Severity warning`, then sets `$record['extensions']['docs.precision-limit'] = [ordered]@{ element_kind = <ElementKind> }` on the returned record, creating `extensions` as an empty ordered map first only when the member is absent or `$null`; the returned record has an `extensions` member: YES. No 1020 file is edited. Resolved in favor of 1023. | P1-T2, P6-T4 |
| C6 | Anchor literal found: `# --- 1033: TypeScript and .NET analyzers ---` inside `$script:DocsAnalyzerRow`, after `# --- 1022: Python and configuration analyzers ---` and before `$script:DocsAnalyzerNativeRow`; no `# --- 900NNN:` anchor in the module. Row method field `AnalysisMethod`, value `scanner`; row form `[pscustomobject]@{ Id; Version; AnalysisMethod; ElementKinds; Module; Function }`; `Test-DocsAnalyzerModulePath` requires a `DocsAnalyzer*.psm1` leaf inside `.claude/lib/docs/`. 1020 suite `DocsAnalyzerRegistry.Tests.ps1` searched for row-count or empty-registry assertions over the committed tables: `Get-DocsAnalyzerRegistration` without `-ScannerRow`/`-NativeRow` appears once (`It 'reports no finding for the committed registry'`, asserting `(Test-DocsAnalyzerRegistration ...).Count` is 0, a finding count, not a row count); `$script:DocsAnalyzerRow` appears only in the anchor-order text test and the `Test-Path variable:` test; no `HaveCount` and no empty-result assertion on either table variable. `DocsProfile.Tests.ps1` `DOCS_ANALYZER_UNKNOWN` case uses `unregistered-analyzer`, which is none of the seven. No 1022 suite is present on the branch. | Anchor literal: `# --- 1033: TypeScript and .NET analyzers ---`; field `AnalysisMethod` = `scanner`; suite search result: NONE (disposition: `DocsAnalyzerRegistry.Tests.ps1` unchanged); `DocsProfile.Tests.ps1` unchanged; module name `DocsAnalyzerExtensionImport.psm1`. | P6-T1, P6-T2 |
| C7 | Divergent. The merged 1020 enforces `$script:DocsSurfaceCodePattern = '^[A-Z][A-Z0-9_]*$'` in `New-DocsDiagnostic` (`DOCS_IDENTITY_INPUT_INVALID: Code '<code>' does not match ^[A-Z][A-Z0-9_]*$`, observed in the [P0-T3] probe) and `schemas/docs/v1/common.schema.json` `$defs.diagnostic.properties.code` carries `"pattern": "^[A-Z][A-Z0-9_]*$"`. The spec's lowercase hyphenated codes cannot be built or validated under 1020. | Adopted: every diagnostic code of this feature is the spec code mapped by the mechanical rule "uppercase every letter and replace `-` with `_`". The adopted spellings are listed in the table below; every later task, test assertion, and the `Get-DocsScannerPrecisionLimit` `code` column uses them. Extension keys (`docs.precision-limit`, `docs.analysis-method`), element kinds, analyzer identifiers, and property names are unchanged (they follow other grammars). | P1-T2 and every later task that names a code |
| C8 | 1022 (`DocsInventory.psm1`, `New-DocsInventorySnapshot`) is not executed on this branch; its spec states the merge removes duplicates with `duplicate-declaration` and does not state the imported-versus-built-in precedence. | Provisional default stands: built-in wins, imported element dropped with a non-blocking diagnostic, implemented by 1022's merge; no task of this plan implements or tests it. | none (documentation only) |
| C9 | Resolved by 1023 `### Scanner precision limits (D3)`: 1023 reads only diagnostics whose `extensions` carries `docs.precision-limit` with an `element_kind`, a non-null relative `path`, and an `analyzer_id` whose snapshot analyzer item has `analysis_method` `scanner`; it records one `deferred` entry per `(analyzer_id, code, path)` with element id `Get-DocsElementId -Kind <element_kind> -Path <diagnostic path> -Declaration <diagnostic id>`. | This feature supplies stable codes (C7 spelling), the marker (C5), `## Scanner Precision Limit`, and `Get-DocsScannerPrecisionLimit`; nothing else. | P1-T2, P6-T4 |
| C10 | 1022 is not executed on this branch; the strings are agreed in the epic `### Analyzer decisions from the first preparation of 1022` and the 1033 spec. The 1022 spec spells the shared codes in lowercase, which the merged 1020 rejects (C7), so 1022 will adopt the same mapping when it executes. | `<dynamic>` prefix segment; `config-key` declaration rule: a segment matching `^[A-Za-z0-9_-]+$` stays bare, any other segment is double-quoted with `"` and `\` escaped, an array member contributes `[]`; shared codes under C7: `DECLARATION_INVALID`, `DUPLICATE_DECLARATION`, `INPUT_OVER_BOUND`, `INPUT_UNDECODABLE`. | P1-T2, P4-T2, P6-T3 |

## C7 adopted code spellings

| Spec code | Adopted code |
|---|---|
| `cli-dynamic-registration` | `CLI_DYNAMIC_REGISTRATION` |
| `cli-unbound-registration` | `CLI_UNBOUND_REGISTRATION` |
| `cli-command-module-unresolved` | `CLI_COMMAND_MODULE_UNRESOLVED` |
| `http-dynamic-route` | `HTTP_DYNAMIC_ROUTE` |
| `http-prefix-dynamic` | `HTTP_PREFIX_DYNAMIC` |
| `http-mount-unresolved` | `HTTP_MOUNT_UNRESOLVED` |
| `http-receiver-unresolved` | `HTTP_RECEIVER_UNRESOLVED` |
| `http-route-token-unresolved` | `HTTP_ROUTE_TOKEN_UNRESOLVED` |
| `http-endpoint-kind-unsupported` | `HTTP_ENDPOINT_KIND_UNSUPPORTED` |
| `dotnet-route-inherited-unresolved` | `DOTNET_ROUTE_INHERITED_UNRESOLVED` |
| `dotnet-conventional-routing-unresolved` | `DOTNET_CONVENTIONAL_ROUTING_UNRESOLVED` |
| `ts-reexport-unresolved` | `TS_REEXPORT_UNRESOLVED` |
| `ts-export-pattern-unsupported` | `TS_EXPORT_PATTERN_UNSUPPORTED` |
| `ts-export-assignment` | `TS_EXPORT_ASSIGNMENT` |
| `ts-ambient-module` | `TS_AMBIENT_MODULE` |
| `ts-commonjs-export` | `TS_COMMONJS_EXPORT` |
| `csharp-declaration-unrecognized` | `CSHARP_DECLARATION_UNRECOGNIZED` |
| `csharp-conditional-compilation` | `CSHARP_CONDITIONAL_COMPILATION` |
| `input-over-bound` | `INPUT_OVER_BOUND` |
| `input-undecodable` | `INPUT_UNDECODABLE` |
| `ts-lexical-invalid` | `TS_LEXICAL_INVALID` |
| `csharp-lexical-invalid` | `CSHARP_LEXICAL_INVALID` |
| `token-limit` | `TOKEN_LIMIT` |
| `json-invalid` | `JSON_INVALID` |
| `input-key-limit` | `INPUT_KEY_LIMIT` |
| `declaration-invalid` | `DECLARATION_INVALID` |
| `duplicate-declaration` | `DUPLICATE_DECLARATION` |
| `extension-finding-skipped` | `EXTENSION_FINDING_SKIPPED` |
| `extension-repository-unverified` | `EXTENSION_REPOSITORY_UNVERIFIED` |
| `extension-revision-unverified` | `EXTENSION_REVISION_UNVERIFIED` |
| `extension-manifest-invalid` | `EXTENSION_MANIFEST_INVALID` |
| `extension-manifest-digest-mismatch` | `EXTENSION_MANIFEST_DIGEST_MISMATCH` |
| `extension-repository-mismatch` | `EXTENSION_REPOSITORY_MISMATCH` |
| `extension-adapter-invalid` | `EXTENSION_ADAPTER_INVALID` |
| `extension-input-not-captured` | `EXTENSION_INPUT_NOT_CAPTURED` |
| `extension-input-digest-mismatch` | `EXTENSION_INPUT_DIGEST_MISMATCH` |
| `extension-result-digest-mismatch` | `EXTENSION_RESULT_DIGEST_MISMATCH` |
| `extension-result-invalid` | `EXTENSION_RESULT_INVALID` |
| `extension-finding-source-mismatch` | `EXTENSION_FINDING_SOURCE_MISMATCH` |

Tokenizer diagnostics (`TS_LEXICAL_INVALID`, `CSHARP_LEXICAL_INVALID`, `TOKEN_LIMIT`) are produced by the tokenizers as records without an analyzer identifier and are re-emitted by each analyzer under its own identifier through `New-DocsDiagnostic`, so they follow the same grammar.

## Other recorded facts used by later tasks

- `Invoke-DocsAnalyzer` passes `-Selection` through unchanged and accepts `$null`; the analyzer contract parameter is `[AllowNull()] [object] $Selection`.
- `New-DocsDiagnostic -Path` must pass `Test-DocsRelativePath` when non-null; `-Message` must be non-blank; `-AnalyzerId` must match the identifier grammar `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`.
- `New-DocsSurfaceElement -Property` values must be scalars (string, number, boolean, null); property names must match the identifier grammar (`^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`); `-Extension` keys must match `^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+$`.
- Registry row `Module` must resolve inside `.claude/lib/docs/` with a `DocsAnalyzer*.psm1` leaf and `Function` must match `^Invoke-DocsAnalyzer[A-Za-z]+$`.
- Coordinator note: the 1022 spec's lowercase code spellings (for example `duplicate-declaration`, `env-file-not-captured`) are rejected by the merged 1020 `New-DocsDiagnostic`; 1022 will need the same C7 mapping. This is reported upward and changes nothing in this feature's scope.
