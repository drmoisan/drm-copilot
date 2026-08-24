# Remediation Baseline — Shell Lane (local pre-check)

Timestamp: 2026-08-10T21-41
Issue: #462
Task: [P0-T3]
Target files: `scripts/bash/shell_qc_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh`
State: pre-edit (RI-3 suppressions still present)

## Command 1 — local shellcheck version

Command: `shellcheck --version`

EXIT_CODE: 0

Output Summary:

```
ShellCheck - shell script analysis tool
version: 0.11.0
license: GNU General Public License, version 3
website: https://www.shellcheck.net
```

Local shellcheck is **0.11.0**, as predicted by Constraint 2.

## Command 2 — local shellcheck on the two RI-3 target files

Command: `shellcheck -S style scripts/bash/shell_qc_lib.sh scripts/bash/cleanup_worktrees_lib.sh`

EXIT_CODE: 0

Output Summary: No findings. Zero output, exit 0, at severity `style` (the most inclusive level).

## Command 3 — local shfmt diff on the two RI-3 target files

Command: `shfmt -d scripts/bash/shell_qc_lib.sh scripts/bash/cleanup_worktrees_lib.sh`

EXIT_CODE: 0

Output Summary: No diff. Both files already match shfmt default formatting at baseline.

Supplementary: `shfmt --version` reports `v3.12.0`. CI pins shfmt 3.8.0
(`.claude/rules/shell.md`, CI-vs-Local Version Drift).

## Mandatory Caveat — this baseline is NOT sufficient RI-3 evidence

Per Binding Environment Constraint 2 and `.claude/rules/shell.md` lines 72-77:

- Local shellcheck 0.11.0 reports **zero findings on these files even with the file-wide
  `# shellcheck disable=SC2015` directives removed**. It therefore cannot distinguish the unfixed
  code from the fixed code, and a clean local run before or after the RI-3 edit carries no
  discriminating signal.
- The CI runner installs the apt-packaged shellcheck, an older version that **does** emit SC2015 for
  the `A && B || true` sites. That version divergence is why the finding appeared only in CI.
- CI versions are canonical. The authoritative RI-3 verification is the P5-T3 CI dispatch of
  `_shell-coverage.yml`, not this local run. The local commands are retained as a fast pre-check for
  syntax and formatting regressions only (P4-T3).
- `bats` and `kcov` are unavailable locally (Constraint 1), so no local test or coverage baseline is
  obtainable. The coverage baseline is the CI value recorded in
  `shell-ci-baseline.2026-08-10T21-40.md` (92.4%).

Output Summary: Local shellcheck 0.11.0 and shfmt 3.12.0 are both clean on the two pre-edit target
files (exit 0, no findings, no diff). This establishes that no unrelated local lint or format defect
exists before the RI-3 edits. It is explicitly insufficient as RI-3 correctness evidence because the
local shellcheck version does not emit the SC2015 finding under any condition.
