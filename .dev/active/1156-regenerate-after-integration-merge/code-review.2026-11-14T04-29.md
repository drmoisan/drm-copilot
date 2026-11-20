# Code Review: Regenerate path after an integration merge (#1156)

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/regenerate-after-integration-merge-1156`
**Feature Folder Selection Rule:** named by the caller; matches branch `feature/regenerate-after-integration-merge-1156` and issue #1156
**Base Branch:** `main` (resolved `origin/main` at `063504dc4b2ea08a2c5bd39b57d70ce5963815ed`, equal to the merge base)
**Head Branch:** `feature/regenerate-after-integration-merge-1156` at `8533618dd00aa5dc43ee353598fdf1107a76d192`
**Review Type:** Initial review

---

## Executive Summary

The branch (118 files, 12016 insertions, 49 deletions) adds an opt-in regenerate path for merge conflicts confined to declared generated files. The design keeps all decisions in three pure PowerShell modules (`RegenerationConfig.psm1`, `RegenerationClassifier.psm1`, `RegenerationDelta.psm1`) and confines git, process, file, and clock access to four seams in `Invoke-RegenerationPath.ps1`. Two byte-identical hook helpers per runtime add a key-gated merge-gate consistency check (`REVIEW_GATE_REGENERATION_UNVERIFIED`) and a narrow preimplementation allowance for regeneration commits on the integration branch. Skills, agents, the rules file, the six-copy brief, bundle mirrors, pack manifests, the frozen-surface digests, and ledger patches are updated consistently after two merges of `origin/main`.

Evidence reviewed: the PR context summary and appendix generated at the reviewed head, the plan and all gate evidence, `artifacts/pester/powershell-coverage.xml` (parsed per file by the reviewer), a root Jest coverage run by the reviewer, the tier-classification check run by the reviewer, and a real-process probe of the entry point and of the AD-1 process default. Implementation quality is high and the tests are thorough (74 result-table rows, call-sequence suites, AST pins for every seam default). Two blocking defects remain.

**What changed:**
New lib folder `.claude/lib/regeneration/` (four files), new hook helpers `enforce-epic-merge-gate-regeneration.ps1` and `hook-epic-regeneration.ps1` in `.claude/hooks/` and `.codex/hooks/`, one dot-source plus one call in each `enforce-epic-merge-gate.ps1` and each `enforce-orchestration-preimplementation-gate-epic-scope.ps1`, a new `## Merge-Conflict Remediation` section and rule 7 and 11 sentences in the orchestrate skill, an `## Integration-Tip Regeneration` section and main-sync and early-start sentences in the epic-orchestrate skill, a parallel-skill paragraph, one agent sentence and one Bash grant, a rules-file section, two corpus fixtures, and the mirrors listed above.

**Top 3 risks:**
1. CI `tier-classification` fails with QT008 because `quality-tiers.yml` has no entry for `.claude/lib/regeneration` (Blocker, CR-1).
2. On Windows, a declared command whose executable is a `.cmd` or `.ps1` shim (`npm`, `npx`) cannot be started by the AD-1 default, so the regenerate path silently degrades to a fallback for such repositories; Linux CI cannot observe it (Major, CR-2).
3. `Invoke-RegenerationPath.ps1` is 711 logical lines, above the 700-line advisory tier, and further fixes in it will push toward the 800-line limit (Warning).

