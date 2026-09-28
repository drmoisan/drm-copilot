# Fail-before — R5: the diff header filter is content-blind

Timestamp: 2026-09-08T06-34

Task: [P4-T4] of `remediation-plan.2026-09-08T05-00.md` — tagged `[expect-fail]`
Finding: R5 (code review F4; feature audit AC-14)

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats`

EXIT_CODE: 1
ExpectedExitCode: 1

Run against the **unfixed** header-skip pattern `"+++ "* | "--- "*` in
`scripts/bash/cleanup_worktrees_dirt_lib.sh`.

TAP plan line: `1..23`
Lines beginning `ok`: 22
Lines beginning `not ok`: 1

## Failing line, verbatim

```
not ok 22 dirt_build_artifact_plus_content: an added content line beginning with plus-plus-plus is counted and the entry is UNIQUE
# (in test file tests/shell/test_cleanup_worktrees_dirt_classify.bats, line 337)
#   `[[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE|| M|src/Legacy/Legacy.csproj'* ]]' failed
ok 23 dirt_build_artifact_added_file: a dev-null header is still skipped and the entry is DISPOSABLE_BUILD_ARTIFACT
```

## Both halves

The failing half is present. The unfixed pattern matches on prefix alone, so the added line
whose content begins `+++ ` is dropped before the `changed` counter and before the
`HintPath` test. The only lines the filter then counts are the genuine `HintPath` rewrite
pair, the diff is judged confined, and the entry resolves `DISPOSABLE_BUILD_ARTIFACT` despite
carrying a real hand edit to a project file. That is the fail-open direction, and it is what
makes the entry clearable.

The passing half is present and is required by this task. `ok 23` shows the
`dirt_build_artifact_added_file` fixture resolves `DISPOSABLE_BUILD_ARTIFACT` **before** the
fix as well as after it: its `--- /dev/null` and `+++ b/src/Legacy/Legacy.csproj` headers
both match the unanchored pattern and are skipped, so the entry is confined either way.
Without this half, a fixture that produced no record at all would satisfy this task.

## Fixture correction made during execution, and why it was necessary

The plan text for [P4-T1] specifies the added line's text as
`+++ this line is real added content and is NOT a HintPath rewrite`. That text is
unsatisfiable for [P4-T6], and the reason is not visible from the header-skip logic alone.

The line's own text contains the literal `HintPath`. Once the anchored pattern stops
dropping the line, the line reaches the confinement test
`if [[ $line != *"HintPath"* ]]`, and because it contains that substring the test treats it
as an analyzer path rewrite. The counter advances, the loop completes, and the diff is
reported confined — so the entry resolves `DISPOSABLE_BUILD_ARTIFACT` *after* the fix as
well as before it, and [P4-T6]'s acceptance condition could never be met.

This was observed rather than inferred. With the plan's original line text and the anchored
pattern in place, the classifier emitted:

```
DIRTFILE|/repo-wt/dirt|DISPOSABLE_BUILD_ARTIFACT|| M|src/Legacy/Legacy.csproj
DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|
```

The added line's text was therefore changed to
`+++ this line is real added content and is not an analyzer path rewrite`, which:

- retains the exact literal `+++ this line is real added content` that [P4-T1]'s acceptance
  condition asserts, so that condition is unaffected and was re-verified after the change;
- retains the leading `+++ ` that makes the line indistinguishable from a header under the
  unfixed pattern, so the fail-before half above is unaffected;
- no longer contains the literal `HintPath`, so the confinement test correctly rejects it
  once the anchoring stops the line being dropped.

Because the fixture changed, this fail-before run was **re-captured against the corrected
fixture** rather than carried forward from the first capture. The anchored pattern was
temporarily reverted to `"+++ "* | "--- "*`, this command was re-run to produce the output
recorded above, and the anchored pattern was then re-applied. Every figure in this artifact
describes the tree with the corrected fixture and the unfixed pattern.

After re-applying the anchored pattern, the same scenario emits:

```
DIRTFILE|/repo-wt/dirt|UNIQUE|| M|src/Legacy/Legacy.csproj
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|
```

Output Summary: The suite exits 1 with exactly the predicted split of results, 1 `not ok` for
the plus-content test and `ok` for the dev-null-header test. The defect is reproduced at the
level of the emitted record. One fixture-text correction was required for the pin to be able
to pass after the fix, and it is recorded above with the observation that established it.
