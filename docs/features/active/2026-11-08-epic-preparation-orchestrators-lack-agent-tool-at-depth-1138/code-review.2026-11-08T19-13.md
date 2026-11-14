# Code Review: Epic preparation orchestrators lack the Agent tool at depth (#1138)

**Review Date:** 2026-11-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138`
**Base Branch:** `main` (merge base `72e8b299c8ce99adce7db335e936974e8119493b`, equal to `origin/main`)
**Head Branch:** `bug/epic-subagent-nesting-depth` (`039dc51af81cc31f05f27e189843bd9f4506fcdb`)
**Review Type:** Re-audit after full remediation cycle 2 (F2, merge conflict with `origin/main`)

---

## Executive Summary

Cycle 2 merged `origin/main` in `1db21f006` and resolved the `PINNED_FROZEN_SURFACE_HASHES` conflict as F2 prescribed. F2 is closed.

- Mergeability: `git merge-tree --write-tree --name-only origin/main HEAD` exits 0 with result tree `db6598fc7349f201e8e909e20b4745f04d036a22`; `git diff <that tree> HEAD` is empty. `origin/main` is an ancestor of HEAD and is the merge base.
- Pins: `epic-orchestrator.md` pin `5ff9c66f58595fa91a1f568a18a0a5aae5d1736a9dd1b13a9bbbab459df7899c` and `epic-orchestrate/SKILL.md` pin `2e67dae3dd5a015693696125374e341f8c21963f36145bcf5fa8265ff8be924e` equal `sha256sum` of the head working files and of the `HEAD:` blobs.
- Comment blocks: the #1136 block is unchanged from main; the #1138 block follows it and states that the skill digest is the merged result of #1129, #1130, #1136, and #1138.
- No regression from the merge: for each of the nine files changed by both sides (six brief copies, two `epic-orchestrate/SKILL.md` copies, `core.json`), the sorted set of the branch's added and removed lines against `a90d522c6` equals the set against `72e8b299c`. Live and bundle copies of the skill, the execution-environment brief, and `epic-orchestrator.md` are byte-identical (`cmp`); the six brief copies share blob `5b833e77…`.

**Top risks:**
1. None blocking. The hook reads only the configured value of the process environment; the instruction-level preflight remains the primary control (unchanged from the first review).

**PR readiness recommendation:** **Go.**

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | `PINNED_FROZEN_SURFACE_HASHES` | F2 closed. Merge resolved with both comment blocks, the branch's agent digest, and the merged skill digest. | None. | Matches the prescribed resolution exactly. | `git diff 72e8b299c HEAD` of the module; `sha256sum`; reviewer `pytest -n auto` of the surface-contract module: 38 passed |
| Info | `.claude/hooks/epic-invocation-nesting-depth.ps1` | parse message | Carried forward: a value above the Int64 range gets "is not an integer". | None; fail-closed. | Unchanged since the prior review. | Prior real-process probe |
| Info | `.claude/skills/*/SKILL.md` | `## Nesting Depth`, Fallback paragraph | Carried forward: the fallback does not say how the main session obtains the coordinator's delegation prompt. | None now; spec non-goal. | Spec-accepted design limitation. | `spec.md` Non-goals |

No covered file reaches 700 lines (pin module 457 logical lines, helper 126, origin hook 295, largest test module 499); no file-size Warning applies and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well
- No branch PowerShell file changed in the delta; the merge brought in main's files without touching the branch's hunks.

#### Coverage at the merged head
- `artifacts/pester/powershell-coverage.xml` (written after the merge): helper 19/19, origin hook 69/76, repo-wide 95.66%.

### Python implementation audit
Test-only: the merge resolution edits one digest and the comment block in a test-support module. No production Python changed.

### TypeScript and C# implementation audits
N/A. No TypeScript or C# file changed.

---

## Base Drift Check

- `git fetch origin`; `origin/main` = `72e8b299c`, equal to `git merge-base origin/main HEAD`.
- `git merge-tree --write-tree --name-only origin/main HEAD`: exit 0, no conflict; result tree equals the head tree.
- Merge commit `1db21f006` parents: `91527f56b` (branch) and `72e8b299c` (main).

---

## Test Quality Audit

### Reviewed test and QA artifacts
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (merge-resolved).
- `evidence/qa-gates/post-merge-gates.2026-11-08T19-12.md`.

### Quality assessment prompts
- The pin test discriminates the resolution: at the merged head, either side's pre-merge skill digest (`73d5c859…` from main, `07c02db2…` from the branch) differs from the file's SHA-256, so choosing a side would fail `test_frozen_epic_surface_matches_pinned_baseline_digest`. The test passes with `2e67dae3…`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection of the delta |
| No unsafe subprocess or command construction | PASS | No production change in the delta |
| Input validation at boundaries | PASS | Unchanged |
| Error handling remains explicit | PASS | Unchanged |
| Configuration / path handling is safe | PASS | Unchanged |

---

## Research Log

No external research was required.

---

## Verdict

PASS. F2 is closed; the merge introduced no regression in the branch's files; no blocking finding remains.
