# Code Review: epic-orchestrate (#275)

---

**Review Date:** 2026-07-02
**Reviewer:** feature-review agent (Claude Sonnet 5)
**Feature Folder:** `docs/features/active/2026-07-02-epic-orchestrate-275/`
**Feature Folder Selection Rule:** Selected as the active feature folder matching issue #275 referenced in the branch name (`drm-copilot-wt-2026-07-02-19-03`) and in the PR context artifacts' "Referenced issues" section.
**Base Branch:** `main` (merge-base `3c5ff3289022abc3b7b16e2441c772e5f81fd9ff`)
**Head Branch:** `drm-copilot-wt-2026-07-02-19-03` @ `25a4a3644c9767d27a79d72c2033d68c8561eaf2`
**Review Type:** Initial review

---

## Executive Summary

This change adds `epic-orchestrate`: a new `epic-orchestrator` agent, `.claude/skills/epic-orchestrate/SKILL.md`, three new PowerShell `PreToolUse` gate hooks, an epic-checkpoint schema plus Python and TypeScript validators (kept in exact parity), routing-configuration and settings-wiring updates, and an epic-mode extension to the existing single-feature `orchestrate` skill's S9/PR-Creation-Gate sections. The change is large (81 files, 8225 insertions) but the core logic footprint is modest and cohesive: 3 new PowerShell hooks (304/304/237 lines), 1 modified PowerShell hook (+112 lines), 1 new Python validator module (488 lines) with a matching TypeScript port (451 lines), and dispatch/enum wiring in existing files.

**What changed:**
The implementation follows the repository's existing sibling-module and cross-language-port conventions closely: the new epic-checkpoint validator is a sibling to `validate_orchestrator_state.py` (not folded into it), the TypeScript port mirrors the Python module function-for-function with identical error-string wording, and the new hooks follow the same injectable-read-seam pattern (`Get-*Content` functions) already used by `enforce-orchestration-preimplementation-gate.ps1` and `enforce-pr-author-skill.ps1`. All toolchains were independently re-run by this review (not solely re-read from executor evidence) and passed cleanly: PSScriptAnalyzer zero findings, 467/467 Pester; Black/Ruff/Pyright clean, 1184+19/48 Pytest; Prettier/ESLint/TSC clean, 1462/47 Jest.

**Top 3 risks:**
1. `.claude/hooks/enforce-pr-author-skill.ps1` now exceeds the repository's 500-line file-size limit (543 lines), and its bundled mirror is equally affected — a concrete policy violation, not a style nit.
2. No coverage artifact in the mandated `lcov` format exists anywhere in the repository for the TypeScript changes in this feature, because the final QA gate's `--coverageReporters` override excluded `lcov`. Measured coverage is compliant, but the artifact requirement is not met.
3. `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` gates every `git worktree remove` command unconditionally, with no epic-mode precondition (unlike the wave-barrier hook), which could surprise a future non-epic workflow that legitimately needs to remove a worktree.

