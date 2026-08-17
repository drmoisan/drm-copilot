# Cycle 3 Pass 6 PowerShell Coverage Baseline

Timestamp: 2026-08-15T11:52:13-04:00
Command: Independently parse fresh `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`; parse and verify the preserved 25-owner matrix.
EXIT_CODE: 0
Output Summary: 2,447 passed, 9 disabled, and 0 failures/errors. Bundled line coverage is 4,040/4,260 = 94.835681%. The report contains no BRANCH counter, so genuine branch covered=0, missed=0, denominator=0, and the required coverage-policy result is FAIL.

## Fresh artifact identity

- JUnit SHA-256: `119D402F428CE6CBFDF3A4E6653BEBBFF29BA6D1346CC93A5EA38E62A51980A2`
- Coverage XML SHA-256: `B750B029C0C0530062C4408133A6791286BED4D7E647767A5AF7F4E46A8ECE93`
- JUnit last-write UTC: `2026-08-15T15:52:11.9694085Z`
- Coverage last-write UTC: `2026-08-15T15:50:52.3120592Z`

## Fresh test result

- Test suites: `126`
- Total tests: `2,456`
- Passed: `2,447`
- Disabled/skipped: `9`
- Failures: `0`
- Errors: `0`
- Reported duration seconds: `130.226`

## Fresh bundled coverage result

- Packages: `8`
- Classes: `52`
- Report-level LINE counter count: `1`
- Line covered: `4,040`
- Line missed: `220`
- Line denominator: `4,260`
- Line coverage: `94.835681%`
- Line threshold: `85%`
- Line result: `PASS`
- Report-level BRANCH counter count: `0`
- All-scope BRANCH counter count: `0`
- Genuine branch covered: `0`
- Genuine branch missed: `0`
- Genuine branch denominator: `0`
- Genuine branch percentage: `0.000000%` fail-closed numeric representation for a zero denominator; this is not a measured branch rate and cannot satisfy the threshold.
- Branch threshold: `75%`
- Branch result: `FAIL`
- Coverage-policy result: `FAIL`
- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`
- `POWERSHELL_BRANCH_POLICY_UNRESOLVED`

## Owner-attribution basis

The fresh repository-default bundled report contains one of the 25 issue-owner sources and omits 24. It therefore cannot replace the preserved source-attributed owner matrix. The preserved matrix was independently parsed from `evidence/qa-gates/powershell-final-test-coverage.2026-08-13T15-38.md` at SHA-256 `0EB357342E614E3077DD880465A4395D4F33D069E6B307440CB0D96B654082A3`; its reconciliation receipt is `evidence/remediation-baseline/powershell-owner-reconciliation.2026-08-14T09-36.md` at SHA-256 `F83A0B49A237BAD782EB688301790B36AD615EA90EFAF2F4083E57195A6B8A07`. The parse produced exactly 25 rows, 17 added owners, 8 modified owners, 2,646/2,934 = 90.184049% combined lines, added-owner minimum 90.000000%, and modified-owner minimum 80.888889%.

| Runtime owner | Status | Covered | Missed | Total | Percent | Requirement | Fresh bundled presence | Attribution result |
|---|:---:|---:|---:|---:|---:|---|:---:|:---:|
| `.codex/hooks/authorize-root-parallel-invocation.ps1` | A | 116 | 10 | 126 | 92.063492% | >=90% | absent | PASS |
| `.codex/hooks/codex-authority-store.ps1` | M | 49 | 9 | 58 | 84.482759% | >=80% | absent | PASS |
| `.codex/hooks/enforce-codex-model-routing.ps1` | M | 68 | 11 | 79 | 86.075949% | >=80% | absent | PASS |
| `.codex/hooks/enforce-completion-consistency.ps1` | M | 157 | 2 | 159 | 98.742138% | no regression | present, matches 157/159 | PASS |
| `.codex/hooks/enforce-parallel-abandon-gate.ps1` | A | 27 | 2 | 29 | 93.103448% | >=90% | absent | PASS |
| `.codex/hooks/enforce-parallel-child-worktree-binding.ps1` | A | 27 | 3 | 30 | 90.000000% | >=90% | absent | PASS |
| `.codex/hooks/enforce-parallel-cohort-barrier.ps1` | A | 26 | 2 | 28 | 92.857143% | >=90% | absent | PASS |
| `.codex/hooks/enforce-parallel-drift-gate.ps1` | A | 26 | 2 | 28 | 92.857143% | >=90% | absent | PASS |
| `.codex/hooks/enforce-parallel-root-invocation.ps1` | A | 76 | 7 | 83 | 91.566265% | >=90% | absent | PASS |
| `.codex/hooks/enforce-parallel-worktree-removal-gate.ps1` | A | 27 | 3 | 30 | 90.000000% | >=90% | absent | PASS |
| `.codex/hooks/parallel-hook-common.ps1` | A | 50 | 1 | 51 | 98.039216% | >=90% | absent | PASS |
| `.codex/hooks/record-subagent-routing-attestation.ps1` | M | 186 | 43 | 229 | 81.222707% | >=80% | absent | PASS |
| `.codex/hooks/validate-codex-subagent-routing.ps1` | M | 76 | 10 | 86 | 88.372093% | >=80% | absent | PASS |
| `.codex/hooks/validate-parallel-agent-output.ps1` | A | 72 | 4 | 76 | 94.736842% | >=90% | absent | PASS |
| `.codex/scripts/codex-child-launch-contract-core.ps1` | A | 142 | 5 | 147 | 96.598639% | >=90% | absent | PASS |
| `.codex/scripts/codex-child-launch-persistence.ps1` | A | 91 | 7 | 98 | 92.857143% | >=90% | absent | PASS |
| `.codex/scripts/codex-child-launch-resume.ps1` | A | 133 | 2 | 135 | 98.518519% | >=90% | absent | PASS |
| `.codex/scripts/codex-child-launch-runtime.ps1` | A | 105 | 6 | 111 | 94.594595% | >=90% | absent | PASS |
| `.codex/scripts/epic-child-launch-contract.ps1` | M | 135 | 25 | 160 | 84.375000% | no regression from 134/160 | absent | PASS |
| `.codex/scripts/launch-epic-child-wave.ps1` | M | 182 | 43 | 225 | 80.888889% | >=80% | absent | PASS |
| `.codex/scripts/launch-parallel-child-batch.ps1` | A | 217 | 24 | 241 | 90.041494% | >=90% | absent | PASS |
| `.codex/scripts/parallel-child-launch-contract.ps1` | A | 105 | 3 | 108 | 97.222222% | >=90% | absent | PASS |
| `.codex/scripts/parallel-child-post-session.ps1` | A | 159 | 16 | 175 | 90.857143% | >=90% | absent | PASS |
| `.codex/scripts/resume-epic-child.ps1` | M | 156 | 22 | 178 | 87.640449% | >=80% | absent | PASS |
| `.codex/scripts/resume-parallel-child.ps1` | A | 238 | 26 | 264 | 90.151515% | >=90% | absent | PASS |

- Source-attributed owners recorded: `25/25`
- Added owners at or above 90%: `17/17`
- Modified owners meeting applicable threshold/no-regression requirement: `8/8`
- Preserved source-attributed repository lines: `6,529/7,035 = 92.807392%`
- Combined owner lines: `2,646/2,934 = 90.184049%`

Result: `BASELINE FAIL` because the genuine source-attributable branch denominator is zero. The line and owner gates pass, but they do not substitute for genuine branch outcomes.
