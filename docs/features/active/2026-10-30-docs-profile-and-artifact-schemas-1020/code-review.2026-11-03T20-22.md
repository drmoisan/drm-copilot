# Code Review: Documentation profile and artifact schemas (#1020)

**Review Date:** 2026-11-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip `5e535f7a6`)
**Head Branch:** `feature/docs-profile-and-artifact-schemas-1020-r2` (head `71217a14e`)
**Review Type:** Initial review

---

## Executive Summary

The branch delivers the base library for the documentation tooling epic: nine new PowerShell files under `.claude/lib/docs/` (2,943 logical lines in total, largest 458), eight v1 JSON schemas with byte-identical runtime and bundle copies, seven examples, core-pack manifest entries, a T3 tier entry, and 383 Pester tests. The design keeps I/O inside the entry script's command context and keeps validation, composition, identity, and shaping logic in pure functions that take an injected context. Process and file-write seams are thin, argument-validated, and shell-free. Evidence reviewed: the regenerated PR context, the item diff against the epic tip, the coverage artifact, the executor's evidence files, and reviewer re-runs of Pester (docs scope), PSScriptAnalyzer, the formatter, and the contract and gate suites.

**What changed:**
New modules `DocsJson`, `DocsFinding`, `DocsSurface`, `DocsSchema`, `DocsSchemaWalk`, `DocsAnalyzerRegistry`, `DocsProfile`, `DocsProfileCommands`, and the entry script `Invoke-DocsCommand.ps1` with the `init` and `validate-profile` subcommands; schemas and examples under `schemas/docs/v1/` and `examples/docs/v1/`; their copies; 17 appended lines in `core.json`; 3 lines in `quality-tiers.yml`; tests under `tests/scripts/claude-lib/docs/`.

**Top 3 risks:**
1. The two filesystem write functions do not implement ShouldProcess, contrary to `.claude/rules/powershell.md`.
2. `Invoke-DocsCommand.ps1` line coverage is 85.91%, 0.91 points above the floor; the ShouldProcess fix must add test coverage (for example a `-WhatIf` call) rather than only unexecuted lines.
3. The full `tests/scripts` single-process run and the CI checks are proven only by `windows-latest` CI, which has not yet run for a PR head.

