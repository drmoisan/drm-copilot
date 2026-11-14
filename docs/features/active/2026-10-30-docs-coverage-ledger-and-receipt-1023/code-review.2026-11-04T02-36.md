# Code Review: Documentation coverage ledger and receipt (#1023)

**Review Date:** 2026-11-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip and merge base `d24071738`)
**Head Branch:** `feature/docs-coverage-ledger-and-receipt-1023-r2` (head `1b160781a`; working tree clean; no pull request yet)
**Review Type:** Initial full-branch review

---

## Executive Summary

The review covers the full branch diff against the epic integration branch (`git diff d24071738...HEAD`, 97 paths). The head commit `1b160781a` merges the integration branch, which brings sibling #1021; the merge base therefore equals the integration tip and the item diff excludes 1021's own changes. The two files where 1021 and 1023 meet were inspected: in `.claude/lib/docs/Invoke-DocsCommand.ps1` the 1021 `check` row is intact above the `# --- 1022 ---` anchor and the three 1023 rows sit directly under `# --- 1023: coverage, update-ledger, validate ---`, exactly as the spec's `### Dispatch rows` block states; in `pack-manifests/core.json` the ten 1023 module lines precede the 1021 `DocsPage*` lines with no duplicate and no lost entry.

The branch adds ten PowerShell modules under `.claude/lib/docs/` (the eight specified modules plus the two pre-approved splits `DocsLedgerRules.psm1` and `DocsCoverageReport.psm1`), byte-identical bundle copies (git blob ids equal for all eleven pairs, including the entry script), ten `core.json` lines, 25 Pester suites and one test-support module, and feature-folder documentation.

The reviewer re-ran PSScriptAnalyzer and the formatter over the 48 changed `.ps1`/`.psm1` files (0 findings, 0 differences), the docs Pester suites without coverage, the module-convention, no-Python-invocation and file-size gate suites (44 of 44), the push-down contract pytest (34 of 34), and the evidence-location validator (exit 0). Counts are in `policy-audit.2026-11-04T02-36.md` section 6.

**What changed well:**
- One write boundary. `Invoke-DocsArtifactWrite` (`DocsLedgerMutation.psm1`) is the only function that invokes a write scriptblock, it reaches the file system only through the injected `-ReadBytes`, `-TestFile` and `-WriteText` parameters, and `DocsWriteBoundary.Tests.ps1` proves this with the PowerShell AST, including a positive control on an in-memory source string.
- Ordinal comparison throughout: `-ceq`/`-cne`, `[System.StringComparer]::Ordinal` sorted dictionaries, and ordinal-comparer hashtables with a justified `PSUseLiteralInitializerForHashtable` suppression.
- Exit-code layering is explicit: argument validators run before any context read (exit 2), findings are exit 1, and each command body is wrapped in one catch that converts any unexpected exception into exactly one `DOCS_CLI_RUNTIME` finding (exit 3) with the exception message.

**Top 3 risks:**
1. The canonical PowerShell coverage artifact in the worktree no longer describes the recorded full run (F1 in the policy audit). It was overwritten at 2026-11-04T02:05Z by the five-test file-size gate run, so the per-file figures 96.84% to 100% recorded in `evidence/qa-gates/qa-pester-coverage.2026-11-04T01-51.md` cannot be re-derived locally. Resolution is the `windows-latest` coverage report on the PR head (`awaiting_ci`).
2. `DocsLedgerCommands.psm1` is 785 logical lines (and its bundle copy), 15 lines below the hard limit. Any further command logic belongs in a new module; the spec's pre-approved split already moved the coverage report out.
3. The check-then-write window in `Invoke-DocsArtifactWrite` (spec risk R3): another writer can change a file between the digest re-check and the `overwrite` call. The spec accepts this for a local single-writer command and the behavior is documented in comment help.

