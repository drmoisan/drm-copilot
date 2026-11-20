# Existing 500-Line Assertion Dispositions (AC5)

Timestamp: 2026-10-28T21-47
Command: targeted Pester run (Invoke-Pester, JUnit to SCRATCH) over the ten Phase 5 suites listed below; grep -n "500" over the unchanged suites
EXIT_CODE: 0
Output Summary: 154 tests passed, 0 failed across the ten suites (four suites carrying unchanged assertions plus the six edited in [P5-T2] through [P5-T4]). Decision 2 applied: per-file `<= 500` assertions are kept; names, comments, and `-Because` text that called 500 the repository cap are reworded; the two directory-discovered general gates use the shared 800 hard limit.

Every suite named in `spec.md` `### Existing 500-based Pester assertions (AC5)`:

| Suite | Assertion | Disposition | Reason |
|---|---|---|---|
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | general `.claude/lib` module size gate | Updated ([P5-T2]): limit is `(Get-FileSizePolicyLimit).HardLimit`; row renamed `keeps every claude library module within the shared hard file-size limit`; `.DESCRIPTION` and assert comment updated | Directory-discovered general gate; a 500 bound would compete with the 800 hard limit for every `.psm1` file |
| `tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1` | `H12: stays within 500 lines` | Unchanged | Pinned per-file bound on one helper; passes under a stricter bound and states no repository policy |
| `tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1` | `H12: stays within 500 lines` | Unchanged | Same as the Claude twin |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | `parse-checks each root and bundled hook and keeps every file within 500 lines` | Unchanged | Per-file list (`$script:StaticCheckNames`); now also covers `enforce-file-size-limit.ps1` and `file-size-policy.ps1`, both below 500 lines; suite passes |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` | `keeps <File> at or under 500 lines in the repository and the bundle` | Reworded ([P5-T4]): row name unchanged; header comment and both `-Because` strings describe a pinned per-file bound | Per-file pinned bound; only the wording called 500 the repository cap |
| `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` | general `.codex/hooks`, `.codex/scripts`, `.codex/agents` size gate | Updated ([P5-T3]): limit from the dot-sourced `.codex/hooks/file-size-policy.ps1`; row renamed `keeps hook, config, and agent files within the shared hard file-size limit` | Directory-discovered general gate; same rule as `ClaudeLibModuleConvention` |
| `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | orchestrator-state module `<= 500` | Reworded ([P5-T4]): row renamed `the orchestrator-state module stays within its pinned 500-line bound`; arrange and assert comments no longer call 500 the repository cap; assertion kept | Per-file pinned bound |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` | four surface copies `<= 500` | Reworded ([P5-T4]): row renamed `keeps every surface copy of the targets module within its pinned 500-line bound`; header comment and `-Because` updated; assertion kept | Per-file pinned bound |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` | four surface copies `<= 500` | Reworded ([P5-T4]): row renamed `keeps every surface copy of the helpers module within its pinned 500-line bound`; header comment and `-Because` updated; assertion kept | Per-file pinned bound |
| `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` | `keeps every changed file within the line cap` (`<= 500` per listed file) | Unchanged | Per-file list of issue #850 files; the row name does not state a repository figure; passes |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | `.DESCRIPTION` help block mentions the 500-line cap | Unchanged | Comment only, no assertion; historical description of why the content lines were measured |

Historical-comment class (`spec.md` `### Policy text and mirrors (AC1, AC5)`): explanatory comments of the form "keeps the file inside the 500-line limit" in code and tests describe why a file was split and state no policy; they are confirmed unaffected and are classified individually in `residual-500-classification.<timestamp>.md` ([P6-T12]).
