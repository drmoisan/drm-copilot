# unauthorized-noqa-e501-in-blast-radius-parity-test (Issue #512)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/unauthorized-noqa-e501-in-blast-radius-parity-test/ (Issue #512)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #512
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/512
- Last Updated: 2026-08-23
## Summary

`tests/scripts/dev_tools/test_blast_radius_config_parity.py` carries a `# noqa: E501` that is not
authorized by `.claude/rules/python-suppressions.md`, and the plan task whose acceptance forbade a
new `noqa` was nonetheless checked off.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `poetry run ruff check .`
- Data source or fixture: not applicable

## Steps to Reproduce

1. Open `tests/scripts/dev_tools/test_blast_radius_config_parity.py` and find the `def` line of
   `test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion`. It ends with
   `# noqa: E501`.
2. Read `.claude/rules/python-suppressions.md`. A suppression must either match a pre-authorized
   pattern or carry explicit user approval. `E501` appears in neither the pre-authorized list nor
   the explicitly-not-authorized list, and no approval is recorded.
3. Observe that the rule's required explanatory comment for a suppression is absent.

## Expected Behavior

Either the line fits the 88-character limit without a suppression, or the suppression matches a
pre-authorized pattern, or an explicit user approval for this specific suppression is recorded.

## Actual Behavior

An unauthorized `E501` suppression is present in committed test code. Separately, task P5-T2 of
`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T17-20-remediation/remediation-plan.2026-08-22T18-05.md`
is checked `[x]` while its stated acceptance is "zero new `noqa` present", which the tree does not
satisfy. No deviation was recorded against that task.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: the `def` line measures 91 characters; the Ruff limit is 88.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium rather than Low on two counts. A suppression outside the enumerated set weakens a lint gate
without a recorded decision, and a task checked against a half-satisfied acceptance condition is the
same class of defect that issue #500 corrected four separate times (AC9, AC10, AC4, and cycle 4's
own R1). The severity is not higher because the suppressed diagnostic is line length only, with no
behavioral effect.

## Suspected Cause / Notes

Introduced by issue #500 remediation cycle 4 and recorded in that cycle's exit re-audit as finding
M4; see
`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-23T04-45-audit/code-review.2026-08-23T04-45.md`.

The suppression was not an arbitrary choice. The cycle-4 plan mandated the 80-character test name at
task P1-T2, and no formatting variant of that name fits: after Black wraps the return type, the
`def` line measures `len(name) + 11` characters, so 80 yields 91. Three other test files in this
repository carry an `E501` suppression for identically-shaped long test names, and the executor
followed that precedent rather than editing `pyproject.toml`, which the same plan forbade at P5-T10.
Precedent is not authorization under a rule that enumerates its authorized patterns exhaustively.

It was left in place deliberately rather than hot-fixed. The exit re-audit had already returned
`blocking_count` 0 against the committed tree, and renaming the function afterwards would have
shipped code that differed from the reviewed tree while leaving five citations of the old name in the
executed plan and two evidence artifacts.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: rename the test so the `def` line fits without a suppression. Any name of
      77 characters or fewer works, since the line measures `len(name) + 11`. A measured candidate is
      `test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion` at 74 characters.
      Remove the `# noqa: E501` in the same edit and confirm `poetry run ruff check .` stays clean.
- [x] Integration scenario to retest: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py`
      should still collect and pass 17 tests. Re-confirm the gate is non-vacuous by registering a key
      against an assertion that does not read it and observing exactly one failure.
- [x] Manual verification notes: decide the general question this raises, which is whether `E501`
      belongs in the pre-authorized list for long descriptive test names. Three existing precedents
      suggest the pattern recurs. If it is authorized, add it to
      `.claude/rules/python-suppressions.md` with its required explanatory-comment convention rather
      than leaving each instance to precedent.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
