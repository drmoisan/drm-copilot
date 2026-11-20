# Code Review: Stage I, Early Dependent Starts, with the Remediation Cycle 1 Re-audit (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `8ed1c611d1f54e65a4fe0c6f4e06938f2cebc9fb`
- **Base:** `main`, merge base `72e8b299c8ce99adce7db335e936974e8119493b` (equal to `origin/main`)
- **Scope:** full branch diff, 93 files, 41 commits including merge commit `76eee9f10`
- **Reviewer:** feature-review agent, 2026-11-08

## Executive Summary

- **Both layers implement the D7 design in three runtimes and both gate families.** Layer 1 skips only the edge a valid `early_start` record names, and only while the upstream is at `worktree_created`, `pr_open`, `ci_green`, or `merge_conflict`; every deny string is unchanged. Layer 2 judges that edge by its own table (nothing before `pr_open`; otherwise upstream merged, then a non-empty string `synced_at`), and every other edge keeps the status and timing checks. Without a valid record, no runtime computes an exempt edge.
- **Revertibility holds and is independent of history.** Reversing the `0010` patch into a scratch index of HEAD yields the `origin/main` blob on all 38 patch paths, so a revert removes only this reduction and keeps main's #1129, #1130, and #1136 text. The chain and every `-StopBefore` sub-chain are valid over 10 entries.
- **The chain fix is correct and does not move older entries.** A created file is absent before its reduction whatever its source, so ending a created derived copy absent is right; modify and delete hunks on derived paths are still skipped. No created path in `0001` to `0009` is a derived path.
- **Merge controls are untouched.** No merge-gate, review-gate, or child-CI file is in the diff; steps 5 to 8 of the procedure finish before S7 and S8, so the #1130 child-CI gate reads post-sync heads.
- **Two contained gaps block.** F1: the Claude procedure names no fallback when the validator CLI is absent (destination repositories). F2: one fail-closed Layer 1 branch has no test.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/skills/epic-orchestrate/SKILL.md` and its bundle copy | `## Early Dependent Starts (early_start)`, procedure step 2 | F1. Step 2 validates only through `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts`. Its fallback fires only on an `EPIC_WAVE_BARRIER_VIOLATION` that names the feature, the absent sibling, or a Layer 1 deny. In a destination repository the CLI does not exist (`quality-tiers.yml`: `scripts/dev_tools` "not published by push-down"; no pack manifest lists the file), so the command fails with a module error and the text gives no instruction. The #1129 allowlist reason for that path ("the citing step keeps the wave barrier when its route lacks the rule") relies on a fallback the step does not state for this case. | Add the absent-CLI case to step 2: when the repository CLI is absent or does not run, remove the three values and keep the barrier. Align the allowlist reason in `test_epic_skill_script_citations_shipped.py`, extend an `ESS-*` Claude row to pin the clause, re-pin the skill digest, and regenerate the 0010 patch in the same `reduction: 0010` commit. | A pushed-down epic orchestrator reads this skill. Without the clause, it may proceed unvalidated and later fail completion under an installed MCP that lacks the rule, or halt. Owner guidance places related findings inside the item. | `git show 5988fc822`; pack-manifest grep (no match); `quality-tiers.yml` row `scripts/dev_tools` |
| Major | `tests/scripts/claude-hooks/EpicWaveEarlyStart.Cases.Helpers.ps1` | `$script:EarlyStartRow` | F2. No row sets `interface_settled_at` to an empty string or a non-string. Lines 77 to 79 of `epic-wave-barrier-early-start.ps1`, which reject such a record, are the only uncovered lines of the sibling in `powershell-coverage.xml`. Deleting them makes Layer 1 allow an early start with an empty settled time, and no Claude or Codex row fails. | Add a deny row such as `empty-interface-settled-at` (and optionally a numeric value), consumed by both EarlyStart suites; regenerate the 0010 patch, because the helper is a created file of 0010. | The predicate is a gate relaxation guard; untested fail-closed branches in a gate are not acceptable under the scenario-completeness rule even when line thresholds pass. The reviewer's real-process probe confirms the current behavior is correct (empty and numeric values return null). | Coverage XML line 78 `ci="0"`; helper rows 103 to 125 |
| Minor | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; merge commit | `e40cbfda4`, `76eee9f10` | CR3. The merge commit and the re-pin commit edited regions recorded by 0010 (skill hunk context and the two digest lines) without `reduction: 0010`; `80b87df59` reconciled the record two commits later. README `## Revert Order` requires the same-commit update and names no merge-reconciliation case. | Optionally add a sentence to README `## Revert Order` stating how a `main` merge that touches recorded regions is reconciled (the regenerated record lands in the next commit carrying the token). | History only; the head is consistent and a revert does not use history. Precedent `d48ea60ce` put the tokens in the merge subject instead. | `git show --stat e40cbfda4 80b87df59` |
| Nit | `docs/engineering/process-reductions/0010-early-dependent-starts.md` | `## Summary` | CR4. `Merge commit: pending (PR #1097)` uses the issue number as a stand-in; the entry states the orchestrator replaces it after PR creation. | Replace with the PR number after PR creation and back-fill the merge commit later, as for 0008 and 0009. | Structure checker accepts the form. | Entry text |
| Nit | `.claude/agents/epic-orchestrator.md` | Wave scheduling exception paragraph | CR5. The agent paragraph names only the CLI route; if F1 adds the absent-CLI fallback to the skill, the agent paragraph still reads as the CLI being always available. | Optional: append "or keeps the barrier when that CLI is absent" in the same commit as F1; this also re-pins the agent digest. | Consistency; the skill governs. | Diff of the agent file |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest changed covered file is `scripts/dev-tools/ProcessReductionChain.psm1` at 596 logical lines. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Layer 1 (both gates and the sibling)

