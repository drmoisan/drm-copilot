# push-down-ac22-test-command-omits-memory-tests (Issue #892)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/push-down-ac22-test-command-omits-memory-tests/ (Issue #892)
- Origin: issue #790 (PR #876), feature-audit finding FA-B1; parallel run bug-burndown-2026-10-08

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #892
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/892
- Last Updated: 2026-10-11
## Summary

The verification command for #790's AC-22 (the Test Strategy pytest command in `spec.md:196`) omits `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py` and `tests/scripts/dev_tools/test_push_down_claude_pack_memory_modes.py`, both of which exercise the measured modules. Under that command `push_down_claude_filesystem.py` initially measured 64.29% branch coverage, below the 75% floor, while the full suite measured 89.29%. Remediation added tests to pass the command, but the command text still omits the two files and therefore under-reports coverage for the modules it names.

## Environment

- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing`
- Data source or fixture: `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` at main 2ef8d361

## Steps to Reproduce

1. Run the AC-22 command above.
2. Run the same command with the two memory test files appended.
3. Compare the reported line and branch coverage for the four modules.

## Expected Behavior

An acceptance criterion's verification command includes every test file that exercises the modules it measures, so its result matches the coverage the repository suite reports.

## Actual Behavior

- `spec.md:223` (AC-22) names the four modules and says it is "Verified by the Test Strategy pytest command"; `spec.md:196` omits the two memory test files.
- Both omitted files import `scripts.dev_tools.push_down_claude_customizations` (lines 69 and 70) and exercise `ExcludingFileSystem` memory modes in `push_down_claude_filesystem`.
- AC-22 is now checked at 92.92% line / 78.57% branch under the original command after tests were added (`feature-audit.2026-10-10T09-15.md:71`); the AC text is unchanged (`:77`).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `feature-audit.2026-10-10T08-46.md:73` (FA-B1): "Under the Test Strategy pytest command, `push_down_claude_filesystem.py` is 88.5% line / 64.29% branch (below 75%) ... Under the repository test suite the module is 95.58% / 89.29%, so the coverage policy is met; the AC is unmet only because its named verification command omits `test_push_down_claude_memory_scope.py` and `test_push_down_claude_pack_memory_modes.py`."
- Snippet: `remediation-inputs.2026-10-10T08-46.md:27`: "a planning agent may amend the AC-22 verification command ... Executors and reviewers must not edit AC text."

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Low. The coverage policy is met under the full suite. The defect is that the recorded verification command does not measure what the AC describes, which can mislead later regression checks that reuse it.

## Suspected Cause / Notes

- The test list was written before the memory-mode tests were identified as covering these modules.
- Reviewers and executors are not permitted to edit AC text, so the command was left as written and tests were added instead.
- No potential entry or issue covered this gap; PR #876's Follow-ups list only #510 items.

## Proposed Fix / Validation Ideas

- [ ] Have a planning agent amend the Test Strategy command in the #790 spec (or its successor document) to include the two memory test files, or record that the command is intentionally partial.
- [ ] Consider a planner check that each AC coverage command includes every test file importing the measured modules.
- [ ] Manual verification notes: re-run the amended command and confirm it reports the full-suite figures for `push_down_claude_filesystem.py`.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch