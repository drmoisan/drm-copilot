# Phase Gate — Phase 2 (cycle 3, [P2-T3] [phase-gate])

Timestamp: 2026-11-14T01-16
Command: sh SCRATCH/issue-1160-c3r3-static.sh (Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the four sibling copies, the Cases file, the existing commands suite, and the new Modelled suite); sh SCRATCH/issue-1160-r4-gate.sh c3p2 (one Invoke-PoshQCParallelTest run on the branch-current scripts/powershell/PoshQC/PoshQC.psd1); sh SCRATCH/issue-1160-c3r3-contracts.sh (one pytest -n auto run over the seven contract files of [P3-T5]); sh SCRATCH/issue-1160-c3r3-gen.sh (scripts.dev_tools.generate_codex_agent_variants --check in module form)
EXIT_CODE: 0
Output Summary: static 0 formatter differences and 0 analyzer findings over 7 files, git status --porcelain digest identical before and after (no rewrite); type check not applicable to PowerShell; architecture-boundary stage not applicable (no boundary rule covers these files); unit stage one Invoke-PoshQCParallelTest run, 8 workers, 751.61 s, PARALLEL_EXIT=0, merged JUnit written 2026-11-14T01-15: 23215 tests, 0 failures, 0 errors, 10 skipped; contract stage pytest 130 passed, 0 failed (exit 0) and generator --check exit 0. No failure or rewrite occurred, so the gate closed on its first pass.

| Stage | Command | Exit code | Findings |
|---|---|---|---|
| Format | Invoke-Formatter comparison, 7 files | 0 | 0 differences |
| Lint | Invoke-ScriptAnalyzer, 7 files | 0 | 0 findings |
| Type check | not applicable (PowerShell) | n/a | n/a |
| Unit | Invoke-PoshQCParallelTest (8 workers, 751.61 s) | 0 | 23215 tests, 0 failures, 10 skipped |
| Contract | pytest -n auto, 7 contract files | 0 | 130 passed |
| Contract | generate_codex_agent_variants --check | 0 | no drift |

Named results from the merged JUnit: 384 existing-denial tests (ED-01 to ED-96, 2 tests x 2 runners) 0 failed; 68 false-positive tests (FP-01 to FP-17) 0 failed; 18 non-goal tests (NG-01 to NG-09) 0 failed; both `returns exactly the decision D2 executing-option exclusions` pins 0 failed.

Coverage read from `artifacts/pester/powershell-coverage.xml` of this run (informational; the final gate is [P3-T2]): repo-wide 95.88% (39146/40828); `.claude/hooks` and `.codex/hooks` commands copies 99.01% (201/203) each, uncovered lines being the `break` after a `-CommandWithArgs` or `-EncodedCommand` payload that is the last word of a modelled mention (no row or case uses that shape) and the unchanged Opaque NoPayload `continue` (review item N2, uncovered before this cycle).
