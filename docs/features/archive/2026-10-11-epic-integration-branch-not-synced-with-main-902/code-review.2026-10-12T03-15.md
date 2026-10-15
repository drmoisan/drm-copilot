# Code Review: Epic Integration Branch Pre-Wave Main-Sync Step (#902)

---

**Review Date:** 2026-10-12
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902`
**Feature Folder Selection Rule:** Supplied by the caller; it is the only active folder whose suffix matches issue #902 in the branch name.
**Base Branch:** `origin/main` @ `12b2454256cfa11ff809d5d2333ddaf988574e21` (merge base; local `main` ref is stale at `2ef8d361e` and was not used)
**Head Branch:** `bug/epic-integration-branch-not-synced-with-main-902` @ `15e8c2a46`
**Review Type:** Initial review (reduced, minor-audit)

---

## Executive Summary

The branch closes the gap reported in issue #902: the epic integration branch was created from `origin/main` once and never re-synced, so it drifted 278 commits during epic #852. The change inserts a pre-wave main-sync step into the canonical Claude skill, mirrors it byte-for-byte into the Claude bundle, adds a condensed equivalent paragraph to the Codex skill and its bundle mirror, re-pins the frozen skill digest, and adds a 13-node pytest contract module. The scope is six files outside the feature folder (four Markdown surfaces, two Python test files). The review inspected the full diff against `origin/main`, the feature evidence tree, the `enforce-epic-wave-barrier.ps1` hook the new text cites, and the two CI-only Pester suites. It also re-ran Black, Ruff, Pyright, and the 111-node pytest set. Implementation quality is good: the text is precise, the factual claim about the barrier hook is accurate, and the tests are sensitive to the removal of the step, as the fail-before evidence shows.

**What changed:**
- `.claude/skills/epic-orchestrate/SKILL.md` and its bundle mirror: new step 3 in `## Epic Integration Branch Lifecycle`. The step runs `git fetch origin main` and then `git rev-list --count origin/epic/<epic-slug>-integration..origin/main`. A zero count proceeds to the wave. A non-zero count runs a chore child main-sync (PR #882 pattern) before the wave: the sync child is pre-registered in `features[]`/`waves[]`, does not reuse a manifest issue number, uses `git merge --no-ff origin/main`, opens a PR into the integration branch, and must reach `merge_status: merged`. At most one sync runs per wave. Former steps 3-5 become 4-6.
- `.agents/skills/epic-orchestrate/SKILL.md` and its bundle mirror: one paragraph carrying the same rule in condensed form.
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: skill digest re-pinned to `0b1a629a...`, with a rationale comment.
- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py`: presence (4 surfaces), ordering (Claude x2), numbering (Claude x2), removal-sensitivity (Claude, Codex), pre-change rejection, and two helper negative tests.

**Top 3 risks:**
1. The sync-before-wave rule is procedural only. `enforce-epic-wave-barrier.ps1` gates a child on its own `depends_on` list, and wave children do not list the sync child, so no hook blocks a wave that launches before the sync PR merges. The issue explicitly excluded a hook change, so this is a known limit, not a defect.
2. The Codex paragraph is a condensed restatement, not a textual copy. It omits "wave 0 included", the `--no-ff`/no-rebase/no-force-push constraint, the `waves[]` entry, and the epic-issue-or-chore-issue choice. It is also placed after the sentence that creates child worktrees, and no ordering test covers the Codex surfaces.
3. The CI-only Pester parity suites have not run yet; no PR exists for the branch.

**PR readiness recommendation:** **Go** - no Blocker or Major findings; the remaining items are Minor, Nit, or Info, and the CI Pester run is covered by the S9 gate.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.agents/skills/epic-orchestrate/SKILL.md` (and bundle mirror) | `## Integration Branch and Child Worktrees`, inserted paragraph after line 69 | The main-sync paragraph follows the sentence "Create every child worktree from that tip, never from `main`...". The text says "Before each wave launches", but its position puts the check after child-worktree creation, and no ordering test covers the Codex surfaces. | In a follow-up, consider moving the paragraph ahead of the child-worktree sentence and adding a Codex ordering node. No change is required for this PR. | A reader following the Codex text top to bottom may perform the check after creating worktrees, which would base those worktrees on the pre-sync tip. | `git diff 12b2454 HEAD -- .agents/skills/epic-orchestrate/SKILL.md`; test module lines 238-255 parametrize Claude surfaces only |
| Minor | `artifacts/python/lcov-902.info` (untracked) | n/a | The Python LCOV output was written to a non-canonical file name, and the second coverage run overwrote the first, so the file holds only the support-module record (LF 34, LH 34). The canonical `artifacts/python/lcov.info` is not present. | Write Python LCOV to `artifacts/python/lcov.info`, or one file per run, in future executions. | The feature-review coverage hook reads the canonical path only. Numeric figures for both runs are preserved verbatim in `evidence/qa-gates/`. | `ls artifacts/python/`; `evidence/qa-gates/final-pytest-coverage.2026-10-11T10-38.md`; `evidence/qa-gates/final-support-coverage.2026-10-11T10-38.md` |
| Info | `.claude/skills/epic-orchestrate/SKILL.md` | Lifecycle step 3 | The sync-before-wave rule has no hook enforcement. Wave children's `depends_on` lists do not include the sync child, so `enforce-epic-wave-barrier.ps1` would not deny an early launch. | No action for this PR (the issue states "No hook change"). Track as a possible follow-up if early launches are observed. | Procedural-only rules depend on coordinator compliance. | `.claude/hooks/enforce-epic-wave-barrier.ps1` lines 194-213 and 319-331 |
| Info | `.agents/skills/epic-orchestrate/SKILL.md` (and bundle mirror) | Inserted paragraph | The Codex paragraph is a semantic subset of the Claude step. It omits wave 0, `--no-ff`/no-rebase/no-force-push, the `waves[]` entry, and the issue-number choice. | Acceptable as written; the Codex skill is condensed throughout. Consider adding `--no-ff` in a later pass. | AC-3 requires "the same step"; the twelve pinned fragments, which carry the decision rule and route, are present on all four surfaces. | Reviewer comparison of both diffs; presence nodes pass for `codex-skill` and `codex-bundle` |
| Nit | `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py` | Lines 70-91, 291-295 | `PRE_CHANGE_LIFECYCLE_TEXT` is an inline copy of the baseline text, so the test proves only that the fragment set rejects that frozen string. | None required. The reviewer verified that the constant is a byte-exact substring of `.claude/skills/epic-orchestrate/SKILL.md` at `12b2454`. | The removal tests already exercise the live files; this test adds a historical anchor. | Reviewer check: `PRE_CHANGE_LIFECYCLE_TEXT in <baseline skill>` returned `True` |
| Info | `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py` | Lines 207-224 | Executor deviation 1: added `read_section` helper not listed in the plan's Test Inventory. | Accept. It removes a duplicated read-then-assert sequence from five tests and is exercised by every live-file test. | Consistent with the reusability principle in `general-code-change.md`. | `evidence/other/small-audit-handoff.2026-10-11T10-38.md` Deviations 1 |
| Info | `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py` | Commit `e9e35d70a` | Executor deviations 2 and 3: pass-1 Ruff found five E501 errors in the pre-change literal. They were fixed by implicit string concatenation, without `noqa`; the loop was restarted from formatting and the fix committed separately. | Accept. The restart follows the mandatory toolchain loop, and the separate commit is traceable. | Fixing without suppression complies with `.claude/rules/python-suppressions.md`. | `evidence/qa-gates/final-ruff.2026-10-11T10-38.md`; `git show --stat e9e35d70a` (1 file, +20/-12) |
| Info | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | Lines 160-173 | Digest re-pin with a dated rationale comment; persona digest unchanged. | None. | The frozen-surface guard stays live for both entries. | `evidence/regression-testing/digest-rebaseline.2026-10-11T10-38.md`; `evidence/qa-gates/final-parity-nodes.2026-10-11T10-38.md` |

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Fragment matching runs after whitespace normalization, so reflowing the Markdown cannot turn an assertion into a no-op (a known failure class for line-wrapped greps).
- The removal tests strip the step from the live file text in memory and assert that the contract then fails, which ties AC-4's "fail when the step is removed" to the current file rather than to a fixture.
- The numbering test pins exactly six steps, which catches both a dropped step and a duplicated number after future edits.
- The fail-before run (10 failed, 3 passed) shows the expected sensitivity before the skill edits.

