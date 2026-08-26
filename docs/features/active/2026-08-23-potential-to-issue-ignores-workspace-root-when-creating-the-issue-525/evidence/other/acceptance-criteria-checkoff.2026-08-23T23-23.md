# Acceptance-Criteria Check-Off Mapping ([P6-T8])

Timestamp: 2026-08-25T10-14
Command: sed -n '/^## Acceptance Criteria$/,/^## Risks/p' spec.md | grep -c "^- \[x\]"
EXIT_CODE: 0

AC source: `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/spec.md`, section `## Acceptance Criteria`.
AC source resolution: work mode `full-bug` (persisted marker `- Work Mode: full-bug` in `issue.md`
and in `spec.md`), which per `acceptance-criteria-tracking` makes `spec.md` the sole AC source.
`user-story.md` is intentionally absent and is not an AC source under this mode.

## Output Summary

The verification command reports **17 checked boxes**; the companion count of `^- \[ \]` in the same
section reports **0 unchecked boxes**. Before this task the same two counts were 0 and 17. All 17
criteria are checked, and each was checked only after concrete passing evidence was named.

| # | Criterion (abbreviated) | Satisfying task(s) | Evidence artifact | Concrete result |
| --- | --- | --- | --- | --- |
| 1 | Issue-creation vector carries explicit `--repo <owner/name>` resolved from `workspace_root`, asserted at the injected CLI boundary with no live GitHub call | [P1-T2], [P3-T1] | `evidence/regression-testing/pass-after.2026-08-23T23-23.md` | Test `binds the repo selector into the issue create vector` passes (run B, EXIT_CODE 0). Fail-before recorded in `p1-t2-gh-client.2026-08-23T23-23.md` |
| 2 | Label-create recovery call and issue-view call carry the same selector | [P1-T2], [P3-T2] | `evidence/regression-testing/pass-after.2026-08-23T23-23.md` | Tests `binds the repo selector into the label create vector` and `binds the repo selector into the issue view vector` pass (run B, EXIT_CODE 0) |
| 3 | Re-created issue on the missing-label recovery leg carries the same selector as the initial attempt | [P4-T1] | `evidence/regression-testing/pass-after.2026-08-23T23-23.md` | Test `carries the same repo selector on the missing-label recovery retry` passes (run B, EXIT_CODE 0) |
| 4 | Slug resolution runs against the checkout at the resolved `workspace_root`, asserted through a seam recording the workspace value; recorded value equals the supplied root and is not the process cwd | [P1-T1], [P1-T3], [P3-T4] | `evidence/regression-testing/pass-after.2026-08-23T23-23.md` | Tests `returns the nameWithOwner slug and runs with cwd set to the workspace root` (run A) and `resolves the target repository from a workspace root that differs from the process working directory` (run C) pass, both EXIT_CODE 0 |
| 5 | With no repository binding, the three vectors are byte-identical to their pre-change form | [P4-T2] | `evidence/regression-testing/pass-after.2026-08-23T23-23.md` | Test `leaves the three vectors unchanged when no repo is supplied` passes (run B, EXIT_CODE 0) |
| 6 | Same-repository promotion yields unchanged summary, `destination_path`, and `artifacts`, echoes that checkout's slug, and every pre-existing assertion passes with unmodified expected values | [P1-T4], [P3-T5], [P4-T3] | `evidence/regression-testing/pass-after.2026-08-23T23-23.md`, `evidence/other/write-set-diff-audit.2026-08-23T23-23.md` | Test `resolves the target repository when the workspace root matches the process working directory` passes (run C). 130/130 tests pass across the 9 matched suites. The branch diff of the two seam-only test files removes zero `expect(` lines; every removed line is a helper moved verbatim into a `-test-support.ts` sibling |
| 7 | Result exposes the resolved slug snake-cased on the MCP surface, verified through the full projection chain rather than only at the service-call return | [P3-T7], [P4-T4] | `evidence/qa-gates/ts-test-coverage.2026-08-23T23-23.md` | Test `projects the target repository onto the potential to issue MCP result` passes inside the 2677/2677 full-suite run (EXIT_CODE 0), dispatching the tool against a mocked service rather than reading the unexported helper |
| 8 | The field is optional on the shared execution-result contract; other tools' results are unchanged with the field absent | [P3-T6], [P4-T5] | `evidence/qa-gates/ts-typecheck.2026-08-23T23-23.md`, `evidence/qa-gates/ts-test-coverage.2026-08-23T23-23.md` | Test `omits the target repository key for tools that resolve none` passes; `typecheck` reports 0 diagnostics, which is the gate on the property being optional (a required property would break every other tool's result construction) |
| 9 | Unresolvable slug fails with an explicit error naming the `workspace_root`; no `--repo`-less invocation and no implicit-resolution fallback | [P2-T1], [P2-T3], [P3-T8] | `evidence/regression-testing/pass-after.2026-08-23T23-23.md` | Tests `names the workspace root in the thrown message` (run A) and `fails closed without creating an issue or moving the record when the slug cannot be resolved` (run C) pass, both EXIT_CODE 0 |
| 10 | On resolution failure no issue-creation invocation is made and the record is not moved, asserted against the recording CLI fake and the in-memory filesystem fake | [P3-T8] | `evidence/regression-testing/pass-after.2026-08-23T23-23.md` | Test `fails closed without creating an issue or moving the record when the slug cannot be resolved` passes (run C, EXIT_CODE 0); it asserts zero recorded issue-creation invocations and the record still at its original path |
| 11 | Resolver unit tests cover success, no `origin` remote, non-zero exit, empty output, unparseable output, non-object payload, and missing or non-string owner/name field | [P1-T1], [P2-T2], [P2-T3] | `evidence/regression-testing/pass-after.2026-08-23T23-23.md` | Run A: `Test Suites: 1 passed` / `Tests: 9 passed, 9 total` on `repo-slug.test.ts`, EXIT_CODE 0. The nine are the success test, the seven enumerated failure conditions, and the message-content test |
| 12 | The client docstring no longer asserts byte-identical argument vectors with the Python sibling and states the divergence and its reason | [P3-T3] | this artifact | `git grep -n -F "are byte-identical to the Python source" -- extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts` exits **1** (zero matches), re-run at [P6-T8] time. The `GH_NOT_FOUND_MESSAGE` docstring's separate, still-true parity claim was left intact as the task required |
| 13 | The Python promotion module and its three dedicated pytest modules are unmodified in the branch diff | [P6-T6] | `evidence/other/write-set-diff-audit.2026-08-23T23-23.md` | Pattern `_to_issue.py` matches **0** paths in `git diff --name-only origin/main...HEAD`; `^scripts/` matches 0 and `^tests/` matches 0, so no Python file is touched at all |
| 14 | No file under the feature-promotion-lifecycle skill, no bundled copy, no file under `.claude/rules/`, and no tool-definition module appears in the branch diff | [P6-T6] | `evidence/other/write-set-diff-audit.2026-08-23T23-23.md` | Patterns `promotion-lifecycle`, `resources/`, `[.]claude/rules/`, `^[.]claude/`, `tool-definitions`, and `^[.]github/` each match **0** paths |
| 15 | Per-changed-file thresholds of 85% line and 75% branch are configured for and met by every changed extension source file, including the new resolver | [P4-T6] | `evidence/other/coverage-delta.2026-08-23T23-23.md`, `evidence/qa-gates/ts-test-coverage.2026-08-23T23-23.md` | Three entries added at 85/75; `mcp-tools.ts` already carried an 85/75 entry. Measured: `gh-client.ts` 100.00/81.82, `repo-slug.ts` 100.00/100.00, `potential-to-issue-service-call.ts` 100.00/85.00, `mcp-tools.ts` 94.14/86.67 — all four clear both floors. `test:coverage` EXIT_CODE 0 is the mechanical confirmation. See the note below on the fifth changed file |
| 16 | New and updated tests create no temporary files, mock the child-process boundary, and inject the CLI path lookup, so the suite passes with no network and no real CLI execution | [P1-T1], [P3-T4], [P4-T3] | `evidence/qa-gates/ts-test-coverage.2026-08-23T23-23.md` | Search for `mkdtemp`, `os.tmpdir`, `tmpdir()`, and `fs.writeFileSync` across the four new test/support modules exits **1** (zero matches). `extension.potential-to-issue.test.ts` registers `jest.mock("node:child_process", ...)`. `repo-slug.test.ts` injects `ghPathLookup: () => GH_PATH` at every call site. Settled Design Decision 7 keeps the default resolver from performing a PATH probe. 2677/2677 tests pass, EXIT_CODE 0 |
| 17 | The full seven-stage toolchain completes without errors in a single pass | [P6-T1] through [P6-T4] | `evidence/qa-gates/ts-format.*.md`, `ts-lint.*.md`, `ts-typecheck.*.md`, `ts-test-coverage.*.md` | Four stages ran, all EXIT_CODE 0, in one uninterrupted pass with no restart. Three stages have no configured runner; see the stage table below |

