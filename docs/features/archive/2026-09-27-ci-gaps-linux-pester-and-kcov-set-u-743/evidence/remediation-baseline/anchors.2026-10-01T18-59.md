# Remediation Cycle 1 Anchors (P0-T2)

Timestamp: 2026-10-01T18-59

Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: dcb2abf17704cc6b6f370b363a4f6385e9adda11 (START_SHA; begins with dcb2abf1)

Command: git rev-parse --abbrev-ref HEAD
EXIT_CODE: 0
Output Summary: bug/ci-gaps-linux-pester-and-kcov-set-u-743

Command: git merge-base HEAD origin/main
EXIT_CODE: 0
Output Summary: 41217012d31d35c2ee33a50be50684affd2f5f43 (equals MERGE_BASE)

Command: git status --porcelain
EXIT_CODE: 0
Output Summary: two untracked entries, both under `<FEATURE>/`:
```
?? docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/remediation-baseline/
?? docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/remediation-plan.2026-10-01T18-07.md
```

Command: git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743
EXIT_CODE: 0
Output Summary: dcb2abf17704cc6b6f370b363a4f6385e9adda11 refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743 (equals START_SHA)

Acceptance: START_SHA begins dcb2abf1; branch name matches; merge base matches; every porcelain path is under `<FEATURE>/`; remote head equals START_SHA. Met.