**PR readiness recommendation:** **Needs Revision** - one Major policy finding is fixable inside the item; CI-dependent items then resolve at S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/lib/docs/Invoke-DocsCommand.ps1` | `Write-DocsFileText` lines 226-245; `Write-DocsContextText` lines 316-326 | State-changing functions (directory creation, file create, file overwrite) declare `[CmdletBinding()]` without `SupportsShouldProcess` and never call `$PSCmdlet.ShouldProcess`. The suppression of `PSUseShouldProcessForStateChangingFunctions` on `Write-DocsContextText` is inert (PSSA does not apply that rule to the `Write` verb). | Add `[CmdletBinding(SupportsShouldProcess = $true)]` to `Write-DocsFileText` and gate the directory creation and stream write with `if ($PSCmdlet.ShouldProcess($FullPath, "Write file ($Mode)"))`; give `Write-DocsContextText` `SupportsShouldProcess` too (or remove the inert suppression and forward `-WhatIf`/`-Confirm`). Keep the `init` dry-run and `-Write`/`-Force` contract unchanged. Add a test that calls `Write-DocsFileText -WhatIf` and asserts no write occurs, which also covers the body lines without touching the filesystem. Re-sync the bundle mirror. | `.claude/rules/powershell.md` line 30 and `.github/instructions/powershell-code-change.instructions.md` line 52 require ShouldProcess for any state-changing action; the CLI dry run does not satisfy the stated rule, and sibling library `DiscoveryStart.psm1` follows it. | Inspected source; PSSA 0 findings (rule not triggered for `Write`) |
| Info | `.claude/lib/docs/Invoke-DocsCommand.ps1` | file | Coverage 85.91% (128 of 149) with all 21 missed lines inside the two seam bodies. | When fixing the finding above, verify the file stays at or above 85% from the regenerated coverage artifact. | Margin is 0.91 points. | `artifacts/pester/powershell-coverage.xml` |
| Minor | `examples/docs/v1/*.example.json` | all seven files | Keys are in artifact-header order; `format_json --check` reports `would reformat` for all seven, while the discovery examples are sorted. No CI workflow, test, or rule enforces it; the local `fix_all` JSON branch (`scripts/dev_tools/fix_all_branches.py` line 89) runs `format_json` in write mode and would rewrite them on the next local run. | Optionally run `poetry run python -m scripts.dev_tools.format_json examples/docs/v1` in the same remediation cycle and re-run `DocsSchemaContract.Tests.ps1` and `DocsNeutrality.Tests.ps1`. Non-blocking. | Avoids an unrelated diff appearing in a later PR. | Reviewer `format_json --check --verbose examples` |
| Nit | `tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1` | line 310 | The `Test-Json` mock emits `Write-Error`, which prints a red error line on every run though the test passes. | Write the error record into the mock's error variable path without console output, or redirect it in the test (`2>$null` around the act step) if the production `-ErrorVariable` capture is still exercised. Non-blocking. | Console noise in a green run can be mistaken for a failure. | Reviewer Pester run output |
| Info | `docs/features/epics/documentation-estate-tooling/epic-status.md` | n/a | Present on the epic tip, absent on HEAD; HEAD never touched it, so a merge into the epic keeps it. | None required; a merge of `origin/epic/...` before PR creation would refresh the branch. | Avoid misreading the two-dot diff as a deletion. | `git diff --name-status origin/epic/documentation-estate-tooling-integration HEAD` |

No Blocker findings. One Major finding.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The command context is an injected object with scriptblock members; command modules never touch the filesystem directly, so every command path is tested with an in-memory context and no temporary files.
- `Invoke-DocsProcess` uses `ProcessStartInfo` with `ArgumentList` and `UseShellExecute = $false`; argument validation (`ConvertTo-DocsProcessRequest`) and result shaping (`ConvertTo-DocsProcessResult`) are pure and fully tested.
- Repository-relative paths are validated by a pattern that rejects absolute paths, `.` and `..` segments, backslashes, colons, control characters, and line or paragraph separators before any access (`DocsSurface.psm1` line 35, mirrored in `common.schema.json`).
- Dispatch and analyzer registration are validated data tables with owner anchors, which lets later children add rows without editing shared logic.
- Case-sensitive JSON keys use ordinal-comparer dictionaries with justified suppressions.

#### API and safety notes

- Advanced functions, `Mandatory`/`ValidateSet`/`AllowNull` validation, approved verbs, and explicit exports throughout.
- ShouldProcess is absent on the two write functions (Major finding). The `init` command's dry-run default, refusal of existing targets without `-Force`, and listing of planned writes are sound user-level safeguards and should remain.
- `Write-DocsFileText` uses `FileMode.CreateNew` for `create`, so a race between the existence check and the write fails rather than overwriting.
- Symlink resolution is out of scope by the schema description ("symlinks require the shared path policy"); noted, not a finding.

#### Error handling and logging

- Errors are `DOCS_*` coded throws or findings with pointers and next actions; exit 3 writes exactly one stderr line. No empty catch.

---

## Test Quality Audit

Reviewed: reviewer re-run of the 13 docs suites (383 of 383), the module-convention suite (6 of 6), `enforcement-hooks-no-python-invocation.Tests.ps1` (33 of 33), `FileSizePolicy.RepoGate.Tests.ps1` (5 of 5), push-down contract pytest (32 passed), quality-tiers contract pytest (16 passed); executor evidence for shuffled-order runs and coverage.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1` - validates every example with the real `Test-Json`, mutation rejection per schema, runtime-copy identity, common-definition parity.
- `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` - exit-code matrix, envelope validation against the envelope schema, process-member forwarding through a mock.
- `tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1` - seeded identity and digest property tests, golden vectors, diagnostic severity coupling.
- `evidence/regression-testing/isolation-shuffled.2026-11-03T18-50.md` - three seeded file orders, all green.
- `evidence/regression-testing/isolation-single-process.2026-11-03T20-06.md` and `evidence/remediation-baseline/same-host-mergebase-pester.2026-11-03T20-06.md` - full-tree failures on this host are pre-existing; CI proof pending.

### Quality assessment prompts

- **Determinism:** seeded RNG with printed seed; injected clock; no timers or processes.
- **Isolation:** one behavior per `It`; module-scoped mocks.
- **Speed:** 383 tests in under one minute.
- **Diagnostics:** assertions on codes, pointers, and digests; one noisy mock (Nit).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Neutrality suite holds consumer identifiers only as SHA-256 digests; no credentials. |
| No unsafe subprocess or command construction | ✅ PASS | No `Invoke-Expression`; `ProcessStartInfo.ArgumentList`; no shell. |
| Input validation at boundaries | ✅ PASS | Relative-path pattern, argument parser exit 2, process request validation. |
| Error handling remains explicit | ✅ PASS | Coded throws and findings. |
| Configuration / path handling is safe | ⚠️ PARTIAL | Path validation is sound; destructive writes lack ShouldProcess (Major finding). |

---

## Research Log

No external research was required. Repository sources consulted: `.claude/rules/powershell.md`, `.github/instructions/powershell-code-change.instructions.md`, `scripts/dev_tools/json_config.py`, `scripts/dev_tools/fix_all_branches.py`, `.github/workflows/*.yml`, `.claude/lib/discovery-validation/DiscoveryStart.psm1`.

---

## Verdict

The implementation is well structured, thoroughly tested, and verified clean by the analyzer, formatter, and gate suites. It is not ready for PR until the two write functions implement ShouldProcess as `.claude/rules/powershell.md` requires, with a test that keeps `Invoke-DocsCommand.ps1` at or above 85% line coverage and a re-synced bundle mirror. After that fix, the remaining items (full-tree Pester and the required checks) resolve through `windows-latest` CI on the PR head.
