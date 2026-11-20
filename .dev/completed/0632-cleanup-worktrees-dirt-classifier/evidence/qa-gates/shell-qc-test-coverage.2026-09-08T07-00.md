# Final QC — bash line coverage (kcov, measured in CI)

Timestamp: 2026-09-08T08-02

Task: [P8-T6] of `remediation-plan.2026-09-08T05-00.md`

Command: `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`

EXIT_CODE: 0

Run id: `34194469882`
Run URL: <https://github.com/drmoisan/drm-copilot/actions/runs/34194469882>
Event: `workflow_dispatch`
headSha: `ea1baef8aad811c6c9d6d12e32c8ab05f636ecaa`
Conclusion: `success`

## headSha reconciliation

[P8-T6]'s acceptance condition requires the recorded headSha to equal "the head SHA recorded
in P8-T5". [P8-T5] records two SHAs under distinct labels, so the referent is stated
explicitly here: it is **`PostCommitHeadSha`**, because the CI dispatch measures the tree that
[P8-T5] pushed, not the tree that existed before its commit.

| Label in [P8-T5] | Value | Equals this run's headSha |
|---|---|---|
| `PreCommitHeadSha` | `a226a1c59369544fc50ed96da6ebd9d35dfc4536` | no |
| `PostCommitHeadSha` | `ea1baef8aad811c6c9d6d12e32c8ab05f636ecaa` | **yes** |

## TAP figures from the run log

TAP plan line: `1..404`
Lines matching an `ok <n>` TAP result: 404
Lines matching a `not ok <n>` TAP result: 0

These agree with the local [P8-T3] figures, so the local stage and the CI stage enumerate the
same suite at this commit.

## Coverage headline, verbatim from the run log

```
Bash coverage (lines): 93.7%
```

`93.7` clears the uniform 85.0 floor with 8.7 points of margin, and is 0.8 points above the
`92.9` baseline recorded at [P0-T7].

The run log also carries three lines containing the string
`"Bash coverage (lines): NN.N%" summary.` These are docstring text emitted by the
missing-tool tests in `tests/shell/test_shell_qc_commands.bats`, not measurements. The
verbatim headline above is the single line carrying an actual percentage.

The run printed a `Bash coverage (lines):` line, so this is a real measurement rather than
the silent-zero path where `print_coverage_summary` can return 0 having printed nothing. A
run whose log printed no such line would be INCOMPLETE, not a pass, because the percentage
is the only failable observation.

## Why a CI dispatch rather than a local run

`kcov` has no local route in this worktree: `bash scripts/bash/shell-qc.sh test --coverage`
exits 127 with `kcov not installed; cannot run shell tests with coverage.` The dispatch
measures the pushed tree, and no local coverage invocation substitutes for it.

Output Summary: The dispatched run at `ea1baef8` concluded `success` with 404 of 404 tests
passing, 0 failures, and a repository-wide bash line coverage headline of `93.7%`. The
recorded headSha equals `PostCommitHeadSha` from [P8-T5]. Per-file figures are read from the
merged Cobertura report at [P8-T7].
