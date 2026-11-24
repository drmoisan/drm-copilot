# P0-T2 Phase 0 baseline Pester gate

Timestamp: 2026-11-23T07-50
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (launcher pester suite, Invoke-PoshQCParallelTest, 8 workers, integration and golden lanes excluded)
EXIT_CODE: 0
Output Summary: Run reached the machine lock on the third launcher invocation after two exit-75 queue timeouts (lock held by sibling worktrees); the passing run is recorded here. Counts read from artifacts/pester/pester-junit.xml: tests=29157, failures=0, errors=0, disabled=22, wall-clock 689.16s. Repo-wide line coverage read from artifacts/pester/powershell-coverage.xml: LINE covered=47286 missed=1541, 96.84 percent (INSTRUCTION covered=82814 missed=3776). No per-file figure is recorded because this feature changes no production PowerShell file; the changed files are Markdown, JSON manifests and test files.