**PR readiness recommendation:** **Needs Revision** — the two Blocker-level findings below (500-line limit; missing coverage artifact) should be resolved before merge; the remainder are Major/Minor and can be addressed in the same change or tracked as prompt follow-ups.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/enforce-pr-author-skill.ps1` (and its byte-identical bundled mirror) | Whole file (543 lines) | The file now exceeds the repository's mandatory 500-line limit for production PowerShell/scripts. Baseline was 441 lines; this feature added +112 lines (the sixth receipt check, `Test-EpicBaseBranchOverride`, plus its checkpoint-read seam and docstrings). | Extract `Test-EpicBaseBranchOverride` and `Get-PrAuthorCheckpointContent` (and their docstrings) into a small sibling dot-sourced module, or otherwise trim the file below 500 lines; re-verify byte-identical mirror parity afterward. | `general-code-change.md` and `powershell.md` both state "No production code... file may exceed 500 lines" / "Keep scripts cohesive and under 500 lines" with no tier-based exception. | `wc -l .claude/hooks/enforce-pr-author-skill.ps1` → 543; `git show 3c5ff329...:.claude/hooks/enforce-pr-author-skill.ps1 \| wc -l` → 441 (independently reproduced). |
| Blocker | (repository-wide; TypeScript coverage output) | `extensions/drm-copilot/coverage/` (no `lcov.info`) | No coverage artifact in `lcov` format exists for the TypeScript changes in this feature. The final QA gate ran Jest with `--coverageReporters=text-summary --coverageReporters=json-summary`, which overrides Jest's default reporter set (which includes `lcov`) and produces no `lcov.info`. | Re-run the final TypeScript coverage gate without overriding `--coverageReporters` (or explicitly include `lcov`), and commit/reference the resulting artifact path (e.g., `extensions/drm-copilot/coverage/lcov.info`) in the feature's evidence. | The repository's mandatory coverage-verification procedure treats an absent coverage artifact for a language with changed files as a FAIL condition, independent of the underlying (here, compliant) coverage percentages. | `find . -iname lcov.info` returns only `artifacts/python/lcov.info`; `extensions/drm-copilot/coverage/` contains only `coverage-final.json` and `coverage-summary.json` (independently confirmed). |
| Major | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` array | The canonical `artifacts/pester/powershell-coverage.xml` artifact's file allowlist does not include any of the 5 new/modified hook files in this feature (`enforce-epic-merge-gate.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `enforce-pr-author-skill.ps1`, `validate-orchestrator-output.ps1`). Real per-file coverage numbers for these files exist only in a non-canonical supplemental artifact (`artifacts/pester/final-phase2-coverage.xml`), generated with a different (non-default) settings file. | Add the 5 files to `CodeCoverage.Path` so the canonical coverage artifact reflects this feature's code going forward. | The canonical artifact is the one referenced by the repository's coverage-verification contract; a durable scope gap means every future change to these files will continue to be invisible to the canonical coverage gate. | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` list inspected directly; `artifacts/pester/final-phase2-coverage.xml` independently parsed and its per-file numbers matched exactly against `evidence/qa-gates/final-powershell.2026-07-02T22-10.md`. |
| Major | `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` | Whole file (739 lines, was 635 at baseline) | This test file was already over the 500-line limit before this feature (635 lines, a pre-existing violation) and grew by +104 lines via this feature's new epic-dispatch tests, rather than placing those tests in a new sibling test file — a pattern this same feature *did* use for `test_validate_epic_orchestrator_state.py`. | Split the dispatch-integration tests for `epic-orchestrator-state` (and ideally the pre-existing `orchestrator-state` dispatch tests) into a dedicated sibling test file, consistent with the sibling-module convention already used for the validator itself. | `general-unit-test.md`/`general-code-change.md`'s 500-line limit applies to test files too; growing an already-oversized file compounds the debt instead of paying it down. | `git show 3c5ff329...:tests/scripts/dev_tools/test_validate_orchestration_artifacts.py \| wc -l` → 635; current `wc -l` → 739 (independently reproduced). |
| Major | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | Whole file (unconditional activation) | The hook gates *every* `git worktree remove` Bash command fail-closed, with no epic-mode precondition — unlike `enforce-epic-wave-barrier.ps1`, which only activates when `subagent_type == "orchestrator"` and the prompt contains the `"Epic mode: true"` marker. Standalone (non-epic) orchestration does not currently call `git worktree remove` itself (confirmed via repo-wide grep), so no regression exists today, but any future or manual non-epic worktree cleanup will be unconditionally blocked unless a matching epic-checkpoint record exists. | Either document explicitly why this hook is intentionally scoped globally (matching AC9's literal wording, which does not itself require epic-mode scoping), or add the same epic-mode precondition used by the wave-barrier hook for consistency and to avoid surprising a future non-epic workflow. | Design-consistency and blast-radius concern: two sibling hooks in the same feature use different activation-scoping strategies with no stated rationale for the difference. | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` lines 199-201 (`if ($commandText -notmatch '(?i)\bgit\s+worktree\s+remove\b') { return ... }` with no subagent/marker check) vs. `.claude/hooks/enforce-epic-wave-barrier.ps1` lines 257-265 (subagent + marker guard). `git grep -n "worktree remove" .claude` shows no standalone-orchestration caller today. |
| Minor | `.claude/skills/orchestrate/SKILL.md` | Line 162 (S9 step 6) | The text references "convert the conflict into a synthetic Blocking finding per 'Merge-Conflict Remediation' below," but no heading named "Merge-Conflict Remediation" exists anywhere in this file. The actual procedure lives in a different file, `.claude/skills/epic-orchestrate/SKILL.md`'s "Merge-Conflict Handling (Fan-In)" section. | Correct the cross-reference to name the actual file and heading (e.g., "...per the epic-orchestrate skill's 'Merge-Conflict Handling (Fan-In)' section"). | A dangling "below" reference in a procedural document that agents follow at runtime is misleading and could cause a future agent to search the wrong document. | `grep -n "Merge-Conflict Remediation" .claude/skills/orchestrate/SKILL.md` returns only the referencing line itself; the real heading is confirmed present only in `.claude/skills/epic-orchestrate/SKILL.md` line 117. |
| Minor | `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md` | Wave Assignment sections | The longest-path-layering wave-computation formula is specified only as agent-followed prose; no dedicated, unit-tested pure function computes wave numbers from a DAG fixture. Only cycle-rejection (`_detect_dependency_cycle` / `detectDependencyCycle`) and post-hoc `waves[]`/`wave_number` self-consistency (`_validate_waves_consistency` / `validateWavesConsistency`) are code-tested; the formula's correctness against a known diamond-shaped DAG (as described in `user-story.md`'s own scenario) is not directly exercised by any test. | Consider adding a small, pure `compute_waves(features) -> dict[str, int]` helper (Python and/or TypeScript) with unit tests against a diamond-shaped DAG, a linear chain, and a cycle, mirroring the validator's own sibling-module pattern. | `spec.md`'s own "Seeded Test Conditions" checklist lists "Unit coverage areas: wave/topological-sort (longest-path-layering) computation" and leaves it unchecked, corroborating that this specific area was identified but not closed. | `docs/features/active/2026-07-02-epic-orchestrate-275/spec.md` lines 398-400 (unchecked); no `compute_wave`/`computeWave`-named function found via `grep -rn "computeWave\|compute_wave"` in the diff. |
| Info | `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` | Whole file | Excellent cross-language parity with the Python source: identical function names (camelCase vs. snake_case aside), identical error-string wording, identical validation ordering. This materially reduces the risk of the two validators silently drifting apart over time. | None — noted as a positive pattern to continue. | N/A | Direct side-by-side comparison of `scripts/dev_tools/validate_epic_orchestrator_state.py` and `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`. |

