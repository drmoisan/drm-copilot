# Code Review: Completion gate rejects adopted feature folder (#992)

---

**Review Date:** 2026-10-29
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-28-completion-gate-rejects-adopted-feature-folder-992`
**Feature Folder Selection Rule:** the only active feature folder added on the branch; its suffix matches issue #992 in the branch name.
**Base Branch:** `main` (merge base `f721222cf4eaacc799aa0c35fe54722868ef7e93`, equal to `origin/main`)
**Head Branch:** `bug/completion-gate-rejects-adopted-feature-folder-992` (`839bfb8242a7ecfb14ab92a3e397f95c0e089f44`)
**Review Type:** Initial review of the full branch diff

---

## Executive Summary

The orchestrator completion gate required a successful `new_active_feature_folder` receipt from the finishing run, so an item prepared by an earlier session or a planner stalled at DONE. The branch makes three changes:

- It adds the tool to the closed `issue_adoption` waivable set in all three validator runtimes.
- It requires a declared `feature_folder_record`, checked by rules 10 and 11a-11e, before the waiver takes effect.
- It adds a HEAD probe in the Claude `SubagentStop` hook, so the declared folder must exist as a committed tree when the run stops.

The receipt loops are unchanged. They skip the tool only because the resolver now returns it in the waived set, and that happens only when every adoption rule passes. The fail-closed model is therefore preserved: any adoption error waives nothing, and the missing-receipt line still appears.

**What changed:**
- Three new pure record modules (Python, TypeScript, PowerShell) with byte-identical error strings and one shared path pattern.
- One call added after rule 9 in each resolver, inside the rule-8 shape gate.
- New hook sibling `validate-orchestrator-output-feature-folder.ps1` with a single git seam (`Invoke-FeatureFolderGitExe`), loaded through the guarded dot-source pattern.
- Shared corpus grows from 34 to 48 fixtures; parity minimums raised to 48 in all three suites.
- Rule, skill, and bundle prose; `core.json`; a per-file Jest threshold.

**Top 3 risks:**
1. The validators cannot see the repository, so only the Claude hook proves the folder exists. The MCP, Python CLI, and Codex gates accept a well-formed declaration. The rule prose states this boundary explicitly (AC-12), and the spec records it as accepted.
2. The real-git default invoker is not exercised by an automated test. Its behavior is confirmed by a one-time manual probe (AC-19), and every failure mode fails closed: a non-zero exit, a throw, or any output other than `tree` blocks.
3. The run that delivers this fix adopts a pre-existing folder itself, so its own checkpoint must carry a valid `feature_folder_record`, and the hook copy that runs must contain the change (spec `### Dependencies or blocked work`).

