# Code Review: Stage I, Early Dependent Starts, Re-audit after Remediation Cycles 2 and 3 (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `ecdbcab193c02a2682f6c20eee2a9abc0a9de6af`
- **Base:** `main`, merge base `5c81af727d0c4c85b893d6542356c47123454117` (equal to `origin/main`)
- **Scope:** full branch diff, 120 files, 59 commits including merge commits `76eee9f10` and `4dae0e385`
- **Reviewer:** feature-review agent, 2026-11-08

## Executive Summary

- **F1 of the prior review is resolved.** Step 2 of `## Early Dependent Starts (early_start)` in `.claude/skills/epic-orchestrate/SKILL.md` and its byte-identical bundle copy ends with "When the repository CLI is absent or does not run (a destination repository without `scripts/dev_tools/`), the parent likewise removes the three values and keeps the barrier." `ESS-CLAUDE-NAMES-PYTHON-CLI-ROUTE` pins the clause after the CLI route token, and the allowlist reason in `test_epic_skill_script_citations_shipped.py` names the absent case and still contains `validate_orchestration_artifacts`.
- **F2 of the prior review is resolved.** `EpicWaveEarlyStart.Cases.Helpers.ps1` adds `empty-interface-settled-at` and `numeric-interface-settled-at` deny rows, consumed by both EarlyStart suites; both `epic-wave-barrier-early-start.ps1` siblings are at 30 of 30 lines in `artifacts/pester/powershell-coverage.xml`. No production logic changed.
- **The cycle 3 merge kept both sides.** No line of `main` is deleted in any shared file; `.claude/skills/epic-run/SKILL.md` keeps the `early_start_on` paragraph before #1142's `## Nesting Depth`; the pin file keeps the `RE-BASELINED by issue #1138.` paragraph before the #1097 paragraph; pins equal the merged surface digests.
- **The #1142 overlap is consistent.** `Get-EpicInvocationNestingDepthDenyReason` reads only `-Target`, `-Caller`, and `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, so the early-start kickoff lines cannot change its decision. The new sentence is correct: under the main-session fallback no `epic-orchestrator` exists to run the parent steps, so keeping the barrier is the safe default, and decision D7 is unchanged.
- **Revertibility holds at head.** The 0010 patch reverses on the live tree and in a scratch index to `origin/main` on all 38 paths; the chain and all ten sub-chains are valid.
- **One new non-blocking item.** CR6 records that cycle 3 deferred the record regeneration and the re-pin to later commits, so intermediate commits were red; history only.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch`; `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | Commits `4dae0e385`, `8abf90f98`, `5c50de7d8`, `785076762` | CR6. README `## Revert Order` requires an edit inside a recorded region to update the record in the same commit, with the token. `8abf90f98` (fallback sentence, bundle copy, `ESS-` case) and `5c50de7d8` (pin digests) carry `reduction: 0010` but leave the stored patch at its cycle 2 state; `785076762` regenerates it. The merge `4dae0e385` edited recorded regions without the token. Reconstructed per commit: the commit's own 0010 patch fails `git apply -R --check` at `4dae0e385`, `8abf90f98`, `a6bf843cd`, and `5c50de7d8` (and by inheritance `6f2d6ac70`, `a6ce12460`, `132139fac`), and the pinned digests differ from the surfaces at `4dae0e385` through `a6bf843cd`. | Ratify in the PR description. For later cycles, have the planner place the re-pin and the patch regeneration in the same commit as the region edit, including inside a merge commit's resolution. | History only. The head is consistent, a revert does not use history, and no CI ran on those heads (no PR). A forward fix needs a history rewrite, which the repository forbids. Same class as CR3 in the prior review. | Reviewer scratch-index checks; per-commit `git show` digests |
| Minor | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; merge commit | `e40cbfda4`, `76eee9f10` | CR3 (carried). The cycle 1 merge and re-pin commits edited 0010 regions without the token; `80b87df59` reconciled. README names no merge-reconciliation case. | Optionally add a README sentence stating how a `main` merge that touches recorded regions is reconciled. | History only; head consistent. | `git show --stat e40cbfda4 80b87df59` |
| Nit | `docs/engineering/process-reductions/0010-early-dependent-starts.md` | `## Summary` | CR4 (carried). `Merge commit: pending (PR #1097)` uses the issue number as a stand-in. | Replace with the PR number after PR creation; the orchestrator does this. | Structure checker accepts the form. | Entry text |
| Nit | `.claude/agents/epic-orchestrator.md` | `Exception (issue #1097)` paragraph | CR5 (carried). The paragraph names only the CLI route; the skill section it points to now states the absent-CLI and nesting-fallback cases. | Optional alignment; it would move the agent digest. | Consistency; the skill governs. | Diff of the agent file |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest changed covered file is `scripts/dev-tools/ProcessReductionChain.psm1` at 596 logical lines. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Cycle 2 fixes (`448d9918c`)

- One commit with `reduction: 0010` changes the skill and bundle copy, the cases helper, the contract test, the citation test, and the pin file, and regenerates the patch and entry. The cycle 3 multiset comparison shows the cycle 2 lines carried unchanged into the head patch.
- The absent-CLI clause sits after the existing route-lacks-rule and sibling-absent fallbacks, so all three failure routes now end in the same action (remove the three values, keep the barrier).

### Cycle 3 merge and fix

- Merge `4dae0e385` has parents `8b374f939` and `5c81af727`. In the eight shared files the reviewer counted deleted lines relative to `origin/main`: 0 in each.
- Mirrors: 14 source and bundle pairs, including #1142's `epic-invocation-nesting-depth.ps1`, `enforce-epic-invocation-origin.ps1`, and `orchestrate/SKILL.md`, are byte-identical; the sibling twins are identical.
- The fallback sentence is placed in the section's opening paragraph, ahead of the procedure, so it governs every parent step. It does not restate or alter D7's merge or sync rules; it narrows where the opt-in can run, in the same way the Codex skill already states the early start is unavailable until the release.
- `ESS-CLAUDE-FALLBACK-KEEPS-BARRIER` matches the sentence on the whitespace-collapsed section text for the skill and its bundle copy.

### Ledger

- `## Files Changed` (38 non-ledger paths) equals the patch path set; the reversed tree differs from `origin/main` only in the chain-fix module and its test, which are not a reduction.
- Every `reduction: 0010` commit touches only 0010 paths and feature-folder records.
- Revert step 4 names `origin/main`'s pinned digests as the pre-0010 values; step 6 adds `NestingDepthContract.Tests.ps1`.

### Merge and CI controls

No merge-gate, review-gate, or child-CI file changed. The early-start procedure permits no merge; it gates only the parent's `pr_open` write.

### Security and correctness

No secret, network call, or new subprocess in hook or validator code. All new rules fail closed on malformed records. The nesting-depth helper does not read prompt text.

## Verification Performed

- Scratch-index reversal of the 0010 patch and `git ls-tree` comparison with `origin/main` on 38 paths; `git diff --quiet` over the same paths.
- `git apply -R --check` of the 0010 patch on the live tree (exit 0) and of each commit's own patch at four cycle 3 commits (exit 1 each).
- In-memory `Test-ProcessReductionLedger` (valid, 10 rows) and `Invoke-ProcessReductionChain` (full and 10 sub-chains valid).
- SHA-256 of both frozen surfaces against the pins, per commit from `ac9053572` to `ecdbcab19`.
- Coverage XML and lcov parsing for every changed production file.
- Logical line counts of every added or modified covered file.

## Verdict

PASS. No blocking finding. CR3 to CR6 are non-blocking.