No additional Blocker findings beyond the two listed above.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `scripts/dev_tools/validate_epic_orchestrator_state.py` follows the existing sibling-module convention exactly (matching `validate_orchestrator_state.py`, `validate_policy_audit_artifact.py`), keeping the epic-checkpoint's structurally different required-key/status shape out of the per-feature validator rather than overloading it with conditional branches.
- Every function has a complete Google-style docstring (Purpose/Args/Returns/Raises/Side Effects), satisfying `self-explanatory-code-commenting.md` in full.
- Dependency-cycle detection (`_detect_dependency_cycle`) uses a standard iterative-DFS-with-visiting/visited-sets pattern, correctly distinguishing "still on the current path" (cycle) from "already fully resolved" (safe revisit) — this is a materially harder algorithm than the rest of the module and is implemented correctly and tested for both self-referential and transitive cycles.

#### Typing and API notes

- Fully typed under `from __future__ import annotations`; Pyright reports zero errors. The module exposes exactly one public function (`validate_epic_orchestrator_state_text`); all helpers are `_`-prefixed.
- `cast("list[Any]", ...)` / `cast("dict[str, Any]", ...)` are used narrowly at the exact points where `json.loads`'s untyped return needs a type assertion after an `isinstance` guard — an appropriate, minimal use of `cast`, not a blanket escape hatch.

