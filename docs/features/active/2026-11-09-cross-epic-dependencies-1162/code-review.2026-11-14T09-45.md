# Code Review: cross-epic-dependencies (#1162)

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-09-cross-epic-dependencies-1162`
**Feature Folder Selection Rule:** named by the caller; matches the branch issue number 1162
**Base Branch:** `main` (merge base `1d9f14e2c595b0065ad42a24188620f320ac514c`, equal to `origin/main` after a fetch at review time)
**Head Branch:** `feature/cross-epic-dependencies-1162` (head `97f4e351dd0dc42d206c225eed9ed999322d3521`, clean worktree)
**Review Type:** Re-audit after remediation cycle 1 (S7). Prior review `*.2026-11-14T07-20.md` (F1, F2); plan `remediation-plan.2026-11-14T07-20.md`, 20 of 20 tasks checked.

---

## Executive Summary

Remediation cycle 1 closes both blocking findings of the prior review with small, contained changes:
- F1: `Get-EpicCrossReadinessResult` in `.claude/lib/epic-wave/EpicCrossDependency.psm1` now fetches with `fetch -q --prune origin`, so a prerequisite integration branch deleted on the remote drops its remote-tracking ref. `Read-EpicCrossManifestText` then falls back to `origin/main`, and row 2 (`PREREQ_IN_MAIN`) is reachable. The module has a single fetch site, and the two copies carry the same blob id (`b7f1eb4d4`).
- F2: a **Status mapping (D7).** paragraph now follows the records paragraph in both epic-orchestrate skills, closes `## Wave Scheduling` in the epic-orchestrator agent, and forms a new bullet in the Codex toml. All four bundle copies are byte-identical. The mapping (`hold` to `held`; `PREREQ_IN_MAIN` to `in_main`; `PREREQ_ALREADY_INTEGRATED` or a completed D4 merge to `integrated`; `released` only between `merge_required` and the completed merge) agrees with `CROSS_EPIC_STATUSES`, `CROSS_EPIC_INTEGRATED_STATUSES`, the PowerShell `$script:IntegratedStatuses`, and the TypeScript twin. No validator changed.

The branch then merged `origin/main`, bringing in #1156. The 0010 ledger patch and the frozen-digest expectations conflicted and were resolved. The reviewer checked that the merge did not alter this item's own content (per-path comparison) and that the pinned digests match the committed bytes.

**Top 3 risks:**
1. The integration-to-main hold remains a skill-level control with a retrospective validator backstop (spec D5). This is documented and accepted by the spec.
2. `git fetch --prune origin` also prunes every other stale remote-tracking ref in the shared repository. This is standard git behavior and only removes refs whose remote branch no longer exists. It is recorded here as a property of the fix, not as a defect.
3. `EpicCrossDependency.psm1` is at 769 lines (advisory tier). The next growth of the module should move the gather functions into a sibling file.

