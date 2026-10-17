# Dependency state record, rule 17 RI-2 re-run of P0-T5 (AC-30, PD-1)

Timestamp: 2026-10-17T00-09
Command: git rev-parse origin/main
EXIT_CODE: 0
Output Summary: Re-run of P0-T5 for rule 17 RI-2 without the leading git fetch, so the recorded origin/main is the ref that RI-1 merged (b8fcd7790). Both dependencies are present on origin/main: #952 (merge_group) and #953 (poshqc-shard, poshqc-static). This record is the new comparison base for the P6-T10 re-check.

## Commands and exit codes

- `git rev-parse origin/main` EXIT_CODE: 0 -> `b8fcd77905a51284cfbca54226a2da2a7916a836`
- `git rev-parse origin/bug/ci-merge-queue-for-main-952` EXIT_CODE: 0 -> `5c8fff171a45ef042f878170de8765ef49c02db9`
- `git rev-parse origin/bug/pester-profiler-coverage-953` EXIT_CODE: 0 -> `9285674cfc95b01ba1a5c8eca2216e58d61c2b2d`
- `git grep -c -E -e '^  merge_group:[[:space:]]*$' origin/main -- .github/workflows/ci.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/ci.yml:1`
- `git grep -c -E -e '^  poshqc-shard:[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`
- `git grep -c -E -e '^  poshqc-static:[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`
- `git grep -c -E -e '^    name: PowerShell QC[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`

## Derived lines

TOKEN-merge_group: present (1)
TOKEN-poshqc-shard: present (1)
TOKEN-poshqc-static: present (1)
TOKEN-PowerShell QC: present (1)
DEP-952: present
DEP-953: present
DEPENDENCY_STATE: RECORDED
