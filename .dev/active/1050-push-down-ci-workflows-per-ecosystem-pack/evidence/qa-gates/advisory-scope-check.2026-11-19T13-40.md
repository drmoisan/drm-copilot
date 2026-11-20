# Advisory-Fix Scope Check (P2-T4)

Timestamp: 2026-11-19T13-40
Command: git hash-object <four pair files>; git diff --name-only <merge base of origin/epic/shared-agent-harness-layer-integration and HEAD> HEAD; git diff --name-only 2a77b8b65 HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary: Both pairs have one hash each. Every path this plan touched is one of the eight named files or lies under `<FEATURE>`; no other path appears.

## Hashes

| Pair | Source hash | Bundle hash |
| --- | --- | --- |
| `scripts/ci/Set-CiRequiredChecks.ps1` / `extensions/drm-copilot/resources/ci-workflows/Set-CiRequiredChecks.ps1` | acac0fbb754381c219d0c70a12d4c578cce21fa9 | acac0fbb754381c219d0c70a12d4c578cce21fa9 |
| `.github/workflows/harness-powershell.yml` / `extensions/drm-copilot/resources/ci-workflows/workflows/harness-powershell.yml` | 2fcf236c2aaf23e24aab252d11ec4a66477d5532 | 2fcf236c2aaf23e24aab252d11ec4a66477d5532 |

## Paths

- Branch diff from the merge base (`git merge-base origin/epic/shared-agent-harness-layer-integration HEAD`) to HEAD: 102 paths, the whole #1050 branch; the eight files named in P1-T1 to P1-T4 are all present in it.
- Paths touched by this plan, derived as `git diff --name-only` from the plan commit (the branch head when execution began, `docs(1050): plan fixes for the three minor review items`) to HEAD, plus `git status --porcelain`:
  - `scripts/ci/Set-CiRequiredChecks.ps1`
  - `extensions/drm-copilot/resources/ci-workflows/Set-CiRequiredChecks.ps1`
  - `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1`
  - `.github/workflows/harness-powershell.yml`
  - `extensions/drm-copilot/resources/ci-workflows/workflows/harness-powershell.yml`
  - `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test-helpers.ts`
  - `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts`
  - `extensions/drm-copilot/README.md`
  - under `<FEATURE>`: the plan file and the evidence files of this plan (committed: 9; uncommitted at check time: the plan file and five `final-*` artifacts).
- No other path appears.