**PR readiness recommendation:** **Go.** No blocking finding remains.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved | `.claude/lib/epic-wave/EpicCrossDependency.psm1` (and its two byte-identical copies) | `Get-EpicCrossReadinessResult`, line 653 | Prior F1 closed. The fetch runs as `fetch -q --prune origin` through `Invoke-EpicCrossGitExe`. A non-zero exit or a thrown wrapper still sets the fail-closed path. | None. | The stale-ref state from the prior review now reaches `release` with `PREREQ_IN_MAIN`, as spec `## Alternate and edge flows` (third bullet) requires. | Executor fail-before (`evidence/other/stale-ref-fail-before.2026-11-14T08-20.md`: `merge_required`) and pass-after (`stale-ref-pass-after.2026-11-14T08-22.md`). Reviewer mutant probe in SCRATCH: against the head module the adapter file passes 26 of 26; with the `--prune` argument removed, 6 tests fail, including the new stale-ref test. Blob id `b7f1eb4d4` for all three copies. |
| Resolved | `.claude/skills/epic-orchestrate/SKILL.md`, `.agents/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.codex/agents/epic-orchestrator.toml` (and bundle copies) | **Status mapping (D7).** paragraph (SKILL.md line 510; `.agents` line 309; agent line 165; toml line 79) | Prior F2 closed. Each surface states the decision-to-status mapping verbatim, including the main-gate statuses. | None. | Every launched feature now records `integrated` or `in_main`, the two statuses the started-while-held invariant accepts in all three runtimes. | `CES-STATUS-MAPPING` cases: fail-before 4 of 4 (`status-mapping-fail-before.2026-11-14T08-23.md`), pass-after (`status-mapping-pass-after.2026-11-14T08-24.md`). Reviewer read of the four paragraphs and of the validator status sets. Bundle blob parity confirmed with `git ls-files -s`. |
| Warning | `.claude/lib/epic-wave/EpicCrossDependency.psm1` | whole file | 769 logical lines, at or above the 700-line advisory tier and below the 800-line hard limit. The same count applies to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/EpicCrossDependency.psm1` and `extensions/drm-copilot/resources/lib/epic-wave/EpicCrossDependency.psm1`. The cycle added no line. | Move the gather functions and `Invoke-EpicCrossReadinessCommand` into a sibling adapter file when the module next grows. | Advisory tier only; non-blocking. | Reviewer logical line count (`awk 'END{print NR}'`). |
| Info | `.claude/lib/epic-wave/EpicCrossDependency.psm1` | `ConvertFrom-EpicCrossFlowValue` | Carried from the prior review: a trailing YAML comment after the inline value is rejected as malformed. This fails closed. | None required. | Conservative parse. | Code reading of the parser. |

Blocking findings: none. The Resolved rows record the closure of the prior blocking findings. The Warning and Info rows are non-blocking.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well

- No Python production file changed in the cycle. The only Python change is `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: two re-pinned digests and an extended `# RE-BASELINED by issue #1162.` paragraph that states the cycle-1 and #1156 merge history.

#### Typing and API notes

- Pyright 0 errors; Black and Ruff clean (`python-static.2026-11-14T09-10.md`).

#### Error handling and logging

- Unchanged.

### PowerShell implementation audit (if applicable)

#### What changed well

- The F1 fix is one argument added in place inside the existing wrapper call, so the seam, the fail-closed `try`/`catch`, and the line count are unchanged.
- The new adapter test models one clone. A `fetch` call that carries `--prune` marks the stale ref as pruned. `show` of the branch manifest then exits 128 instead of returning the provider text. The test asserts both the decision and exactly one call with the argument array `fetch|-q|--prune|origin`. Its state lives in module script scope and is cleared in `finally`.
- The `CES-STATUS-MAPPING` rows reuse the file's section, collapse, and token helpers, and read the whole toml when the row has no heading.

#### API and safety notes

- No public interface change. `Invoke-EpicCrossReadiness.ps1` and its tests are unchanged.

#### Error handling and logging

- Unchanged: usage errors exit 2, validation errors exit 1.

### TypeScript implementation audit (if applicable)

- No TypeScript source changed in the cycle or in the main merge. The item's four validator files keep their earlier review state. Root-report figures: `epic-orchestrator-state-resolution.ts` 98.85% lines / 96.99% branches, the other three at 100% lines.

### C# implementation audit (if applicable)

- N/A: no C# file in the branch diff.

---

## Test Quality Audit

- Discrimination (F1): verified independently by mutation. The reviewer copied the head module and the adapter test file into SCRATCH with the repository layout, and ran the file once against the head module and once against a copy with the `--prune` argument removed. Results: 26 of 26 pass on the head module; 20 pass and 6 fail on the mutant, including `releases with PREREQ_IN_MAIN when the remote integration branch was deleted but its tracking ref is stale`.
- Discrimination (F2): the six tokens are whole sentences, so removing or rewording any sentence fails the matching surface row. The executor's fail-before run shows exactly the four new cases failing before the text existed.
- Determinism and isolation: no real `git` or `gh`; the clock is mocked; no temporary file (reviewer search of added test lines for temporary-path APIs: no match); parallel gates pass with 0 failures.
- Merge regression check: post-merge Pester 25005 tests, pytest 16828, Jest 5629 and 5646, all 0 failed. These include `PRC-LEDGER-CHAIN-HOLDS`, `PRC-LEDGER-SUBCHAIN-HOLDS`, `test_frozen_epic_surface_matches_pinned_baseline_digest`, the push-down resource and pack-manifest contract tests, and the #1156 suites.

