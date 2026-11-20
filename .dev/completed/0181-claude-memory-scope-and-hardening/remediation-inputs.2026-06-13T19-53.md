# Remediation Inputs: claude-memory-scope-and-hardening (Issue #181)

**Generated:** 2026-06-13T19-53
**Base branch:** `main` (merge-base `2745d23d01ea179d8d02fc240dbadb1017ee7aeb`)
**Head SHA:** `75b0ea6191b0498b9e2240f9a262457f348a57e3`
**Source artifacts:**
- `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/policy-audit.2026-06-13T19-53.md`
- `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/code-review.2026-06-13T19-53.md`
- `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/feature-audit.2026-06-13T19-53.md`

## Overall Disposition

No code or toolchain remediation is required. Black, Ruff, project-scoped Pyright, and Pytest with coverage all pass against the branch head, and all in-branch acceptance criteria are PASS. This file records one UNVERIFIED out-of-band acceptance criterion and two non-blocking observations so the orchestrator can close them outside the code path.

## Remediation-Required Findings

### RF-1 — Three follow-up GitHub issues (Decision L) not verified as opened

- **Severity:** Non-blocking (out-of-band acceptance criterion; not a code or toolchain defect).
- **Source:** `user-story.md` `## Acceptance Criteria` item 14; `spec.md` `## Definition of Done`.
- **Verdict:** UNVERIFIED.
- **Detail:** The feature requires three follow-up GitHub issues for the cross-language items in Decision L (new-code delta coverage gate for TS/C#/PowerShell; test-purity hooks for TS/C#; batch-budget hooks for TS/C#). These items are correctly out of scope for the branch diff and have zero changed files. No evidence of issue creation is available to this review.
- **Required action (orchestrator):** File the three GitHub issues and record their issue numbers/URLs in the feature folder, then check off `user-story.md` AC item 14. This action is outside the code branch and does not require a code remediation plan.
- **Owner:** Orchestrator (as stated in the caller prompt: "filed as separate GitHub issues by the orchestrator").

## Non-Blocking Observations (no remediation plan required)

### OB-1 — Repo-wide coverage TOTAL is 82% (below the 85% repo-wide line threshold)

- **Severity:** Informational. Not attributable to this feature.
- **Detail:** The combined line+branch TOTAL is 82%, identical to the pre-feature baseline (`evidence/baseline/baseline-pytest.md`). This feature introduces no regression; the two edited modules are at 88% and 92% line coverage. The repo-wide figure reflects long-standing repository state and is not a feature-blocking finding.
- **Required action:** None for this feature. Repository-wide coverage uplift is a separate concern.

### OB-2 — Extension template Pyright isolated-invocation noise

- **Severity:** Informational. No policy violation.
- **Detail:** `poetry run pyright extensions/drm-copilot/resources/templates/push_down_claude_customizations.py` in isolation reports 16 errors rooted in the bundled-deployment import fallback (lines 86-94), which is unresolvable in the repo layout. The policy command `poetry run pyright` (include = scripts/src/tests) does not cover this path and returns 0 errors.
- **Optional action:** Add a module comment noting the file is excluded from the project Pyright include because it runs only in the bundled deployment context.

### OB-3 — Validator malformed-`cycles` negative test coverage

- **Severity:** Low. Defensive hardening suggestion.
- **Detail:** `_validate_remediation_loop` correctly handles a non-list `cycles` (returns no errors) and a non-dict cycle entry (appends an explicit "must be an object" error, lines 209-211). The test suite covers the three invariants and the backward-compat case but does not include a dedicated negative test for a non-dict cycle entry or a non-list `cycles` container.
- **Optional action:** Add one negative test for a non-dict cycle entry and one for a non-list `cycles` value to lock in the defensive behavior.

## Plan Handoff

No remediation plan file is created because there are no code- or toolchain-level FAIL findings. RF-1 is an out-of-band orchestrator action (file GitHub issues), and OB-1 through OB-3 are informational or optional hardening items. If the orchestrator elects to address OB-3 as a code change, it should be routed through the standard lifecycle as a minor follow-up; it is not required for this feature's PR readiness.
