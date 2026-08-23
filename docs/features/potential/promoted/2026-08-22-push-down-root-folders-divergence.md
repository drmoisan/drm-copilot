# push-down-root-folders-divergence (Issue #507)

- Date captured: 2026-08-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/push-down-root-folders-divergence/ (Issue #507)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: full-bug

- Issue: #507
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/507
- Last Updated: 2026-08-23
## Summary

The Python and TypeScript implementations of the Claude push-down publish different sets of root folders. The TypeScript path publishes `.claude` and `config`; the Python path publishes `.claude` only. A destination pushed through the Python entry point therefore never receives the `config` tree, including `config/blast-radius.json` and `config/orchestration-routing.json`.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: 3.13.12 (Poetry 2.3.2)
- Command/flags used: source inspection of both push-down implementations
- Data source or fixture: `scripts/dev_tools/push_down_claude_customizations.py` and `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`

## Steps to Reproduce

1. Read `scripts/dev_tools/push_down_claude_customizations.py` line 101.
2. Read `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` line 50.
3. Compare the two declarations.

## Expected Behavior

The two implementations publish the same payload. A destination receives the same files whichever entry point performed the push, so the two surfaces cannot drift into producing different destination states.

## Actual Behavior

The declarations differ:

```text
scripts/dev_tools/push_down_claude_customizations.py:101
  ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)

extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:50
  export const ROOT_FOLDERS: ReadonlyArray<string> = [".claude", "config"];
```

Issue #462 added the `config` tree to the shipped payload on the TypeScript side. The Python side was not extended.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: the two declarations quoted above, read at commit `627c45d1`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. A destination pushed through the Python path silently lacks the blast-radius and orchestration-routing truth tables it is expected to carry. The blast-radius library then falls back to whatever the destination already had, or to nothing, and the resulting conflict graph is not the one the payload intended. The severity is not higher only because the TypeScript path appears to be the one in routine use.

## Suspected Cause / Notes

Issue #462 extended one implementation and not the other. This is the same class of gap that produced issue #500: a payload contract expressed in two places where only one was updated. Related, and worth reading together with, the parity-gate scope gap recorded in `.claude/rules/parallel-orchestration.md`, where `SCOPED_ROOTS` in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` likewise covers `.claude` only.

## Proposed Fix / Validation Ideas

- [ ] Decide which implementation is authoritative, then align the other, or derive both from one declaration.
- [ ] Add a parity assertion that fails when the two root-folder sets differ, so the next divergence is caught at test time rather than in a destination.
- [ ] Unit coverage areas: the root-folder declaration in both implementations and the new parity assertion.
- [ ] Integration scenario to retest: a push through each entry point produces the same destination file set.
- [ ] Manual verification notes: confirm whether any consumer depends on the Python path publishing `.claude` alone before widening it.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