- The sibling is byte-identical in `.claude/hooks/` and `.codex/hooks/` and in both bundles, defines functions only, and is dot-sourced under the existing hook-dependency guard, so a missing sibling denies.
- `Get-EpicWaveEarlyStartReference` checks names case-sensitively (`-cnotcontains`) because `PSObject.Properties` ignores case; booleans are rejected; `interface_settled_at` accepts a `[datetime]` because `ConvertFrom-Json` converts ISO strings. Probed in a real process.
- `Test-EpicWaveEarlyStartEdge` compares records by `feature_folder` ordinally and accepts only the four usable upstream statuses; a merged upstream returns false so the existing merged check passes the edge.
- The Codex gate resolves the exempt record with `Find-CodexWaveFeature` keyed as each edge, so issue-number and folder references behave like other edges; the Codex skill notes that a lifecycle-prefixed reference fails closed.

### Layer 2 (Python, TypeScript, PowerShell)

- The three ports share the validity rules, the decision table, and two message strings; the shared corpus (28 cases) runs in all three. The TypeScript check moved out of `epic-orchestrator-state-core.ts` unchanged, with `MERGED_STATUSES` exported for the completion gate.
- The exempt edge skips the timing check by design (an early dependent always starts before the upstream merge); step 9's ancestry check proves the sync.

### Ledger

- Entry `0010` lists 41 paths; the stored patch covers the 38 non-ledger paths, equal to the branch code paths apart from the chain fix. Revert steps cover mirrors, the generator check, digests, contract-test literals, and the tests from `main` that read 0010 paths.
- Regeneration instead of a later landing is correct: a later landing would make a revert delete main's text, which the scratch-index reversal shows does not happen with the regenerated patch.
- The chain fix commit is not a reduction and carries no token, which is correct.

### Merge and CI controls

No merge-gate, review-gate, or child-CI file changed. The early-start procedure permits no merge; it gates only the parent's `pr_open` write. The #1130 child-CI gate requires a successful run on the live PR head, which is post-sync.

### Security and correctness

No secret, network call, or new subprocess in hook or validator code. All new rules fail closed on malformed records.

## Verification Performed

- Scratch-index reversal of the 0010 patch and blob comparison with `origin/main` on 38 paths.
- `git apply -R --check` of the 0010 patch on the live tree (exit 0).
- In-memory `Test-ProcessReductionLedger` (valid, 10 rows) and `Invoke-ProcessReductionChain` (full and 10 sub-chains valid).
- Created-path scan of stored patches 0001 to 0009 (no derived path).
- SHA-256 of both pinned surfaces; `cmp` of 11 source and bundle pairs and the sibling twins.
- Parsing of the three coverage artifacts; uncovered-line listing for the wave-barrier hooks.
- Real-process probe of `Get-EpicWaveEarlyStartReference`.
- Logical line counts of 25 changed covered files.

## PR Readiness

Not ready. Fix F1 and F2 in one commit whose subject carries `reduction: 0010`, with the 0010 patch regenerated and the skill digest re-pinned in that commit, then re-review. CR3 to CR5 are optional.
