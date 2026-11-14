# Phase Gate — Phase 2 ([P2-T3] [phase-gate])

Timestamp: 2026-11-13T19-05
Command: sh SCRATCH/issue-1160-r4-static.sh (Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the six PowerShell files of [P0-T1]); sh SCRATCH/issue-1160-r4-gate.sh p2 (one Invoke-PoshQCParallelTest run on the branch-current scripts/powershell/PoshQC/PoshQC.psd1); sh SCRATCH/issue-1160-r4-contract.sh (one env -u VIRTUAL_ENV poetry run pytest -n auto -q --no-cov run of the seven [P3-T5] contract files, then env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check)
EXIT_CODE: 0
Output Summary: single clean pass. Format 0 differences, analyzer 0 findings over 6 files (git status --porcelain digest unchanged before and after); type check not applicable to PowerShell; no architecture-boundary rule covers these files; unit stage one Invoke-PoshQCParallelTest run (8 workers, 669.61 s, 2026-11-13T18-53 to 2026-11-13T19-04), exit 0, merged JUnit 22305 tests, 0 failures, 0 errors, 10 skipped; contract stage pytest 130 passed, 0 failed, generator --check exit 0 with no output.

| Stage | Exit code | Result |
|---|---|---|
| Format (Invoke-Formatter comparison, 6 files) | 0 | 0 differences |
| Lint (Invoke-ScriptAnalyzer, 6 files) | 0 | 0 findings |
| Type check | n/a | not applicable (PowerShell) |
| Unit (Invoke-PoshQCParallelTest) | 0 | 22305 tests, 0 failures, 0 errors, 10 skipped |
| Contract (pytest -n auto, 7 files) | 0 | 130 passed, 0 failed |
| Contract (generator --check) | 0 | no difference |

Named results from the merged JUnit: existing-denial rows (ED-01 to ED-50, classify and deny, both runners) 200 test cases, 0 failed; false-positive rows 68, 0 failed; non-goal rows 18, 0 failed; decision D16 cases 40 (fifteen confirm and five guard cases on two surfaces), 0 failed; the two updated pins on two surfaces, 0 failed.

Informational coverage from the same run (`artifacts/pester/powershell-coverage.xml`): repo-wide 95.86% (38163/39812); `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` each 98.96% (95/96), the one missed line being the pre-existing `continue` of the Opaque NoPayload branch.
