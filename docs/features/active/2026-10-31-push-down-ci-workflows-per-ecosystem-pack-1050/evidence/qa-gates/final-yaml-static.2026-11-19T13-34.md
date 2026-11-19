# Final QC: YAML Static (advisory-fix plan, P2-T1)

Timestamp: 2026-11-19T13-34
Command: actionlint .github/workflows/harness-python.yml .github/workflows/harness-powershell.yml .github/workflows/harness-typescript.yml .github/workflows/harness-dotnet.yml (through SCRATCH/issue-1050-advisory-gate-static.sh afinal)
EXIT_CODE: 0
Output Summary: actionlint version 1.7.12; 0 findings over the four harness workflows. The bundle copy `extensions/drm-copilot/resources/ci-workflows/workflows/harness-powershell.yml` is byte-identical to the source (checked in P2-T4) and was linted with 0 findings in the P1-T3 task check.

| Step | Command | Exit code | Findings |
| --- | --- | --- | --- |
| Lint | actionlint 1.7.12 over the four `harness-*.yml` files | 0 | 0 |
| Format / type check | not applicable for workflow YAML | n/a | n/a |

Porcelain observation: `git status --porcelain` 0 lines before and after the static run (identical).
