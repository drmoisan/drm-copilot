# parallel-only-test-gates-and-leak-scan - Remediation Plan Addendum (Process-Reduction Ledger)

- **Issue:** #1094
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T06-50
- **Status:** Draft
- **Version:** 0.1
- **Work Mode:** full-feature
- **Remediation-Mode:** design
- **Branch:** feature/parallel-only-test-gates-and-leak-scan-1094
- **Addendum to:** `remediation-plan.2026-11-07T05-01.md` in this folder

## Required References

- Policy order: `policy-compliance-order`. This addendum adds documentation only, so no language toolchain applies.
- Requirements: `docs/engineering/process-reductions/README.md`, `.claude/skills/feature-review-workflow/SKILL.md` `### Process-reduction ledger`, and `spec.md` `## Overview`.
- Tool routes, launchers, command-text restrictions, and CI shape are owned by the `execution-environment` skill and are not restated.

## Execution Rules

Terms: `<FEATURE>` is `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094`. `SCRATCH` resolves to `<session scratchpad>/issue-1094/`, and every step script and extracted file lives under it. Evidence records the token, never a host path. The merge base is the merge base of `origin/main` and `HEAD`. The ledger is `docs/engineering/process-reductions/`. The entry is `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`. The patch is `docs/engineering/process-reductions/patches/0001-parallel-only-test-gates.patch`. The reduction path set is every path changed from the merge base to `HEAD`, excluding `<FEATURE>/`, `docs/features/potential/`, and the ledger, with rename detection off, so both sides of a rename are listed.

- **Working directory.** Every `git` command and every step script starts from the item worktree root.
- **No test runs (owner directive).** No task runs a test suite or a test run of any form. The checks here are `Test-ProcessReductionLedger`, `Invoke-ProcessReductionRevert`, and `git apply -R --check`. CI on the PR head runs the suites.
- **Commit and push.** Each task ends with one commit and one push to `feature/parallel-only-test-gates-and-leak-scan-1094`, with one exception to the usual staging: the P1-T1 commit holds only the entry, the patch, and the ledger `README.md`, so this plan's P1-T1 checkbox is committed by P2-T1. `.claude/agent-memory` is never staged.
- **New code.** Step scripts are PowerShell under `SCRATCH`. No Python file is written, and nothing is added to the repository except the entry, the patch, the README row, evidence, and this plan.
- **Evidence.** Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and `EXIT_CODE:` goes non-zero when an asserted value fails. Evidence prose uses none of the tokens that `remediation-plan.2026-11-07T05-01.md` P2-T6 scans for.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reading

No test suite and no language baseline runs in this phase, because no code changes.