**PR readiness recommendation:** **Ready for PR, pending CI.** No autonomous finding. The blocking items are CI-dependent (`awaiting_ci`).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Warning | `.claude/lib/docs/DocsLedgerCommands.psm1` | whole file | 785 logical lines, at or above the 700-line advisory tier (non-blocking). | Place any further command logic in a new sibling module. | `## File Size Limit` in `.claude/rules/general-code-change.md`, advisory tier. | `@(Get-Content -LiteralPath <path>).Count` = 785 |
| Warning | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsLedgerCommands.psm1` | whole file | 785 logical lines (byte-identical bundle copy), at or above the 700-line advisory tier (non-blocking). | As above; the copy follows the source. | Same rule. | `@(Get-Content -LiteralPath <path>).Count` = 785 |
| Info | `.claude/lib/docs/DocsEvidencePins.psm1` | `Get-DocsPinFinding`, lines 217-221 | A `catch` around `Get-DocsElementId` sets the expected id to `$null`, which yields the `DOCS_PIN_INCONSISTENT` finding; the exception message (the grammar violation) is not carried into the finding message. | Optional: append `$_.Exception.Message` to the finding message so the tampered field is named. | The outcome is an explicit error finding, not a silent skip; only diagnostic detail is lost. | Source inspection |
| Info | `.claude/lib/docs/DocsLedgerMutation.psm1` | `Invoke-DocsArtifactWrite`, lines 139-153 | Check-then-write window between the digest re-check and the write call (spec risk R3). | None required; accepted by the spec for a local single-writer command. | Spec `## Risks` R3. | Source inspection |
| Info | `.claude/lib/docs/DocsLedgerMutation.psm1`, `DocsLedgerCommands.psm1` | `Invoke-DocsArtifactWrite`, `Invoke-DocsUpdateLedgerCommand`, `Invoke-DocsValidateCommand` | These functions do not declare `SupportsShouldProcess`. They perform no I/O themselves: every write goes through the context member `WriteText`, which is the 1020 `Write-DocsContextText`/`Write-DocsFileText` pair that declares `SupportsShouldProcess` and gates the write with `$PSCmdlet.ShouldProcess` (`Invoke-DocsCommand.ps1` lines 240-249, 330). The command layer uses the spec's dry-run default with an explicit `-Write`/`-WriteReceipt` opt-in. | None required. | `.claude/rules/powershell.md` line 30 is satisfied at the primitive, as established in the 1020 review (`policy-audit.2026-11-03T20-57.md` of the 1020 folder). | Source inspection |