#### Typing and API notes

- All functions are annotated, and `section_body` returns `str | None` with an explicit `None` test. Pyright reports 0 errors.
- No new public Python API surface was added; the module is test-only.

#### Error handling and logging

- `remove_block` raises `ValueError` naming the absent marker; `read_section` asserts with the path and heading in the message. No broad exception handling. No logging is needed in test code.

---

## Test Quality Audit

The reviewer inspected the new module line by line and re-ran it, together with the 98-node regression set (111 passed, 1.37s). Fail-before and pass-after evidence is present. Coverage evidence shows no regression and 100% line coverage of the modified test-support module; no production Python changed.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py` - pins twelve fragments on four surfaces, ordering and numbering on the Claude surfaces, and removal-sensitivity on Claude and Codex. Gap: no Codex ordering node (Minor finding above).
- `evidence/regression-testing/fail-before.2026-10-11T10-38.md` - 10 failed / 3 passed before the skill edits; failure messages name the first absent fragment.
- `evidence/regression-testing/contract-tests-pass.2026-10-11T10-38.md` - 13 passed after the edits.
- `evidence/qa-gates/final-parity-nodes.2026-10-11T10-38.md` - bundle-parity and frozen-digest nodes, 6 passed.
- `evidence/qa-gates/final-parity-eol.2026-10-11T10-38.md` - pair-hash equality and LF endings; the reviewer reproduced the hashes (`7a214403...`, `c708d88d...`).
- `evidence/other/pester-ci-handoff.2026-10-11T10-38.md` - CI-only Pester suites. The reviewer confirmed that their epic-skill assertions target `## Epic-Level Checkpoint`, which is unchanged.