**PR readiness recommendation:** **Go**. No Blocker, Major, or Minor finding; the toolchain and coverage thresholds pass in all three languages. Merge remains subject to the S9 CI green gate on the final PR head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/validate-orchestrator-output-feature-folder.ps1` | `Invoke-FeatureFolderGitExe`, `$code = $LASTEXITCODE` | The seam reads `$LASTEXITCODE` after the invoker runs. An injected invoker that neither runs a native command nor sets `$global:LASTEXITCODE` would observe whatever value a previous command left. | No change required. A future test invoker should always set `$global:LASTEXITCODE`, as the current recording invoker does. | The production default always runs git, which sets the value. The hook suite resets it in `AfterEach`, and the null-exit-code row pins the `-1` fallback. | Hook sibling source; `validate-orchestrator-output.FeatureFolder.Tests.ps1` lines 54 and 69. |
| Info | `.claude/hooks/validate-orchestrator-output-feature-folder.ps1` | Default `-GitInvoker { git @args 2>&1 }` | The two uncovered lines (25 of 27 covered) are the default real-git invoker and its call. Real-git output is confirmed only by `evidence/other/probe-confirmation.2026-10-29T14-51.md`. | No change required. | Tests must not start git (AC-18). The default merges standard error into the output, and success requires the exact string `tree`, so error text cannot be read as success. A native-stderr exception under `$ErrorActionPreference = 'Stop'` would also be caught and returned as `-1`, which blocks. | Reviewer parse of `artifacts/pester/powershell-coverage.xml`. |
| Info | `.claude/hooks/validate-orchestrator-output.ps1` | Guarded import of `OrchestratorStateFeatureFolderRecord.psm1` | This import omits `-Force` and `-Global`, unlike the neighbouring module imports. The comment explains why `-Force` is omitted. | No change required. | The hook calls `Test-OrchestratorStateFeatureFolderPath` from its own scope. The hook suite and the full Pester run exercise this path, and `hook-dependency-guard-completeness.Tests.ps1` passes. | Hook diff; full Pester run 0 failures. |
| Info | `extensions/drm-copilot/jest.config.cjs` | Whole file | 497 lines after the new per-file threshold entry. | Consider consolidating per-file `coverageThreshold` entries before the next addition. | The file is under the 500-line guidance tier, so this is not a finding under the file-size policy; it is noted because each new TypeScript module adds four lines. | Reviewer logical line count. |
| Info | `artifacts/python/lcov.info` (gitignored) | Executor final Python run | The executor's final Python coverage run used `--cov=` on the two changed modules only, so the artifact listed two source files and could not support a repo-wide verdict. The reviewer regenerated it from a full-suite run (policy audit, Approved Exceptions). | For future runs, write the final Python coverage artifact from a full-suite `--cov --cov-branch` run. | Per-file figures for the changed modules were already valid and are identical in the regenerated artifact. | Reviewer backup of the executor artifact in the session scratchpad; regenerated `artifacts/python/coverage.json`. |

No Blocker, Major, or Minor findings. No covered file in the branch diff is at or above 700 lines (largest 497), so no file-size Warning row applies, and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `_orchestrator_state_feature_folder_record.py` is pure: it imports only `re` and `typing`. Its docstring states that the module performs no I/O and that the hook performs the probe.
- The path pattern is applied with `re.fullmatch`, so a trailing newline cannot pass even though the pattern carries `$`.
- Rule 11b runs only when 11a passed, so a malformed path produces one error, not two. The three runtimes agree on this.
- `resolve_issue_adoption` calls the new function inside the existing `waived is not None` branch, which matches the rule-8 shape gate stated in the rule prose.

#### Typing and API notes

- Pyright: 0 errors on all six changed Python files (reviewer). `cast("dict[str, Any]", raw_record)` follows an `isinstance(dict)` guard. `__all__` lists the public constants and functions.

#### Error handling and logging

- Errors are literal module constants appended in rule order; no exception path is added.

### TypeScript implementation audit

#### What changed well

- `orchestrator-state-feature-folder-record.ts` uses `unknown` with type guards (`isPlainObject`, `isFeatureFolderPath`) and contains no `as` assertion.
- The regular expression has no `m` flag, so `$` anchors only at the end of the value, matching the Python full match.
- `state[...] !== recordPath` reproduces the Python rule that an absent, non-string, or different `feature-folder` fails 11b.
- The new file has its own `coverageThreshold` entry (85/75) and measures 100% lines and branches.

#### Type safety and maintainability

- `FEATURE_FOLDER_VERIFIED_VIA` is a `readonly string[]`; the tool name and record key are exported once and imported by the adoption module.

#### Error handling and logging

- Error strings are byte-identical to Python and PowerShell; the shared corpus compares the ordered lists exactly in all three parity suites.

### PowerShell implementation audit

#### What changed well

- `OrchestratorStateFeatureFolderRecord.psm1` uses `-cmatch` with `\A...\z`, `-ccontains`, and ordinal `[string]::Equals`, so comparisons are case-sensitive as the rule requires.
- The hook probe runs only after the routing contract reports no errors and only for `orchestrator-state`. By that point the record has passed rules 10 and 11, so the probe never runs on an unvalidated record.
- The hook re-checks `feature-folder` against the shared pattern before building git arguments. The pattern rejects a leading `-`, glob characters, and `..`, so the value cannot become a git option or a pathspec. The argument list is fixed: `-C`, root, `cat-file`, `-t`, `HEAD:<folder>`.
- Both new dependencies load through `try { ... } catch { Add-HookDependencyFailure ... }`. A missing or broken copy blocks the hook instead of failing open.
- `cmp` reports all four changed `.claude` PowerShell files identical to their bundle copies; `core.json` lists both new files.

#### API and safety notes

- `Invoke-FeatureFolderGitExe` never throws, and it returns `-1` both when the invoker throws and when no exit code is available.
- The block message keeps the `ROUTING_CONTRACT_BLOCKED:` prefix and `Repairable = $true`, so the subagent receives a corrective instruction rather than a halt.
- `Test-FeatureFolderProbeWaived` uses `-ccontains` over string entries only, which matches the validators' case-sensitive tool-name rule (`case-variant-tool-name.json`).

#### Error handling and logging

- No new logging channel; the block decision carries the message.

### C# implementation audit

#### What changed well

- Not applicable; no C# file changed.

#### Type safety and API notes

- Not applicable.

#### Error handling and logging

- Not applicable.

---

## Test Quality Audit

The reviewer ran the full Python suite with branch coverage (7429 passed, 6 skipped) and parsed the Python, Jest, and Pester coverage artifacts. The reviewer also ran PSScriptAnalyzer over nine changed PowerShell files (0 findings), Black, Ruff, Pyright, Prettier, ESLint, `tsc`, the Codex generator `--check`, and `check_quality_tiers`. Results are recorded in the policy audit.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1`: 22 cases. They cover allow, the five block outcomes plus a throwing invoker, the fixed argument list, the no-call cases (not waived, epic and parallel types, failing path, malformed `issue_adoption`), and direct seam rows. Checkpoints are in-memory JSON, and the worktree root is a POSIX literal.
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.Tests.ps1`, `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py`, and `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-feature-folder.test.ts`: the same rule 10 and 11a-11e matrix in each runtime, including the path-rejection table.
- Shared corpus: 14 new fixtures and the reworked `waives-new-active-feature-folder.json`; minimums raised to 48 in all three parity suites (reviewer `grep`, directory count 48).
- `evidence/regression-testing/fail-before.2026-10-29T14-38.md` and `fail-before-hook-suite.2026-10-29T14-46.md`: the new tests fail against the pre-change code.
- `evidence/regression-testing/isolation.2026-10-29T15-16.md`: seeded Jest, reversed Python, and six-seed shuffled Pester runs pass.

### Quality assessment prompts

- **Determinism:** no real git, no temporary files, no wall-clock reads; recording invokers set `$global:LASTEXITCODE`, and `AfterEach` resets it.
- **Isolation:** `Get-CheckpointFileContent` is re-mocked per test with a closure; the run resolution mock is in a `Describe`-level `BeforeAll`.
- **Speed:** all new tests are pure or use mocked seams.
- **Diagnostics:** hook rows assert the exact block message; parity suites report the fixture name with the ordered error-list diff.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | PASS | Fixed argument array; the path is validated against an anchored pattern before it reaches git; no string concatenation into a shell. |
| Input validation at boundaries | PASS | Rules 10 and 11a-11e in the validators; path re-check in the hook. |
| Error handling remains explicit | PASS | Every probe failure blocks; any adoption error waives nothing (fail-closed corpus rows). |
| Configuration / path handling is safe | PASS | Only `docs/features/active/` folders are accepted; dot segments, backslashes, drive letters, and leading hyphens are rejected in all runtimes. |
| Receipts remain truthful | PASS | No code path writes `mcp_call_receipts[]`; the waiver is a separate declared record. |
| No host paths in committed artifacts | PASS | Added-line scan for host-path patterns: no matches. |

---

## Research Log

No external research was required. The review relied on the branch diff, `research/research.2026-10-29T15-40.md`, the spec, the evidence folder, and repository policy files.

---

## Verdict

The change is ready for the normal PR flow. The waiver is gated by a validated declaration in all three runtimes, and the Claude hook verifies that declaration against HEAD. The fail-closed behavior and the closed waivable set are preserved and pinned by the shared corpus. The validator-only gates remain declaration-only, which the rule prose states. Coverage is at or above baseline for every changed file. Merge remains subject to the S9 CI green gate on the final PR head.
