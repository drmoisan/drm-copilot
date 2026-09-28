# Pester Directory, Convention, and Guard Runs, Re-run after P5-T14 Format (P5-T13 re-run)

Timestamp: 2026-09-27T16-37
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
EXIT_CODE: 0
Output Summary: PASS. Re-run required by P5-T14 after the format call changed the hash of BlastRadiusScheduling.Tests.ps1. Directory run: TotalCount=496, PassedCount=496, FailedCount=0 (no FAILED names; the P0-T32 baseline failure set is empty). Convention run (B46): 6/6, FailedCount=0. Guard run (B47): 5/5, FailedCount=0. Each command exited 0.

## Directory run

```text
TotalCount=496
PassedCount=496
FailedCount=0
```

## Convention run (block B46)

```text
TotalCount=6
PassedCount=6
FailedCount=0
```

## Guard run (block B47)

```text
TotalCount=5
PassedCount=5
FailedCount=0
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