### Reviewed test and QA artifacts

- `evidence/remediation-baseline/` (pester, pytest, jest, jest-root, powershell-static, python-static)
- `evidence/other/stale-ref-fail-before.2026-11-14T08-20.md`, `stale-ref-pass-after.2026-11-14T08-22.md`, `status-mapping-fail-before.2026-11-14T08-23.md`, `status-mapping-pass-after.2026-11-14T08-24.md`
- `evidence/other/frozen-digests.2026-11-14T08-26.md`, `frozen-digests.2026-11-14T09-02.md`, `main-sync.2026-11-14T09-02.md`, `autonomous-decisions.2026-11-14T09-36.md`, `preflight-fixes.2026-11-14T07-52.md`
- `evidence/qa-gates/phase-gate.P1.2026-11-14T08-57.md`, `powershell-static.2026-11-14T09-09.md`, `python-static.2026-11-14T09-10.md`, `pester.2026-11-14T09-30.md`, `pytest.2026-11-14T09-34.md`, `jest.2026-11-14T09-35.md`, `jest-root.2026-11-14T09-35.md`, `coverage-comparison.2026-11-14T09-36.md`, `self-review.2026-11-14T09-37.md`

### Quality assessment prompts

- Do the tests discriminate? Yes. The F1 test was mutation-verified by the reviewer, and the F2 rows were fail-before verified by the executor.
- Are legacy inputs covered? Yes. The failed-fetch and thrown-wrapper rows still hold with `PREREQ_UNVERIFIABLE` under the new argument array.

---

## Security / Correctness Checks

- No secrets, absolute paths, or host names in the added lines (reviewer search of the full branch diff).
- No unsafe command construction; executables still run only through the two wrappers.
- No hook file and no registration changed (`git diff --stat` over `.claude/hooks`, `.codex/hooks`, and `.claude/settings.json` is empty).
- Main merge (#1156): the item's per-path added and removed line counts are identical before and after the merge, except in `parallel_orchestrator_surface_expectations.py` (the extended re-baseline paragraph) and `0010-early-dependent-starts.patch` (hunks regenerated over #1156). The changed-line sets of both epic surfaces are identical. The SHA-256 values of the committed `.claude/agents/epic-orchestrator.md` (5561f79d...af03) and `.claude/skills/epic-orchestrate/SKILL.md` (e334237b...7e80) equal the pinned values and the patch's `+` digest lines.
- Ledger chain: the post-merge full Pester gate passes `PRC-LEDGER-CHAIN-HOLDS` and `PRC-LEDGER-SUBCHAIN-HOLDS`.
- Status mapping versus validators: `CROSS_EPIC_STATUSES = ("held", "released", "integrated", "in_main")`, `CROSS_EPIC_INTEGRATED_STATUSES = ("integrated", "in_main")`, and the PowerShell `$script:IntegratedStatuses` agree with the mapping text. The main gate is documented as `held` or `released`, and the completion check requires `released`.

---

## Research Log

- Read the prior review set and remediation inputs, the remediation plan, and every cycle-1 evidence file.
- Read the fix commit `692aece0c` in full, and the main-merge resolution evidence.
- Fetched `origin/main`: it equals the merge base `1d9f14e2c`, and `git merge-tree` with HEAD is clean.
- Ran SCRATCH probes: the F1 mutant probe; per-path main-merge neutrality; digest recomputation; blob parity for all source and copy pairs; logical line counts of the changed covered files; scans of the diff for absolute paths and temporary-file APIs; the evidence-location validator; per-file coverage parsed from the three canonical reports.
- Checked GitHub: no PR and no CI run exist for the branch.

---

## Verdict

**Go.** Prior findings F1 and F2 are closed, with discrimination verified. No new blocking finding was found. One file-size Warning and one Info row are non-blocking.