**PR readiness recommendation:** **Needs Revision** — CR-1 fails a CI step and CR-2 defeats the feature for common Windows-declared commands; both are contained fixes.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `quality-tiers.yml` | project list (no `.claude/lib/regeneration` entry) | CR-1: the branch adds the project folder `.claude/lib/regeneration/`, and `check_quality_tiers` reports `QT008: discovered project '.claude/lib/regeneration' has no entry`. CI step `tier-classification` in `quality-checks7` runs the same module and will fail, which also skips the later pytest and coverage steps of that job. | Add a tier entry for `.claude/lib/regeneration` (the orchestration-control libs such as `.claude/lib/review-verdict` and `.claude/lib/ci-gate` are the precedent for the tier choice) and re-run `python -m scripts.dev_tools.check_quality_tiers`. | The repository has adopted tiers; every project must be classified, and CI fails for an unclassified project. | `evidence/qa-gates/quality-tiers-check.2026-11-14T04-29.md`; `.github/workflows/_quality-checks.yml` step `tier-classification` |
| Major | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | lines 98-116 (`Invoke-RegenerationProcess` `-Invoker` default) and its bundle copy | CR-2: the AD-1 default starts `$FilePath` with `ProcessStartInfo` and `UseShellExecute = false`. On Windows this resolves only an `.exe` name, so `npm`, `npx`, and other `.cmd`/`.ps1` shims throw "The system cannot find the file specified". The step wrapper reports not started, and the result is exit 1 and a fallback. The call-operator form it replaced did resolve them (`Get-Command npm` returns `npm.ps1`). Neither `### Config file` in the spec, the orchestrate skill config rules, nor the rules file states that `command[0]` must be a directly startable executable. | Choose one, in this item: (a) resolve `argv[0]` before the start (on Windows, when the name has no extension, search `PATH` with the `PATHEXT` list and start `.cmd`/`.bat` through `cmd.exe /d /c` with the argv kept as separate `ArgumentList` items), pinned by a direct seam case and an updated check (h); or (b) document in the orchestrate skill config rules and the rules-file section that `command`, `idempotency_check`, and each `unit_gate` argv must name a directly startable executable, with the Windows extension (for example `npm.cmd`), and pin the sentence in `regeneration-path-skill-contract.Tests.ps1`. | Orchestrators in this repository run on Windows; a repository that declares an npm-based generator would never take the regenerate path, and Linux CI cannot detect it. The fallback is safe, so this is a functional gap, not a safety defect. | `evidence/other/process-start-probe.2026-11-14T04-29.md` (real-process probe and end-to-end Tip run) |
| Warning | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | whole file | 711 logical lines (700-line advisory tier). The plan targeted under 500 lines. | A later split of the Merge and Tip flows into a module would bring it under 700; avoid growing it further while fixing CR-2. | File-size advisory tier. | `@(Get-Content -LiteralPath <path>).Count` = 711 |
| Warning | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | whole file | 711 logical lines (byte copy of the source). | Same as above. | File-size advisory tier. | `@(Get-Content -LiteralPath <path>).Count` = 711 |
| Minor | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | `Invoke-RegenerationMergeFlow`, `Invoke-RegenerationTipFlow`, `Invoke-RegenerationTipRestore` | The functions that run `git merge`, `git checkout`, `git add`, and `git clean` do not declare `SupportsShouldProcess`; PSScriptAnalyzer does not flag the `Invoke` verb. | Non-blocking: consistent with the other orchestration entry points in `.claude/lib`; consider `SupportsShouldProcess` if the adapter is refactored. | `.claude/rules/powershell.md` asks for ShouldProcess on state-changing actions. | Diff inspection |
| Info | `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` | lines 107-113 | The AD-1 default buffers the child's stdout and stderr until exit and then writes both to stderr. stdout stays one JSON object, there is no pipe deadlock (both streams are read asynchronously before `WaitForExit`), a start failure throws, and the integer exit code is the only success-stream output. Long generator runs give no streamed progress. | No change required. | Behavior confirmed against the AD-1 requirements. | `evidence/other/process-start-probe.2026-11-14T04-29.md` |
| Info | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | allowlist and DynamicInvocation class | AD-1 satisfies the guard by removing the variable call-operator invocation that the guard reports. The guard's intent is that enforcement code invokes no Python interpreter it can be traced to; the regeneration adapter runs a repository-declared argv, which no static scan can classify in either form, and the same `ProcessStartInfo` pattern is the accepted `Invoke-DocsProcess` precedent. The allowlist entry was correctly left unchanged, because the adapter does not invoke Python itself and this repository declares no command (D11). | No change required; the plan's check (h) was rewritten to pin the new shape and is not weaker. | Consistency of AD-1 with the guard. | `evidence/other/task-check.P6-T2.2026-11-14T03-25.md` |
| Info | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | re-baseline comment above `PINNED_FROZEN_SURFACE_HASHES` | The comment lists the PRs of the first main merge but not #1174 from the second merge. The digests equal the current files; #1174 did not edit either pinned file. | Optional wording update. | Comment accuracy only. | `sha256sum` of both files equals the pinned digests |

No Blocker or Major finding other than CR-1 and CR-2.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Test-only edits: an in-place digest re-baseline with a dated comment, a fixture-acceptance test, and a handoff-projection test that proves the destination projection drops `regeneration_events`, `integration_regenerations`, and `review_kind`.

#### Typing and API notes

- No new public Python API surface was added.

