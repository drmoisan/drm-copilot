# Feature Audit: Epic Integration Branch Pre-Wave Main-Sync Step (#902)

---

**Audit Date:** 2026-10-12
**Feature Folder:** `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902`
**Base Branch:** `origin/main`
**Head Branch:** `bug/epic-integration-branch-not-synced-with-main-902`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `12b2454256cfa11ff809d5d2333ddaf988574e21`)
- **Head branch/commit:** `bug/epic-integration-branch-not-synced-with-main-902` (commit `15e8c2a46e4f6a4c4d8f316a1144e38f7f7a57c6`)
- **Merge base:** `12b2454256cfa11ff809d5d2333ddaf988574e21`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-12 23:35 UTC, head `15e8c2a46`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902/evidence/{baseline,regression-testing,qa-gates,other}/`
  - Additional evidence: reviewer re-runs of Black `--check`, Ruff, Pyright, the 111-node pytest set, `validate_evidence_locations.py`, `git hash-object` on the four surfaces, and a baseline-substring check of `PRE_CHANGE_LIFECYCLE_TEXT`
- **Feature folder used:** `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902`
- **Requirements source:** `issue.md` `## Acceptance Criteria` only
- **Work mode resolution note:** Explicit marker `- Work Mode: minor-audit` in `issue.md`; `spec.md` and `user-story.md` are intentionally absent.
- **Scope note:** The local `main` ref is stale (`2ef8d361e`); the audit used `origin/main` @ `12b2454`, which matches the PR context. Merge commit `94a55ff5c` contributes no diff relative to that merge base. Full branch diff: 39 files, of which 6 lie outside the feature folder.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902/issue.md` - only source (`## Acceptance Criteria`)

### Acceptance criteria

