# Code Review: Epic-Child PR Merges Without CI (Issue #1130), Re-audit After Cycle 1

- **Branch:** `bug/epic-child-pr-ci-required` @ `10c5da1894c7f18fcfab454f5ef5541787ca8212`
- **Base:** `main`, merge base `cdcff3871765396183590128e142a929cf78327b` (equal to `origin/main` after fetch); `git merge-tree --write-tree origin/main HEAD` exits 0
- **Scope:** full branch diff, 72 files
- **Reviewer:** feature-review agent, 2026-11-08
- **Prior review:** `code-review.2026-11-08T15-30.md` at `03d222c55`

## Executive Summary

- `git diff --stat 03d222c55..HEAD` lists seven files: the four prior review artifacts, the cycle-1 evidence artifact, the Codex `core.json` manifest, and the manifest-completeness test module. No hook, helper, gate, skill, rule, brief, or Pester file changed, so the prior review's conclusions on those files are carried forward unchanged: the gate is not weakened, every verification stage fails closed, the child branch has no fall-through in either runtime, the #1097 review guard still precedes the child branch, no hook invokes Python, and all mirror copies match.
- **F1 is resolved.** `.agents/skills/ci-workflows/SKILL.md` is now listed at line 13 of `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, in alphabetical position, and the matching entry is removed from `PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS`. The bundle copy exists and is byte-identical to the source skill (`cmp`). The manifest parses as JSON with 220 paths and no duplicates. Removing the exception tightens the completeness test: it now fails if the skill is dropped from the manifest.
- Reviewer test run at `10c5da189` (`pytest -n auto`, seven manifest and contract modules): 74 passed, 0 failed. Executor full run: 16537 passed, 0 failed; Black, Ruff, Pyright clean on the edited test file; Codex generator `--check` exit 0.
- The skill sentence "Destination repositories receive this rule only through push-down" is now accurate for both runtimes.

No blocking finding remains. Verdict: PASS.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.codex/hooks/enforce-epic-merge-gate.ps1` | `Invoke-CodexEpicMergeDecision`, `Test-CodexChildMergeReady` branch | CR2 (carried forward). When the repository root holds a ready epic-child checkpoint for PR 43 and the command names PR 42, the Codex gate denies at stage 1 and does not reach the epic or standalone branch; the Claude gate's binding predicate makes the same case fall through. | None required for this item. If Codex epic roots can hold a child checkpoint, consider binding the Codex child branch by PR number in a later item. | Spec-directed (`RGC-CHILD-CI-STAGE1-PR-MISMATCH`) and fails closed. | Prior review `code-review.2026-11-08T15-30.md`; file unchanged since `03d222c55` |
| Minor | `.claude/skills/orchestrate/SKILL.md`; `.agents/skills/orchestrate/SKILL.md` | `## Step S9 — CI Green Gate`, dispatch fallback | CR3 (carried forward). The assumption that `gh pr checks` lists the check runs of a `workflow_dispatch` run on the PR head is unconfirmed. | On the first epic run after release, record whether `gh pr checks` shows the dispatched `CI` checks, as the spec's `## Rollout & Follow-up` names. | A failed assumption stalls S9; it does not weaken the merge gate, which reads `gh run list`. | Prior review; files unchanged since `03d222c55` |
| Nit | `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` and five other existing suites | Branch-1 allow rows | CR4 (carried forward). Several existing suites mock the entry `Get-EpicMergeGateChildCiDecision` instead of the two seams; plan-sanctioned, each with a stated reason. | None required. | The two new suites cover the helper. | Prior review; files unchanged since `03d222c55` |
| Nit | `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` | C11 | CR5 (carried forward). The load-failure case covers the Claude gate only; no row drives a Codex load failure of the new helper. | Optional: add the Codex counterpart in a later change. | The guarded pattern is shared and statically checked by `hook-dependency-guard-completeness.Tests.ps1`. | Prior review; file unchanged since `03d222c55` |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. Cycle 1 changed one covered file, the Python test module, by removing one line. The largest changed covered file is still `.claude/hooks/enforce-epic-merge-gate.ps1` and its bundle copy at 500 logical lines. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Cycle 1 change

The manifest entry is a single path string added to the `paths` array; the JSON remains valid and duplicate-free. The test-module change is a one-line removal from a `frozenset` literal; formatting, lint, and type checks are clean per `evidence/qa-gates/remediation-cycle1.2026-11-08T15-40.md`. The skill text and its bundle copy are unchanged, as the remediation inputs required. No other file was touched, so the light-path constraint (only the two named files plus the AC13 checkbox) holds; `spec.md` is not in the cycle-1 diff because AC13 was already checked at `03d222c55` and the prior review's uncommitted uncheck was not committed.

### Carried-forward areas

Helper stage logic, gate wiring, skill and rule text, security, and correctness are as recorded in `code-review.2026-11-08T15-30.md`; none of those files changed after `03d222c55`.

## Recommendation

PASS. Proceed to PR authoring; CR2 to CR5 need no change in this item.
