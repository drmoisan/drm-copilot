# QA Gate — RI-3 Local Shell Pre-Check (post-edit)

Timestamp: 2026-08-10T21-55
Issue: #462
Task: [P4-T3] (pre-checks the [P4-T1] and [P4-T2] edits)
Target files: `scripts/bash/shell_qc_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh`
State: post-edit (both file-wide SC2015 suppressions deleted, all eight sites rewritten)

## Command 1 — shfmt diff mode

Command: `shfmt -d scripts/bash/shell_qc_lib.sh scripts/bash/cleanup_worktrees_lib.sh`

EXIT_CODE: 0

Output Summary: No diff. Both rewritten files already match shfmt default formatting; no `shfmt -w`
pass was needed and no re-run was required.

## Command 2 — shellcheck at style severity

Command: `shellcheck -S style scripts/bash/shell_qc_lib.sh scripts/bash/cleanup_worktrees_lib.sh`

EXIT_CODE: 0

Output Summary: No findings, at the most inclusive severity level, with **no suppression of any
scope present in either file**.

## Supplementary — syntax check

`bash -n scripts/bash/shell_qc_lib.sh` -> exit 0
`bash -n scripts/bash/cleanup_worktrees_lib.sh` -> exit 0

## Change Summary

| File | Suppression removed | Sites rewritten | Lines (post-edit, cap 500) |
| --- | --- | --- | --- |
| `scripts/bash/shell_qc_lib.sh` | file-wide `# shellcheck disable=SC2015` at pre-edit line 13, plus its four-line justification block and the `#` separator | 7 (pre-edit lines 92, 115, 191, 197, 247, 347, 356) | 379 |
| `scripts/bash/cleanup_worktrees_lib.sh` | file-wide `# shellcheck disable=SC2015` at pre-edit line 16, plus its four-line justification block | 1 (pre-edit line 479) | 479 |

Post-edit assertions:

- `grep -n "disable=SC2015" <file>` -> no match (exit 1) for both files.
- `grep -n "shellcheck disable" <file>` -> no match (exit 1) for both files. **No replacement
  suppression of any scope was added.**
- `grep -nE '&&.*\|\| true' <file>` -> no match (exit 1) for both files.
- Both files remain under the 500-line cap.

## Protected Lines — confirmed untouched

`scripts/bash/shell_qc_lib.sh` pre-edit lines 263 and 361 are the `|| rc=$?`-family exit-code
capture that `.claude/rules/shell.md` lines 81-83 genuinely mandates. They are load-bearing under
`set -e` and are NOT SC2015 sites. Both retain their `|| true` unmodified and now sit at post-edit
lines 267 and 369:

```
267:	match=$(grep -oE "line-rate=[\"'][0-9.]+[\"']" "$cov_xml" 2>/dev/null | head -n1) || true
369:			cp -f "$out_dir/kcov-merged/cov.xml" "$out_dir/cov.xml" || true
```

Verified by `git diff -U0 -- scripts/bash/shell_qc_lib.sh`: every removed line containing `|| true`
is one of the eight SC2015 sites or one of the two deleted justification comment lines. Neither
protected line appears as a removed line. The acceptance pattern `grep -nE '&&.*\|\| true'` is
deliberately written so that it does not match these two capture sites.

## Rewrite Form and shfmt Version Selection

The sites were rewritten in the expanded multi-line `if` form:

```bash
if [[ -d $root ]]; then
	roots+=("$root")
fi
```

rather than the single-line `if <test>; then <action>; fi` form given as the example in P4-T1. Both
forms were probed against local shfmt 3.12.0 and both are stable (`shfmt -d` exit 0, no diff). CI
pins shfmt 3.8.0, which may expand the single-line form; it cannot join a multi-line `if` onto one
line. The expanded form is therefore stable under both versions and is exactly the output the plan
directs the executor to accept if shfmt expands ("If shfmt expands the single-line `if` form, accept
its output"). Choosing it up front removes a predictable P5-T3 dispatch failure without any semantic
difference. Semantics are unchanged either way: the `|| true` existed solely to keep a false test
from aborting under `set -e`, and an `if` whose condition is false does not trigger `set -e`, so the
guard becomes unnecessary rather than relocated.

## Mandatory Insufficiency Statement

**This clean local run is a pre-check only and is NOT sufficient evidence for RI-3.**

Local shellcheck is version 0.11.0. It reports zero findings on these files **even on the unfixed
code with the suppressions removed** (verified at P0-T3 against the pre-edit files, exit 0, no
output at `-S style`). It therefore cannot distinguish the unfixed code from the fixed code, and its
clean result carries no discriminating signal for RI-3.

The CI runner installs the apt-packaged shellcheck, an older version that **did** flag the original
`A && B || true` sites — that version divergence is why the finding appeared only in CI, and why the
suppressions were added there. Per `.claude/rules/shell.md` lines 72-77, CI versions are canonical
and local disagreement defers to CI.

The authoritative RI-3 verification is the P5-T3 dispatch of `_shell-coverage.yml`, whose
`Run shell-qc check (shfmt diff + shellcheck)` step exercises the apt-packaged shellcheck against
the rewritten files with no suppression present. This artifact records only that the rewrite
introduces no local formatting or syntax regression.

Output Summary: `shfmt -d` exit 0 with no diff; `shellcheck -S style` exit 0 with no findings;
`bash -n` exit 0 on both files. Both file-wide suppressions are gone, all eight sites are rewritten
as `if` statements, no replacement suppression exists, and the two protected `|| rc=$?`-family
capture lines are untouched. Explicitly insufficient as RI-3 correctness evidence; P5-T3 is
authoritative.
