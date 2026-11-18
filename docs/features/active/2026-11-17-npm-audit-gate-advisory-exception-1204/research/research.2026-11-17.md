# Research: expiring dev-only advisory exception in the npm audit gate (Issue #1204)

Scope note: the researcher tool set has no shell, so no `npm audit --json` run was made. Items marked UNVERIFIED must be confirmed by the executor with one real run per manifest before the parser is finalized.

## Current State

- `.github/workflows/_npm-audit-gate.yml`: matrix job `npm-audit` over `.`, `extensions/drm-copilot`, `packages/mcp-server`; steps are checkout, setup-node 26.13.0, `npm ci`, then `run: npm audit --audit-level="$AUDIT_LEVEL"` with `AUDIT_LEVEL` from `inputs.audit-level` (default `moderate`). The caller job in `ci.yml` is named `NPM Audit Gate`; check names (`NPM Audit Gate / npm audit (<manifest>)`) must not change.
- No test pins the gate's step text. `tests/scripts/dev_tools/test_host_environment_contracts.py` only regex-matches `node-version` in this file (line 212 to 220), so keep that line intact. No test pins a `config/` allowlist.
- `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1` is the pattern for workflow tests: read the YAML as text, partition into job blocks, no YAML module.
- `.github/workflows/ci.yml` already runs `shell: pwsh` steps and `Invoke-CiRequiredGate.ps1` on `ubuntu-latest`, so `pwsh` is available on the runner.

## npm audit JSON shape (npm 11, auditReportVersion 2; from npm behavior, UNVERIFIED against the three manifests)

- Top level: `auditReportVersion`, `vulnerabilities` (map keyed by package name), `metadata.vulnerabilities` (`info|low|moderate|high|critical|total`) and `metadata.dependencies` (`prod|dev|optional|peer|peerOptional|total`).
- Each vulnerability: `name`, `severity`, `isDirect`, `via[]`, `effects[]`, `range`, `nodes[]`, `fixAvailable` (`false` when no fix).
- `via[]` holds two kinds of element: an advisory object (`source` numeric registry id, `name`, `dependency`, `title`, `url`, `severity`, `cwe`, `cvss`, `range`) when the package itself is the vulnerable one, or a plain string naming another vulnerable package when the vulnerability is inherited. The GHSA id is NOT a field; extract it from `url` with `GHSA-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}`. `source` is the numeric id and is not a GHSA.
- Transitive dependents of `picomatch` (jest packages, `@parcel/watcher` and so on) appear as their own entries with string-only `via` and `severity` equal to the highest severity in their chain. They carry no advisory object, so they have no GHSA of their own.
- Level ordering for the gate: `info < low < moderate < high < critical`; an entry counts when its severity rank is at or above `AUDIT_LEVEL`. `npm audit --audit-level` "does not filter the report output, it simply changes the command's failure threshold" (npm docs), so the filter must be applied in the script.
- `npm audit` exits non-zero when findings at or above the level exist, and also on network or registry errors; the script must treat an unparseable or empty JSON result as failure (fail closed), not as "no findings".

## Approaches

### A (recommended): two audits plus advisory-set filter

1. Production strictness, no exceptions: `npm audit --omit=dev --audit-level="$AUDIT_LEVEL"` must pass. The npm docs state omitted dependency types are "skipped when generating the report" and are dropped from the submitted payload. An excepted advisory that reaches a production dependency therefore fails here, with no exception logic, which satisfies "fails when an excepted advisory reaches a production dependency" by construction.
2. Full audit, filtered: `npm audit --json` (all types). Collect the set of unique advisory objects across all `via[]` object elements (key = GHSA from `url`, else `source`). Keep those whose severity is at or above the level. Remove those whose GHSA matches a non-expired exception entry. Any remainder fails. String-only `via` entries need no handling: their advisories are in the set through the `via` chain's advisory-bearing entries, so a transitive dependent of an excepted advisory is covered and a dependent with an additional unexcepted advisory still fails through that advisory.
3. Expiry and schema: an exception whose `expires` is earlier than the clock date fails the gate (and is not applied). A malformed file, unknown key, duplicate id, bad date, or missing field fails the gate. Every exception is printed (id, package, reason, approved_at, expires, days remaining) to the log and `GITHUB_STEP_SUMMARY`.
4. The step still fails if the audit JSON cannot be parsed, so a registry outage is not a silent pass.

