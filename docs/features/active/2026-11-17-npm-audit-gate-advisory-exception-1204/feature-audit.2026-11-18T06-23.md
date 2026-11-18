# Feature Audit: npm audit gate advisory exception (#1204)

**Audit Date:** 2026-11-18
**Feature Folder:** `docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204`
**Base Branch:** `main`
**Head Branch:** `bug/npm-audit-gate-advisory-exception`
**Work Mode:** `full-bug`
**Audit Type:** Re-review at the same head (CI-dependent criterion now verified)

---

## Scope and Baseline

- **Base branch:** `main` (commit `1b9e5746eaa5e32366de695e3f511dbc28700b08`)
- **Head branch/commit:** `bug/npm-audit-gate-advisory-exception` (commit `f3df6dcf1de2dedb804d9dbb0a80007bb890281c`)
- **Merge base:** `1b9e5746eaa5e32366de695e3f511dbc28700b08`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204/evidence/**`
  - Additional evidence: twelve decision probes run against the real module in this review; per-file and repo-wide coverage read from the regenerated `artifacts/pester/powershell-coverage.xml`; `artifacts/pester/pester-junit.xml`; `gh pr checks 1205`; `gh run view` head SHA of runs 44247785049 and 44247785257
- **Feature folder used:** `docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the only acceptance-criteria source.
- **Scope note:** The PR context bundle head equals the reviewed head. CI is complete on that head (32 checks pass, 0 pending, 0 failing), so the CI-dependent criterion is evaluated.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204/spec.md` — only source

### Acceptance criteria

1. `config/npm-audit-exceptions.json` exists with `version` 1 and exactly one entry: `id` GHSA-fc5q-39xc-vjpf, `package` picomatch, a non-empty `reason`, `approved_at` 2026-11-18, `expires` 2026-12-18.
2. Exception-file validation fails with `NPM_AUDIT_EXCEPTION_INVALID` for a wrong `version`, an unknown key, a duplicate id, a missing or empty field, a malformed id, a bad or non-`yyyy-MM-dd` date, and `expires` not after `approved_at`; each case has a failing-then-passing test.
3. `scripts/ci/NpmAuditGate.psm1` and `scripts/ci/Invoke-NpmAuditGate.ps1` implement approach A: strict `npm audit --omit=dev` pass, then full `npm audit --json` advisory-set filter by GHSA from `via` url, severity rank at or above `AUDIT_LEVEL`, expiry against the injected UTC date (expired when `expires` is strictly earlier), fail closed on unparseable output, and distinct codes evaluated in the stated order.
4. Every applied exception (id, package, reason, approved_at, expires, days remaining) is printed to the log and to `GITHUB_STEP_SUMMARY`; an unused exception is reported as informational without failing.
5. `.github/workflows/_npm-audit-gate.yml` replaces the bare `npm audit` step with the `pwsh` step calling `Invoke-NpmAuditGate.ps1`; `AUDIT_LEVEL` is not lowered; dev dependencies are not omitted from the full audit; the job id, job name, check names, and `node-version` line are unchanged; actionlint passes.
6. Pester tests pass for: dev-only excepted advisory passes; unexcepted advisory fails; expired exception fails; excepted advisory reaching a production path fails; malformed exception file fails; transitive dependent covered; mixed advisories fail; below-level severity ignored; unparseable JSON fails.
7. `tests/scripts/workflows/NpmAuditGateWorkflow.Tests.ps1` passes and asserts the workflow text conditions listed in Test Strategy.
8. New tests create no temp files and call no real `npm`; no new Python is added; each new file is under 500 lines.
9. Line coverage of `NpmAuditGate.psm1` and `Invoke-NpmAuditGate.ps1` is at least 85%.
10. Process-reduction ledger entry `0013-npm-audit-advisory-exception.md` exists with the prior text (`run: npm audit --audit-level="$AUDIT_LEVEL"`), a revert note and six ordered revert steps, plus its index row in `docs/engineering/process-reductions/README.md`; the ledger chain and index tests pass.
11. The executor's one real run per manifest confirms `--omit=dev` is honored and the audit JSON shape (or the `npm ls` fallback is implemented and recorded), with evidence appended under `evidence/other/`.
12. CI-dependent: `NPM Audit Gate / npm audit (.)`, `(extensions/drm-copilot)` and `(packages/mcp-server)` pass on the PR head (checked off at S9 only).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Exception file content | PASS | `config/npm-audit-exceptions.json` holds version 1 and one entry with the stated id, package, reason, dates; `NAG-EXC-COMMITTED-FILE` asserts it | `git show HEAD:config/npm-audit-exceptions.json` | Extra `scope` field is in the spec file contract |
| 2 | Exception validation cases | PASS | Test ids for wrong version, unknown key (top and entry level), duplicate id, missing and empty field, malformed id, bad date, expires not after approved_at, unparseable JSON; probes: missing fields and duplicate key give `NPM_AUDIT_EXCEPTION_INVALID`; fail-before record `evidence/regression-testing/fail-before-exception.2026-11-18T04-05.md` | review probe script against `scripts/ci/NpmAuditGate.psm1` | Fail-before proof is absence of the module, as the plan allows for new code |
| 3 | Approach A, codes, order | PASS | Module code read; probes: excepted passes, extra advisory gives `NPM_AUDIT_UNEXCEPTED_ADVISORY`, day after expiry gives `NPM_AUDIT_EXCEPTION_EXPIRED`, expiry date itself passes, trailing garbage gives `NPM_AUDIT_OUTPUT_UNPARSEABLE`, production exit 1 gives `NPM_AUDIT_PROD_FINDING` | review probe script | Order and `NAG-DEC-ORDER` test confirmed |
| 4 | Applied exceptions printed | PASS | `INA-OUTPUT-WRITER`; local end-to-end log shows `Exception applied: ... days_remaining=30` on log and Summary targets, and an unused line for `packages/mcp-server` | `evidence/other/gate-script-local-run.2026-11-18T05-28.md` | The Summary target appends to the file named by `GITHUB_STEP_SUMMARY` |
| 5 | Workflow change | PASS | Diff of `_npm-audit-gate.yml` is a two-line change inside the `Audit dependencies` step; job id, name, matrix, `node-version` unchanged; actionlint 1.7.12 exit 0 | `git diff origin/main...HEAD -- .github/workflows/_npm-audit-gate.yml` | Live `NPM Audit Gate` legs for all three manifests are green |
| 6 | Named Pester cases | PASS | Test ids `NAG-DEC-DEV-ONLY-EXCEPTED-PASSES`, `NAG-DEC-UNEXCEPTED-FAILS`, `NAG-DEC-EXPIRED-FAILS`, `NAG-DEC-PROD-FINDING-FAILS`, `NAG-EXC-*`, `NAG-DEC-TRANSITIVE-COVERED`, `NAG-DEC-MIXED-FAILS`, `NAG-DEC-BELOW-LEVEL-IGNORED`, `NAG-DEC-UNPARSEABLE-FAILS` present; full run 0 failures | `evidence/qa-gates/final-qc-pester.2026-11-18T05-43.md` | Tests not re-run; gate evidence and probes relied on |
| 7 | Workflow text suite | PASS | Seven `NAW-` tests cover job id and name, node-version, script call, bare line absent, exceptions path, level from env, `shell: pwsh` | `NpmAuditGateWorkflow.Tests.ps1` read | Included in the 27605-test run |
| 8 | No temp files or real npm, no Python, size | PASS | Grep of suites finds no temporary-file or process cmdlet use; no `.py` path in the diff; logical line counts 408, 249, 406, 285, 70 | `git diff --name-only origin/main...HEAD` | npm is mocked with the production parameter name |
| 9 | Line coverage at least 85% | PASS | `NpmAuditGate.psm1` 161/161 = 100.00%, `Invoke-NpmAuditGate.ps1` 50/55 = 90.91%, read from the regenerated canonical coverage file and equal to the evidence record | LINE counters of the two `sourcefile` entries in `artifacts/pester/powershell-coverage.xml` | Repo-wide 96.05% (45075 of 46927) |
| 10 | Ledger entry 0013 | PASS | Entry has Prior text, Current and Prior blocks, six ordered revert steps, revert signals; README row added; ledger chain, index, and replay suites are in the 0-failure full run | `git diff origin/main...HEAD -- docs/engineering/process-reductions` | Merge commit field reads pending, as the format requires before merge |
| 11 | One real run per manifest | PASS | `evidence/other/npm-audit-observation.2026-11-18T03-41.md` has six result blocks and `OMIT_DEV_HONORED: yes`; the later local gate run covers all three manifests | evidence records read | Evidence files are append-only: none modified after its adding commit |
| 12 | CI-dependent NPM Audit Gate legs | PASS | `gh pr checks 1205`: `NPM Audit Gate / npm audit (.)`, `(extensions/drm-copilot)` and `(packages/mcp-server)` all pass; run 44247785049 has head SHA `f3df6dcf1de2dedb804d9dbb0a80007bb890281c`, equal to the PR head | `gh pr checks 1205`; `gh run view 44247785049 --json headSha` | Checked off in `spec.md` by this review |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 12 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Back-fill the `Merge commit:` field of ledger entry 0013 after merge.
2. Before 2026-12-18, renew or remove the exception per the ledger revert signals.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as PASS are checked off in `spec.md`; criteria 1 to 11 were already checked by the executor and each was verified in this review, so no checkbox change was needed.
- Criterion 12 was verified through `gh` on the reviewed head (three NPM Audit Gate checks pass; run head SHA equals the PR head) and is newly checked off in `spec.md`.

### AC Status Summary

- Source: `docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204/spec.md`
- Total AC items: 12
- Checked off (delivered): 12
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204/spec.md` | 12 | 12 | 0 | Checkbox-backed; criterion 12 checked off in this review |

Newly checked off in this review: criterion 12 (CI-dependent NPM Audit Gate legs). The edit changes only `- [ ]` to `- [x]`; the spec.md change is uncommitted in the worktree.
