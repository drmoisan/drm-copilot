# P2-T9 Helper Pass Run (issue #927) - BLOCKED

Timestamp: 2026-10-16T01-53
Command: stat -c %Y artifacts/pester/pester-junit.xml (R-JUNIT J0)
EXIT_CODE: 0
MCP_CALL: error Command exited with code 40.
TASK_STATUS: BLOCKED (plan defect; task acceptance unsatisfiable as written)
Output Summary: Suites A, B, and D pass in full (30, 36, 32). The JUnit file reports 40 failures instead of FAIL_BASE + 39. The 39 expected rows of Appendix R and R2 fail as predicted. The additional failure is the existing repository guard `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` row `reports no Python invocation beyond the allowlist across the guarded tree`, which reports the Appendix D seam invocations `& $GitCommand` and `& $GhCommand` as fail-closed DynamicInvocation findings. The plan's acceptance condition ("every J3 line is either a token of Appendix R or R2 or a B_FAILED line") cannot be met without a design change, which the executor is not authorized to make.

## R-JUNIT reads

- J0: JUNIT_MTIME_BEFORE: 1792113651
- J1: JUNIT_MTIME_AFTER: 1792115551 (rewritten)
- J2: tests=7166 failures=40 errors=0 (expected FAIL_BASE + 39 = 39)
- J5: 18 (create side unchanged, as expected)
- J10: suite A 30, suite B 36, suite D 32 (as expected)
- J11: suites A, B, D failures 0 (as expected)
- J3 lines outside Appendix R, R2, and B_FAILED (count 1):
  - enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree

## Defect detail

Failure message (repository paths only):

- .claude/hooks/hook-docs-only-diff.ps1:175 [DynamicInvocation] in Invoke-DocsOnlyGitExe: ampersand-invoked variable $GitCommand is not a [scriptblock] parameter, so its target cannot be verified statically (fail-closed)
- .claude/hooks/hook-docs-only-diff.ps1:221 [DynamicInvocation] in Invoke-DocsOnlyGhExe: ampersand-invoked variable $GhCommand is not a [scriptblock] parameter, so its target cannot be verified statically (fail-closed)
- .codex/hooks/hook-docs-only-diff.ps1:175 (same finding, Codex copy)
- .codex/hooks/hook-docs-only-diff.ps1:221 (same finding, Codex copy)

Cause: the guard scans `.claude/hooks` and `.codex/hooks` and treats an ampersand-invoked variable that is not a `[scriptblock]` parameter as a possible Python invocation. Its allowlist is pinned empty by the row `ships an empty allowlist`, so an allowlist entry is not an available remedy. The guard accepts a `[scriptblock]`-typed seam parameter (rows at lines 197-231 and 310-336 of that suite).

Scope of the defect:

- Appendix D (`Invoke-DocsOnlyGitExe -GitCommand <string>`, `Invoke-DocsOnlyGhExe -GhCommand <string>`) triggers it now.
- Appendix H edits H4 to H6 (`[ValidateNotNullOrEmpty()][string] $GitCommand = 'git'` and `& $GitCommand -C $WorktreeRoot @GitArgs` in `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`) would trigger the same finding at [P3-T13], [P4-T24], and [P6-T3].
- Spec AC-7 and AC-M4 name the string-typed `-GitCommand` / `-GhCommand` form, so the spec text also requires revision.
- Planned J-values that would need re-derivation after the redesign: none of the J10 counts change if the seam rows keep their count; J2 baselines are unaffected.

Candidate remediation (for the planner; not applied): replace the string command-name parameters with `[scriptblock]` invoker parameters whose default runs the executable (for example `[scriptblock] $GitInvoker = { git @args }` invoked as `& $GitInvoker -C $WorktreeRoot @GitArgs`), update Appendix D, Appendix H (H4-H6), Appendix T block T2, Appendix N blocks N-A and N-D (pass scriptblocks instead of function names), the AC-7/AC-M4/AC-8 wording in spec.md, and the [P2-T1], [P3-T2], [P3-T3], and Phase 6 source-token greps. The planner should confirm that the guard accepts the chosen default scriptblock form.

## Work state at stop

- Completed and checked: [P2-T1] to [P2-T8].
- Unchecked: [P2-T9] (this task), [P2-T10] and all later tasks.
