# Code Review: Epic preparation orchestrators lack the Agent tool at depth (#1138)

**Review Date:** 2026-11-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138`
**Base Branch:** `main` (merge base `a90d522c6ac239bca858d7bc800d52860e823219`; `origin/main` is now `72e8b299c8ce99adce7db335e936974e8119493b`, 31 commits ahead)
**Head Branch:** `bug/epic-subagent-nesting-depth` (`88cbdb8eaf22197b1e74ba262affcbeb019e9b12`)
**Review Type:** Re-audit after light remediation cycle 1

---

## Executive Summary

Cycle 1 (commit `88cbdb8ea`) closed F1 and applied the orchestrator-added P0-T2 change correctly.

- F1 closed: the four coordinator agents and their bundle copies carry, in the `## Startup Protocol` lead paragraph after the child-halt sentence, "When an `Agent(orchestrator)` call is denied with a reason beginning `NESTING_DEPTH_INSUFFICIENT:`, halt with that reason and record `spawn_agent_unavailable` in the same way; do not do the child's work in its place." The text matches the required change verbatim. `cmp` confirms the bundle copies are byte-identical. The new contract `It` "coordinators halt on a NESTING_DEPTH_INSUFFICIENT deny" asserts `NESTING_DEPTH_INSUFFICIENT:` and `halt with that reason` inside the preflight region of all eight copies; `halt with that reason` appears exactly once per coordinator file, only in the new sentence, so removing the sentence fails the `It`. The `epic-orchestrator.md` pin equals the SHA-256 of the head file (`5ff9c66f…`), and the #1138 comment block was extended.
- P0-T2 correct and tested: `[long] $parsedValue` with `[long]::TryParse` (Integer style, invariant culture). A real-process probe (`pwsh -NoProfile`, variable set in the child environment) gave: `3`, `99999999999`, `9223372036854775807`, `+5`, ` 7 ` allow; `2` and `-99999999999` deny with the below-3 reason; `9223372036854775808`, `1e3`, `0x10` deny with the parse message; `epic-orchestrator` to `orchestrator` at `2` denies. The added allow value `99999999999` fails under the prior `[int]` parse, so the test discriminates the change. The helper stays at 19 of 19 lines covered, including lines 113 and 114.

One new blocking finding: `origin/main` received PR #1140 (issue #1136) after the merge base, and that PR also re-baselined `PINNED_FROZEN_SURFACE_HASHES`. `git merge-tree --write-tree --name-only origin/main HEAD` exits 1 with a content conflict in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`. A conflicting pull request gets no CI checks, so the S9 gate cannot pass.

**Top risks:**
1. F2 (blocking): merge conflict with `origin/main`; the `epic-orchestrate/SKILL.md` digest must be re-derived from the merged file, because both sides changed that file.
2. The hook reads only the configured value of the process environment; the instruction-level preflight remains the primary control (unchanged from the first review).

