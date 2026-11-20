# quality-tiers-yml-missing-and-unenforced (Issue #734)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/quality-tiers-yml-missing-and-unenforced/ (Issue #734)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #734
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/734
- Last Updated: 2026-09-27
- Work Mode: full-bug

## Summary

`quality-tiers.yml` does not exist at the repository root on `main`. `.claude/rules/quality-tiers.md` says every project must be classified there, and that CI's `tier-classification` stage fails when a project is unclassified. Either that stage does not exist or it does not fail on a missing file.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: `git ls-files --error-unmatch quality-tiers.yml` on main (fails: "did you forget to git add?"); `git ls-tree --name-only origin/main | grep -i tier` (no match)
- Data source or fixture: main at 2026-09-27

## Steps to Reproduce

1. Check out main.
2. Look for `quality-tiers.yml` at the root: it is absent.
3. CI is green, so no stage enforces the documented requirement.

## Expected Behavior

`quality-tiers.yml` classifies every project (T1-T4). CI fails when a project is unclassified or the file is missing.

## Actual Behavior

The file is absent, and plans assume a tier. #706 assumed T4 "because quality-tiers.yml was absent". Reviewers on #707, #708 and #710 flagged it independently.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #706 spec (tier assumption); the #707, #708 and #710 reports.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The tier-dependent gates (mutation score, property-test density, determinism budgets) cannot be applied reliably without the classification source.

## Suspected Cause / Notes

The file was never authored, or it was removed. Verify whether a `tier-classification` job exists in `.github/workflows/`. `.claude/rules/quality-tiers.md` names `docs/ci.research.md` section 1 as the source of truth, and that doc is itself missing (see open issue #511).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: author `quality-tiers.yml` covering every project (extension, mcp-server, scripts, .claude libs, hooks), using the examples in the rules doc; add or repair a CI stage that fails when the file is missing, a project is unclassified, or a tier is invalid.
- [ ] Integration scenario to retest: removing a project's entry makes CI fail.
- [ ] Manual verification notes: coordinate with #511.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

## Consolidated Scope (2026-09-29, authoritative)

Source: operator comment on #734, 2026-09-29.

> Consolidation (2026-09-29): this issue now also carries #336 (same root: `quality-tiers.yml` never created) and #511 (`.claude/rules/quality-tiers.md:9` cites `docs/ci.research.md` section 1, which does not exist; the citation and its mirrors under `.github/`, `.agents/`, and bundled resources must be corrected in the same change).

Consolidated issues (both now closed into #734):

- #336 `Bug: quality-tiers-yml-missing-at-repo-root` — same root cause: `quality-tiers.yml` was never created. Triage comment (2026-08-25) notes the tier system is defined in `.claude/rules/quality-tiers.md` and the `quality-tiers` skill, and that the rule still cites a missing doc and a root YAML map that was never created.
- #511 `Bug: ci-research-doc-missing-at-documented-path` — `.claude/rules/quality-tiers.md` names `docs/ci.research.md` section 1 as the tier system's source of truth; that file does not exist. Expected: the rule cites the document that actually defines the tier system.

Scope requirement: the `docs/ci.research.md` citation must be corrected in `.claude/rules/quality-tiers.md` and in every mirror under `.github/`, `.agents/`, and `extensions/drm-copilot/resources/` in the same change. Policy-document edits are operator-directed and limited to the citation correction.
