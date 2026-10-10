# Remediation Inputs: Issue #824 Addendum 2 feature review

- Timestamp: 2026-10-10T00-44
- Branch: `bug/issue-823-tier-rule-adoption-follow-ups-824` @ `1d5b66015`
- Base: `origin/main` @ `816b5513a` (merge base)
- Verdict: HALT_NON_REMEDIABLE
- Blocking findings: 1 (0 classified `autonomous`)
- Remediation plan target: none created (no autonomous blocking finding)

## Source Artifacts

- `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/policy-audit.2026-10-10T00-44.md`
- `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/code-review.2026-10-10T00-44.md`
- `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/feature-audit.2026-10-10T00-44.md`

## Blocking Findings

### PA-1: Bash coverage measurement absent for the changed `.codex/codex-web-setup.sh`

- Classification: Blocking
- Remediability: human_decision_required
- Remediability-Evidence: `.claude/rules/shell.md` limits kcov include roots to `tools/`, `scripts/`, `.claude/lib/bash/`, `.claude/skills/`; spec.md Scope & Non-Goals hard-excludes "any other shell-coverage workflow work"; spec.md Risks and Rollout record the `.codex/` kcov gap as a pre-existing follow-up.
- Files: `.codex/codex-web-setup.sh`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`
- Finding: the branch adds three functions and two guards to the script, but no coverage artifact exists for the changed lines. `.claude/rules/general-unit-test.md` applies the 85% line threshold to bash (kcov) and keeps every production file in the coverage denominator; the review contract requires PASS or FAIL for each language with changed files and treats an absent artifact as FAIL.
- Decision options for the maintainer:
  1. Record a waiver for this item (for example in issue #824 or the PR body) accepting bash behavioral verification by `tests/shell/test_codex_web_setup_codex_copy.bats` in place of kcov measurement for `.codex/`, with the existing follow-up retained.
  2. Expand scope (separate item recommended) to bring `.codex/` under shell-qc discovery and the kcov include roots, which also subjects the script to shfmt and shellcheck (policy-audit PA-5).
- Verification after decision: for option 1, the waiver reference is cited in a re-audit; for option 2, a kcov report listing `.codex/codex-web-setup.sh` with line coverage >= 85%.

## Pending Items (not findings)

- bats suite and `sh -n` checks on the PR head (OPS-1): AC-6 and AC-13 stay unchecked until CI passes.
- PR authoring: AC-15 stays unchecked; include the `.claude/rules/parallel-orchestration.md` follow-up (policy-audit PA-2).

## Do Not Do

- Do not edit `.claude/rules/shell.md`, `.github/workflows/_shell-coverage.yml`, or shell-qc discovery roots within this item without a maintainer decision.
- Do not mark the Bash coverage verdict as not applicable in any re-audit.
- Do not check off AC-6, AC-13, or AC-15 before their CI or PR evidence exists.