**PR readiness recommendation:** **No-Go until F2 is resolved.**

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | `PINNED_FROZEN_SURFACE_HASHES` and its comment block | F2. Base drift: `origin/main` (`72e8b299c`, PR #1140, issue #1136) re-baselined the `.claude/skills/epic-orchestrate/SKILL.md` digest and added a #1136 comment block in the same region this branch edited, so the merge conflicts. Both sides also changed `epic-orchestrate/SKILL.md`; the merged file's SHA-256 is `2e67dae3dd5a015693696125374e341f8c21963f36145bcf5fa8265ff8be924e`, which equals neither side's pin (`73d5c859…` on main, `07c02db2…` on the branch). All other overlapping files (six brief copies, both `epic-orchestrate` copies, `core.json`) auto-merge, and in the merged tree the six brief copies share one blob id and the two skill copies share one blob id. | Merge `origin/main` into the branch. In the pin module keep both comment blocks (#1136 and #1138), keep the branch's `epic-orchestrator.md` digest (main did not change that file), and set the skill digest to the SHA-256 of the merged `.claude/skills/epic-orchestrate/SKILL.md`. Re-run one `Invoke-PoshQCParallelTest` and one `pytest -n auto --cov --cov-branch` at the merged head. | A conflicting PR receives zero CI checks, so S9 cannot complete. The semantic part (re-deriving the skill digest) is not resolved by picking either side of the textual conflict. | `git merge-tree --write-tree --name-only origin/main HEAD`: exit 1, `CONFLICT (content)` in the pin module; `git diff a90d522c6..origin/main` of the module; SHA-256 of the merged-tree blob |
| Info | `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py` | arc 395 to 362 | Repo-wide pytest branch coverage is 94.36% (12648 of 13404) at the cycle-1 gate versus 94.37% (12649) at baseline. The coverage JSON reports differ only in this file and only in this arc, the loop-back from the idle-timeout check to the next 0.1 s queue poll, which runs only when a poll sees the process still running within its idle window. | None for this branch. The file is outside the branch diff and no Python production line changed; the difference comes from subprocess timing in an existing test. | Not attributable to the branch; no changed-line regression. | Reviewer comparison of `issue-1138-cov-{baseline,final,r1}.json` |
| Info | `.claude/hooks/epic-invocation-nesting-depth.ps1` | parse message | A value above the Int64 range (`9223372036854775808`) still gets "is not an integer". | None; fail-closed and not a realistic setting. | Residual of the closed Low item. | Real-process probe |
| Info | `.claude/skills/*/SKILL.md` | `## Nesting Depth`, Fallback paragraph | Unchanged from the first review: the fallback does not say how the main session obtains the coordinator's delegation prompt once the coordinator halts. | None now; spec non-goal (research option C2). | Spec-accepted design limitation. | `spec.md` Non-goals |

No covered file reaches 700 lines (largest: `test_parallel_orchestrator_surface_contracts.py`, 499 logical lines; helper 126; origin hook 295); no file-size Warning applies and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well
- The P0-T2 edit is limited to the declaration and parse call; the subsequent `-ge 3` comparison and both messages work unchanged on `[long]`.
- The live hook and its bundle copy are byte-identical (`cmp`).
- The new contract `It` reuses the preflight-region extractor, so it pins the sentence to the Startup Protocol lead paragraph rather than anywhere in the file.

#### Real-process probe (reviewer, head helper)

| Value | Caller | Target | Decision |
|---|---|---|---|
| `3`, `99999999999`, `9223372036854775807`, `+5`, ` 7 ` | main | epic-planner | allow |
| `2`, `-99999999999` | main | epic-planner | deny, below-3 reason |
| `9223372036854775808`, `1e3`, `0x10` | main | epic-planner | deny, parse message |
| `2` | epic-orchestrator | orchestrator | deny |

#### Mirror and pin parity
- `cmp` of the five agent files and the helper against `extensions/drm-copilot/resources/claude-customizations/.claude/`: identical.
- `PINNED_FROZEN_SURFACE_HASHES`: `5ff9c66f…` and `07c02db2…` equal the SHA-256 of the head `epic-orchestrator.md` and `epic-orchestrate/SKILL.md`.

### Python implementation audit
Test-only: the cycle-1 edit changes one digest and extends the #1138 comment. No production Python changed.

### TypeScript and C# implementation audits
N/A. No TypeScript or C# file changed.

---

## Base Drift Check

- `git log --oneline a90d522c6..origin/main`: 31 commits (PR #1140, issue #1136).
- Files changed on both sides: six execution-environment brief copies, both `epic-orchestrate/SKILL.md` copies, `pack-manifests/core.json`, and the pin module.
- `git merge-tree --write-tree --name-only origin/main HEAD`: exit 1; conflict only in the pin module (F2).

---

## Test Quality Audit

### Reviewed test and QA artifacts
- `tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1`, `tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1`, the pin module.
- `evidence/qa-gates/pester-final.2026-11-08T18-42.md`, `poshqc-static-final.2026-11-08T18-42.md`, `pytest-final.2026-11-08T18-42.md`, `python-static-final.2026-11-08T18-42.md`.

### Quality assessment prompts
- Discrimination was judged by fixture inspection and direct real-process probes rather than a single-file mutant run (the repository runs tests in parallel only): the `99999999999` allow value and the `halt with that reason` literal each fail against the pre-cycle code.
- The added deny value `-99999999999` passes under both parses (Int32 parse failure also denies); it documents the lower bound but does not by itself discriminate the change.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection |
| No unsafe subprocess or command construction | PASS | The helper starts no process |
| Input validation at boundaries | PASS | Trimmed invariant-culture Int64 parse; non-integer fails closed |
| Error handling remains explicit | PASS | Guarded dot-source denies on import failure |
| Configuration / path handling is safe | PASS | Unchanged from the first review |

---

## Research Log

No external research was required.

---

## Verdict

REMEDIATION_REQUIRED. F1 is closed and P0-T2 is correct and tested. One blocking finding remains: F2 (merge conflict with `origin/main`, Remediability autonomous, Finding-Scope contained). The remediation path is full because the prior cycle was light.
