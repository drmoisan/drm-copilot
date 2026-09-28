# AC Check-Off — Policy compliance (5 criteria; spec.md and user-story.md)

Timestamp: 2026-09-17T08:48:15-04:00 (file write time)
Command: per-criterion review against the named evidence, then '- [ ] ' -> '- [x] ' for the lines between '### Policy compliance' and the next heading in spec.md and user-story.md (criterion text unchanged)
EXIT_CODE: 0
Output Summary: 5 of 5 criteria verified and checked off in both files. Criteria 2 and 5 are checked under the interpretations stated below.

| # | Criterion (abridged) | Verified by |
| --- | --- | --- |
| 1 | No Python file added or edited; the Python-invocation guard passes with the new module in scope | evidence/qa-gates/changed-file-inventory.2026-09-13T22-00.md: no `.py` path in either listing; evidence/regression-testing/convention-and-python-guard.2026-09-13T22-00.md: 33 passed, including "reports no Python invocation beyond the allowlist across the guarded tree" (re-run after the final repair: 33 passed) |
| 2 | No created or edited file exceeds 500 physical lines, as counted by the ClaudeLibModuleConvention assertion | evidence/qa-gates/module-line-counts.file1.2026-09-13T22-00.md (480), evidence/qa-gates/module-line-counts.file2.2026-09-13T22-00.md (341), evidence/qa-gates/suite-line-counts.2026-09-13T22-00.md (448, 408, 88 after the final repair); core.json 178 lines and both runsettings copies 300 lines; convention-and-python-guard: "keeps every claude library module within the five hundred line limit" passes |
| 3 | All suites live under tests/scripts/claude-lib/worktree-resolution/; no colocated test | changed-file-inventory: the three suite paths are the only test paths, all under that folder; no test file under .claude/lib/ |
| 4 | Both modules satisfy ClaudeLibModuleConvention.Tests.ps1 in full | convention-and-python-guard: all six convention tests pass with both modules discovered from disk |
| 5 | Toolchain completes in one pass in order with no stage failing or modifying a file; observed PoshQC output captured under evidence/qa-gates/ | evidence/qa-gates/toolchain-single-pass.2026-09-13T22-00.md (format 08:34:23 -> analyze 08:35:23 -> test 08:40:15; no rewrite; analyze clean); evidence/qa-gates/poshqc-observed-success-output.2026-09-13T22-00.md and the final-poshqc-* artifacts carry the verbatim MCP result objects and the self-hosted output lines |

## Interpretations recorded for review

- Criterion 2: the scope is taken as the ten code, test, and configuration files this feature creates or
  edits, which is the scope of the 500-line rule in `.claude/rules/general-code-change.md` (production code,
  test code, reusable scripts; Markdown is exempt). The plan itself mandates evidence copies of the Pester
  JUnit and coverage XML under `evidence/other/`, which exceed 500 lines. Those are captured run outputs, not
  code, and are outside this reading.
- Criterion 5: the repository-wide MCP test stage returns `ok: false` in both the baseline and the final run
  because of two failures in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and
  `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`. Both predate this feature, are
  identical in the baseline, and lie outside its scope. This plan's [P4-T9] defines a stage failure as one
  beyond the [P0-T6] baseline failure set, and none occurred. The self-hosted run scoped to
  `tests/scripts/claude-lib` passed 1490 of 1490. The first analyze pass did fail (26 findings on new files);
  the loop was repaired and restarted as the plan directs, and the governing second pass is clean.

Evidence files: the seven artifacts named in the table.
