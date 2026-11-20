# R3 Reverted-Mutant Probe (P2-T5)

Timestamp: 2026-11-16T00-34
Command: sh SCRATCH/issue-1195-r3probe.sh (runs pwsh -NoProfile -File SCRATCH/issue-1195-r3probe.ps1 with the worktree as cwd: dot-sources .claude/hooks/enforce-orchestration-preimplementation-gate.ps1, reads the final .claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1 text into memory, and for each variant asserts the anchor occurs exactly once, replaces it, dot-sources [scriptblock]::Create(<variant text>), and evaluates the four P1-T1 function rows with Get-OrchestrationGateSupplementalPatternIndex and the two P1-T1 gate rows with Test-ImplementationCommand)
EXIT_CODE: 0
Output Summary:
- Classify text: the final text after Part 1 (the wrapped-payload function is present).
- Variants: control (unmutated); N2 removes " -or $beforeBackticks % 2 -ne 0"; N5 replaces "$member.Tail -match $script:OrchestrationGateSupplementNpmPattern" with "$run.Text -match $script:OrchestrationGateSupplementNpmPattern"; N6 removes " -and (Test-CommandLineWordPresent -RawText $member.Raw -Word 'npm')"; N7 removes " -and (Test-CommandLineWordPresent -RawText $member.Raw -Word 'npx')". Each anchor occurred exactly once.
- control: 0 rows failed. N2: 2 rows failed. N5: 1 row failed. N6: 3 rows failed. N7: 1 row failed (AC-14).
- The probe writes no file: git status --porcelain was identical before and after the run; its only outputs are SCRATCH files and this record.

## Per-variant, per-row results

- VARIANT control | function | echo `npm --version` lint | expected [] | got [] | pass
- VARIANT control | function | echo $(echo npm --version) lint | expected [] | got [] | pass
- VARIANT control | function | FOO=$(echo npx jest) ls | expected [] | got [] | pass
- VARIANT control | function | FOO=$(echo npm x lint) npm --version | expected [] | got [] | pass
- VARIANT control | gate | echo `npm --version` lint | expected False | got False | pass
- VARIANT control | gate | echo $(echo npm --version) lint | expected False | got False | pass
- VARIANT control SUMMARY failed_rows=0
- VARIANT N2 | function | echo `npm --version` lint | expected [] | got [2] | FAIL
- VARIANT N2 | function | echo $(echo npm --version) lint | expected [] | got [] | pass
- VARIANT N2 | function | FOO=$(echo npx jest) ls | expected [] | got [] | pass
- VARIANT N2 | function | FOO=$(echo npm x lint) npm --version | expected [] | got [] | pass
- VARIANT N2 | gate | echo `npm --version` lint | expected False | got True | FAIL
- VARIANT N2 | gate | echo $(echo npm --version) lint | expected False | got False | pass
- VARIANT N2 SUMMARY failed_rows=2
- VARIANT N5 | function | echo `npm --version` lint | expected [] | got [] | pass
- VARIANT N5 | function | echo $(echo npm --version) lint | expected [] | got [] | pass
- VARIANT N5 | function | FOO=$(echo npx jest) ls | expected [] | got [] | pass
- VARIANT N5 | function | FOO=$(echo npm x lint) npm --version | expected [] | got [2] | FAIL
- VARIANT N5 | gate | echo `npm --version` lint | expected False | got False | pass
- VARIANT N5 | gate | echo $(echo npm --version) lint | expected False | got False | pass
- VARIANT N5 SUMMARY failed_rows=1
- VARIANT N6 | function | echo `npm --version` lint | expected [] | got [] | pass
- VARIANT N6 | function | echo $(echo npm --version) lint | expected [] | got [2] | FAIL
- VARIANT N6 | function | FOO=$(echo npx jest) ls | expected [] | got [] | pass
- VARIANT N6 | function | FOO=$(echo npm x lint) npm --version | expected [] | got [2] | FAIL
- VARIANT N6 | gate | echo `npm --version` lint | expected False | got False | pass
- VARIANT N6 | gate | echo $(echo npm --version) lint | expected False | got True | FAIL
- VARIANT N6 SUMMARY failed_rows=3
- VARIANT N7 | function | echo `npm --version` lint | expected [] | got [] | pass
- VARIANT N7 | function | echo $(echo npm --version) lint | expected [] | got [] | pass
- VARIANT N7 | function | FOO=$(echo npx jest) ls | expected [] | got [3] | FAIL
- VARIANT N7 | function | FOO=$(echo npm x lint) npm --version | expected [] | got [] | pass
- VARIANT N7 | gate | echo `npm --version` lint | expected False | got False | pass
- VARIANT N7 | gate | echo $(echo npm --version) lint | expected False | got False | pass
- VARIANT N7 SUMMARY failed_rows=1
