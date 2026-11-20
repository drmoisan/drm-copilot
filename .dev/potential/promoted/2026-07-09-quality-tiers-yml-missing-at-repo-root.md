# quality-tiers-yml-missing-at-repo-root (Issue #336)

- Date captured: 2026-07-09
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/quality-tiers-yml-missing-at-repo-root/ (Issue #336)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #336
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/336
- Last Updated: 2026-07-09
## Summary

`.claude/rules/quality-tiers.md` and `.claude/rules/general-code-change.md` describe `quality-tiers.yml` at the repository root as the source of truth mapping every project to a T1-T4 module rigor tier, and state that a CI `tier-classification` stage fails when a project is unclassified — but no `quality-tiers.yml` file exists at the repository root.

## Environment

- OS/version: N/A (missing data file, not environment-specific)
- Python version: N/A
- Command/flags used: N/A
- Data source or fixture: repository root; expected file `quality-tiers.yml`

## Steps to Reproduce

1. Run a glob/search for `quality-tiers.yml` at the repository root.
2. Observe no matching file.
3. Compare against `.claude/rules/quality-tiers.md` ("`quality-tiers.yml` at the repository root is... the source of truth") and `.claude/rules/general-code-change.md` ("Every project must be classified in `quality-tiers.yml` at repo root").

## Expected Behavior

Either `quality-tiers.yml` exists at the repository root and is consumed by a real `tier-classification` CI stage, or the rule text should not describe a CI gate that does not exist.

## Actual Behavior

The rule files describe an authoritative tier-classification data file and a CI gate that fails on an unclassified project, but the data file itself is absent, so the described gate has nothing to validate against.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: N/A — confirmed by direct file-existence check (no `quality-tiers.yml` at repo root).

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Identified as a known, explicitly out-of-scope follow-up during feature #272 (`local-preflight-orchestrator-state-gate`): see `docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/other/follow-up-quality-tiers-gap.md` ("`quality-tiers.yml` does not currently exist at the repository root... This is a pre-existing, orthogonal gap... Explicitly out of scope for issue #272."). Confirmed still present via `docs/research/2026-07-09-remaining-technical-debt-audit.md`; no open or closed GitHub issue currently tracks it.

## Proposed Fix / Validation Ideas

- [ ] Author `quality-tiers.yml` at the repository root, classifying every existing project/module into T1-T4 per `.claude/rules/quality-tiers.md`.
- [ ] Wire (or confirm/implement) the `tier-classification` CI stage referenced by the rule text, so it actually fails when a new project has no tier entry.
- [ ] Integration scenario to retest: adding an unclassified project should fail the `tier-classification` CI stage once implemented.
- [ ] Manual verification notes: reconcile rule-text wording with the true current state if a CI gate is intentionally not yet built.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
