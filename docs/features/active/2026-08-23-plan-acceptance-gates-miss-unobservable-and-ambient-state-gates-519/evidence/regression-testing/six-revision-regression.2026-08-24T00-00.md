# Six-Revision Regression — [P5-T3] and [P5-T4]

Timestamp: 2026-08-26T13-19
Tasks: [P5-T3] (counts) and [P5-T4] (direction assertion)
Command: `poetry run python scripts/dev_tools/_tmp_plan_gate_regression_driver.py`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

The driver calls the shipped entry point `evaluate_plan_gates` with a real repository context built by the shipped `build_plan_gate_context`. It reimplements no predicate. It attributes an already produced finding to the rule that produced it by the fixed leading phrase each rule's frozen finding string carries, and it reads each revision's text from git object storage with the same `git show` commands [P5-T1] recorded.

The exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect. No pipe stands between the command and the capture.

## Verbatim driver output

```
commit      G7    G8   G8b    G9  total
e2aa6446     2     3     0     1  6
eff8f196     4     0     0     0  4
30414365     4     0     0     0  4
e913e0a9     4     0     0     0  4
ceacb5a5     4     0     0     0  4
5a8ede0f     1     0     0     0  1
```

## The six-by-four count table — twenty-four integers

| # | Commit | G7 | G8 | G8b | G9 | Total new-rule findings |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `e2aa6446` | 2 | 3 | 0 | 1 | **6** |
| 2 | `eff8f196` | 4 | 0 | 0 | 0 | **4** |
| 3 | `30414365` | 4 | 0 | 0 | 0 | **4** |
| 4 | `e913e0a9` | 4 | 0 | 0 | 0 | **4** |
| 5 | `ceacb5a5` | 4 | 0 | 0 | 0 | **4** |
| 6 | `5a8ede0f` | 1 | 0 | 0 | 0 | **1** |

Twenty-four integer counts, six rows by four rules. Per-revision totals, in authoring order: 6, 4, 4, 4, 4, 1.

## [P5-T4] — direction of the regression comparison

**The total new-rule finding count at commit `e2aa6446` is 6. The total at commit `5a8ede0f` is 1. 6 is strictly greater than 1, so the assertion holds: PASS.**

Both integers are quoted above and are read from the same driver run recorded verbatim in this artifact. The comparison is on the total across all four new rules, not on any single rule.

The comparison is not a waiver of anything: had it failed, this artifact would have recorded it as a FAIL and the outcome would have been remediation-required, with the corrective action being a revision of the rule predicates rather than a relaxation of this criterion. It did not fail.

## The findings behind the endpoint totals

These are reproduced so the two endpoint integers are auditable rather than merely asserted. Both lists come from the same driver, invoked in its detail mode, which prints the same findings the count mode counts.

### First revision `e2aa6446` — 6 findings

```
1. [P0-T3] write-mode command `poetry run ruff check .` rewrites tracked source and exits 0 after rewriting; the attributed task text carries none of its observation markers. Record an observation beyond the exit code.
2. [P5-T7] git diff span `git diff --exit-code -- tests/fixtures/blast_radius/conflict-path-overlap.json` carries no ref operand and no --cached flag; it compares the worktree against the index and passes vacuously once the change is committed. Anchor the diff to a ref.
3. [P5-T12] git diff span `git diff --name-only -- tests/fixtures/blast_radius` carries no ref operand and no --cached flag; it compares the worktree against the index and passes vacuously once the change is committed. Anchor the diff to a ref.
4. [P6-T4] git diff span `git diff --exit-code -- .claude/rules/plan-acceptance-gates.md .github` carries no ref operand and no --cached flag; it compares the worktree against the index and passes vacuously once the change is committed. Anchor the diff to a ref.
5. [P8-T2] write-mode command `poetry run ruff check .` rewrites tracked source and exits 0 after rewriting; the attributed task text carries none of its observation markers. Record an observation beyond the exit code.
6. [P2-T2] coverage command `poetry run pytest --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch tests/scripts/dev_tools/test_blast_radius_token_shapes.py` supplies no terminal reporter and the project addopts supplies none either, so no coverage table is printed. Add --cov-report=term-missing.
```

All three G8 findings are the unanchored `git diff` form the issue records as the defect that motivated this work: each compares the worktree against the index, so each passes vacuously once the change is committed. The single G9 finding is the coverage-argument form that collects data but prints no table, so its threshold could not be read.

### Final revision `5a8ede0f` — 1 finding

```
1. [P0-T10] write-mode command `npm run format` rewrites tracked source and exits 0 after rewriting; the attributed task text carries none of its observation markers. Record an observation beyond the exit code.
```

Every G8 and G9 finding of the first revision is gone by the final revision. The single residual finding is a G7 on the write-mode Prettier invocation, whose task text records no observation marker even in the final revision; that residual is examined by [P5-T5].

## Note on the non-monotonic G7 column

The G7 column reads 2, 4, 4, 4, 4, 1 rather than descending monotonically. This is recorded rather than smoothed, because the middle rise is real and is explained by the same mechanism the rule exists to detect.

At revision 1 the plan's `npm run format` task carried an observation marker and was exonerated, while two `ruff check` tasks did not and were reported. Revisions 2 through 5 restructured those tasks: the `npm run format` task lost its marker and a further `ruff check` task was added, taking the count to 4. Revision 6 then added observation markers to three of the four, leaving one. The intermediate rise therefore records a genuine intermediate regression in observability, not a rule artefact.

The plan's stated direction condition is on the endpoint totals, and those are 6 and 1. The intermediate column is reported here in full so the shape of the trajectory is visible rather than hidden behind the endpoints.

## Output Summary

The regression driver exited 0 and printed six rows of four integer counts. Twenty-four counts recorded; per-revision totals 6, 4, 4, 4, 4, 1 in authoring order. **[P5-T4] direction assertion PASSES: total at `e2aa6446` is 6, strictly greater than the total at `5a8ede0f` which is 1.** All three G8 findings and the single G9 finding of the first revision are absent from the final revision; one G7 finding remains at the final revision, on `npm run format` in [P0-T10].
