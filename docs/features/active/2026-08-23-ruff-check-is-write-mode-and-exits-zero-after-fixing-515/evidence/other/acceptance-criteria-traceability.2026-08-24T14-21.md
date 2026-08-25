# Acceptance-Criteria Traceability (P5-T2)

Timestamp: 2026-08-24T14-21

Task: [P5-T2]
Issue: #515
Work Mode: full-bug
AC source: `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/spec.md`, section `## Acceptance Criteria` (10 criteria)

Per the `acceptance-criteria-tracking` skill, work mode `full-bug` resolves the acceptance
criteria source to `spec.md` only. `user-story.md` is expected to be absent for this mode
and is absent.

Command: `sed -n '249,262p' docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/spec.md`

EXIT_CODE: 0

Verbatim output confirming zero unchecked boxes remain in the `## Acceptance Criteria`
section (truncated at 60 columns for readability; the checkbox state is the load-bearing
part):

```text
## Acceptance Criteria

- [x] The `[tool.ruff]` table in `pyproject.toml` no longer
- [x] `show-fixes = true` remains present in the `[tool.ruff
- [x] Neither `ruff.toml` nor `.ruff.toml` exists at the rep
- [x] The Ruff lint step in `.github/workflows/_quality-chec
- [x] `poetry run pytest tests/scripts/dev_tools/test_ruff_c
- [x] Fail-before evidence is recorded: a run of `test_ruff_
- [x] `git diff --name-only` against the merge base lists ex
- [x] The lint stage performs no write: a working-tree statu
- [x] The manual verification required by `issue.md` line 98
- [x] The seven-stage toolchain in `.claude/rules/general-co

## Risks & Mitigations
```

All ten boxes read `- [x]`. The section is bounded by its own heading and the following
`## Risks & Mitigations` heading, so the enumeration is complete.

## Out-of-scope boxes left unchanged

The unchecked boxes under `Impact / Severity` are **not** acceptance criteria and were not
modified. Confirmed unchanged after the edit:

```text
Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low
```

The `- [x] High` box was already checked by the spec author and remains so; the three
unchecked severity boxes remain unchecked. The two `Logs / Screenshots` and three
`Test Strategy` seeded boxes elsewhere in `spec.md` were likewise not touched.

## Traceability table — 10 rows, none unmapped

| # | Acceptance criterion (abbreviated) | Satisfying task(s) | Evidence artifact path |
| --- | --- | --- | --- |
| 1 | Fix mode removed from `[tool.ruff]`; `test_ruff_config_does_not_enable_fix_mode` passes post-change | P2-T1, P3-T1 | `evidence/regression-testing/regression-ruff-config-alignment-suite.2026-08-24T14-03.md` |
| 2 | `show-fixes = true` retained; `test_ruff_config_retains_show_fixes` passes | P1-T1, P2-T2, P3-T1 | `evidence/regression-testing/regression-ruff-config-alignment-suite.2026-08-24T14-03.md` |
| 3 | No root `ruff.toml` or `.ruff.toml`; `test_no_standalone_ruff_config_at_repository_root` passes | P1-T1, P3-T1 | `evidence/regression-testing/regression-ruff-config-alignment-suite.2026-08-24T14-03.md` |
| 4 | CI Ruff lint step still invoked; `test_quality_checks_workflow_still_runs_a_ruff_lint_step` passes | P1-T1, P3-T1 | `evidence/regression-testing/regression-ruff-config-alignment-suite.2026-08-24T14-03.md` |
| 5 | Module collects exactly four tests and reports 4 passed, 0 failed, 0 errors, recorded under `evidence/regression-testing/` | P1-T1, P3-T1 | `evidence/regression-testing/regression-ruff-config-alignment-suite.2026-08-24T14-03.md` |
| 6 | Fail-before and pass-after in a single artifact, failing run declaring its non-zero expectation | P1-T2, P3-T2 | `evidence/regression-testing/fail-before-pass-after-ruff-config-alignment.2026-08-24T13-57.md` |
| 7 | Merge-base diff lists exactly the authorized paths and none of the prohibited ones | P5-T1 | `evidence/other/write-target-verification.2026-08-24T14-19.md` |
| 8 | Lint stage performs no write; before/after status snapshots byte-identical, under `evidence/qa-gates/` | P3-T3, P4-T2 | `evidence/qa-gates/lint-stage-no-write.2026-08-24T14-06.md` and `evidence/qa-gates/final-python-lint.2026-08-24T14-13.md` |
| 9 | Manual differential on scratch inputs outside the repository, with `ExpectedExitCode` declared | P3-T4 | `evidence/qa-gates/lint-stage-manual-differential.2026-08-24T14-09.md` |
| 10 | Seven-stage toolchain completes in a single pass with no stage having changed a file | P4-T1, P4-T2, P4-T3, P4-T4, P4-T6 | `evidence/qa-gates/final-qa-loop-single-pass.2026-08-24T14-18.md`, supported by `final-python-format.2026-08-24T14-12.md`, `final-python-lint.2026-08-24T14-13.md`, `final-python-typecheck.2026-08-24T14-14.md`, `final-python-test-coverage.2026-08-24T14-16.md` |

All evidence paths are relative to
`docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/`.
Every row maps to at least one plan task and at least one evidence artifact; no row is left
unmapped.

## Key result per criterion

1. `git diff --numstat -- pyproject.toml` reported `0 1` (0 added, 1 deleted); the test
   passes post-change after failing pre-change.
2. `show-fixes = true` remains at the `[tool.ruff]` table; the test passed both before and
   after the deletion, so retention is demonstrated rather than coincidental.
3. Neither root filename exists; the test checks both the dotted and undotted spellings.
4. `.github/workflows/_quality-checks.yml` still runs `poetry run ruff check` with
   `continue-on-error: false`; the test asserts on the invocation, not the step name.
5. `collected 4 items` and `4 passed in 0.05s`, exit code 0, with all four node IDs
   enumerated individually.
6. Fail-before: `1 failed, 3 passed`, `EXIT_CODE: 1` with `ExpectedExitCode: 1`.
   Pass-after: `1 passed`, `Pass-After EXIT_CODE: 0`. Both in one artifact, with the
   fail-before headline rows first in the file.
7. Union is exactly `pyproject.toml`,
   `tests/scripts/dev_tools/test_ruff_config_alignment.py`, and feature-folder paths; all
   four prohibited paths absent; both required targets present.
8. Both snapshot pairs byte-identical, verified by `cmp` exit 0 and matching SHA-256
   `36dbc1c0...0a0f3e`; lint exit code 0 with 0 findings.
9. Both scratch runs exit 1; the fixable input reports `F401 [*]` with
   `[*] 1 fixable with the \`--fix\` option.` and no `Fixed` line; all four before/after
   hashes identical. Settings resolution confirmed to come from the repository
   `pyproject.toml` with `fix = false`.
10. P4-T1 through P4-T4 all exit 0; entry and exit snapshots byte-identical with matching
    digest. The Phase 4 restart caused by unrelated filed issue #510 is disclosed in the
    P4-T1, P4-T4, and P4-T6 artifacts.

Output Summary: **All 10 acceptance criteria in the `## Acceptance Criteria` section of
`spec.md` are marked `- [x]`; the section contains zero unchecked boxes.** The 10-row
traceability table above maps each criterion to its satisfying plan task(s) and to the
evidence artifact path that substantiates it, with no row unmapped. The unchecked boxes
under `Impact / Severity` are not acceptance criteria, were outside this task's scope, and
remain unchanged.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/spec.md`
- Total AC items: 10
- Checked off (delivered): 10
- Remaining (unchecked): 0
- Items remaining: none