#### Error handling and logging

- `json.JSONDecodeError` is caught specifically (not a broad `except Exception`), consistent with `python.md`'s "fail fast with specific exceptions" rule.
- The module returns error-string lists rather than raising, matching the existing validator convention and making the function trivially composable with the dispatch layer.

### TypeScript implementation audit

#### What changed well

- `epic-orchestrator-state-core.ts` mirrors the Python module function-for-function with identical error-string text — this is the single strongest quality attribute of this change, since a follow-on change to one validator without the other would be caught immediately by a text-level diff review or by the existing cross-language consistency test (`epic-artifact-type-consistency.2026-07-02T21-35.md` confirms the artifact-type string itself is identical across both).
- `isObject` type guard correctly excludes both `null` and arrays, avoiding the common `typeof x === "object"` pitfall.

#### Type safety and maintainability

- No `any` types are used; `unknown` plus explicit `isObject`/type-guard narrowing is used throughout, consistent with `typescript.md`.
- `orchestration-artifacts.ts`'s dispatch `switch` statement cleanly adds the new `"epic-orchestrator-state"` case using the same options-spreading pattern as the existing `"orchestrator-state"` case, requiring no refactor of the existing cases.

#### Error handling and logging

- `JSON.parse` failures are caught and converted into the same error-string-array contract used elsewhere; no exception escapes `validateEpicOrchestratorStateText`.

### PowerShell implementation audit

#### What changed well

- All three new hooks (`enforce-epic-merge-gate.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`) follow the established injectable-read-seam pattern (`Get-*Content` functions that tests mock directly), avoiding any temp-file usage in tests.
- The wave-barrier hook's `Find-EpicWaveBarrierFeatureFolderFromPrompt` function explicitly reuses the technique from `enforce-prd-feature-before-planner.ps1`'s `Find-PrdFeatureFolderFromPrompt` (longest-match-wins, `.md`-suffix-resolves-to-parent-directory) rather than reinventing path-token extraction — a good reuse decision per `general-code-change.md`'s "Reusability" principle.
- Every hook fails closed on an unreadable/missing checkpoint (deny, not allow), which is the correct posture for a security/policy gate and is explicitly documented as such in each hook's `.DESCRIPTION`.

#### API and safety notes

- Every function uses `[CmdletBinding()]` with typed `[OutputType(...)]`; parameter validation (`[Parameter(Mandatory)]`, `[AllowNull()]`) is used precisely where the fail-closed contract requires accepting `$null`.
- `enforce-pr-author-skill.ps1`'s new sixth check (`Test-EpicBaseBranchOverride`) is well-integrated into the existing five-check ordered-decision chain without disturbing the existing four PR_AUTHOR_RECEIPT_* checks' behavior or ordering (verified: the existing tests for checks 1-5 still pass unmodified aside from the three added `Mock -CommandName Get-PrAuthorCheckpointContent` no-op setups). See Findings Table for the resulting file-size concern.

#### Error handling and logging

- Malformed `CLAUDE_TOOL_INPUT` JSON throws an explicit, named error (`"enforce-epic-merge-gate hook received malformed JSON in CLAUDE_TOOL_INPUT: $_"`) rather than failing silently, and the top-level entrypoint wraps the decision call in `try/catch` with `Write-Error`/`exit 1`.

---

## Test Quality Audit

