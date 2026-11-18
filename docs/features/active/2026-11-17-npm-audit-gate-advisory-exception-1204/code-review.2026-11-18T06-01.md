# Code Review: npm audit gate advisory exception (#1204)

**Review Date:** 2026-11-18
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204`
**Feature Folder Selection Rule:** named by the caller and by the issue number 1204 in the folder name
**Base Branch:** `main` (resolved `origin/main` at `1b9e5746eaa5e32366de695e3f511dbc28700b08`)
**Head Branch:** `bug/npm-audit-gate-advisory-exception` at `f3df6dcf1de2dedb804d9dbb0a80007bb890281c`
**Review Type:** Initial review

---

## Executive Summary

The change replaces the bare `npm audit` workflow line with a PowerShell gate that runs a strict production-only audit and a full audit filtered by one committed, expiring, validated exception. It adds a pure decision module (408 lines), an entry script with injectable seams (249 lines), three Pester suites (761 lines in total), the exception file, a workflow edit of two lines, and process-reduction ledger entry 0013. The review read the module, the entry script, the workflow diff, the exception file, the ledger entry, and all evidence records, and ran twelve decision probes against the real module.

**What changed:**
`.github/workflows/_npm-audit-gate.yml` now runs the `Audit dependencies` step with `shell: pwsh` and calls `scripts/ci/Invoke-NpmAuditGate.ps1` with the unchanged `AUDIT_LEVEL` value. The script runs `npm audit --omit=dev --audit-level=<level>` and `npm audit --json`, and `Get-NpmAuditGateDecision` fails with one of five distinct codes unless every advisory at or above the level is excepted, unexpired, and absent from the production pass.

**Top 3 risks:**
1. The real-runner behavior of `Invoke-NpmAuditExe` (native stderr merged with `2>&1` under the Actions `Stop` preference) is covered by a local probe only; two of the three matrix legs were already green on the PR at review time, which confirms it, and the third was pending.
2. The exception matches by advisory id only; `package` and `scope` are descriptive fields that the code does not compare. The strict production pass bounds the exposure, so this is an observation.
3. The 30-day expiry will turn the gate red on 2026-12-19 unless the exception is renewed or removed; this is intended and recorded in the ledger revert signals.

**PR readiness recommendation:** **Conditional Go** — one awaiting_ci coverage finding (F1); no code defect found.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/ci/NpmAuditGate.psm1` | `Get-NpmAuditGateDecision`, exception match by `$_.Id` | An exception covers an advisory by id alone; the entry's `package` and `scope` fields are printed but not compared with the advisory. | Optional: compare the package name when the id matches, or state in the spec that the id is the sole key. | A reused advisory id for another package cannot occur for a GHSA, and the strict production pass already rejects any production reach. | Code read; probe `excepted` and `plus other` in the review run |
| Info | `scripts/ci/Invoke-NpmAuditGate.ps1` | `Invoke-NpmAuditExe`, `exit 0`, `exit 1` | Five of 55 lines are uncovered: the two-line npm process wrapper and the two guarded exit lines. | None; these are the thinnest host-bound lines and a local end-to-end run is recorded. | Line coverage 90.91% is above the 85% threshold. | `evidence/qa-gates/final-qc-pester.2026-11-18T05-43.md`; shard coverage union 50/55 |
| Blocker | `artifacts/pester/powershell-coverage.xml` | n/a | The canonical merged coverage file was rewritten at 05:55 UTC by a later two-suite ledger run and now reads 0.82% repo-wide, so the repo-wide PowerShell line coverage cannot be verified locally (F1, awaiting_ci). | Close with the poshqc CI shard coverage on the PR head; the per-file figures were re-derived from untouched shard files and equal the evidence record. | The 85% repo-wide floor needs a verifiable full-run figure. | Shard files `shard-3` through `shard-8` dated 05:39 to 05:41 UTC; policy audit section 8 |

One Blocker, F1, classed awaiting_ci; no Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Fail-closed by construction: an unreadable or blank exception file, trailing garbage after the audit JSON, a JSON error object, a missing `vulnerabilities` object, a missing exit code, and a throwing seam all yield a failing decision (probes and `INA-FAIL-CLOSED-ENVELOPE`). An unknown or missing severity ranks above every level, so it is never ignored.
- The gate cannot be weakened through the workflow: the level is passed through unchanged, the workflow text has no `--omit`, and the full audit includes dev dependencies. Expiry is strict (`expires` before the UTC date fails; the date itself passes), and every entry is checked even when unused.
- The exception file contract is closed: version, key set, field types, GHSA id pattern, real calendar dates in `yyyy-MM-dd`, ordering of dates, duplicate ids, and duplicate JSON keys (through a custom `System.Text.Json` conversion that throws on a repeated key) are each rejected with `NPM_AUDIT_EXCEPTION_INVALID`.
- The strict production pass has no exception logic, so an excepted advisory that reaches a production dependency still fails with `NPM_AUDIT_PROD_FINDING`.
- Applied exceptions are printed with id, package, scope, approved_at, expires, days remaining, and reason, to the log and to `GITHUB_STEP_SUMMARY`; unused exceptions are reported as informational.