#### Error handling and logging

- No production Python code changed.

### TypeScript implementation audit

#### What changed well

- One appended validator case in `epic-orchestrator-state-core.test.ts` showing the epic validator tolerates `integration_regenerations`.

#### Type safety and maintainability

- No production TypeScript changed; `tsc` and ESLint are clean.

#### Error handling and logging

- Not affected.

### PowerShell implementation audit

#### What changed well

- Default-off is enforced in code at every entry: the usage check precedes any config read, the config stage precedes any git call in all three modes, the merge-gate check is keyed on `review_kind` exactly `regeneration_delta`, and the allowance admits nothing without a valid config.
- The normative result table (rows R01 to R74) is transcribed once and asserted once per row, which closes the class of unpinned result fields.
- Every git path argument follows `--`; the allowance rejects glob characters, dot segments, leading slashes, `-a`, `--all`, `--amend`, `--no-verify`, and chained commands.
- The merge-gate helper compares JSON booleans by type, so a string `"true"` fails, and it runs no process.
- Real-process probe: `-Mode Validate` from a scratch directory printed one JSON object and exited 0 for a valid config and 3 for an absent one; Merge without `-MergeRef` and Tip with a `..` `-ConfigPath` exited 2; an end-to-end Tip run in a scratch git repository with a `pwsh` command produced outcome `applied`, `changed_paths` `["gen/a.txt"]`, and left the change unstaged.

#### API and safety notes

- Advanced functions throughout; two justified analyzer suppressions in `New-RegenerationResult`.
- CR-2 concerns executable resolution in the process seam default only; the wrapper contract (one integer, empty argv throws, start failure throws) is intact.

#### Error handling and logging

- Step wrappers convert a throwing git or process call into exit 1 with a stderr line naming the call; a non-zero `git merge --abort` or restore call turns the result into exit 1, as the result table requires.

---

## Test Quality Audit

Coverage and regression evidence is complete for all three languages, and the reviewer re-derived the PowerShell per-file figures from the coverage XML. The gap is not in the tests but in two checks the executor did not run: the tier classification (CR-1) and a real Windows start of a shim command (CR-2).

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1` — 74 row cases plus 4 structure checks and AST checks (a) to (h); the row data comes from `RegenerationResultTable.psd1` (74 rows, matching the 74 spec rows).
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1` — allow and deny per event field, stale-head denial, R73 completion context.
- `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1` — section- and item-scoped literals in each `.claude` file and its bundle copy, the D11 absence check, and the Codex-scope check.
- `evidence/qa-gates/pester-final.2026-11-14T04-07.md` — 24326 tests, 0 failures, at the head content after the second main merge.
- `evidence/qa-gates/coverage-comparison.2026-11-14T04-13.md` — per-file and repo-wide comparison; figures agree with the reviewer's XML parse.

### Quality assessment prompts

- **Determinism:** injected clock, in-memory config text, wrapper mocks; no temporary files.
- **Isolation:** one behavior per case; one case per table row.
- **Speed:** no waits; the full Pester gate ran in 697.59 s across eight workers.
- **Diagnostics:** row IDs and result keys appear in `-Because` text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token literal in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | `ProcessStartInfo` with one `ArgumentList` item per argument and no shell; git calls splat an argv array; no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Config rules 1 to 9 before any git call; usage errors exit 2; the allowance rejects unsafe path operands. |
| Error handling remains explicit | ⚠️ PARTIAL | Failures map to exit 1 or 3 with stderr text; CR-2 maps a valid Windows shim command to a start failure. |
| Configuration / path handling is safe | ✅ PASS | Relative `-ConfigPath` only; absolute and `..` forms rejected; the config file is never bundled. |

---

## Research Log

No external research was required. The Windows executable-resolution behavior of `ProcessStartInfo` with `UseShellExecute = false` was confirmed by direct execution on the review host rather than from documentation.

---

## Verdict

The change is well structured, default-off, and thoroughly tested, and the main-sync fallout (mirrors, manifests, digests, brief copies, ledger patches) is consistent with the post-merge files. It is not ready for the normal PR flow: CR-1 fails the CI `tier-classification` step and must be fixed by adding a `quality-tiers.yml` entry, and CR-2 must be fixed either by resolving Windows command shims in the process default or by documenting and pinning the directly-startable-executable constraint. Both are contained fixes inside this item; the 711-line Warning and the Minor and Info rows need no remediation cycle.