Advantages: the dev-only decision is delegated to npm's own tree walk with one exit code (no empty-output parsing); the logic is a pure function over parsed JSON, which is testable without a process; no dependence on `npm ls` behavior. Limitation: relies on `--omit=dev` being honored by `npm audit` in npm 11 (documented; UNVERIFIED by a run, so the executor runs it once and records the result as evidence).

### B (rejected): `npm ls <pkg> --omit=dev --all` per excepted package

A package absent from the production tree gives empty output and a non-zero exit (npm 7+ exits 1 when a requested package is not found), so "dev-only" is read from a failure exit and output text. That signal conflates a missing package with a broken tree (`ELSPROBLEMS`), needs `node_modules` and ties the check to a named package rather than the advisory. Not recommended.

### C (rejected): audit JSON `isDirect`/`effects`/`nodes` to infer dev-only

The audit JSON carries no prod/dev flag per node (only `metadata.dependencies` totals), so path analysis would have to rebuild the tree from `effects` and `nodes`. More code and more failure modes than A.

## Recommendation: PowerShell, not node

- Script `scripts/ci/Invoke-NpmAuditGate.ps1` (entry, I/O seams, exit code, dot-source guard, explicit `exit 0`/`exit 1` per `.claude/rules/ci-workflows.md`) plus module `scripts/ci/NpmAuditGate.psm1` (pure: `ConvertFrom-NpmAuditException`, `Get-NpmAuditAdvisories`, `Get-NpmAuditGateDecision`). Mirrors `Invoke-CiRequiredGate.ps1` + `CiRequiredGate.psm1`.
- Seams: `-ReadFile` for the exception file and audit JSON, `-GetUtcDate` for the clock (no `Get-Date` in the module), a `Invoke-NpmAuditExe -NpmArgs <string[]>` wrapper for the two `npm` calls, `-OutputWriter` for log/summary. Tests never spawn `npm` or touch the disk (policy: no temp files).
- Workflow step replaces the single run line: `shell: pwsh`, `working-directory: ${{ matrix.manifest }}`, `run: ${{ github.workspace }}/scripts/ci/Invoke-NpmAuditGate.ps1 -AuditLevel "$env:AUDIT_LEVEL" -ExceptionsPath "${{ github.workspace }}/config/npm-audit-exceptions.json"` (resolve the script path through `github.workspace`; the step runs inside the manifest folder). The reusable workflow is called with default checkout, so repo files exist.
- No new Python; node would need a new TypeScript/JS surface with its own coverage entry and tooling for no gain.
- Exception file `config/npm-audit-exceptions.json`: `{ "version": 1, "exceptions": [ { "id": "GHSA-fc5q-39xc-vjpf", "package": "picomatch", "scope": "dev", "reason": "...", "approved_at": "2026-11-17", "expires": "2026-12-18" } ] }`. Date-only values, compared as UTC dates; `expires` strictly before the clock date is expired. Exactly one id per entry; unknown keys rejected.

## Conventions and Mirrors

