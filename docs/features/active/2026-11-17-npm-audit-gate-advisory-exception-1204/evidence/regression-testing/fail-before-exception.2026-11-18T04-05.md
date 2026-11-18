# Fail-before exception dossier (P1-T1)

Timestamp: 2026-11-18T04-05
Command: git -C <worktree> cat-file -e HEAD:scripts/ci/NpmAuditGate.psm1 (and the same for tests/scripts/ci/NpmAuditGate.Tests.ps1), plus `git ls-tree -r --name-only HEAD scripts/ci` filtered for `npmaudit` (case-insensitive count)
EXIT_CODE: 128
Output Summary: both `cat-file -e` calls exit 128 (`exists on disk, but not in 'HEAD'`, run after the files were written and before they were committed); the `ls-tree` filter count is 0. At the parent commit neither the module nor its test file exists.

WhyFailingRunImpossible: The exception-file cases test `ConvertFrom-NpmAuditException`, which is defined by a module this task creates; before the task the module path does not exist, so `Import-Module` fails and no test case can run, so no per-case failing run exists to record.

## Absence-of-module proof

- `scripts/ci/NpmAuditGate.psm1` is not present in `HEAD` (exit 128 above) and `git ls-tree` over `scripts/ci` lists no file whose name contains `NpmAudit`.
- The test file `tests/scripts/ci/NpmAuditGate.Tests.ps1` is likewise absent from `HEAD`.
- Pass-after: see `evidence/other/task-check.P1-T1.*.md` (31 tests pass, 0 failures, including every `NAG-EXC-*` case).
