# 2026-11-17-npm-audit-gate-advisory-exception (Spec)

- **Issue:** #1204
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-18
- **Status:** Draft
- **Version:** 0.2

## Context

The NPM Audit Gate (`.github/workflows/_npm-audit-gate.yml`, matrix over `.`, `extensions/drm-copilot`, `packages/mcp-server`, step `npm audit --audit-level="$AUDIT_LEVEL"`) fails on every branch, including `main`. The cause is advisory GHSA-fc5q-39xc-vjpf, a high-severity ReDoS in `picomatch` (`<= 4.0.7`). No patched version exists. `picomatch` reaches the repository only through development dependencies (`jest`, `@parcel/watcher`); `npm ls picomatch --omit=dev --all` is empty in all three manifests. Every PR is blocked, including #1201 and epic #1018.

Impact / Severity: Blocker.

## Repro & Evidence

1. Run CI on any branch.
2. Observe `NPM Audit Gate / npm audit (.)` and `(extensions/drm-copilot)` fail with GHSA-fc5q-39xc-vjpf.

Expected: the gate fails on any advisory at or above the configured level except advisories listed in a committed exception file. Each exception names one advisory id, a reason, an approval date and an expiry date. An expired exception, or an excepted advisory that reaches a production dependency, fails the gate. Every applied exception is reported in the job log.

Actual: the gate fails on a development-only advisory that has no fix.

## Scope & Non-Goals

- In scope: the exception file and its validation; the gate script and module; the workflow step; tests; the process-reduction ledger entry.
- Out of scope: lowering `AUDIT_LEVEL`; omitting dev dependencies from the audit wholesale; upgrading or overriding `picomatch`; changing job ids, job names, check names, or the `node-version` line; any Python; any edit to the execution-environment brief copies.

## Root Cause Analysis

Upstream has not published a patched `picomatch`, and the gate has no exception mechanism. The narrowest remedy is one advisory id, dev-only, expiring 2026-12-18, enforced in code, with the prior gate text recorded in the process-reduction ledger.

## Proposed Fix

### Design summary

Approach A from the research record (`research/research.2026-11-17.md`):

1. Strict production pass: `npm audit --omit=dev --audit-level="$AUDIT_LEVEL"` runs with no exception logic. Any finding fails with `NPM_AUDIT_PROD_FINDING`. An excepted advisory reaching production therefore fails.
2. Full audit, filtered: `npm audit --json` (all dependency types). Collect the unique advisory objects from `via[]` object elements, keyed by the GHSA id extracted from `url` with `GHSA-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}` (fall back to numeric `source` when no GHSA is present). Keep advisories whose severity rank is at or above `AUDIT_LEVEL` (`info < low < moderate < high < critical`). Remove advisories matching a valid, unexpired exception id. Any remainder fails with `NPM_AUDIT_UNEXCEPTED_ADVISORY`. String-only `via` entries need no handling: transitive dependents are covered by their chain's advisory objects.
3. Fail closed: empty or unparseable audit JSON fails with `NPM_AUDIT_OUTPUT_UNPARSEABLE`.

### Boundaries and invariants

- Audit level is passed through unchanged from `inputs.audit-level` (default `moderate`).
- Check order: exception file validation, production audit, full audit. The log names the first cause.
- Failure codes: `NPM_AUDIT_EXCEPTION_INVALID`, `NPM_AUDIT_EXCEPTION_EXPIRED`, `NPM_AUDIT_PROD_FINDING`, `NPM_AUDIT_UNEXCEPTED_ADVISORY`, `NPM_AUDIT_OUTPUT_UNPARSEABLE`. Each is distinct and appears in the log.
- An exception for an advisory absent from the audit is reported as unused (informational, not a failure).
- The pure module performs no I/O and does not read the clock. The entry script injects file read, clock (UTC date), the `npm` wrapper, and output writers.

### Files to change or add

