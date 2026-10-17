# Dependency state record (P0-T5, AC-30, PD-1)

Timestamp: 2026-10-16T23-21
Command: git fetch origin
EXIT_CODE: 0
Output Summary: origin/main is 475bb06d5c6caeb3e68b13f847a4097dc026fa89. #953 is present on origin/main (poshqc-shard and poshqc-static jobs present); #952 is absent (no merge_group trigger). The PowerShell QC job name is retained.

## Commands and exit codes

- `git fetch origin` EXIT_CODE: 0 (no output)
- `git rev-parse origin/main` EXIT_CODE: 0 -> `475bb06d5c6caeb3e68b13f847a4097dc026fa89`
- `git rev-parse origin/bug/ci-merge-queue-for-main-952` EXIT_CODE: 0 -> `ea9b652a2391936a4123c68ae250397b4c6c62a5`
- `git rev-parse origin/bug/pester-profiler-coverage-953` EXIT_CODE: 0 -> `9285674cfc95b01ba1a5c8eca2216e58d61c2b2d`
- `git grep -c -E -e '^  merge_group:[[:space:]]*$' origin/main -- .github/workflows/ci.yml` EXIT_CODE: 1 -> (no output)
- `git grep -c -E -e '^  poshqc-shard:[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`
- `git grep -c -E -e '^  poshqc-static:[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`
- `git grep -c -E -e '^    name: PowerShell QC[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`

## Derived lines

TOKEN-merge_group: absent
TOKEN-poshqc-shard: present (1)
TOKEN-poshqc-static: present (1)
TOKEN-PowerShell QC: present (1)
DEP-952: absent
DEP-953: present
DEPENDENCY_STATE: RECORDED

Note: the plan's revision-time expectation was `DEP-953: absent`; the orchestrator merged origin/main 475bb06d5 (with #953) into the branch after preflight cleared (merge commit 4e82b3a3c), so `DEP-953: present` is the observed and recorded value. This task is a record, not a gate.
