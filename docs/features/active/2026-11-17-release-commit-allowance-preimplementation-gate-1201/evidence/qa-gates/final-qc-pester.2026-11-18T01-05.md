# Final QC - Pester gate

Timestamp: 2026-11-18T00-51
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run, 8 workers, integration and golden lanes excluded)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-18T00-51 to 2026-11-18T01-05 UTC; wall-clock 716.56 s; all shards exited 0.
- JUnit (artifacts/pester/pester-junit.xml): tests 28105, passed 28087, failed 0, errors 0, skipped 18. Failing tests: none.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 45276/47121 = 96.08%.
- .claude/hooks/hook-release-allowance-context.ps1: 171/171 = 100.00%.
- .codex/hooks/hook-release-allowance-context.ps1: 171/171 = 100.00%.
- .claude/hooks/enforce-orchestration-preimplementation-gate-release.ps1: 32/32 = 100.00%.
- .codex/hooks/enforce-orchestration-preimplementation-gate-release.ps1: 32/32 = 100.00%.
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1: 171/177 = 96.61%.
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1: 182/182 = 100.00%.
- The bundle copies under extensions/ are byte-identical to these files (parity suite) and outside the coverage roots of config/poshqc-coverage.json, so they are not measured.
