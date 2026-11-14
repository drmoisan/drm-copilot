# Remediation Inputs — Issue 1097

Timestamp: 2026-11-08T19-22
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: light
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-08T19-22.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-08T19-22.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-08T19-22.md`
Head reviewed: `8ed1c611d1f54e65a4fe0c6f4e06938f2cebc9fb` (merge base `72e8b299c8ce99adce7db335e936974e8119493b`)
Prior cycle: cycle 1, full path (`remediation-plan.2026-11-08T18-06.md`), merge-conflict finding F1, resolved by this review.

This file supersedes `remediation-inputs.2026-11-08T18-06.md` for the current head. It records the first review of stage I and the re-audit of cycle 1.

## Findings requiring remediation

### F1 — Claude early-start step 2 names no fallback when the validator CLI is absent

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is skill wording, a test reason string, a contract-test token, a digest re-pin, and a stored-patch regeneration, all on files already in the branch diff; it needs no external party, owner decision, or CI result.
Finding-Scope: contained

- Files: `.claude/skills/epic-orchestrate/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` (procedure step 2 of `## Early Dependent Starts (early_start)`).
- Problem: step 2 validates only through the repository CLI `scripts.dev_tools.validate_orchestration_artifacts` and keeps the barrier only on an `EPIC_WAVE_BARRIER_VIOLATION` naming the feature, an absent sibling, or a Layer 1 deny. In a destination repository the CLI does not exist (`quality-tiers.yml`: `scripts/dev_tools` is not published by push-down; no pack manifest lists it), so the step gives no instruction. The #1129 allowlist reason for `scripts/dev_tools/validate_orchestration_artifacts.py` relies on that fallback.
- Required change: in step 2 of both copies, state that when the repository CLI is absent or does not run (a destination repository without `scripts/dev_tools/`), the parent removes the three values and keeps the barrier. Update the allowlist reason in `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` to name the absent case (it must still contain `validate_orchestration_artifacts`). Pin the new clause in `ESS-CLAUDE-NAMES-PYTHON-CLI-ROUTE` (or a new Claude-only `ESS-*` row) of `tests/scripts/claude-runtime/early-start-skill-contract.Tests.ps1`. Re-pin the `.claude/skills/epic-orchestrate/SKILL.md` digest in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (and the agent digest too if the optional CR5 wording is applied to `.claude/agents/epic-orchestrator.md` and its bundle copy). Do not change the Codex skill.
- Verification required: mirrors byte-identical; SHA-256 equals the pins; `test_frozen_epic_surface_matches_pinned_baseline_digest`, `test_epic_skill_script_citations_shipped.py`, and `early-start-skill-contract.Tests.ps1` pass.

### F2 — No Layer 1 test row for an empty or non-string `interface_settled_at`

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix adds rows to a test helper already in the branch diff and regenerates the stored patch; it needs no external party, owner decision, or CI result.
Finding-Scope: contained

- Files: `tests/scripts/claude-hooks/EpicWaveEarlyStart.Cases.Helpers.ps1` (`$script:EarlyStartRow`), consumed by both `enforce-epic-wave-barrier.EarlyStart.Tests.ps1` suites.
- Problem: lines 77 to 79 of `.claude/hooks/epic-wave-barrier-early-start.ps1` (and its byte-identical twin) reject a present but empty or non-string `interface_settled_at`. They are uncovered in `artifacts/pester/powershell-coverage.xml`, and removing them makes Layer 1 allow an early start with an empty settled time without any row failing. The production code is correct and must not change.
- Required change: add a deny row `empty-interface-settled-at` (`interface_settled_at = ''`) and a deny row `numeric-interface-settled-at` (`interface_settled_at = 5`) through `Get-EpicWaveEarlyStartRecord -Override`.
- Verification required: both suites pass with the new rows; the sibling's line 78 is covered in the post-fix coverage XML (100% lines on both siblings).

## Light Fix Tasks

- [x] [P0-T1] `.claude/skills/epic-orchestrate/SKILL.md`, its Claude bundle copy, `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py`, `tests/scripts/claude-runtime/early-start-skill-contract.Tests.ps1`, and `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (F1): add the absent-CLI fallback to step 2, align the allowlist reason, pin the clause, re-copy the bundle, and re-pin the skill digest.
- [x] [P0-T2] `tests/scripts/claude-hooks/EpicWaveEarlyStart.Cases.Helpers.ps1` (F2): add the `empty-interface-settled-at` and `numeric-interface-settled-at` deny rows.
- [x] [P0-T3] `docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch` and `docs/engineering/process-reductions/0010-early-dependent-starts.md` (F1, F2): regenerate the patch as `git diff --cached --binary --full-index --no-renames 72e8b299c8ce99adce7db335e936974e8119493b -- <the 38 paths of ## Files Changed other than the ledger folder>` over the staged tree, update the `## Stored Patch` and revert step 4 text only where it names changed values, and commit P0-T1 to P0-T3 together in one commit whose subject carries `reduction: 0010`; then run the ledger checks (`Test-ProcessReductionLedger`, the chain and every `-StopBefore` sub-chain, `git apply -R --check`, scratch-index reversal equal to `origin/main` on all patch paths), the Codex generator `--check`, the PowerShell and Python static gates on the edited files, one `Invoke-PoshQCParallelTest` run, and one `pytest -n auto` run, each compared with the stage I Phase 0 baseline.

## Non-remediation items (record only)

- CR3, Minor: `76eee9f10` and `e40cbfda4` edited 0010-recorded regions without the token; `80b87df59` reconciled the record. Optional README sentence on merge reconciliation.
- CR4, Nit: `Merge commit: pending (PR #1097)` stands in for the PR number until PR creation.
- CR5, Nit: the agent's exception paragraph names only the CLI route; optional alignment with F1.
- CI on this head is pending-CI; no PR exists yet. It is not a finding.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs.
- Do not change production PowerShell, Python, or TypeScript logic, the Codex skill, or entries `0001` to `0009`.
- No baseline task, evidence, or comparison is reduced. No Epic #1019 or other item's folder is edited.
- Avoid new Python.
- Any commit makes this review stale, so a re-review follows.
