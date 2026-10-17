# Policy Audit (Re-audit) - Issue #887 (also resolves #888)

- Branch: bug/host-tools-manifest-and-bootstrap-behavior-887
- Head: b5e58fc6085af0d8c744cefc066b9c3f33e55e44 (PR #919, base main)
- Base: origin/main (`git diff origin/main...HEAD`)
- Work mode: minor-audit
- Timestamp: 2026-10-12T15-30
- Supersedes: `policy-audit.2026-10-12T15-00.md` (not edited)

## Rejected Scope Narrowing

None. The caller asked for a re-audit of the existing reduced review against new evidence. The branch diff and the full policy set remain the audit scope.

## Delta since the 15-00 audit

- `git diff --name-only 59fa06a04 HEAD` lists six files: `issue.md`, `plan.2026-10-11T08-29.md`, and four evidence files (`evidence/qa-gates/ci-poshqc-job.2026-10-12T15-17.md`, `ci-coverage-perfile.2026-10-12T15-18.md`, `coverage-delta.2026-10-12T15-19.md`, `evidence/other/reduced-audit-handoff.2026-10-12T15-19.md`). No file under `scripts/` or `tests/` changed. The production and test code audited at 15-00 is the same code that CI run 38294481892 (headSha 59fa06a04) exercised. Verified with git.
- `issue.md` diff: only AC-16 and AC-17 changed from `[ ]` to `[x]`.

## Changed-file languages

| Language | Changed files | Coverage verdict |
|---|---|---|
| PowerShell | 4 production `.psm1`/`.ps1` files, 6 test files, 1 new test suite | PASS (see Coverage Verification) |
| JSON | `scripts/host-tools.manifest.json` (new) | Not a coverage language |
| Markdown | feature docs and evidence | Not a coverage language |
| TypeScript, Python, C# | none | Zero changed files |

## Policy verdicts

| Policy | Verdict | Evidence |
|---|---|---|
| CLAUDE.md (tone, reading order) | PASS | Unchanged from 15-00; no policy file modified. |
| general-code-change (simplicity, separation, size, errors, API, I/O) | PASS | Unchanged: code identical to the 15-00 audit. Maximum file size 462 lines (`evidence/qa-gates/line-counts.2026-10-12T14-49.md`). |
| general-unit-test (no temp files, determinism, location, AAA, scenarios) | PASS | Unchanged: tests identical to the 15-00 audit. |
| powershell.md toolchain (format, analyze, test) | PASS | Local PoshQC artifacts (15-14, 15-14, 14-48) plus CI job `poshqc / PowerShell QC` success (`evidence/qa-gates/ci-poshqc-job.2026-10-12T15-17.md`). |
| quality-tiers uniform gates | PASS | Format, lint, and regression gates evidenced; coverage now PASS. |
| Coverage: >= 85% line, no changed-line regression | PASS | See Coverage Verification. |
| Coverage exclusion policy | PASS | `evidence/qa-gates/coverage-exclusion-check.2026-10-12T14-51.md`; no exclusion added. |
| tonality.md | PASS | No humor or hyperbole. |

## Coverage Verification

Authoritative source: the CI `PowerShell QC` coverage artifact `poshqc-test-results` for PR run 38294481892 (headSha 59fa06a04, equal to the code at HEAD for `scripts/` and `tests/`). The reviewer did not rerun coverage generation. The reviewer inspected the downloaded copy (`SCRATCH/887/ci-pr-887/powershell-coverage.xml`, 1,499,394 bytes) and read its LINE counters directly.

| Item | Measured | Threshold | Verdict |
|---|---|---|---|
| Repo-wide PowerShell line coverage | 16,232 covered, 1,737 missed = 90.33% | >= 85% | PASS |
| `HostTooling.psm1` | 40 covered, 2 missed = 95.24% (baseline 94.74%) | >= 85%, no regression | PASS |
| `HostBootstrapWorkspace.psm1` | 64 covered, 0 missed = 100.00% (baseline 100.00%) | >= 85%, no regression | PASS |
| `HostBootstrap.psm1` | 154 covered, 0 missed = 100.00% (baseline 100.00%) | >= 85%, no regression | PASS |
| `publish-sideloaded-extension.ps1` | 32 covered, 0 missed = 100.00% (baseline 100.00%) | >= 85%, no regression | PASS |
| Changed-line coverage (all four files) | 100.00%, uncovered none | no regression on changed lines | PASS |
| Local artifact `artifacts/pester/powershell-coverage.xml` (gitignored, scoped local run) repo-wide PowerShell line coverage | 4.04% (496 covered of 12,282) | >= 85% | FAIL (artifact only; superseded by the CI rows above, see PA-4) |
| Branch coverage | not measured by Pester | no branch gate for PowerShell | Not applicable |

Per-file counters in the artifact match `evidence/qa-gates/ci-coverage-perfile.2026-10-12T15-18.md` exactly. The line-drift guard in that evidence passed (origin/main equal to the merge base, so changed-line numbers apply to the measured source). `evidence/qa-gates/coverage-delta.2026-10-12T15-19.md` records verdict PASS with no regression against the main baseline (`evidence/baseline/ci-coverage-main.2026-10-12T14-33.md`).

The 4.04% repo-wide figure cited at 15-00 came from a scoped local run and is superseded by the CI figure above. Note: the repo-wide figure is not recorded in the committed evidence files; this audit derived it from the CI artifact. Non-blocking (PA-3).

## Evidence Location Compliance

- `git diff --name-only origin/main...HEAD -- artifacts` returned no path under `artifacts/`.
- All evidence is under `docs/features/active/2026-10-11-host-tools-manifest-and-bootstrap-behavior-887/evidence/{baseline,regression-testing,qa-gates,other}/` (canonical kinds).
- No EVIDENCE_LOCATION_OVERRIDE_REJECTED condition. `validate_evidence_locations.py` not run; the diff-path scan was used. Result: PASS.

## Re-evaluation of 15-00 findings

| ID | 15-00 severity | Current status | Severity now | Basis |
|---|---|---|---|---|
| PA-1 | non-blocking | Unchanged. Estimated filename timestamps remain disclosed in `Timestamp note` lines. | non-blocking | Process note only. |
| PA-2 | BLOCKING | RESOLVED. | closed | CI artifact shows each changed file >= 85% line coverage (95.24, 100.00, 100.00, 100.00), changed-line coverage 100.00%, no regression, repo-wide 90.33%. Evidence: `ci-poshqc-job.2026-10-12T15-17.md`, `ci-coverage-perfile.2026-10-12T15-18.md`, `coverage-delta.2026-10-12T15-19.md`. |

## Findings

| ID | Severity | Description |
|---|---|---|
| PA-1 | non-blocking | Filename timestamps on four artifacts were estimated and disclosed; use the system clock in later artifacts. |
| PA-2 | resolved (was BLOCKING) | PowerShell coverage evidence gap closed by the CI coverage artifact for PR run 38294481892. |
| PA-3 | non-blocking | Repo-wide CI line coverage (90.33%) is absent from the committed evidence; record it in a future coverage evidence file. |

| PA-4 | non-blocking | The local gitignored artifact `artifacts/pester/powershell-coverage.xml` still reports 4.04% repo-wide because it came from a scoped local run (recorded as FAIL in the coverage table for that artifact only). It is not the authoritative figure: the CI artifact for the same code reports 90.33% repo-wide and >= 95.24% for each changed file. A full-suite local coverage run would replace the stale file; the reviewer does not rerun coverage generation. |

BLOCKING findings: 0.
