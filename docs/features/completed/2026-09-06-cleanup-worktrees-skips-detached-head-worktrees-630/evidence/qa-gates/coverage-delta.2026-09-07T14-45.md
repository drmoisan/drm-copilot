# QA Gate — Bash Coverage Delta and Threshold Verification (Issue #630)

Timestamp: 2026-09-07T14-45

Task: [P7-T5]

Command: none. This task records no new command. It reads the two numeric coverage values
already captured by [P0-T6] and [P7-T3], and re-derives two source lines from
`scripts/bash/shell_qc_lib.sh` with `grep`. The `grep` re-derivation is reproduced below.

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

[P7-T5] names no command in the plan's `wsl -d Ubuntu -- bash -lc '...'` wrapper form, so no
wrapper substitution applies to this task. The two coverage figures it reads were both
produced under the substitution recorded in the [P0-T6] and [P7-T3] artifacts: that wrapper
is refused by the worktree-isolation guard and `kcov` has no local route, so both runs were
dispatched to the CI workflow `.github/workflows/_shell-coverage.yml`, whose step executes
`bash scripts/bash/shell-qc.sh test --coverage` on `ubuntu-latest`. Both figures therefore
come from the same instrument and are directly comparable. The plan's stale worktree path
`agent-a06652a3fd875c703` is wrong; the real worktree is `agent-adf4f49cbc48904be`.

## Line Coverage: Baseline, Post-Change, Delta

| Measure | Value | Source |
|---|---|---|
| Baseline line coverage | **93.6%** | [P0-T6], `evidence/baseline/bash-test-coverage.2026-09-07T14-30.md`, run 34113725852 against `epic/cleanup-merged-worktrees-hardening-integration` at `a36b6dca` |
| Post-change line coverage | **92.9%** | [P7-T3], `evidence/qa-gates/final-bash-test-coverage.2026-09-07T14-45.md`, run 34118811332 against the feature branch at `fdd0fecf` |
| Signed delta | **-0.7** | 92.9 minus 93.6 |

**Threshold.** The post-change value of **92.9 is at least 85.0**, the uniform line-coverage
floor stated in `.claude/rules/quality-tiers.md` ("Line coverage: >= 85%", uniform across
T1-T4). The threshold is therefore **met**, with 7.9 percentage points of margin.

## The Delta Is Negative, and Why

Aggregate line coverage **fell by 0.7 percentage points**. This is a decrease, not a neutral
or immaterial movement, and it is recorded as such.

The cause is identifiable from the per-file figures below. The new library
`scripts/bash/cleanup_worktrees_detached_lib.sh` is **301 lines** ([P3-T8],
`evidence/qa-gates/detached-lib-line-count.2026-09-07T14-30.md`) and is itself covered at
**80.6%**, which is below the 85.0 aggregate floor. It is large enough relative to the
measured corpus to move the total: the file is the single largest addition to the coverage
denominator in this change set, and every other measured file in the `cleanup-worktrees`
group sits at or above 92.1%. A new file covered below the aggregate rate necessarily pulls
the aggregate down, and 0.7 points is the size of that pull.

**What the gate is, and what it is not.** The gate AC24 defines is the **aggregate headline**
printed by the line beginning `Bash coverage (lines):`, and that gate is **met** at 92.9,
above the 85.0 floor. The per-file figure of 80.6% for the new library is recorded here so a
reviewer can judge whether that library needs additional test cases. It is **not** measured
against a per-file gate, because this repository defines no per-file coverage threshold; no
claim is made here that 80.6% passes or fails such a gate.

## No Branch-Coverage Value Is Reported

**No branch-coverage value is reported for this change set, and none is asserted.**

`kcov` does not measure branch coverage for bash in any of its output formats. Because the
measurement does not exist, no branch-coverage gate applies to bash. This is the exemption
stated in `.claude/rules/shell.md` and repeated in `.claude/rules/quality-tiers.md` and
`.claude/rules/general-unit-test.md`: the >= 75% branch threshold applies only to languages
whose coverage tooling measures branch coverage, and PowerShell (Pester) and bash (kcov) are
named as the exceptions.

The Cobertura report the run uploads carries a `branch-rate="1.0"` attribute on every entry,
including the overall element and each of the per-file elements listed below. That value is
**kcov's fixed placeholder, not a measurement**. It is identical for every file regardless of
that file's branching structure, so it carries no information and is not read as a branch
figure here. Recording a branch-coverage number from it would be a fabricated value.

The exemption is a capability limit on an unevaluable threshold. It does not permit excluding
any file from measurement: every bash production file remains in the line-coverage
denominator under the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`.

## The New Library Is Inside the kcov Include Pattern

`scripts/bash/cleanup_worktrees_detached_lib.sh` is **inside** the include pattern and is
**not** matched by the exclude pattern, so it is measured rather than silently omitted from
the denominator.

The two lines are re-derived from the current tree with
`grep -nE "local (include|exclude)_pattern=" scripts/bash/shell_qc_lib.sh`, which prints:

```
335:	local include_pattern="$repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash"
336:	local exclude_pattern="$repo_root/tests"
```

Both lines sit inside `run_test_coverage`, which begins at `scripts/bash/shell_qc_lib.sh:294`
(re-derived with `grep -n run_test_coverage scripts/bash/shell_qc_lib.sh`). The include
pattern is the three-element list `$repo_root/tools`, `$repo_root/scripts`, and
`$repo_root/.claude/lib/bash`; the exclude pattern is the single element `$repo_root/tests`.

The new library's path is `scripts/bash/cleanup_worktrees_detached_lib.sh`, which is under
`$repo_root/scripts` — the second element of the include pattern — and is not under
`$repo_root/tests`, so nothing excludes it. This is confirmed empirically as well as
structurally: the file appears as its own entry in the uploaded Cobertura report with a
measured `line-rate`, which it could not do if the include pattern had missed it.

## Per-File Line Coverage from the Uploaded Report

Read from `shell-coverage/cov.xml` in run 34118811332 (and the identical
`shell-coverage/kcov-merged/cov.xml`):

| File | Line coverage | Note |
|---|---|---|
| overall (`line-rate="0.929"`) | **92.9%** | the aggregate the AC24 gate reads; meets the 85.0 floor |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | **80.6%** | the new 301-line library added by this feature |
| `scripts/bash/cleanup_worktrees_lib.sh` | 93.3% | |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 93.3% | |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 92.1% | |
| `scripts/bash/cleanup-worktrees.sh` | 100.0% | |

Every entry carries `branch-rate="1.0"`, the placeholder described above.

Output Summary: Baseline line coverage is **93.6** ([P0-T6]); post-change line coverage is
**92.9** ([P7-T3]); the signed delta is **-0.7**. The post-change value **is at least 85.0**,
the uniform line-coverage floor in `.claude/rules/quality-tiers.md`, so the threshold is
**met**. The delta is a genuine decrease: the new 301-line library
`scripts/bash/cleanup_worktrees_detached_lib.sh` is covered at **80.6%**, below the 85.0
aggregate floor, and is large enough to move the total. The gate AC24 defines is the
aggregate headline, which is met at 92.9; the per-file figure is recorded so a reviewer can
judge whether the new library needs more cases, and no per-file gate exists in this
repository against which to pass or fail it. **No branch-coverage value is reported**,
because kcov does not measure branch coverage for bash and no bash branch-coverage gate
applies (`.claude/rules/shell.md`); the `branch-rate="1.0"` attributes in the report are
placeholders, not measurements. The new library **is inside the kcov include pattern**,
confirmed at `scripts/bash/shell_qc_lib.sh:335-336` and by its own measured entry in the
report.
