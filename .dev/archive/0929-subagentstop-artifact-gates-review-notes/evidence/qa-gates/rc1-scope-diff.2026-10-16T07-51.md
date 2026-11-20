# Remediation Cycle 1 Scope Diff (P3-T8)

Timestamp: 2026-10-16T07-51

RC1_START_HEAD source: `rc1-branch-baseline.2026-10-16T06-47.md` (greatest `rc1-branch-baseline.*.md`), RC1_START_HEAD 8d9bad34cebeceae2871593194ebd39a8a7a3c23.

Command: git diff --name-only 8d9bad34cebeceae2871593194ebd39a8a7a3c23 HEAD
EXIT_CODE: 0

```
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/coverage-repo-wide.2026-10-16T07-38.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/rc1-full-run-prestate.2026-10-16T07-17.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/rc1-f2-analyze.2026-10-16T07-15.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/rc1-f2-envelope-identity.2026-10-16T07-09.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/rc1-f2-file-state.2026-10-16T07-09.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/rc1-f2-format.2026-10-16T07-09.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/rc1-f2-suite.2026-10-16T07-15.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/remediation-baseline/phase0-instructions-read.2026-10-16T06-45.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/remediation-baseline/rc1-analyze-baseline.2026-10-16T06-50.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/remediation-baseline/rc1-branch-baseline.2026-10-16T06-47.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/remediation-baseline/rc1-file-state-baseline.2026-10-16T06-47.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/remediation-baseline/rc1-format-baseline.2026-10-16T06-48.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/remediation-baseline/rc1-poshqc-test-mcp-baseline.2026-10-16T07-04.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/remediation-baseline/rc1-suite-coverage-baseline.2026-10-16T07-05.md
docs/features/active/subagentstop-artifact-gates-review-notes-929/remediation-plan.2026-10-16T05-25.md
tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1
```

Command: git diff --name-only 8d9bad34cebeceae2871593194ebd39a8a7a3c23 HEAD -- .claude .codex extensions scripts .github
EXIT_CODE: 0

```
```

Command: git status --porcelain -- . ":(exclude)SCRATCH"
EXIT_CODE: 0

```
 M docs/features/active/subagentstop-artifact-gates-review-notes-929/remediation-plan.2026-10-16T05-25.md
?? docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/rc1-coverage-comparison.2026-10-16T07-50.md
?? docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/rc1-f1-currency.2026-10-16T07-50.md
?? docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/rc1-final-analyze.2026-10-16T07-40.md
?? docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/rc1-final-file-state.2026-10-16T07-50.md
?? docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/rc1-final-format.2026-10-16T07-39.md
?? docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/rc1-final-poshqc-test-mcp.2026-10-16T07-49.md
?? docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/rc1-final-suite-coverage.2026-10-16T07-49.md
```

Output Summary: the cycle diff lists `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` and otherwise only paths under the feature folder; the protected-tree diff (`.claude`, `.codex`, `extensions`, `scripts`, `.github`) prints nothing; every porcelain path is under the feature folder (this plan file and the uncommitted P3-T1 to P3-T7 artifacts).
