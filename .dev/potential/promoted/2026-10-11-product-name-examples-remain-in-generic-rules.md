# product-name-examples-remain-in-generic-rules (Issue #894)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/product-name-examples-remain-in-generic-rules/ (Issue #894)
- Origin: issue #824 follow-ups (PR #879): policy-audit PA-2 (OPS-3), code-review CR-5, and Follow-ups item 5

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #894
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/894
- Last Updated: 2026-10-11
## Summary

PR #879 neutralized product names in the pushed rule surfaces but left exceptions that are pushed into consumer repositories: the `src/TaskMaster.Domain` example in `.claude/rules/parallel-orchestration.md` and its bundled copy, and `No-COM` in `.claude/rules/typescript.md` and `.claude/rules/csharp.md`. The guard test exempts whole files, so new product-name occurrences in an exempted file are not detected (CR-5). The `typescript.md` cross-reference also no longer matches the renamed heading.

## Environment

- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`
- Data source or fixture: main at 2ef8d361

## Steps to Reproduce

1. Read `.claude/rules/parallel-orchestration.md:409-411` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md:409-411`.
2. Read `PRE_EXISTING_NAME_EXCEPTIONS` at `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py:110-120`.
3. Add a second product name to an exempted file and run the test; it still passes.

## Expected Behavior

Pushed rule surfaces contain no repository-specific product names, and the guard test fails on any new occurrence, including in files with pre-existing exceptions.

## Actual Behavior

- `.claude/rules/parallel-orchestration.md:411`: "`src/TaskMaster.Domain`; host-qualified tokens such as `example.com/page.html` or `owner/repo.git`;" (sentence begins at line 409, "**Accepted residuals (fail-closed direction).** ... such as the C#-style"). The bundled copy has the same text.
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py:116-118` exempts both files with the comment "Added by #797 after #824 planning; out of scope for #824 (follow-up)". The test's staleness check fails once an exempted file no longer names a product, so removing the example also requires removing these lines.
- `No-COM` remains in `.claude/rules/typescript.md` and `.claude/rules/csharp.md` (held in the AC-5 exception set).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: PR #879 Follow-ups item 1: "PA-2 (OPS-3): remove the `src/TaskMaster.Domain` example from `.claude/rules/parallel-orchestration.md` and its bundled copy; it is currently held in `PRE_EXISTING_NAME_EXCEPTIONS`."
- Snippet: CR-5 (`code-review.2026-10-10T00-44.md`): "`PRE_EXISTING_NAME_EXCEPTIONS` is per file; pin per-file occurrence counts so new occurrences fail."
- Snippet: PR #879 Follow-ups item 5: "`No-COM` remains in `.claude/rules/typescript.md` and `.claude/rules/csharp.md` (held in the AC-5 exception set) and the `typescript.md` cross-reference no longer matches the renamed heading."

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Low. The names are examples, not behavior, but they are delivered to consumer repositories and the per-file exemption weakens the guard.

## Suspected Cause / Notes

- The `TaskMaster.Domain` example was added by #797 after #824 was planned, so #824 recorded it as an exception instead of removing it.

## Proposed Fix / Validation Ideas

- [ ] Replace the example in both copies of `parallel-orchestration.md` with a neutral one (for example `src/Example.Domain`) and delete test lines 116-118.
- [ ] Neutralize `No-COM` in `typescript.md` and `csharp.md`, update the AC-5 exception set, and fix the `typescript.md` heading cross-reference.
- [ ] Unit coverage areas: change `PRE_EXISTING_NAME_EXCEPTIONS` to pin per-file occurrence counts (CR-5).
- [ ] Keep the bundle byte-parity test green.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch