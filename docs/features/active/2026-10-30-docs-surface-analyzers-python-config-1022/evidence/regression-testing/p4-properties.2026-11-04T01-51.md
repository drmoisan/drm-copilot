# [P4-T6] Pester gate: DocsInventoryProperties (issue #1022)

Timestamp: 2026-11-04T01-51
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsInventoryProperties.Tests.ps1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml; no new production file, so no coverage path; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsInventoryProperties.Tests.ps1: 8 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; result object Passed=8 Failed=0 Skipped=0). The JUnit file is well-formed; counts were read from it. Suite duration 34.8 s (four full inventory builds over both corpora through `Invoke-DocsInventoryCommand`).

## Toolchain for the new file

- Formatter: one rewrite on the first pass (hashtable alignment), then `Already formatted:` on the final pass; 0 files rewritten afterwards.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings on the final pass.
- Physical line count: `DocsInventoryProperties.Tests.ps1` 328.
- Defects found and fixed during this task: a direct call to `Invoke-DocsAnalyzerConfigFiles` failed after a command run because `Invoke-DocsAnalyzer` re-imports the analyzer module with `-Force` from inside the registry module, which removes the suite's earlier import from the test scope (the suite now reaches the analyzer through `Invoke-DocsAnalyzer` with the `config-files` row); a case-sensitive `-clike` count could not match `App`; the line split now uses `ConvertTo-DocsSourceLine` so the reconstructed variants follow the digest's one-trailing-LF rule.

## Seeds used (each `It` carries its seed in every `-Because`)

| Test | Seed |
|---|---|
| `property: the snapshot text is byte-identical under permuted ListFile order and repeated builds with a fixed clock` | 102260 |
| `property: every element_id equals Get-DocsElementId of its kind, path and declaration and every element records analysis_method scanner` | 102261 |
| `property: every source_sha256 equals Get-DocsDeclarationSha256 over the captured text and line_range; an edit inside the range changes it, an edit outside or a line-ending variant does not, and an architecture-component changes for an edit anywhere` | 102262 |
| `property: marker values in every TOML, template env, JSON Schema and YAML value position never appear in the snapshot text and element properties carry only key and shape names` | 102263 |
| `property: inputs of 1,048,575 and 1,048,576 bytes are accepted and 1,048,577 bytes yields the over-bound code with no element and no inputs entry` | 102264 |
| `property: an unclassifiable Python input yields PYTHON_LEXER_UNCLASSIFIED with no element from that file while another file keeps its elements` | 102265 |
| `property: App and app stay distinct and the element, input and diagnostic order equals ordinal order with CurrentCulture set to a culture whose collation differs` | 102266 (culture drawn from da-DK, sv-SE, tr-TR; da-DK selected) |
| census `It` (no randomness) | none |

## Behavior covered

- Byte identity: the indented snapshot text of a repeated build and of two builds whose `ListFile` wrapper returns the paths in a seeded random order equals the baseline text over both corpora (the baseline exits 1 because both corpora carry blocking diagnostics by design; more than 100 elements).
- Every `element_id` equals `Get-DocsElementId` of its fields and every element records `analysis_method` `scanner` (elements visited in seeded random order).
- Every `source_sha256` equals 1020 `Get-DocsDeclarationSha256 -Text <captured text> -LineRange <line_range>` (no range for `architecture-component`, whose `line_range` is null); for a seeded sample of 40 elements an edit on a random line inside the range changes the digest, an edit on a random line outside it does not, and the CRLF, CR, no-trailing-newline (when the last line is non-empty) and BOM variants leave it unchanged; an `architecture-component` changes for an edit anywhere (every line is inside its null range); through the registry, an edit inside a `config-key` range changes the emitted element digest, an edit outside does not, and the `element_id` is unchanged.
- Marker values (26 seeded `MK<n>Z` strings per iteration) in every TOML, template env (comment, quoted, plain, multi-line), JSON Schema (`default`, `pattern`, `description`, `enum`, `const`, `examples`) and YAML (scalar, sequence item, mapping item, flow, block scalar, quoted) value position never appear in the snapshot text; element properties carry only `format`, `value_type`, `schema_type`, `required` and `conditional`; the only diagnostics are the expected non-blocking rows and `ENV_FILE_NOT_CAPTURED` for the plain `.env`.
- Size bound (`IN_TEST_ROWS` capture row built in test code): 1,048,575 and 1,048,576-byte inputs are captured with their `size`, and a 1,048,577-byte input yields `DOCS_INPUT_TOO_LARGE` (warning, non-blocking, `docs-capture`) with no `inputs` entry and no element while the sibling file keeps its element.
- An unclassifiable character (`$`, `?` or `` ` ``) yields `PYTHON_LEXER_UNCLASSIFIED` (blocking) with no element from that file, exit 1 with `DOCS_INVENTORY_BLOCKING_DIAGNOSTIC`, while the other file keeps its elements.
- Under `CurrentCulture` da-DK (whose comparer orders `src/a.py` before `src/B.py`, unlike ordinal), `App<n>` and `app<n>` are two distinct `public-symbol` elements (with `APP`, `I` and `i`), and the snapshot's elements, inputs (`src/B.py` before `src/a.py`) and diagnostics are in ordinal order; the culture stays set during the run and is restored in `AfterAll`.
- Census: each of the 32 `CORPUS_CODES` (listed verbatim in the test) matches `^[A-Z][A-Z0-9_]*$` and has at least one `expected_diagnostics` entry in the python corpus; the four `IN_TEST_ROWS` (`DOCS_INPUT_TOO_LARGE`, `DOCS_INPUT_NOT_UTF8`, `PYTHON_TOKEN_LIMIT`, `ARCHITECTURE_EDGE_LIMIT`) have no corpus entry and are named with their proving tasks in the test's comment; every `expected_diagnostics` code in both corpora matches the grammar.

## Acceptance criteria checked off

- spec S6 and user-story U4 (1,048,577 bytes yields the over-bound diagnostic with no element and no `inputs` entry while 1,048,576 is accepted; an unclassifiable construct yields `PYTHON_LEXER_UNCLASSIFIED` with no element): [P1-T2] and this task.
- spec S7 and user-story U5 (byte-identical snapshot under permuted `ListFile` order and repeated builds, seeded, seed printed on failure): this task.
- spec S8 and user-story U6 (marker values never appear; only keys and shapes; the plain `.env` never read and reported by `ENV_FILE_NOT_CAPTURED`): [P1-T4] to [P1-T6], [P4-T1], [P4-T3], [P4-T4] and this task.
- spec S11 and user-story U8 (every element records `analysis_method: scanner`; every 1022 registry row declares the scanner method): [P4-T2] and this task.
- spec S12 and user-story U9 (`source_sha256` equals the 1020 digest; edits inside and outside, line-ending variants, whole-file `architecture-component` digest): [P0-T2], [P3-T8] and this task.
- spec S13 (golden values from the independent helper self-checked against D1; corpus coverage of every classified form and every 1022-owned row except the four in-test rows marked in the census): [P2-T1] to [P2-T3] and this task.
- spec S21 (`App` and `app` distinct; ordinal ordering under a differing culture): this task.

CI: `poshqc / PowerShell QC` (windows-latest shards).