- `config/npm-audit-exceptions.json` (new)
- `scripts/ci/NpmAuditGate.psm1` (new, pure: `ConvertFrom-NpmAuditException`, `Get-NpmAuditAdvisories`, `Get-NpmAuditGateDecision`)
- `scripts/ci/Invoke-NpmAuditGate.ps1` (new, entry, seams `-ReadFile`, `-GetUtcDate`, `Invoke-NpmAuditExe -NpmArgs`, `-OutputWriter`, dot-source guard, explicit `exit 0` / `exit 1`)
- `.github/workflows/_npm-audit-gate.yml` (step replaced)
- `tests/scripts/ci/NpmAuditGate.Tests.ps1`, `tests/scripts/ci/Invoke-NpmAuditGate.Tests.ps1`, `tests/scripts/workflows/NpmAuditGateWorkflow.Tests.ps1` (new)
- `docs/engineering/process-reductions/0013-npm-audit-advisory-exception.md` (new) and its row in `docs/engineering/process-reductions/README.md`

### Exception file contract

`{ "version": 1, "exceptions": [ { "id", "package", "scope", "reason", "approved_at", "expires" } ] }`. Dates are `yyyy-MM-dd`, compared as UTC dates; `expires` strictly before the clock date is expired. Exactly one id per entry. Unknown keys at any level, a `version` other than 1, a missing or empty required field, a duplicate id, a malformed id, a bad date, or `expires` not after `approved_at` fails with `NPM_AUDIT_EXCEPTION_INVALID`.

### Workflow step

`shell: pwsh`, `working-directory: ${{ matrix.manifest }}`, running `${{ github.workspace }}/scripts/ci/Invoke-NpmAuditGate.ps1` with `-AuditLevel "$env:AUDIT_LEVEL"` and `-ExceptionsPath "${{ github.workspace }}/config/npm-audit-exceptions.json"`. The bare `npm audit --audit-level` line is removed. Every applied exception (id, package, reason, approved_at, expires, days remaining) is written to the log and `GITHUB_STEP_SUMMARY`.

### Rollback

Revert per `0013-npm-audit-advisory-exception.md`: restore the prior single line `run: npm audit --audit-level="$AUDIT_LEVEL"` and delete the new script, module, config, and tests.

## Assumptions, Constraints, Dependencies

- `pwsh` is available on `ubuntu-latest` (already used by `ci.yml`).
- Constraint: no new Python; no temp files in tests; no `Get-Date` in the module; each new file under 500 lines.
- Open item for the executor: run `npm audit --omit=dev --json` and `npm audit --json` once per manifest and confirm `--omit=dev` is honored, the `via` object shape, and exit codes; record counts only (advisory ids, severities, exit codes) under `evidence/other/` with clock-read UTC stamps, append-only. If `--omit=dev` is not honored, fall back to `npm ls <pkg> --omit=dev --all` for the dev-only proof only.

## Data / API / Config Impact

- New config file `config/npm-audit-exceptions.json`; no change to the reusable workflow's `inputs` interface.
- Logging: each applied exception and each failure code is printed; applied exceptions go to `GITHUB_STEP_SUMMARY`.

## Test Strategy

Pester tests with in-memory JSON strings and injected seams; no `npm` process, no disk access, no temp files.

- Decision tests: dev-only excepted advisory passes; unexcepted advisory fails; expired exception fails; production audit nonempty (excepted advisory reaching production) fails; transitive dependent of an excepted advisory is covered; mixed advisories (one excepted, one not) fail; severity below `AUDIT_LEVEL` is ignored; unparseable or empty JSON fails; GHSA extraction from `url`; unused exception is informational.
- Exception file tests: wrong version, unknown key, duplicate id, missing field, bad date, `expires` not after `approved_at` each fail.
- Entry script tests: exit codes 0 and 1 and the printed failure code for each path, with `Invoke-NpmAuditExe` mocked using matching `-NpmArgs` parameter names.
- Workflow text test: job id and name unchanged, `node-version` line present, step calls `Invoke-NpmAuditGate.ps1`, old bare `npm audit --audit-level` line absent, exceptions path passed, audit level taken from `AUDIT_LEVEL`.
- Toolchain: format, lint, actionlint 1.7.12 over the changed workflow, PoshQC tests with coverage, ledger tests `ProcessReductionChain.Ledger.Tests.ps1` and `ProcessReductionLedger.Index.Tests.ps1`.