Automated verification evidence was reviewed both as executor-produced artifacts and via independent re-execution by this review (toolchains re-run directly rather than trusting evidence text alone). No end-to-end/manual verification evidence was expected or needed for this change, since it is entirely hook/validator/documentation logic with no UI surface.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `enforce-epic-wave-barrier.Tests.ps1`, `enforce-epic-worktree-removal-gate.Tests.ps1` — each verifies its hook's allow/deny decision across missing-checkpoint, malformed-checkpoint, wrong-epic-mode, and matching/non-matching-value scenarios; execution independently reproduced (30/24/22 `It` blocks, all passing).
- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` — verifies schema, cycle-rejection, wave-barrier-ordering, and completion-gate logic; independently reproduced (contributes to the 48-test scoped run).
- `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` — verifies the same contract as the Python test file, confirming cross-language parity; independently reproduced (contributes to the 47-test scoped run).
- `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/coverage-delta-verification.2026-07-02T22-30.md` — documents baseline-vs-final coverage deltas for all three languages; cross-checked against this review's own independent measurements and found accurate to within rounding.

### Quality assessment prompts

- **Determinism:** No wall-clock reads, `setTimeout`/`Start-Sleep`, or randomness observed in any new/modified production or test code across the three languages.
- **Isolation:** Each `It`/`test`/pytest function targets exactly one decision branch of exactly one function; no test exercises more than one hook/validator behavior at a time.
- **Speed:** Independently measured: 467 Pester tests in 11.65s, 1184+19 Pytest tests in ~5s, 1462 Jest tests in ~3.5s — well within "fast enough for frequent runs."
- **Diagnostics:** Pester assertions target the decision object's `permissionDecision`/`permissionDecisionReason` fields directly, so a failure clearly identifies which gate reason was (or was not) produced; Python/TS assertions compare exact error-string lists, equally diagnostic.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials, tokens, or connection strings observed in any new/modified file. |
| No unsafe subprocess or command construction | ✅ PASS | The new hooks only pattern-match already-supplied `CLAUDE_TOOL_INPUT.command` text via regex; none of them construct or execute a new subprocess/command themselves. |
| Input validation at boundaries | ✅ PASS | Every hook validates JSON parseability, then uses `PSObject.Properties.Name -contains` guards before accessing nested checkpoint fields; the Python/TS validators use `isinstance` guards throughout before treating parsed JSON values as the expected shape. |
| Error handling remains explicit | ✅ PASS | See Implementation Audit sections above; no silent catch-alls were introduced. |
| Configuration / path handling is safe | ✅ PASS | Checkpoint paths are hardcoded script-scoped constants (`artifacts/orchestration/epic-orchestrator-state.json`), not derived from unsanitized user/agent input; the worktree-removal gate normalizes path separators before comparison rather than doing unsafe string interpolation into a shell command. |
| Non-cryptographic trust boundary documented | ✅ PASS (documented limitation, not a defect) | Both `enforce-epic-merge-gate.ps1` and the existing `enforce-pr-author-skill.ps1` receipt mechanism explicitly document that the checkpoint-trust design is a policy-level, non-cryptographic control (any actor with filesystem write access could forge checkpoint state), consistent with the accepted repository posture. |

---

## Research Log

No external research was required for this code review. Feasibility of the merge-conflict-as-remediation-finding design and the three new `PreToolUse`-hook gating mechanisms was confirmed in the feature's own committed research documents (`docs/features/active/2026-07-02-epic-orchestrate-275/research/concurrency-and-hardening.research.md`, §§3-6), which this review read and cross-checked against the implemented hooks; no gaps between the research's stated feasibility conclusions and the actual implementation were found.

---

## Verdict

The implementation quality is high: cross-language parity between the Python and TypeScript validators is exemplary, the PowerShell hooks consistently follow the repository's established injectable-seam and fail-closed conventions, and independent re-execution of all three languages' full toolchains (format, lint, type-check, test) found zero findings and zero failing tests. However, this review identifies two Blocker-level policy-compliance gaps that the executor's own evidence did not surface: a 500-line file-size violation on `.claude/hooks/enforce-pr-author-skill.ps1`, and an absent canonical TypeScript coverage artifact. Three further Major/Minor findings (a PowerShell coverage-artifact scope gap, an already-oversized test file grown further, an unconditional worktree-removal-gate scope, and a broken internal documentation cross-reference) do not block correctness but should be addressed. This change should not merge until the two Blocker findings are resolved; the remaining findings can be resolved in the same pass or tracked as a prompt, scoped follow-up.