- [ ] [P0-T1] Read the policy files in the `policy-compliance-order` order, then the ledger `README.md`, `scripts/dev-tools/ProcessReductionLedger.psm1`, and `.claude/skills/feature-review-workflow/SKILL.md` `### Process-reduction ledger`, and write `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and the list of files read, and the ledger holds no entry file, so `0001` is the next free number.

### Phase 1 — Ledger Entry

- [ ] [P1-T1] Create the entry and the patch, add one data row to `## Index` in `docs/engineering/process-reductions/README.md`, and commit those three files alone with the subject `docs(process-reductions): record parallel-only test gates (#1094), reduction: 0001`.
  - The row sits directly under the table's separator row: `| [0001](0001-parallel-only-test-gates.md) | Parallel-only test gates | 2026-11-07 | #1094 | Active |`.
  - `# 0001: Parallel-only test gates` is the entry's title. `## Summary` carries four lines of their own, with no list marker: `reduction: 0001`, `Date: 2026-11-07`, `Issue: #1094`, and `Merge commit: pending (PR #1101)`. Its prose states what was reduced, that the reduction landed across this branch's commits before the ledger rule reached the branch, and that the entry's own commit carries the token.
  - `## Reason and Evidence`: the owner decision of 2026-11-06 and the three measured figures in spec `## Overview`: the 8-shard run time, the single-process run time range, and the 3-shard CI repeat.
  - `## Files Changed`: every path of the reduction path set, each written in full on its own list line, marked as canonical, mirror, bundle copy, generated variant, or contract test. `.claude/hooks/validate-feature-review-coverage-rules.ps1` and `.codex/hooks/validate-feature-review-coverage.ps1` stay in the list, with a note that they support the new template record `N/A - no pre-change run`.
  - `## Stored Patch` names `patches/0001-parallel-only-test-gates.patch` in backticks, states its derivation from the merge base, and states the check: `git apply -R --check` of the patch succeeds on the working tree.
    - The patch is `git diff --binary --no-renames` from the merge base to `HEAD`, limited to the reduction path set. `--binary` keeps a binary path from failing the check. Git writes the file directly through `--output`, so no shell re-encodes it.
  - `## Prior Text` holds one `### Revert Block:` per canonical file and per non-identical copy, four in all, each with `Current` and `Prior` fences of four backticks. `Prior` is read from that file at the merge base.
    - `.claude/skills/execution-environment/SKILL.md`: the body of `## Test Isolation Checks`. Its five mirrors are byte-identical and take no block.
    - `.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, and `.github/skills/atomic-plan-contract/SKILL.md`: the sentence of the Pre-Mortem rule beginning with the `Test isolation` bullet text `names the parallel gates`. These three copies differ from one another, and each has a byte-identical bundle copy, so the README requires a block for each.
  - `## Revert Steps` names the six README labels in order:
    - `Apply the blocks`: run `git apply -R` of the patch when its check passes. Otherwise replace each `Current` with its `Prior`, which restores the core rule, and restore the other paths from the patch text.
    - `Re-copy mirrors and bundles`: name the five brief copies and the three bundle copies of `atomic-plan-contract`.
    - `Regenerate Codex variants`: the generator, then its `--check`.
    - `Restore pinned hashes`: states "not applicable" when `parallel_orchestrator_surface_expectations.py` is outside the reduction path set; otherwise it names the hash change.
    - `Restore contract-test literals`: restore the merge-base tests `test_brief_test_isolation_requires_seeded_pester_shuffle` and `test_contract_premortem_test_isolation_requires_seeded_pester_shuffle` in place of `test_brief_test_isolation_states_parallel_gates`, `test_brief_copies_carry_no_removed_run_tokens`, and `test_contract_premortem_test_isolation_states_parallel_gates`.
    - `Run the contract tests`: name `test_execution_environment_brief_contracts.py`, `test_single_pass_preflight_contracts.py`, and the two `test_push_down_*_resource_contracts.py` modules. This is a revert instruction; this plan does not run them.
  - `## Revert Signals`: before #1096 lands, a leak surfacing as a shard-dependent failure, or remediation cycles citing order dependence.
  - Before committing, a step script runs the checks of P2-T1 items 1, 3, and 4 against the working files, so the reduction commit is not followed by a correcting commit. Nothing is written to `<FEATURE>/` by this task.
  - Existing tests, each unchanged: `PRL-REAL-LEDGER-AGREES` in `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1` reads the real folder and passes on a valid entry, because it asserts `RowCount` equals the entry count rather than a fixed number. `PRL-README-EXAMPLE-IS-VALID` reads `## Worked Example`, which this task does not edit. The other cases in that file and in `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1` use in-memory text or an absent folder.
  - Acceptance: `git show --name-only --format=%s HEAD` prints the stated subject and exactly the three paths, `git status --porcelain` lists none of the three, and the push succeeds.

### Phase 2 — Ledger Check and Self-Review

- [ ] [P2-T1] Run the ledger checks on the committed state in one step script, write `<FEATURE>/evidence/qa-gates/ledger-check.<timestamp>.md`, and commit it with this plan.
  - The step throws on any failed item, so the exit code carries acceptance. `Test-ProcessReductionLedger` returns an object and does not itself fail.
  1. Checker: import `scripts/dev-tools/ProcessReductionLedger.psm1` from the branch, pass the result of `Read-ProcessReductionLedger` over the ledger to `Test-ProcessReductionLedger`, and require `IsValid` true, zero `Errors`, and `RowCount` 1.
  2. Index agreement: the row's title, date, and issue cells equal the entry's title, `Date:` line, and `Issue:` line.
  3. Patch: extract the committed patch blob byte for byte under `SCRATCH`, because `* text=auto eol=lf` applies to it on commit, and run `git apply -R --check` on that copy with exit 0. The set of paths `git apply --numstat` reads from it equals the reduction path set, which is non-empty, and every path in that set appears in `## Files Changed` of the entry.
  4. Blocks: `Get-ProcessReductionRevertBlock` over `## Prior Text` returns the four named paths. For each, `Invoke-ProcessReductionRevert` over the live file returns without throwing, which proves `Current` occurs exactly once, and `Prior` occurs exactly once in that file at the merge base. Each brief copy equals `.claude/skills/execution-environment/SKILL.md` by hash, and each `atomic-plan-contract` source equals its bundle copy by hash.
  5. Commit: the oldest commit from the merge base to `HEAD` with `reduction: 0001` in its subject holds exactly the three paths, and any later commit with that token, which only a P2-T2 fix creates, holds no other path.
  - Acceptance: `EXIT_CODE: 0`, and `Output Summary:` states the row count, the patch path count, the block count, and the subject of the commit.
