# Remediation Inputs — Issue 1161 (S7 review)

Timestamp: 2026-11-14T00-34
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate
Reviewed head: `6c8f1d9faf651b8244f997fd05c5b21ffb1390fb` (PR #1176), merge base `eb73f1dff52e7175228a03740b53281c81e1c00c`.

Review artifacts:
- `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/policy-audit.2026-11-14T00-34.md`
- `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/code-review.2026-11-14T00-34.md`
- `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/feature-audit.2026-11-14T00-34.md`

Path rationale: one contained finding, but the fix redefines which `recorded_at` values the validators accept in at least one runtime. That is a validator-contract change, so the light path does not apply.

## Findings

### PA-1 — Python and TypeScript disagree on a blank `recorded_at`

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Both validator files and the shared corpus are in this branch; the fix and its tests need no external system, owner ruling, or CI result.
Finding-Scope: contained

- Files: `scripts/dev_tools/validate_epic_planner_state.py` (`_validate_planner_worktrees`, the `recorded.strip()` test) and `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts` (`validateEntryFields`, the `recordedAt.trim()` test).
- Finding: the two runtimes use different whitespace sets for the rule `recorded_at must be a non-empty string when present`. Reviewer probe at head (esbuild bundle of the TypeScript module compared with the Python function on the same single-entry checkpoints):
  - `recorded_at` U+FEFF: Python no error; TypeScript reports the `recorded_at` error.
  - `recorded_at` U+001F: Python reports the error; TypeScript no error.
  - `recorded_at` U+0085: Python reports the error; TypeScript no error.
  - U+00A0 and U+200B agree.
- Requirement violated: spec D11 and `### Validator error strings` (byte-identical results in Python and TypeScript); user-story criterion 1 (reviewer unchecked it as PARTIAL).
- Required change: define the blank set once, as an explicit character class used identically in both runtimes (for example ASCII space, tab, LF, CR, FF, VT), and apply it to `recorded_at` in both validators. State the definition in spec `### Field shape` if it differs from the current wording. Add corpus files under `tests/fixtures/epic_planner_state_planner_worktrees/` for U+FEFF, U+001F, and U+0085 (written with JSON `\u` escapes), each with the `expected_errors` the shared definition yields, so that both parity suites fail on a one-sided edit. Keep coverage of both files at 100% lines. Identify every existing test that asserts `recorded_at` behavior and state its disposition. After the suites pass, re-check user-story criterion 1.

## Non-blocking items (no remediation required)

- Accepted exception DEV-1 (owner directive OD-10): the drive-rooted synthetic value quoted in `evidence/qa-gates/pwsh-static.2026-11-13T20-15.md` is accepted against AC-27; the evidence stays unedited.
- CI on PR #1176 was in progress at review time; pending-CI, owned by the S9 gate.
- Code review Info rows (stderr handling in the git wrappers, in-checkpoint duplicate treated as ambiguous, case-insensitive U5 comparison on Codex, AC-31 reading): no change required.
