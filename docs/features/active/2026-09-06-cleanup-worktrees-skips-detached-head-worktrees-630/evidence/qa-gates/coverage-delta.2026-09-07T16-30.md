# Coverage Delta and Threshold Verification

Timestamp: 2026-09-07T16-30
Task: [P6-T5]

Both figures below were produced by the same instrument: the test step of
`.github/workflows/_shell-coverage.yml`, which runs `bash scripts/bash/shell-qc.sh test --coverage`
on `ubuntu-latest`. The baseline is [P0-T7] run `34136171946` against head sha `65a56cb9`; the
post-change figure is [P6-T4] run `34142466852` against head sha `12cc5766`.

## Aggregate line coverage

| Measurement | Value | Source |
|---|---|---|
| Baseline ([P0-T7]) | 92.9 | `evidence/remediation-baseline/bash-test-coverage.2026-09-07T15-00.md` |
| Post-change ([P6-T4]) | 94.2 | `evidence/qa-gates/final-bash-test-coverage.2026-09-07T16-30.md` |
| Signed delta | **+1.3** | |

The post-change aggregate of 94.2 is at or above the baseline of 92.9, so this cycle causes no
aggregate regression. It is also well above the 85.0 uniform line-coverage floor stated in
`.claude/rules/quality-tiers.md`, which applies to every tier T1 through T4.

## Per-file line rate, `scripts/bash/cleanup_worktrees_detached_lib.sh`

| Measurement | Value | Source |
|---|---|---|
| Baseline ([P0-T7]) | 0.806 | `cov.xml` of run `34136171946` |
| Post-change ([P6-T4]) | 1.000 | `cov.xml` of run `34142466852` |
| Signed delta | **+0.194** | |

The post-change per-file rate of 1.000 is at or above 0.85, which is this cycle's gate.

It is also at or above the plan's stated target of 0.95. Because the target was met, the conditional
clause in the [P6-T5] acceptance — enumerate every line of that file still reported uncovered — does
not apply. The target being met is stated here explicitly rather than the clause being omitted
silently.

For context, the 20 lines of that file reported with `hits="0"` at the [P0-T7] baseline were:

```
90, 91, 116, 117, 120, 121, 127, 128, 131, 132, 141, 142, 146, 147, 152, 153, 160, 190, 212, 213
```

At a post-change line rate of 1.000, none of those lines remains uncovered. That set includes
`:190`, which the plan's enumeration of ten regions did not target; it is covered as a side effect
of the cases added by Phases 2 and 4 rather than by a case written for it.

## Branch coverage

No branch-coverage value is reported. kcov does not measure branch coverage for bash, so the
`branch-rate="1.0"` attributes carried by every entry in the Cobertura report are fixed placeholders
rather than measurements. Reporting a number derived from them would be fabrication. This matches
the exemption stated in `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`:
the branch threshold does not apply to bash because the tooling cannot evaluate it. The exemption is
a threshold exemption only and does not remove any file from the coverage denominator.

## Coverage-denominator confirmation

`scripts/bash/cleanup_worktrees_detached_lib.sh` is inside the kcov include pattern. The pattern is
defined at `scripts/bash/shell_qc_lib.sh:335-336`:

```
	local include_pattern="$repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash"
	local exclude_pattern="$repo_root/tests"
```

The file resolves under `$repo_root/scripts`, which line 335 includes, and does not resolve under
`$repo_root/tests`, which line 336 excludes. The file is therefore in the measured denominator, and
its reported rate of 1.000 is a measurement over a non-empty line set rather than a vacuous result
from an excluded file. No file was excluded from the denominator by this cycle and the include
pattern was not narrowed.

Output Summary: aggregate line coverage moved 92.9 to 94.2, a signed delta of +1.3, which is at or
above the 92.9 baseline and far above the 85.0 uniform floor. The per-file line rate for
`scripts/bash/cleanup_worktrees_detached_lib.sh` moved 0.806 to 1.000, a signed delta of +0.194,
which is at or above this cycle's 0.85 gate and at or above the plan's 0.95 target, so no
uncovered-line enumeration is required. No branch-coverage figure is reported because kcov does not
measure branch coverage for bash. The file is confirmed inside the kcov include pattern at
`scripts/bash/shell_qc_lib.sh:335-336`.
