# Phase 0 Feature Documents Read (issue #713)

Timestamp: 2026-09-27T03-15

Files Read:
1. `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/issue.md`
2. `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/spec.md`
3. `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/research/research.2026-09-27T00-30.md`
4. `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md`

AC Inventory (spec.md, lines below `## Acceptance Criteria` at line 385 that begin `- [ ] **AC`):

| ID | Line | First-line text |
| --- | --- | --- |
| AC1 | 389 | `- [ ] **AC1** With no ready feature checkpoint, a pathspec-scoped commit whose attribution trailers are supplied through `--trailer 'Co-Authored-By: Name <email>'` (separate-value and `--trailer=` forms, one or more occurrences, on `git commit` only) is admitted by both the Claude gate and the Codex gate at the decision seam (no `PREIMPLEMENTATION_GATE_BLOCKED` denial), pinned by the allow rows of `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`.` |
| AC2 | 390 | `- [ ] **AC2** With no ready feature checkpoint, the multi-`-m` form, in which the subject is in the first `-m` and every trailer is in one single-quoted second `-m` value separated by a literal newline, is admitted by both gates at the decision seam and pinned by a test row (pass-before pin per D13).` |
| AC3 | 391 | `- [ ] **AC3** `$` and backtick inside a single-quoted span no longer cause a denial on their own. `<` and `>` inside single- or double-quoted spans remain admitted (#663). `$` and backtick inside double quotes remain denied, per D2, which narrows issue AC2's "inside a quoted commit-message argument" to single quotes for these two characters.` |
| AC4 | 392 | `- [ ] **AC4** The relaxation opens no bypass. Each of the following remains denied at predicate level (`Test-ExemptOrchestrationStagingCommand` false and `Test-ImplementationCommand` true), with one regression test row each:` |
| AC5 | 401 | `- [ ] **AC5** The pre-existing `#` comment bypass is closed. The `#'` desynchronization line in the Security Argument (S4) and an unquoted `# note` suffix are denied at predicate level. The fail-before run records the desynchronization row as admitted on the unmodified helpers, and the evidence identifies the bypass as pre-existing. A `#` inside single or double quotes remains admitted.` |
| AC6 | 402 | `- [ ] **AC6** After the change, the four helpers copies (`.claude/hooks/`, `.codex/hooks/`, and the two `extensions/drm-copilot/resources/.../hooks/` mirrors) are byte-identical by SHA256, measured on the files as they exist at execution time. `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` and `legacy-codex-hook-contracts.Tests.ps1` pass. Each edited skill document is text-identical to its bundle mirror, and `test_push_down_claude_resource_contracts.py` passes in CI.` |
| AC7 | 403 | `- [ ] **AC7** The canonical helpers file is at or under 500 lines and not longer than its line count measured immediately before the edit, whether or not #710 has merged. Its diff touches only the constants block, `Test-OrchestrationCommandTextUnresolvable`, `Test-ExemptOrchestrationSegmentToken`, and optionally the comments of `Test-ExemptOrchestrationStagingCommand`. `Split-OrchestrationCommandLine` and both gate files are unmodified. The new test file is at or under 500 lines.` |
| AC8 | 404 | `- [ ] **AC8** The Integration Commit Form sections of `.claude/skills/parallel-plan/SKILL.md` and `.claude/skills/epic-plan/SKILL.md`, and of their mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`, document:` |
| AC9 | 412 | `- [ ] **AC9** Fail-before and pass-after evidence is recorded under `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/regression-testing/`:` |
| AC10 | 416 | `- [ ] **AC10** The PowerShell toolchain passes in a single pass: PoshQC format, PoshQC analyze with zero findings, and Pester with coverage, with line coverage of 85% or more on the helpers file and no regression on changed lines. The existing suites listed under Test Strategy pass unchanged. Results are recorded under `evidence/qa-gates/`.` |
| AC11 | 417 | `- [ ] **AC11** The new suite satisfies the hygiene constraints: no temporary files, no `git` process, no `origin/main` reference, no gitignored state, and no Windows-only paths or drive letters. Its deny rows assert at predicate level and do not call the decision seam.` |

AC count: 11 (AC1 to AC11, document order).
