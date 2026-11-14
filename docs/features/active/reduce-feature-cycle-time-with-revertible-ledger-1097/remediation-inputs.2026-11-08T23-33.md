# Remediation Inputs — Issue 1097, Stage J

Timestamp: 2026-11-08T23-33
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: design
Head: `60e92a837ca2c8815a79c1c782924e3a8a66c459`
Main: `70e66be7566f4c7259acce97449c769f7ff3854a`
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-08T23-33.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-08T23-33.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-08T23-33.md`
Remediation plan target: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-08T23-33.md`

Path note: the single finding is autonomous and contained. The light path is not used because the fix edits `quality-tiers.yml`, which lies outside the branch diff, its tests, and its mirrors.

## Findings requiring remediation

### F1 — `.claude/lib/review-verdict` is not classified in `quality-tiers.yml`

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is one manifest entry in the repository, and the check runs locally; it needs no owner decision, external system, or CI result.
Finding-Scope: contained

- Location: `quality-tiers.yml` (repository root), `projects` list; the new folder `.claude/lib/review-verdict/` added by stage J.
- Observed: `check_quality_tiers`, run from the item worktree with the main checkout's venv, exits 1 with `QT008: discovered project '.claude/lib/review-verdict' has no entry`. Rule R4 of `scripts/dev_tools/quality_tiers_contract.py` makes every `.claude/lib/<name>` folder holding a file a project. CI job `quality-checks7 / Code Quality & Tests (3.11)` (job 128897774473) failed at step `tier-classification` on `60e92a837`. The CI pytest and coverage steps were skipped, and the 3.12 and 3.13 jobs were cancelled.
- Required change: add an entry `path: ".claude/lib/review-verdict"`, `tier: T3`, with a `rationale` in the form of the other `.claude/lib/*` entries (for example, runtime library shipped in the `.claude` bundle; pure review/verdict eligibility rules and their command entry). Place it next to `.claude/lib/ci-gate`. No other file changes. No stored ledger patch or revert block touches `quality-tiers.yml`, so no ledger record changes and no `reduction:` token is used.
- Verification required: `check_quality_tiers` exits 0, recorded in a gate artifact under `<FEATURE>/evidence/qa-gates/` with `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`. Run one `pytest -n auto` gate, compared with the stage J Phase 0 baseline (16590 passed, 97.11% lines, 94.37% branches), because Python tests read the manifest. No PowerShell file changes, so the stage J Pester gate stands. Then re-review.

## Non-blocking items (no remediation required in this PR)

- CR1: the Review-mode artifact rule does not tie the named policy audit to the PASS outcome.
- CR2: `.claude/rules/orchestrator-state.md` and `## Post-Review Outcome Evaluation` step 6 still scope `head_sha` to concurrent runs.
- CR3: the `Get-ReviewVerdictFactOutput` synopsis says trimmed; the code does not trim.
- CR6 (carried from stage I): owner ratification recommended in the stage J PR description.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison runs.
- No baseline task, baseline evidence, or baseline comparison is reduced.
- No forced push and no history rewrite.
- Avoid new Python, except where an existing validator needs a change for parity.
- No Epic #1019 folder or other item's feature folder is edited.
- Do not run an unqualified `poetry install` from the item worktree; the worktree venv lacks `yaml`, so run `check_quality_tiers` with the main checkout's venv from the worktree root.
