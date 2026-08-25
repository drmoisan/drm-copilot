# Write-Target Verification (P5-T1)

Timestamp: 2026-08-24T14-19

Task: [P5-T1]
Issue: #515
Branch: `bug/ruff-check-is-write-mode-and-exits-zero-after-fixing-515-r2`

Commands, in the order run:

1. `git diff --name-only origin/main...HEAD`
2. `git status --porcelain --untracked-files=all`

EXIT_CODE (1): 0
EXIT_CODE (2): 0

The second command is required because uncommitted work does not appear in the merge-base
diff, and because `git status --porcelain` without `--untracked-files=all` collapses an
untracked directory to a single entry. Neither command alone yields the full write-target
set; the union of the two does.

## Raw output 1 — `git diff --name-only origin/main...HEAD`

```text
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/issue.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/research/2026-08-23T21-05-ruff-write-mode-research.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/spec.md
```

Four paths, all under this feature's folder. These are the feature documents committed to
the branch before execution began.

## Raw output 2 — `git status --porcelain --untracked-files=all`

```text
 M docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md
 M pyproject.toml
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-git-baseline.2026-08-24T13-46.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-instructions-read.2026-08-24T13-45.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-format.2026-08-24T13-47.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-lint.2026-08-24T13-48.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-test-coverage.2026-08-24T13-52.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-typecheck.2026-08-24T13-50.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-ruff-config-state.2026-08-24T13-53.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/coverage-delta-verification.2026-08-24T14-17.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-format.2026-08-24T14-12.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-lint.2026-08-24T14-13.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-test-coverage.2026-08-24T14-16.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-typecheck.2026-08-24T14-14.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-qa-loop-single-pass.2026-08-24T14-18.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/lint-stage-manual-differential.2026-08-24T14-09.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/lint-stage-no-write.2026-08-24T14-06.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/fail-before-pass-after-ruff-config-alignment.2026-08-24T13-57.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/new-module-toolchain-precheck.2026-08-24T14-00.md
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/regression-ruff-config-alignment-suite.2026-08-24T14-03.md
?? tests/scripts/dev_tools/test_ruff_config_alignment.py
```

Twenty-one entries: two modifications and nineteen untracked additions. The
`--untracked-files=all` flag expanded the evidence subtree, which the plain form had
collapsed to the single entry `.../evidence/`.

## Derived union of the two outputs

Grouped by category:

**Repository files outside the feature folder — exactly two, both authorized:**

```text
pyproject.toml
tests/scripts/dev_tools/test_ruff_config_alignment.py
```

**Paths under `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/` — all authorized:**

```text
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/issue.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/research/2026-08-23T21-05-ruff-write-mode-research.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/spec.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-git-baseline.2026-08-24T13-46.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-instructions-read.2026-08-24T13-45.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-format.2026-08-24T13-47.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-lint.2026-08-24T13-48.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-test-coverage.2026-08-24T13-52.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-python-typecheck.2026-08-24T13-50.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/baseline/phase0-ruff-config-state.2026-08-24T13-53.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/coverage-delta-verification.2026-08-24T14-17.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-format.2026-08-24T14-12.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-lint.2026-08-24T14-13.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-test-coverage.2026-08-24T14-16.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-python-typecheck.2026-08-24T14-14.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/final-qa-loop-single-pass.2026-08-24T14-18.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/lint-stage-manual-differential.2026-08-24T14-09.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/lint-stage-no-write.2026-08-24T14-06.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/fail-before-pass-after-ruff-config-alignment.2026-08-24T13-57.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/new-module-toolchain-precheck.2026-08-24T14-00.md
docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/regression-testing/regression-ruff-config-alignment-suite.2026-08-24T14-03.md
```

The union is therefore exactly `pyproject.toml`,
`tests/scripts/dev_tools/test_ruff_config_alignment.py`, and paths under
`docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/`.
No path falls outside those three categories.

## Non-emptiness check

**The union contains both required repository write targets**, so it is neither empty nor
partial and cannot pass vacuously:

| Required path | Present in union | Source | Nature of the write |
| --- | --- | --- | --- |
| `pyproject.toml` | **yes** | output 2, ` M` | P2-T1 single-line deletion (`0 added, 1 deleted`, verified at P2-T2) |
| `tests/scripts/dev_tools/test_ruff_config_alignment.py` | **yes** | output 2, `??` | P1-T1 new module |

## Prohibited-path check

None of the four paths this plan forbids appears anywhere in either raw output or in the
union:

| Prohibited path | Present? |
| --- | --- |
| `.claude/rules/python.md` | **absent** |
| `.github/instructions/python-code-change.instructions.md` | **absent** |
| `scripts/dev_tools/atomic_executor/qc_runner_loop.py` | **absent** |
| `scripts/dev_tools/fix_all_branches_extra.py` | **absent** |

More broadly, no path under `.claude/`, `.github/`, `scripts/`, `src/`, or
`extensions/` appears in either output, and no file was created under
`docs/features/potential/`.

## Notes on paths deliberately absent from the union

- `artifacts/python/coverage.json` and `artifacts/python/lcov.info` — tool output written
  by P0-T6 and P4-T4. `artifacts/` is gitignored at `.gitignore:6`, so these are not
  repository writes and correctly do not appear.
- `.claude/state/python-batch-budget.default.json` — gitignored session state at
  `.gitignore:68`, created by session tooling and removed during the Phase 4 restart
  documented in the P4-T1 and P4-T4 artifacts. It is not a repository file and correctly
  does not appear in either output.
- Two further feature-folder paths are written after this snapshot was taken and are within
  the authorized third category: this artifact itself, and the P5-T2 artifact plus the
  acceptance-criteria check-off edit to `spec.md` (already present in the union via
  output 1).

Output Summary: **The union of the two commands is exactly `pyproject.toml`,
`tests/scripts/dev_tools/test_ruff_config_alignment.py`, and paths under
`docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/`.**
Both required repository write targets are present, so the union is non-empty and
non-partial. None of `.claude/rules/python.md`,
`.github/instructions/python-code-change.instructions.md`,
`scripts/dev_tools/atomic_executor/qc_runner_loop.py`, or
`scripts/dev_tools/fix_all_branches_extra.py` appears. Both raw outputs are reproduced
verbatim above. This satisfies spec acceptance criterion 7 and confirms the plan's scope
lock held.