- Coverage: `config/poshqc-coverage.json` roots include `scripts`, so the new `.psm1` and `.ps1` are in the 85% line-coverage denominator automatically; `config/poshqc-scan.json` scans `scripts` and `tests/scripts`, so tests at `tests/scripts/ci/NpmAuditGate.Tests.ps1` and `tests/scripts/ci/Invoke-NpmAuditGate.Tests.ps1` are sharded automatically. Keep every file under 500 lines.
- Workflow test: add `tests/scripts/workflows/NpmAuditGateWorkflow.Tests.ps1` (text-read technique above) asserting: the job id/name unchanged, `node-version` line present, the step calls `Invoke-NpmAuditGate.ps1`, the old bare `npm audit --audit-level` line is gone, and the exceptions file path is passed.
- Test matrix for the filter (from the issue): excepted dev-only advisory passes; unexcepted advisory fails; expired exception fails; excepted advisory in prod fails (prod audit result fails; also test the decision function with a prod-audit-nonempty input); malformed file fails; plus transitive dependent covered, mixed advisory (one excepted, one not) fails, severity below level ignored, unparseable JSON fails, and GHSA extraction from `url`.
- actionlint is pinned at 1.7.12 in the toolchain; run it over the changed workflow (the repo's shell/workflow validation covers `.github/workflows`).
- Process-reduction ledger: next entry is `0013-npm-audit-advisory-exception.md`, plus an index row in `docs/engineering/process-reductions/README.md` (`| [0013](0013-npm-audit-advisory-exception.md) | ... | 2026-11-17 | #1204 | Active |`). Format: sections `## Summary` (lines `reduction: 0013`, `Date:`, `Issue: #1204`, `Merge commit: pending (PR #N)`), `## Reason and Evidence`, `## Files Changed`, `## Prior Text`, `## Revert Steps` (six labelled steps in order, "not applicable" where so), `## Revert Signals`. Revert Block for `.github/workflows/_npm-audit-gate.yml`: `Current` is the new step text (must occur exactly once in the file), `Prior` is the single line `run: npm audit --audit-level="$AUDIT_LEVEL"`; a second block for `config/npm-audit-exceptions.json` would have an empty `Prior` only if that file is deleted on revert, so prefer listing the new script, module, config, and tests as files to delete in revert step 1. The chain test `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` and `ProcessReductionLedger.Index.Tests.ps1` must pass.
- Execution-environment brief (six byte-identical copies): the brief names the gate only by job and check names (`NPM Audit Gate / npm audit (<manifest>)`, three mentions around its CI Shape section) and none of these change, so no brief edit is required. If the plan adds a sentence about the exception, it must update all six copies and `test_execution_environment_brief_contracts.py` expectations.

## Behavior Semantics

- Pass: production audit passes AND every advisory at or above the level in the full audit is excepted by a valid, unexpired entry AND the exception file is well formed.
- Fail (each reported with a distinct code in the log): `NPM_AUDIT_PROD_FINDING`, `NPM_AUDIT_UNEXCEPTED_ADVISORY`, `NPM_AUDIT_EXCEPTION_EXPIRED`, `NPM_AUDIT_EXCEPTION_INVALID`, `NPM_AUDIT_OUTPUT_UNPARSEABLE`.
- An exception for an advisory that no longer appears is reported as unused (informational, not a failure) so it can be removed.
- Ordering: validate the exception file first, then the production audit, then the full audit, so the log names the first cause.

## Pre-Mortem

- Review checklists: the reviewer could flag the gate as weakened or the exception as unbounded. Mitigation: one id, a 2026-12-18 expiry enforced in code, prod audit kept strict, a ledger entry with prior text and revert steps, and exceptions printed in the log.
- Coverage: the new `.psm1` and entry script are in the PoshQC coverage denominator at 85% line. Mitigation: seams for npm, file read, clock, and writers; the dot-source guard keeps the entry exit lines the only uncovered lines; a test per decision code.
- Mirror parity: not applicable for source mirrors (no skill or agent text changes, no brief edit). If the plan adds brief text, all six copies and the brief contract test must change together.
- File size: all new files stay well below 500 logical lines; the process-reduction entry is Markdown and exempt.
- Test isolation: tests use in-memory JSON strings and injected readers, no `npm` process, no temp files, no `Get-Date`; mocks target the wrapper `Invoke-NpmAuditExe` with matching `-NpmArgs` parameter names. Leak scan: no environment variable, global, or location changes without restore.
- CI-only behavior: the real gate result exists only on the runner. Mitigation: a green run of `NPM Audit Gate / npm audit (<manifest>)` on the PR head is required (`modified-workflow-needs-green-run`); the `pwsh` step must end with explicit exit codes and run with the repository-relative script resolved through `github.workspace`; paths in tests use `Join-Path` and forward slashes for Linux. Verify `--omit=dev` and the JSON shape on the runner log before relying on them.
- Evidence: record the real `npm audit --omit=dev --json` and `npm audit --json` outputs (counts only: advisory ids, severities, exit codes) per manifest under `evidence/other/` with UTC clock stamps, append-only; the ledger `Merge commit:` back-fill is done after merge.

## Open Items for the Executor

- Run both audit forms in each manifest once and confirm: `--omit=dev` is honored, the `via` object shape, and the exit codes. If `--omit=dev` is not honored, fall back to approach B for the dev-only proof only.
- `research.<timestamp>.md` was named with the date only because no clock tool was available to the researcher; rename with the clock-read UTC stamp if the validator requires `yyyy-MM-ddTHH-mm`.