## Criterion 17 — stage-by-stage disposition

`extensions/drm-copilot/package.json` declares exactly these quality-gate scripts: `format`, `lint`,
`typecheck`, `test`, `test:unit`, and `test:coverage`. There is no dependency-cruiser script, no
contract or schema-diff script, and no integration-test script.

| Stage | Runner | Result |
| --- | --- | --- |
| 1. Formatting | `npm --prefix extensions/drm-copilot run format` | EXIT_CODE 0; 405 files processed, 0 rewritten |
| 2. Linting | `npm --prefix extensions/drm-copilot run lint` | EXIT_CODE 0; 0 errors, 0 warnings |
| 3. Type checking | `npm --prefix extensions/drm-copilot run typecheck` | EXIT_CODE 0; 0 diagnostics |
| 4. Architecture-boundary tests | none | **n/a — no configured runner in `extensions/drm-copilot/package.json`** |
| 5. Unit tests | `npm --prefix extensions/drm-copilot run test:coverage` | EXIT_CODE 0; 197/197 suites, 2677/2677 tests |
| 6. Contract / schema compatibility checks | none | **n/a — no configured runner in `extensions/drm-copilot/package.json`** |
| 7. Integration tests | none | **n/a — no configured runner in `extensions/drm-copilot/package.json`** |

