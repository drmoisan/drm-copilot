# CI Quality Gate [P5-T4]: First pull_request Run on PR #975 (Issue #973)

Timestamp: 2026-10-17T14-21
Command: gh api repos/drmoisan/drm-copilot/rulesets/15241672 (required contexts); gh run list --workflow ci.yml --branch bug/ci-docs-only-pr-runs-full-ci-973; gh run view 39039639260 --job 117416308339 --log; gh pr view 975 --json baseRefOid,headRefOid,statusCheckRollup; git merge-base 18d6d1ccd455a280ca3b7a47ce4976f162e8803e e1a6c90eaff39e5da86d46006a1b4459593f8c4f
EXIT_CODE: 0

## Run

- Pull request: #975 (`bug/ci-docs-only-pr-runs-full-ci-973` into `main`)
- Run identifier: 39039639260 (event `pull_request`), the only `ci.yml` run on the branch at the time of reading
- Head SHA: e1a6c90eaff39e5da86d46006a1b4459593f8c4f
- Payload base SHA (`BASE_SHA` in the step environment): 18d6d1ccd455a280ca3b7a47ce4976f162e8803e; `BASE_REF`: main

## Change scope decision

Log line of the `Change scope` job, step `Decide the change scope`:

```
code=true reason=NON_ALLOWLISTED_PATH: .agents/skills/execution-environment/SKILL.md
```

The reason is `NON_ALLOWLISTED_PATH`, not `NO_FULL_GREEN_RUN`. The branch had no earlier `ci.yml` run, so the green-run comparison produced `NO_FULL_GREEN_RUN`; the base ref is `main`, so the merge-base fallback ran, resolved the merge base (an unresolved merge base would log `MERGE_BASE_UNRESOLVED`), and classified the diff from it.

Summary `base=` value: the job summary (`Change scope: code=true; reason=NON_ALLOWLISTED_PATH: ...; base=<sha>`) is not exposed through `gh` or the REST API (the check-run `output.summary` is null). The value is derived: the decision's `BaseSha` on the fallback path is the merge base returned by `git merge-base` of the payload base SHA and the head, and `git merge-base 18d6d1ccd455a280ca3b7a47ce4976f162e8803e e1a6c90eaff39e5da86d46006a1b4459593f8c4f` returns 18d6d1ccd455a280ca3b7a47ce4976f162e8803e. This is a derivation from the code path and the recorded inputs, not a direct reading of the summary.

## Checks

- `CI full run`: SUCCESS
- Ruleset 15241672 required contexts, re-confirmed through `gh api` at this timestamp (11, unchanged from the brief), each SUCCESS on the head SHA:
  - drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)
  - drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)
  - docs-validation / Documentation Validation
  - poshqc / PowerShell QC
  - shell-coverage / Shell Coverage (Bats + kcov)
  - security-scan / Security Scanning
  - quality-checks7 / Code Quality & Tests (3.10)
  - quality-checks7 / Code Quality & Tests (3.11)
  - quality-checks7 / Code Quality & Tests (3.12)
  - quality-checks7 / Code Quality & Tests (3.13)
  - build-check / Build Package
- All checks on the head SHA: 26 observed, 26 pass, 0 pending, 0 failing.

Output Summary: run 39039639260 logged `code=true reason=NON_ALLOWLISTED_PATH:` (not `NO_FULL_GREEN_RUN`) with BASE_REF main; merge base 18d6d1ccd455a280ca3b7a47ce4976f162e8803e (derived, summary not API-readable); `CI full run` success; 11 of 11 required contexts success; 26 of 26 checks pass.