## Acceptance Criteria

- [x] `config/npm-audit-exceptions.json` exists with `version` 1 and exactly one entry: `id` GHSA-fc5q-39xc-vjpf, `package` picomatch, a non-empty `reason`, `approved_at` 2026-11-18, `expires` 2026-12-18.
- [x] Exception-file validation fails with `NPM_AUDIT_EXCEPTION_INVALID` for a wrong `version`, an unknown key, a duplicate id, a missing or empty field, a malformed id, a bad or non-`yyyy-MM-dd` date, and `expires` not after `approved_at`; each case has a failing-then-passing test.
- [x] `scripts/ci/NpmAuditGate.psm1` and `scripts/ci/Invoke-NpmAuditGate.ps1` implement approach A: strict `npm audit --omit=dev` pass, then full `npm audit --json` advisory-set filter by GHSA from `via` url, severity rank at or above `AUDIT_LEVEL`, expiry against the injected UTC date (expired when `expires` is strictly earlier), fail closed on unparseable output, and distinct codes `NPM_AUDIT_EXCEPTION_INVALID`, `NPM_AUDIT_EXCEPTION_EXPIRED`, `NPM_AUDIT_PROD_FINDING`, `NPM_AUDIT_UNEXCEPTED_ADVISORY`, `NPM_AUDIT_OUTPUT_UNPARSEABLE`, evaluated in that order.
- [x] Every applied exception (id, package, reason, approved_at, expires, days remaining) is printed to the log and to `GITHUB_STEP_SUMMARY`; an unused exception is reported as informational without failing.
- [x] `.github/workflows/_npm-audit-gate.yml` replaces the bare `npm audit` step with the `pwsh` step calling `Invoke-NpmAuditGate.ps1`; `AUDIT_LEVEL` is not lowered; dev dependencies are not omitted from the full audit; the job id, job name, check names, and `node-version` line are unchanged; actionlint passes.
- [x] Pester tests pass for: dev-only excepted advisory passes; unexcepted advisory fails; expired exception fails; excepted advisory reaching a production path fails; malformed exception file fails; transitive dependent covered; mixed advisories fail; below-level severity ignored; unparseable JSON fails.
- [x] `tests/scripts/workflows/NpmAuditGateWorkflow.Tests.ps1` passes and asserts the workflow text conditions listed in Test Strategy.
- [x] New tests create no temp files and call no real `npm`; no new Python is added; each new file is under 500 lines.
- [x] Line coverage of `NpmAuditGate.psm1` and `Invoke-NpmAuditGate.ps1` is at least 85%.
- [x] Process-reduction ledger entry `0013-npm-audit-advisory-exception.md` exists with the prior text (`run: npm audit --audit-level="$AUDIT_LEVEL"`), a revert note and six ordered revert steps, plus its index row in `docs/engineering/process-reductions/README.md`; the ledger chain and index tests pass.
- [x] The executor's one real run per manifest confirms `--omit=dev` is honored and the audit JSON shape (or the `npm ls` fallback is implemented and recorded), with evidence appended under `evidence/other/`.
- [x] CI-dependent: `NPM Audit Gate / npm audit (.)`, `(extensions/drm-copilot)` and `(packages/mcp-server)` pass on the PR head (checked off at S9 only).

## Risks & Mitigations

- Reviewer reads the gate as weakened: one id, enforced expiry, strict production pass, ledger entry with revert steps, exceptions printed in the log.
- `--omit=dev` not honored by npm 11: verified once per manifest; `npm ls` fallback for the dev-only proof.
- Coverage shortfall on entry script: seams for npm, file read, clock, and writers; dot-source guard.
- Real gate behavior exists only on the runner: green run on the PR head required.

## Rollout & Follow-up

- Merge, then back-fill `Merge commit:` in the ledger entry.
- Remove the exception and revert per the ledger when upstream ships a patched `picomatch`, or by 2026-12-18.
- Links: issue #1204; research `research/research.2026-11-17.md`.