- [ ] [P2-T2] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base, write the QA self-review to `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`, and commit it with this plan.
  - The walk includes this plan's text under `.claude/rules/tonality.md` and the `### Process-reduction ledger` rule of `feature-review-workflow`, with the entry as its proof.
  - The artifact has one PASS, FAIL, or N/A row per checklist item. A FAIL row is fixed, P2-T1 re-runs, and the self-review is rewritten. A fix to the entry, the patch, or the README row lands in a commit whose subject also carries `reduction: 0001`, and that commit holds only those files.
  - Acceptance: the artifact holds no FAIL row, and `git diff --name-only` from the newest commit carrying the token to `HEAD`, with `git status --porcelain` as its companion, lists only paths under `<FEATURE>/`.

## Acceptance Criteria Traceability

| ID | Requirement | Tasks | Proof |
|---|---|---|---|
| L-1 | The entry passes the checker over the real folder | P1-T1, P2-T1 | `ledger-check` item 1 |
| L-2 | The Index row and the entry agree | P1-T1, P2-T1 | `ledger-check` items 1 and 2 |
| L-3 | The stored patch reverses on the working tree and matches the file list | P1-T1, P2-T1 | `ledger-check` item 3 |
| L-4 | Each revert block replays, and each `Current` occurs exactly once | P1-T1, P2-T1 | `ledger-check` item 4 |
| L-5 | The token is in the subject of a commit holding only the entry, patch, and README row | P1-T1, P2-T1 | `ledger-check` item 5 |
| L-6 | The self-review holds no FAIL row | P2-T2 | `self-review` |

## Pre-Mortem

- Review checklists: P2-T2 walks all three templates against the diff from the merge base and adds the ledger rule, the Blocking finding this addendum closes.
- Coverage: not applicable. No production or test file changes, so the coverage figures of the cycle 3 gates stand.
- Mirror parity: The ledger has no mirror or bundle copy. The brief states no fact this addendum changes, so no brief-update task applies. The non-identical `atomic-plan-contract` copies each take a block, and P2-T1 item 4 compares the byte-identical copies by hash.
- File size: not applicable. `Test-FileSizeCoveredPath` covers neither `.md` nor `.patch`, so a large patch trips no size gate.
- Test isolation: not applicable. This addendum runs no suite. The gates remain one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers, and CI on the PR head covers the change.
- CI-only behavior: `docs/engineering/` is not on the docs-only allowlist, so the PR head gets a full run, and `PRL-REAL-LEDGER-AGREES` reads the entry there. Line-ending normalization could alter the patch on commit, so P2-T1 checks the committed blob, not the working file.
- Evidence: Values come from the step script's results, never from MCP summaries. The P1-T1 commit carries no evidence, so that task's proof is its acceptance output and `ledger-check`, which P2-T1 commits.

## Open Questions / Notes

- Prior Text scope: the delegation named two revert blocks. The README requires a block per non-identical copy, and the `.agents` and `.github` copies of `atomic-plan-contract` differ from `.claude`, so this plan uses four. The brief needs one, because its six copies are byte-identical.
- Status cell: the README defines no Status vocabulary; `Active` is this plan's choice, and the checker requires only a non-blank cell.
- PR number: `PR #1101` is provisional. The orchestrator corrects it after the PR opens, and this plan does not handle it.
- A later change to the reduction path set: under the README, a commit that changes a listed reduction also updates the entry, so a further remediation cycle regenerates the patch and `## Files Changed`.
