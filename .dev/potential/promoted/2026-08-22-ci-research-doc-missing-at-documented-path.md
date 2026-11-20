# ci-research-doc-missing-at-documented-path (Issue #511)

- Date captured: 2026-08-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ci-research-doc-missing-at-documented-path/ (Issue #511)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: minor-audit

- Issue: #511
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/511
- Last Updated: 2026-08-23
## Summary

`.claude/rules/quality-tiers.md` names `docs/ci.research.md` section 1 as the source of truth for the T1 through T4 module rigor tier system. That file does not exist in this repository, so the rule points at nothing.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable; documentation defect
- Command/flags used: `ls docs/ci.research.md`
- Data source or fixture: `.claude/rules/quality-tiers.md`

## Steps to Reproduce

1. Read the opening paragraph of `.claude/rules/quality-tiers.md`, which cites `docs/ci.research.md` section 1 as the tier system's source of truth.
2. Run `ls docs/ci.research.md`.

## Expected Behavior

Either the cited document exists at the stated path, or the rule cites the document that actually defines the tier system.

## Actual Behavior

`ls: cannot access 'docs/ci.research.md': No such file or directory`. Every agent that follows the documented reading order to establish a module's tier reaches a dead reference and must infer the tier instead.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

  ```text
  $ ls docs/ci.research.md
  ls: cannot access 'docs/ci.research.md': No such file or directory
  ```

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Low on its own, because `.claude/rules/quality-tiers.md` restates the tier definitions inline, so the practical guidance survives the broken citation. It is filed because agents are instructed to read it, and a rule that points at a missing file trains readers to skip citations.

## Suspected Cause / Notes

Companion to issue #336, which records that `quality-tiers.yml` is likewise missing from the repository root while the same rule names it as the per-project tier map. The two together mean the tier system has no machine-readable source in this repository, and a research pass during issue #500 had to state module tiers as inferences for that reason.


Documentation drift; the rule was probably authored against a repository that carried both artifacts.

## Proposed Fix / Validation Ideas

- [ ] Either add `docs/ci.research.md` or amend `.claude/rules/quality-tiers.md` to cite the real source.
- [ ] Resolve alongside issue #336 so the tier system ends with one coherent set of references.
- [ ] Unit coverage areas: none; documentation only.
- [ ] Integration scenario to retest: none.
- [ ] Manual verification notes: grep the rules tree for other citations of either path.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
