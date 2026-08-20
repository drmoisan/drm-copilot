# pr-context-verification-cannot-express-expected-nonzero-exit (Issue #485)

- Date captured: 2026-08-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pr-context-verification-cannot-express-expected-nonzero-exit/ (Issue #485)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #485
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/485
- Last Updated: 2026-08-17
- Work Mode: full-bug

## Summary

The PR-context Verification evidence parser normalizes every non-zero `EXIT_CODE` to `fail`, and the evidence schema provides no way to declare an expected exit code. Any verification gate whose acceptance condition is a non-zero exit — most commonly a `git grep` whose acceptance is zero matches, which exits 1 — is reported as failed in the PR body even when it passed. Every expected-nonzero gate is mislabeled by construction.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `mcp__drm-copilot__collect_pr_context` (Verification evidence block)
- Data source or fixture: canonical evidence artifacts under `docs/features/active/<feature>/evidence/{qa-gates,regression-testing,other}/**/*.md`

## Steps to Reproduce

1. Author a canonical evidence artifact for a gate whose acceptance condition is a non-zero exit, for example a `git grep` asserting a forbidden token is absent, which exits 1 when there are zero matches.
2. Record the observed exit code faithfully in the artifact as `EXIT_CODE: 1`.
3. Attempt to declare the expectation, for example by adding an `ExpectedExitCode: 1` line to the artifact.
4. Run `mcp__drm-copilot__collect_pr_context` and read the Verification block in the generated PR context.

## Expected Behavior

An evidence artifact can declare the exit code its gate is expected to produce. A gate whose observed exit code equals its declared expectation is normalized to `pass`. The default expectation remains `0`, so every existing artifact keeps its current result.

## Actual Behavior

The declared expectation is discarded and the row is reported as `fail`.

The normalization is a total binary partition with no third branch:

- `scripts/dev_tools/pr_context/verification_evidence.py:136`

  ```python
  normalized_result: NormalizedResult = "pass" if exit_code == 0 else "fail"
  ```

- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:146`

  ```typescript
  const normalizedResult: NormalizedResult = exitCode === 0 ? "pass" : "fail";
  ```

The `unparseable` result is reached only when a required field is missing or `EXIT_CODE` is not an integer; it is not an escape hatch for an expected non-zero exit.

The expectation cannot be expressed at all. `scripts/dev_tools/pr_context/verification_evidence.py:22` defines the accepted key set as exactly three fields, and the parse loop at lines 102-108 keeps only those keys:

```python
REQUIRED_FIELDS: tuple[str, str, str] = ("Timestamp", "Command", "EXIT_CODE")
...
    if key in REQUIRED_FIELDS:
        parsed[key] = value.strip()
```

An `ExpectedExitCode:` line is therefore dropped silently, with no warning and no `unparseable` signal. A repository-wide search for `expected_exit`, `expectedExit`, and `expected_nonzero` returns zero matches.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see the two normalization lines quoted under Actual Behavior.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The PR body is the primary reviewer-facing verification record. A gate that passed is reported as failed, which either trains reviewers to discount `fail` rows or drives authors to one of three workarounds that all degrade traceability: misrecord `EXIT_CODE: 0`, wrap the command so the process exits 0 and lose the real exit code, or omit the artifact entirely and lose the evidence. The severity is High rather than Blocker because no gate is weakened — the failure mode is a false negative in reporting, not a false pass.

## Suspected Cause / Notes

The evidence schema was designed around the assumption that exit code 0 is the only success condition. That assumption holds for the toolchain stages it was built for (format, lint, type-check, test) and fails for absence assertions, which are common in acceptance criteria and in policy gates.

Related but distinct machinery already exists and must not be confused with this defect. The `[expect-fail]` tag in the atomic-plan contract and the expected-fail resolution in `scripts/dev_tools/atomic_executor/qc_runner_expectations.py` operate at test-node granularity inside the atomic-executor QC loop. Neither module is imported by `scripts/dev_tools/pr_context/`, and the two surfaces have different inputs. A fix belongs in the evidence schema and its two parsers; it should not be duplicated from the executor QC path.

Any fix must land in both runtimes. `scripts/dev_tools/pr_context/verification_evidence.py` and `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` are a parity pair, and a change to one without the other produces divergent PR context depending on which surface generated it.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: parser acceptance of the new expectation key; default-to-zero behavior when the key is absent; normalization to `pass` when observed equals expected; normalization to `fail` when observed differs from a non-zero expectation; `unparseable` when the expectation value is not an integer.
- [ ] Integration scenario to retest: generate PR context for a feature carrying one absence-assertion gate with a declared non-zero expectation and confirm the Verification row reads `pass` while still displaying the observed exit code.
- [ ] Manual verification notes: confirm byte-identical Verification output for a feature whose artifacts carry no expectation key, so the change is additive. Confirm Python and TypeScript parity across the same artifact set.

## Delivered Outcome (2026-08-20)

The fix landed on branch `bug/pr-context-verification-cannot-express-expected-nonzero-exit-485`, with
both runtimes changed in one change set:

- One optional, flat, integer-valued evidence key `ExpectedExitCode`, defaulting to `0` when absent,
  accepted by both parsers without altering the required-field constant in either.
- Normalization extracted into a pure two-argument helper per runtime and changed from "observed equals
  zero" to "observed equals expected".
- A present but non-integer expectation yields `unparseable`, and every `unparseable` record carries a
  null observed code and expectation `0`.
- A duplicated expectation key resolves first-wins in both runtimes.
- One conditional row line, `  - Expected EXIT_CODE: <int>`, emitted between the `EXIT_CODE` and
  `Normalized result` lines only when the expectation is non-zero.
- The optional key documented in all six copies of `evidence-and-timestamp-conventions/SKILL.md`.
- New Python parser test module (54 tests) and new Python collector-level sibling module; 22 tests
  added on the TypeScript side. No pre-existing test was edited.

Verification, in a single clean final toolchain pass for both languages:

- Python: 3995 tests passed, 0 failed; overall line coverage 92.45%, branch 84.93%.
- TypeScript: 2580 tests passed across 185 suites, 0 failed; overall line coverage 96.62%, branch
  89.98%.
- New/changed-code coverage: 100% across the four changed production files.
- Additive proof (Invariant A): 1293 artifacts discovered by `CANONICAL_GLOBS`; **0 rendered-row
  differences** between the pre-change reference and post-change output in BOTH runtimes.
- 23 of the 25 acceptance criteria in `spec.md` are checked off.

## Deferred defect — duplicate-key precedence divergence remains UNFIXED

The two runtimes still disagree on which occurrence of a duplicated required key wins: Python assigns
unconditionally in the parse loop, so the LAST occurrence wins; TypeScript guards with
`!parsed.has(key)`, so the FIRST occurrence wins. This change deliberately does not touch that
precedence, because converging it would change the reported result for real existing artifacts and so
contradicts this fix's additive requirement.

Measured at execution time: 165 artifacts carry two or more `EXIT_CODE:` lines and are reported
differently by the two runtimes. Execution also established that the divergence is WIDER than the
original framing: six further artifacts carry a single `EXIT_CODE:` line but a duplicated `Command:` or
`Timestamp:` line, and are likewise reported differently — one of them renders in TypeScript and is
dropped as unparseable in Python. Acceptance criteria AC10 and AC17, which assert zero cross-runtime
differences over single-`EXIT_CODE` artifacts, are therefore left UNCHECKED.

This defect is to be promoted separately via the potential-to-issue path, with its scope stated as
duplicate-REQUIRED-KEY precedence rather than duplicate-`EXIT_CODE` precedence alone.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
- [ ] Promote the duplicate-REQUIRED-KEY precedence divergence as its own bug
