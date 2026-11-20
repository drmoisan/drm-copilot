# Code Review: general-instructions-first (Issue #122)

## Executive Summary

Relative to `development`, there is no remaining code diff to review: refreshed PR context resolves both `origin/development` and `HEAD` to `f720ff7fae4e11e62b61d62b3072d03c84a2307b`, and `git diff --name-only origin/development...HEAD` returns no files. The scoped feature implementation recorded in `docs/features/active/2026-04-05-general-instructions-first-122` remains technically sound and already present in the base branch: it adds a small grouped sort-key helper, preserves bundled parity, adds targeted ordering regressions, and regenerates `AGENTS.md` with the required general-first ordering.

Top risks:
1. No code risk remains relative to `development`; the only practical risk is opening a redundant no-op PR.
2. The stored evidence does not include an exact changed-line coverage percentage, even though behavior coverage and no-regression evidence are present.
3. Reviewers should avoid re-validating this feature against `spec.md` or `user-story.md`; this is a `minor-audit` bugfix and only the exact `## Acceptance Criteria` section in `issue.md` is authoritative.

**Go/No-Go recommendation for `development`:** **Go**. The ready-to-merge gate passes, but there is nothing left to merge because the branch is already at the `development` tip.

**Feature-folder selection rule:** The user explicitly supplied `docs/features/active/2026-04-05-general-instructions-first-122`, so this review uses that folder as the authoritative scope anchor despite the empty live diff.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `artifacts/pr_context.summary.txt` | `Base/Head`, `Changed files overview` | The refreshed comparison against `development` is empty. | Do not open a new PR to `development` unless additional commits are added; treat the gate as passed and the branch as already merged. | A no-op PR adds review overhead without delivering any additional change. | Refreshed summary shows `Base ref (resolved): origin/development @ f720ff7...`, `Head ref (resolved): bug/general-instructions-first-122 @ f720ff7...`, and `Core logic changes: 0 files`. |
| Minor | `docs/features/active/2026-04-05-general-instructions-first-122/evidence/qa-gates/` | coverage evidence set | The evidence proves behavior and no coverage regression but does not isolate a changed-line percentage. | If a stricter audit package is needed later, add a short focused coverage note; no code remediation is required now. | This is an audit completeness note, not a correctness issue. | Baseline/final Pester artifacts show `47.57%` → `47.86%` command coverage. |
| Nit | `docs/features/active/2026-04-05-general-instructions-first-122/issue.md` | `## Acceptance Criteria` | The issue already contains the exact minor-audit AC section with all five items checked. | Keep using only this section as the source of truth for future review references. | This preserves the repository’s minor-audit integrity contract. | Direct issue inspection shows `AC_START=64`, `AC_CHECKED=5`, `AC_UNCHECKED=0`. |

## Reviewed Implementation Notes

### What changed in the feature scope

- `scripts/dev-tools/sync-agents-from-instructions.ps1`
  - Added `Get-InstructionSortKey`.
  - Switched discovery ordering to grouped sort keys so `general*` basenames precede language-specific instruction files while preserving deterministic order inside each group.
- `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1`
  - Remains byte-identical to the repo-root script.
- `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`
  - Added a helper-ordering regression test.
  - Added a generated-output ordering regression test.
- `AGENTS.md`
  - Regenerated to prove the grouped order.

### Strengths

- The fix is small, local, and easy to reason about.
- The helper is pure and does not widen the command surface.
- Tests cover both internal ordering and user-visible output ordering.
- Bundled parity is preserved.
- The feature evidence set is complete enough to support a pass decision relative to `development`.

## Typed Python Audit

No Python files are in the scoped feature implementation. Typed Python review is **N/A** for this feature folder.

## Test Quality Audit

- **Deterministic:** Yes. The new ordering tests use mocked discovery inputs and assert explicit order relationships.
- **Isolated:** Yes. No network or temporary filesystem dependency is introduced.
- **Fast:** Yes. Final Pester evidence reports `9.96s` total execution time.
- **Diagnostics:** Good. The red regression artifact records the exact failing ordering assertion before the fix.
- **Coverage posture:** Good for behavior and no-regression evidence; partial only for exact changed-line reporting.

## Security and Correctness Checks

- No secrets or credentials were introduced.
- No unsafe subprocess or shelling behavior was added.
- The new behavior is a pure string-based ordering helper.
- Minor-audit integrity holds: `spec.md` and `user-story.md` are absent, and only the exact `## Acceptance Criteria` section in `issue.md` is used as the acceptance source.

## Go/No-Go Recommendation

**Go relative to `development`.**

The gate passes because there is no remaining diff against the selected base branch and the feature-folder evidence confirms the scoped bugfix was implemented and verified. No remediation is required. The only operational note is that a PR to `development` would be redundant unless additional commits are added after this review.
