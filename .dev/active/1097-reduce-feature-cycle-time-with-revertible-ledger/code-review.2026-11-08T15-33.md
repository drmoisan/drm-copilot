# Code Review: Stage H, the Design Check in Single-Pass Preflight (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `7b0c79346f6848380facf8ef5555a770241882d0`
- **Base:** `main`, merge base `cdcff3871765396183590128e142a929cf78327b` (equal to `origin/main`); trial merge clean
- **Scope:** full branch diff, 44 files, 12 commits
- **Reviewer:** feature-review agent, 2026-11-08

## Executive Summary

- **The pass matches spec D6 and the `Design check.` paragraph.**
  - Each contract copy states it as a bullet of `### Single-Pass Preflight`, after `Return substantive defects only` and before `Check the fix against its own rule` (Claude copies) or `Output format.` (Agents and GitHub copies).
  - It runs "within the same single pass, with no new delegation and no new artifact", returns gaps as `PREFLIGHT-DEFECT:` lines, and places them in the substantive class that already holds "an acceptance criterion with no implementing task".
  - It adds no signal, no output line format, no preflight round, and no tool. The at-most-once return to the planner and the single confirming preflight are unchanged, so design-check defects travel in the same one return.
  - It is consistent with the trivial class: a design-check gap is never fixed in place, because fixing it would add a task or change a test, which the trivial rule forbids.
- **Mirror parity holds.** All 14 root and bundle pairs have equal blob ids. Each of the 28 surfaces carries the pass exactly once. The Codex generator `--check` exits 0 on a re-run by the reviewer.
- **The ledger is untouched where it matters.** Stage H adds no entry and reduces nothing. The reviewer's in-memory chain probes show the bullet lies outside every recorded region, and an edit to `0008` G13 text inside the same files fails the chain. The back-fill commit `ca85a8d1d` records the correct merge commits for `0008` and `0009`.
- **No production code, hook, or validator changed.** Gates: Pester 19682 testcases, 0 failed, 95.56% lines equal to baseline; pytest 16537 passed, 0 failed.

No blocking finding.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/skills/atomic-plan-contract/SKILL.md` and the five other contract copies | `### Single-Pass Preflight`, `Run the design check.` bullet | CR1. The bullet makes any spec rule "with no test that would fail if it were broken" a substantive defect. Some spec rules are verified by a reviewer or by recorded evidence rather than by a test, for example the `[I]` criterion "the reviewer confirms from the branch log that each reduction is a separate commit". Read literally, each such rule is a substantive defect. Because a plan returns to the planner at most once and a remaining substantive defect after the confirming preflight halts with `validator_failed`, such a rule can halt a correct plan. | In a later wording pass, state what satisfies the pass for a rule that no automated test can falsify, for example a named verification task with an observable acceptance condition. | The text matches the spec as written (`spec.md` `Design check.` paragraph and D6), so this is not a defect in the delivery. The risk is a false substantive defect at preflight time. | `spec.md` `Design check.` paragraph; `[I]` criteria in `spec.md`; the bullet text in the diff |
| Nit | `.claude/agents/atomic-executor.md` and bundle | `## Preflight Validation`, third bullet | CR2. The new bullet opens with plain `Run the design check:`, while its sibling bullets open with a bold lead-in (`**Review the entire plan in one pass.**`, `**Classify every defect.**`). | Bold the lead-in in a later edit to the file, keeping the pinned tokens. | Formatting consistency only; the pinned tokens do not depend on it. | Diff of the file |
| Nit | `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1` | `PCW-DESIGN-CHECK-NO-DELEGATION-<Id>` | CR3. The row flags a tool entry that begins with `Agent`. It would not flag the legacy delegation tool name `Task`, and no row covers the Codex or Copilot executors, whose definitions carry no comparable tool list. | Optionally extend the pattern to `^(Agent\|Task)\b`. | The Claude executor is the surface where a delegation tool could be granted by frontmatter; the current tool list holds neither name. | Frontmatter of `.claude/agents/atomic-executor.md` at head |
| Nit | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/qa-gates/self-review.2026-11-08T15-23.md` | Row 2 | CR4. The P1-T3 acceptance condition "the `--check` run exits 0" is recorded only as a phrase in the self-review row; no evidence file carries the command and exit code. | None required for this PR. The reviewer re-ran `generate_codex_agent_variants --check` (exit 0), and the Codex wrapper contract tests pass in the pytest gate. | Record only. | Reviewer run |
| Nit | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/research/research.2026-11-06.md` | Section 7 | CR5. Research named `test_single_pass_preflight_contracts.py` for the new pin; the plan put the pin in the Pester wording suite instead. | None required. | The criterion asks for a contract test, which the Pester rows are; the plan's `## Existing Tests That Pin Changed Text` states the choice. | Plan Design Summary |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The only changed covered file is `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1` at 329 logical lines. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Consistency with the Single-Pass Preflight rules

