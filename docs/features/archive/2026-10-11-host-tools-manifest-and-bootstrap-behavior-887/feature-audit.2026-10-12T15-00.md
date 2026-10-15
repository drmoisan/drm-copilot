# Feature Audit - Issue #887 (also resolves #888)

- Work mode: minor-audit (AC source: `issue.md` `## Acceptance Criteria`, AC-1 to AC-18)
- Branch: bug/host-tools-manifest-and-bootstrap-behavior-887, head 59fa06a04
- Baseline: origin/main; coverage baseline in `evidence/baseline/ci-coverage-main.2026-10-12T14-33.md`
- Timestamp: 2026-10-12T15-00

## Acceptance criteria evaluation

Evidence root: `docs/features/active/2026-10-11-host-tools-manifest-and-bootstrap-behavior-887/evidence/`. "pass-after-fix" is `regression-testing/pass-after-fix.2026-10-12T15-08.md` (142 tests, 0 failures, 35 scenario IDs each passed once).

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | Manifest diff shows all seven top-level keys, including `installPackages.windows.winget`; test `AC01-MANIFEST-TOP-LEVEL-KEYS` passed. |
| AC-2 | PASS | Manifest `minimumVersions` = 3.13.12 / 2.3.2 / 7.6.6 / 24.14.0; `AC02-MINIMUM-VERSIONS-PINNED` passed. |
| AC-3 | PASS | Pester 5.6.1 and PSScriptAnalyzer 1.22.0 present; `AC03-POWERSHELL-MODULES-PINNED` passed. |
| AC-4 | PASS | Six winget entries with id and name, `projectRepositories` is `[]`, string arrays; `AC04-ENTRY-SHAPES` passed. |
| AC-5 | PASS | `qa-gates/manifest-path.2026-10-12T14-50.md` (existing assertion untouched; -U0 hunks add only lines); `AC05-MANIFEST-PATH-EXISTS` passed. |
| AC-6 | PASS | New suite `tests/scripts/host-tools.manifest.Tests.ps1` (168 lines), `AC06-*` tests passed; no temporary files (grep). |
| AC-7 | PASS | `AC07-DRYRUN-COMMITTED-MANIFEST` passed. |
| AC-8 | PASS | Production diff shows `@()` and `[AllowEmptyCollection()]`; `AC08-APPLY-EMPTY-PROJECTS` and `AC08-RESOLVE-EMPTY-PROJECTS` passed; expect-fail evidence exists. |
| AC-9 | PASS | New message present in `HostBootstrap.psm1`; `qa-gates/bootstrap-sh-search.2026-10-12T14-50.md` exit 1 (no match); `AC05-BOOTSTRAP-NONWINDOWS-EXIT1` passed. |
| AC-10 | PASS | `AC10-STREAM-OUTHOST-RESETS-EXITCODE` and `AC10-CAPTURE-RESETS-STALE-EXITCODE` passed; pre-existing capture cases unchanged and passing. |
| AC-11 | PASS | Production diff shows `-StreamToHost` at all seven sites with output emission removed; `AC11-*` tests passed (git, winget, npm, wsl, poetry, python -m poetry, pip). |
| AC-12 | PASS | `qa-gates/capture-sites.2026-10-12T14-50.md`: `HostVerification.psm1` unchanged; `Get-CommandVersion` still uses `-MergeErrorStream`. Independent grep of HEAD found `StreamToHost` only inside `HostTooling.psm1` lines 124 to 131 (the function itself). |
| AC-13 | PASS | `AC13-*` tests (nine) passed, covering every listed forwarding rule. |
| AC-14 | PASS | `-ErrorAction` absent from the forwarded names list in the diff; existing not-forwarded assertion retained (not in the diff) and the full file passed. |
| AC-15 | PASS | `AC15-PUBLISH-INHERITED-WHATIF-NOSEAMS` passed; `expect-fail.publish-sideloaded-extension.2026-10-12T14-58.md` shows failure on the pre-fix script. |
| AC-16 | PENDING-CI | Local PoshQC format, analyze, and test each report passing (`qa-gates/poshqc-*.md`). The second clause (CI `PowerShell QC` job on the PR) requires the PR CI run. Completed at the CI gate; left unchecked. |
| AC-17 | PENDING-CI | Exclusion clause verified locally (`qa-gates/coverage-exclusion-check.2026-10-12T14-51.md`). The numeric coverage clause requires `artifacts/pester/powershell-coverage.xml` from PR CI. Completed at the CI gate (plan P2-T10 to P2-T14); left unchecked. |
| AC-18 | PASS | `qa-gates/line-counts.2026-10-12T14-49.md`; maximum 462 lines (`HostBootstrap.psm1`), reconfirmed with `git grep -c ''` at HEAD. |

## Acceptance Criteria Status

- Source: `docs/features/active/2026-10-11-host-tools-manifest-and-bootstrap-behavior-887/issue.md`
- Total AC items: 18
- Checked off (delivered): 16 (AC-1 to AC-15, AC-18)
- Remaining (unchecked): 2
- Items remaining: AC-16 and AC-17 (pending the PR CI run)
- Newly checked off by this review: none. All PASS items were already checked in `issue.md`; no criterion text was modified.

## Plan state

P0-T1 through P2-T9 are checked. P2-T10 to P2-T14 are intentionally open because they require PR CI data.

## Non-AC observations

- Issue.md `## Evidence Checklist` boxes (baseline, targeted verification, end-state) are unchecked although baseline and verification evidence exists. These are not acceptance criteria under minor-audit and were not modified. Non-blocking.
- #888 behaviors (streaming, exit-code reset, preference forwarding) are covered by AC-10 to AC-15.

## Findings

| ID | Severity | Description |
|---|---|---|
| FA-1 | non-blocking | AC-16 and AC-17 pending PR CI; completed at the CI gate. |
| FA-2 | non-blocking | Evidence Checklist in issue.md is unchecked; not an AC. |

| FA-3 | BLOCKING (policy gate, resolved at CI) | The policy-audit records PowerShell coverage rows as FAIL (PA-2): the local scoped artifact shows 4.04% repo-wide and no per-file data for the changed files. AC-17 stays pending-CI; see `remediation-inputs.2026-10-12T15-00.md`. |

BLOCKING findings: 1 (FA-3, same item as PA-2).

## Verdict

OVERALL VERDICT: CONDITIONAL. 16 of 18 acceptance criteria are verified PASS; AC-16 and AC-17 are pending-CI. One blocking finding (PA-2/FA-3) is an evidence gap on PowerShell coverage that is cleared when the PR CI coverage artifact shows >= 85% for each changed file. No functional defect was found.