#### API and safety notes

- Every function is an advanced function with `OutputType`; the audit level is constrained by `ValidateSet`; the date by `ValidatePattern`. The single `PSUseSingularNouns` suppression on `Get-NpmAuditAdvisories` is justified in place because the name is fixed by the spec.
- Boundaries are injectable (`-ReadFile`, `-GetUtcDate`, `-OutputWriter`, `Invoke-NpmAuditExe`); the module reads no clock, file, or environment, which `NAG-EXC-VALID-PASSES` asserts through an AST scan for forbidden cmdlets.
- Workflow safety: `${{ github.workspace }}` and `${{ inputs.audit-level }}` reach the shell as a path and an environment variable respectively; the level is not interpolated into the command text, and the script re-validates it against the closed set.

#### Error handling and logging

- The npm wrapper sends stderr lines to the log through the information stream and returns only standard output and the exit code, so an npm warning cannot corrupt the audit JSON. A first failure to read the exception file is logged and then fails on validation.
- A defect found during the work (the code printed twice in an invalid-file summary) was fixed and pinned by a test.

---

## Test Quality Audit

The three suites build all inputs in memory, mock the npm wrapper with the production parameter name, and start no process. 111 tests were added; the full run records 27605 tests, 0 failures, 0 errors, 18 pre-existing skips. Coverage of both new production files is above 85% lines.

### Reviewed test and QA artifacts

- `tests/scripts/ci/NpmAuditGate.Tests.ps1` (406 lines) — exception-file, advisory-extraction, and decision cases; every one of the five failure codes is asserted; includes boundary and ordering cases.
- `tests/scripts/ci/Invoke-NpmAuditGate.Tests.ps1` (285 lines) — exit mapping per code, npm arguments (`--omit=dev` plus unchanged level, then bare `--json`), writer targets, dot-source guard, fail-closed envelope. No process, no disk.
- `tests/scripts/workflows/NpmAuditGateWorkflow.Tests.ps1` (70 lines) — text-reads the workflow and pins job id, name, matrix, node-version, script call, exceptions path, level source, `shell: pwsh`, and the absence of the old line and of `--omit`.
- `evidence/other/gate-script-local-run.2026-11-18T05-28.md` — real npm 11.20.0 run per manifest plus one negative run; supplementary observation, not a test lane.
- `evidence/other/npm-audit-observation.2026-11-18T03-41.md` — six result blocks and `OMIT_DEV_HONORED: yes`, which justifies the strict production pass design.

### Quality assessment prompts

- **Determinism:** the clock, file read, and npm enter only through seams; no sleep or wall-clock read in tests.
- **Isolation:** one behavior per test id; shared state is reset per test.
- **Speed:** the 111 tests ran inside a 770.94 s run of 27605 tests with 8 workers.
- **Diagnostics:** exact-code assertions and `-Because` text identify the failing rule.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | The diff holds no token, key, or credential; the exception reason cites public advisory data only. |
| No unsafe subprocess or command construction | ✅ PASS | npm is called with an argument array through the call operator; the level is validated by `ValidateSet` before use. |
| Input validation at boundaries | ✅ PASS | Exception file and audit JSON are parsed strictly and fail closed (twelve probes in this review). |
| Error handling remains explicit | ✅ PASS | A top-level envelope converts any exception to a failed decision and exit 1; no empty catch swallows a failure into success. |
| Configuration / path handling is safe | ✅ PASS | The exception path is passed from the workflow; no absolute path appears in any committed artifact (diff scan returned nothing). |
| Audit level not lowered, no wholesale dev omission | ✅ PASS | `NAW-AUDIT-LEVEL-FROM-ENV`, `NAW-BARE-AUDIT-LINE-ABSENT`, `INA-NPM-ARGS`. |
| Process-reduction ledger entry 0013 | ✅ PASS | Prior text `run: npm audit --audit-level="$AUDIT_LEVEL"`, Current and Prior blocks, six ordered revert steps, revert signals, index row; ledger tests in the full run pass. |
| No new Python, no temporary files, evidence append-only | ✅ PASS | No `.py` path in the diff; test grep clean; no evidence file modified or deleted after its adding commit. |
| File size | ✅ PASS | Largest covered file 408 logical lines; no file at or above 500, none at 700. |

---

## Research Log

No external research was required. The decision logic was checked against the spec and the recorded real `npm audit` output; behavior of the PR checks was read through `gh pr checks 1205`.

---

## Verdict

The change is ready for normal PR flow once finding F1 (awaiting_ci) is closed. The gate still fails on any advisory at or above the audit level unless it is excepted, unexpired, and confined to development dependencies; it fails closed on unparseable audit output and on a malformed or unreadable exception file; it prints every applied exception; and it neither lowers the audit level nor omits dev dependencies from the full audit. The one blocking finding, F1, is a coverage-evidence item that CI closes; no code defect was found.

The one open item is the CI result on the PR head: at review time two NPM Audit Gate legs and the `npm-audit` caller legs were green, and the remaining checks were still running.