**Single-pass confirmation.** The four runnable stages executed in the mandated order — formatting,
linting, type checking, testing in coverage mode — and every one exited 0 on its first execution.
[P6-T1] rewrote zero files, so the restart condition in the Phase 6 preamble was never triggered and
the phase did not restart. This is a single clean pass in the sense the criterion requires, across
every stage the repository has a runner for.

The criterion is recorded as satisfied on that basis. It is not a claim that architecture-boundary,
contract, and integration suites exist and passed; those three stages have no runner to execute, and
their absence is a pre-existing property of this package, not a gap introduced by this change.

## Note on criterion 15 and the fifth changed file

Five extension source files changed. Four carry a per-file threshold entry and meet it, as tabulated
above. The fifth, `src/repo-automation-service-contract.ts`, carries no entry and measures 0.00% on
both metrics. This is correct and is not an unmet threshold:

- The file consists solely of `interface` and re-exported `type` declarations with no executable
  behavior, so its declarations are erased at transpile time and it can never report non-zero
  executable coverage.
- `.claude/rules/general-unit-test.md` permits interface/type-only modules with no executable
  behavior to be omitted from threshold measurement, and states this is a clarification that lowers
  no threshold. The file remains inside `collectCoverageFrom`, so it is not excluded from the
  coverage denominator.
- The spec's own `Constraints` section pre-authorizes this: "An interface-only contract file is
  already documented as excluded from the threshold gate and needs no entry."
- The pre-existing inline comment in `jest.config.cjs` recording the omission was extended by
  [P4-T6] with a second comment confirming the omission still holds after the optional
  `targetRepository` property was added, since an interface property declaration emits no executable
  statement.

## Check-Off Protocol Compliance

- Only criterion text prefixes changed: `- [ ]` to `- [x]`. No criterion's wording was altered.
- No criterion was added or removed; the section held 17 items before and holds 17 after.
- Each criterion was checked only after the evidence named in its row was produced and read.
- The replacement was verified as scoped: before the edit, `spec.md` contained exactly 17 occurrences
  of the unchecked-box token document-wide and 17 within the `## Acceptance Criteria` section, so no
  checkbox outside the AC section could have been affected.