No covered file is above 800 logical lines, and `config/file-size-baseline.json` is not in the branch diff. The largest test file is `DocsLedgerCommands.UpdateLedger.Tests.ps1` at 651 logical lines.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Pure modules (`DocsLedger`, `DocsLedgerRules`, `DocsParity`, `DocsEvidencePins`, `DocsStaleness`, `DocsReceipt`, `DocsValidation`, `DocsCoverageReport`) take strings and dictionaries and return new objects; the `Merge-` and `Get-...Without...` functions copy instead of mutating.
- Module headers follow the 1020 convention: `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`, literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` imports with `-ErrorAction Stop`, and the convention token in comment help (`ClaudeLibModuleConvention.Tests.ps1` 6 of 6 in the reviewer run).
- Every `New-` factory carries the `PSUseShouldProcessForStateChangingFunctions` suppression with the spec's justification text; no other suppression is unexplained.
- The dispatch rows are a three-line insertion under the 1023 anchor in both the entry script and its bundle copy; no other line of the entry script changed.
- Bundle parity: `git rev-parse HEAD:<path>` returns the same blob id for each of the eleven source/bundle pairs.

#### API and safety notes

- Exit 2 is returned before any context read for an unknown option, a missing required option and an invalid value (`Test-DocsUpdateLedgerArgument`, `Test-DocsValidateArgument`).
- `validate` passes no write scriptblock unless `-Mode docs-complete -WriteReceipt` is given, and then plans only the receipt document, so a caller that omits the switch is read-only.
- `Invoke-DocsArtifactWrite` stops at the first conflict or write failure and reports already-written paths; there is no rollback, as the spec states.

#### Error handling and logging

- Invariant violations in pure factories throw with a code prefix (`DOCS_LEDGER_INPUT_INVALID`, `DOCS_PARITY_INPUT_INVALID`, `DOCS_RECEIPT_INPUT_INVALID`, `DOCS_CLOCK_NOT_UTC`, `DOCS_RECEIPT_INVALID`).
- `Read-DocsLedgerInputSet` catches only `[System.Management.Automation.ItemNotFoundException]` to treat an absent artifact as empty; any other read failure propagates to the command catch and becomes exit 3.
- The three command-level catches convert every exception to one `DOCS_CLI_RUNTIME` finding carrying the exception message; none swallows an error.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- 25 new suites and `DocsLedger.TestSupport.psm1` under `tests/scripts/claude-lib/docs/`, mirroring the module layout; one property suite per module with pure functions.
- `DocsWriteBoundary.Tests.ps1`: AST scan of every `.ps1`/`.psm1` under `.claude/lib/docs/` with a positive control on an in-memory string; reads repository source files only.
- `DocsCompleteIntegration.Tests.ps1`: fail, `set-disposition -Write`, `pin -Write`, pass over one in-memory context.
- Executor evidence: `evidence/regression-testing/isolation-shuffled-pester.2026-11-04T02-02.md` (three seeded file-order runs), `evidence/qa-gates/qa-test-purity.2026-11-04T02-03.md`, `evidence/qa-gates/qa-pester-coverage.2026-11-04T01-51.md`, `evidence/qa-gates/coverage-delta.2026-11-04T01-51.md`.

### Quality assessment prompts

- **Determinism:** fixed `UtcNow` of `Kind` `Utc` in the test context; seeded `[System.Random]` with the seed in `-Because`; no sleep, timer, process or network.
- **Isolation:** recording in-memory context replaces every I/O seam; no `Mock` of an executable; every suite removes the `Docs*` modules in `AfterAll`.
- **Speed:** the docs folder runs in one process in a few minutes on the shared host; the slowest 1023 suite is the exhaustive validation property suite.
- **Diagnostics:** assertions compare codes, pointers, exit codes and canonical JSON, not message text (spec risk R8).
- **Temporary files:** a token scan of the new suites for `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, `$env:TMP`, `Start-Process`, `Start-Sleep` and `TestDrive` found none; the only `Set-Content` occurrences are in the write-boundary suite's command list and its in-memory positive-control string, which is parsed, not executed.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential, token or host path in the diff; `evidence/qa-gates/qa-forbidden-tokens.2026-11-04T02-07.md`. |
| No unsafe subprocess or command construction | ✅ PASS | No process invocation, no `Invoke-Expression`, no dynamic `& $Context.<Member>` call (`enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33). |
| Input validation at boundaries | ✅ PASS | Argument grammars checked before any read; every artifact parsed with `ConvertFrom-DocsJsonText` and validated with `Test-DocsArtifactText`. |
| Error handling remains explicit | ✅ PASS | Strict mode, `Stop` preference, typed catch for absence, command-level conversion to `DOCS_CLI_RUNTIME`. |
| Configuration and path handling is safe | ✅ PASS | Relative forward-slash paths validated with `Test-DocsRelativePath`; ordinal comparison; no absolute path written to any artifact. |

---

## Research Log

No external research was required. Repository sources consulted: `spec.md`, `user-story.md`, `plan.2026-10-30T16-51.md`, the evidence records under `evidence/`, `.claude/rules/powershell.md`, `.claude/rules/general-code-change.md`, and the 1020 policy audit `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/policy-audit.2026-11-03T20-57.md` for the ShouldProcess precedent.

---

## Verdict

No Blocker, Major or Minor code finding. Two non-blocking file-size Warnings and three Info items are recorded. The blocking items for this item are CI-dependent and are stated in `remediation-inputs.2026-11-04T02-36.md`: the pending-CI criteria S32 and U23, and the local coverage artifact that no longer describes the recorded run, both resolved by the `poshqc / PowerShell QC` coverage report on `windows-latest` for the PR head.