### Quality assessment prompts

- **Determinism:** Pure string operations on committed files; no clock, RNG, network, or subprocess.
- **Isolation:** One contract property per test; parametrized ids name the surface.
- **Speed:** 0.07s for the 13 new nodes.
- **Diagnostics:** Failure messages name the surface and the specific absent fragment or the observed step list.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection: Markdown prose, a SHA-256 digest, and test literals only. |
| No unsafe subprocess or command construction | PASS | Tests run no commands. The skill's git commands are fixed forms with placeholder slugs; no force-push or rebase is introduced, and the text explicitly forbids both. |
| Input validation at boundaries | N/A | No runtime boundary code changed. |
| Error handling remains explicit | PASS | `ValueError` on an absent marker; explicit assertion messages. |
| Configuration / path handling is safe | PASS | Paths are repository-relative constants resolved from `__file__`; no absolute host paths are encoded. |
| Factual accuracy of cited enforcement | PASS | The skill states that `enforce-epic-wave-barrier.ps1` denies a delegation whose feature record is absent; hook lines 319-331 deny when "the feature record was not found". |
| Renumbering side effects | PASS | No reference to lifecycle steps 3-5 exists outside `docs/features/`; the remaining "step 6" references in the skill target S9. |
| Hook/rule/instruction boundary (AC-5) | PASS | `git diff --name-only 12b2454 HEAD -- .claude/hooks .codex/hooks .claude/rules .github/instructions .claude/agents .codex/agents` is empty. |

---

## Research Log

No external research was required. Internal references consulted: `.claude/hooks/enforce-epic-wave-barrier.ps1`, `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, `docs/features/active/epic-852-main-sync/` (the PR #882 precedent), and `research/research.2026-10-11T10-45.md`.

---

## Verdict

The change is ready for normal PR flow. It adds the requested pre-wave main-sync step to every surface the research identified, keeps the edit inside the integration-branch lifecycle section as #900 coordination requires, leaves hooks and policy files untouched, and pins the behavior with tests whose sensitivity was demonstrated by the fail-before evidence. The two Minor findings concern Codex paragraph placement and the non-canonical LCOV path. Neither affects correctness of the delivered criteria, and both can be handled in a follow-up. The only open dependency is the PR CI run of the two Pester parity suites, which the orchestrator's S9 gate covers.