- The pass reads `spec.md`, or the `## Acceptance Criteria` of `issue.md` when a folder has no `spec.md`, which covers minor-audit folders and matches the plan's Design Summary.
- The output is the existing `PREFLIGHT-DEFECT: <task id or heading> | <defect class> | <required change>` line, so no hook or orchestrator parser changes. "The pass records nothing beyond those lines" matches "no new artifact".
- The executor-surface sentence on the Claude, Codex, and Copilot executors states the same rule in short form and points at the contract section, which matches the existing pattern of those surfaces.

### Mirror parity and generation

The three distinct contract texts (Claude full section, Agents, GitHub) each received the same bullet wording and each equals its bundle. The Codex base executor was edited by hand and the five variants and six bundle files were regenerated; the generator check is clean. The four Copilot executors wrap the sentence at the same column as their neighbours, and each equals its bundle.

### Ledger and baselines

- No `Revert Block` `Current` image and no stored-patch hunk covers the inserted text. The reviewer's chain probes confirm this independently of the executor's run.
- Commit `ca85a8d1d` edits `## Summary` lines of `0008` and `0009`. No stored patch covers ledger entry files, and the chain stays valid. The added sentence naming `fe81a1118` and `3681735fc` addresses stage G item CR1; the `0008` back-fill closes stage G item CR3.
- Stage H captured its own Phase 0 baseline and compared both final gates with it. No baseline task, evidence, or comparison is reduced.

### Plans outside stage H delivery

`7b0c79346` adds `plan.2026-11-07T00-56.md` (refreshed stage I) and `plan.2026-11-08T09-47.md` (stage J). They change no production or test file and pass the Python CLI plan validator. They are not reviewed as delivered work.

### Security and correctness

No hook, validator, script, or production code changed. The new test reads tracked files only, normalizes CRLF before the frontmatter match, and fails when the tool list is absent rather than passing vacuously.

## Verification Performed

- `git fetch`, merge base, `merge-tree` (exit 0); `log`, `diff`, and `diff --stat` over `cdcff3871765..HEAD`.
- Blob-id comparison of 14 root and bundle pairs; `git grep -c` of the pass on 28 surfaces at head and of the five pinned tokens on 9 root surfaces at the merge base.
- `generate_codex_agent_variants --check` (exit 0).
- In-memory chain at head, full and with `-StopBefore` for all 9 entries; mutant probes on the bullet (chain stays valid) and on G13 text (chain fails); temporary-index replay of the stored patches at base and head (same outcome).
- `git log -1` of `e33635c14` and `cdcff3871` (merge commits of PRs #1123 and #1131).
- Python CLI plan validation of three plan files (pass); `validate_evidence_locations` (exit 0); JUnit and coverage artifact parsing; logical line count.

## PR Readiness

**Ready for PR creation; merge once CI is green.** No blocking finding. CR1 is a wording candidate for a later contract pass; CR2 to CR5 need no action in this PR.