1. AC-1: `.claude/skills/epic-orchestrate/SKILL.md` "Epic Integration Branch Lifecycle" contains a pre-wave main-sync step that runs `git rev-list --count <integration>..origin/main` after fetching `origin/main` and before each wave launches.
2. AC-2: The new step states that a non-zero count causes the main-sync to run as a dedicated chore child item (a child branch created from the integration branch that merges `origin/main` and opens a PR into the integration branch, per the `epic-852-main-sync` / PR #882 pattern) that must merge before the wave launches, and that a zero count proceeds directly to the wave.
3. AC-3: Every parity surface the research identifies (bundled mirror, epic-orchestrator persona where it restates the lifecycle, Codex counterpart skill) carries the same step, and the existing parity or bundle-sync checks for those surfaces pass.
4. AC-4: New contract tests pin the presence of the pre-wave main-sync step (the `rev-list --count` check and the chore-child route) in the canonical skill and in each parity surface, and fail when the step is removed.
5. AC-5: No hook file under `.claude/hooks/` or `.codex/hooks/` and no policy document under `.claude/rules/` or `.github/instructions/` is modified.
6. AC-6: The final QC loop for every language touched by the change (formatter, linter, type checker where applicable, tests with coverage) passes, with evidence recorded under the feature folder's `evidence/` tree.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 pre-wave `rev-list --count` step after fetching main | PASS | `.claude/skills/epic-orchestrate/SKILL.md` lifecycle step 3: "Before each wave launches (wave 0 included), `epic-orchestrator` runs `git fetch origin main` and then `git rev-list --count origin/epic/<epic-slug>-integration..origin/main`". Ordering nodes confirm it sits after the integration fetch and before child branching. | `git diff 12b2454 HEAD -- .claude/skills/epic-orchestrate/SKILL.md`; `poetry run pytest tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py -q -p no:cacheprovider` | `<integration>` is concretized as `origin/epic/<epic-slug>-integration`, which matches the criterion's placeholder. |
| 2 | AC-2 non-zero count runs a chore child that merges before the wave; zero proceeds | PASS | Step 3 text: "A zero count proceeds directly to the wave. A non-zero count ... the main-sync runs as a dedicated chore child item before the wave launches, following the `epic-852-main-sync` / PR #882 pattern ... Its branch is created from the integration branch, merges `origin/main` with a merge commit ... and opens a PR into the integration branch. The wave does not launch until that PR has merged". | Same diff and presence nodes `[claude-skill]`, `[claude-bundle]` | The text also adds checkpoint pre-registration and a one-sync-per-wave limit; both are consistent with the barrier hook's behavior (hook lines 319-331). |
| 3 | AC-3 parity surfaces carry the step; parity checks pass | PASS | Claude bundle byte-identical (`7a214403...` on both); Codex skill and bundle byte-identical (`c708d88d...` on both) and carry the step paragraph; persona surfaces classified as not restating the lifecycle (`evidence/other/persona-parity-classification.2026-10-11T10-38.md`), and the persona digest node passes. Local parity nodes: 6 passed (`final-parity-nodes`); 98-node regression set passed. | `git hash-object <four surfaces>`; `poetry run pytest <9 modules> -q -p no:cacheprovider` (111 passed, reviewer re-run) | CI-pending dependency: the Pester suites `codex-epic-runtime-contracts.Tests.ps1` and `checkpoint-hygiene-skill-contract.Tests.ps1` run only in PR CI. Their relevant assertions (byte identity, the `## Epic-Level Checkpoint` section) were verified locally by hash equality and section inspection. The Codex paragraph is a condensed restatement (see code-review Minor and Info findings); the pinned fragments are present. |
| 4 | AC-4 contract tests pin presence and fail when the step is removed | PASS | `test_epic_orchestrate_main_sync_contract.py`: four presence nodes (all surfaces) pin `rev-list --count`, the chore-child route, and ten further fragments. Removal tests for the Claude and Codex surfaces and the pre-change test assert failure. Fail-before: 10 failed / 3 passed. Pass-after: 13 passed. | `evidence/regression-testing/fail-before.2026-10-11T10-38.md`; `evidence/regression-testing/contract-tests-pass.2026-10-11T10-38.md` | Removal-sensitivity is tested on the canonical Claude skill and the Codex skill; the bundle copies are covered through presence nodes plus byte-parity. |
| 5 | AC-5 no hook, rule, or instruction file modified | PASS | Reviewer diff over `.claude/hooks`, `.codex/hooks`, `.claude/rules`, `.github/instructions` (plus `.claude/agents`, `.codex/agents`) is empty. | `git diff --name-only 12b2454 HEAD -- .claude/hooks .codex/hooks .claude/rules .github/instructions .claude/agents .codex/agents` | Also recorded in `evidence/qa-gates/final-scope-boundary.2026-10-11T10-38.md`. |
| 6 | AC-6 final QC loop passes with evidence | PASS | Executor pass 2 clean (Black, Ruff, Pyright, Pytest 111, parity nodes, coverage no-regression at 740/17636 and support module 34/34). The reviewer re-ran Black `--check`, Ruff, Pyright, and Pytest; all clean. | `evidence/qa-gates/final-*.2026-10-11T10-38.md`; reviewer commands in policy-audit Appendix B | The Python LCOV was written to a non-canonical name (`artifacts/python/lcov-902.info`); numeric evidence is preserved in qa-gates (policy-audit N-1, non-blocking). Markdown has no coverage tool. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 6 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm the PR CI run, including `_poshqc.yml` with `codex-epic-runtime-contracts.Tests.ps1` and `checkpoint-hygiene-skill-contract.Tests.ps1`, is green at the head SHA (orchestrator S9 gate).
2. Optional follow-up: move the Codex main-sync paragraph ahead of the child-worktree sentence and add a Codex ordering node (code-review Minor finding).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902/issue.md`
- Total AC items: 6
- Checked off (delivered): 6
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902/issue.md` | 6 | 6 | 0 | Checkbox-backed |

No source-file checkbox change was made: all six items were already checked by the executor (commit `15e8c2a46`), and the reviewer evaluated each as PASS. AC-3 carries a CI-pending note for the Pester parity suites; it is not a gap note, because the properties those suites assert were verified locally.
