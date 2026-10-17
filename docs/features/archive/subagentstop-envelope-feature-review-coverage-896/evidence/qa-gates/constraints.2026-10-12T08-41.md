# Constraints (P12-T4, P12-T6; AC-26 under PI-1)

Timestamp: 2026-10-12T08-41
Command: git diff --name-status origin/epic/subagentstop-envelope-integration -- .claude/hooks/ .codex/hooks/ ; git status --porcelain -- .claude/hooks/ .codex/hooks/ ; CR-PY-TOKEN with $Mode = 'final' (scratchpad route)
EXIT_CODE: 0
Output Summary: AC-26 (a) diff lists the three added files with status A and no added .py path; the status command prints nothing. AC-26 (c) PY-TOKEN claude-hooks base=5 head=5 NOT-INCREASED, codex-hooks base=5 head=5 NOT-INCREASED, PY-TOKEN-INCREASED-COUNT: 0. AC-26 (b) and the temporary-file clause are recorded in separate files (named below) because ExpectedExitCode is per file.

PI-1 (AC-26 check mapping): clauses (a) and (c) are recorded here; clause (b) in `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/constraints-no-python.2026-10-12T08-41.md`; the temporary-file clause in `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/constraints-temp-files.2026-10-12T08-41.md`. Clause (a) runs the two AC-26 (a) commands verbatim. Clause (b) runs `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` on the branch head. Clause (c) compares the summed `git grep -i -c python` counts per hook family between the integration ref and HEAD (`.claude/hooks/`: H1, H2, H3, H4; `.codex/hooks/`: H5, H6); the base count is 5 for each family because the token occurs as data (language label, audit labels, coverage path).

AC-26(b) artifact: docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/constraints-no-python.2026-10-12T08-41.md (SUITE Passed=32 Failed=0; AC-26(b): MET)
AC-26 temporary-file artifact: docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/constraints-temp-files.2026-10-12T08-41.md (no output, exit 1 as expected)

## AC-26 (a) output

```
M	.claude/hooks/feature-review-coverage-thresholds.ps1
A	.claude/hooks/validate-feature-review-coverage-metrics.ps1
A	.claude/hooks/validate-feature-review-coverage-rules.ps1
M	.claude/hooks/validate-feature-review-coverage.ps1
A	.codex/hooks/feature-review-coverage-thresholds.ps1
M	.codex/hooks/validate-feature-review-coverage.ps1
(git status --porcelain -- .claude/hooks/ .codex/hooks/: no output)
```

## AC-26 (c) output (CR-PY-TOKEN, $Mode = 'final')

```
GREP-BASE: origin/epic/subagentstop-envelope-integration:.claude/hooks/validate-feature-review-coverage.ps1:5
GREP-HEAD: HEAD:.claude/hooks/validate-feature-review-coverage-metrics.ps1:2
GREP-HEAD: HEAD:.claude/hooks/validate-feature-review-coverage-rules.ps1:2
GREP-HEAD: HEAD:.claude/hooks/validate-feature-review-coverage.ps1:1
PY-TOKEN: claude-hooks | base=5 | head=5 | NOT-INCREASED
GREP-BASE: origin/epic/subagentstop-envelope-integration:.codex/hooks/validate-feature-review-coverage.ps1:5
GREP-HEAD: HEAD:.codex/hooks/validate-feature-review-coverage.ps1:5
PY-TOKEN: codex-hooks | base=5 | head=5 | NOT-INCREASED
PY-TOKEN-INCREASED-COUNT: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
