# Policy Audit - Issue #887 (also resolves #888)

- Branch: bug/host-tools-manifest-and-bootstrap-behavior-887
- Head: 59fa06a04f8b75dcf9dc43466f8758f2345bd2c8
- Base: origin/main (`git diff origin/main...HEAD`, 39 files changed)
- Work mode: minor-audit
- Timestamp: 2026-10-12T15-00

## Rejected Scope Narrowing

None. The caller did not narrow the audit scope. The caller classified AC-16 and AC-17 as pending-CI; that is a status classification for criteria that depend on a PR CI run that does not yet exist, not a scope reduction. The full branch diff was audited.

## Changed-file languages

| Language | Changed files | Coverage verdict |
|---|---|---|
| PowerShell | 4 production `.psm1`/`.ps1` files, 6 test files, 1 new test suite | FAIL (see Coverage Verification) |
| JSON | `scripts/host-tools.manifest.json` (new) | Not a coverage language |
| Markdown | feature docs and evidence | Not a coverage language |
| TypeScript, Python, C# | none | Not applicable (zero changed files) |

## Policy verdicts

| Policy | Verdict | Evidence |
|---|---|---|
| CLAUDE.md (tone, reading order) | PASS | Artifacts and evidence use neutral wording. Policy files were not modified (`git diff` shows no change under `.claude/rules/` or `.github/instructions/`). |
| general-code-change: simplicity, separation of concerns | PASS | Streaming is a parameter-set switch on the existing I/O seam `Invoke-HostNativeCommand`; forwarding logic stays in the entry script because `SideloadedExtensionPublish.psm1` is 456 lines. |
| general-code-change: file size limit (500 lines) | PASS | `evidence/qa-gates/line-counts.2026-10-12T14-49.md`: maximum is `HostBootstrap.psm1` at 462 lines. Confirmed independently with `git grep -c ''` at HEAD (462; manifest test suite 168). |
| general-code-change: error handling | PASS | Nonzero-exit throw messages are unchanged; no catch-all handlers added. |
| general-code-change: API compatibility | PASS | Capture mode and its return shape are unchanged. `DefaultParameterSetName = 'Capture'` keeps existing callers valid. |
| general-code-change: I/O boundaries / dependencies | PASS | No new dependency. I/O remains isolated in `Invoke-HostNativeCommand`. |
| general-unit-test: no temporary files in tests | PASS | Grep of the changed test files for `New-TemporaryFile`, `GetTempPath`, `TestDrive`, `Set-Content`, `Out-File`, `$env:TEMP` returned no match. The manifest suite reads the committed manifest. |
| general-unit-test: determinism / banned APIs | PASS | Grep for `Start-Sleep` and `Get-Date` in the changed test files returned no match. |
| general-unit-test: test file location | PASS | New suite is `tests/scripts/host-tools.manifest.Tests.ps1`, mirroring `scripts/host-tools.manifest.json`; others are under `tests/scripts/dev-tools/`. |
| general-unit-test: AAA structure and descriptive names | PASS | Reviewed diffs of `HostTooling.Tests.ps1` and `publish-sideloaded-extension.Tests.ps1`; each case carries a scenario-ID name and Arrange/Act/Assert comments or equivalent structure. |
| general-unit-test: scenario completeness (positive, negative, edge) | PASS | Forwarding tests cover bound, inherited, default, and bound-false-wins cases; Confirm None/Low/High boundaries; stale-`$LASTEXITCODE` cases for both modes; nonzero-exit throw messages. |
| powershell.md toolchain (format, analyze, test) | PASS | `evidence/qa-gates/poshqc-format.2026-10-12T15-14.md` (ok, no tracked change), `poshqc-analyze.2026-10-12T15-14.md` (ok), `poshqc-test.2026-10-12T14-48.md` (ok; JUnit tests=633 failures=0 disabled=2). Note that the MCP results carry status only; no finding list. |
| quality-tiers: uniform gates (format, lint, regression) | PASS | As above. Expect-fail and pass-after-fix evidence exists for the new tests (`evidence/regression-testing/`). |
| Coverage: >= 85% line, no changed-line regression | FAIL | Local artifact shows 4.04% repo-wide and no entry for the changed files; see Coverage Verification. |
| Coverage exclusion policy | PASS | `evidence/qa-gates/coverage-exclusion-check.2026-10-12T14-51.md`: no change under `config` or `scripts/powershell/PoshQC/settings`; no production file added to an exclusion. |
| tonality.md | PASS | Reviewed artifacts contain no humor or hyperbole. |

## Coverage Verification

PowerShell has changed files. A local artifact exists at `artifacts/pester/powershell-coverage.xml` (modified 2026-10-12 14:48, gitignored, produced by the scoped local PoshQC test run over `tests/scripts/dev-tools` and the new manifest suite). The earlier revision of this audit overlooked it and recorded PENDING-CI. The reviewer does not rerun coverage generation.

Measured from that artifact:

- Repo-wide PowerShell line coverage: 496 covered of 12,282 lines = 4.04% (final LINE counter missed=11786 covered=496). This is below the 85% floor.
- Changed files: a search of the artifact for `HostTooling`, `HostBootstrap`, `HostBootstrapWorkspace`, `HostVerification`, and `publish-sideloaded-extension` returns no match. None of the four changed production files has a measurable per-file figure in this artifact, so the per-file 85% requirement and the no-regression requirement cannot be shown from it.
- Cause (likely, not confirmed): the artifact comes from a scoped local run, so the repo-wide figure reflects the scope selected rather than the true suite. The authoritative figure is the CI `PowerShell QC` artifact for the PR head, which does not exist yet (plan tasks P2-T10..P2-T14 are open for this reason).

Coverage row verdicts (PowerShell):

| Row | Verdict |
|---|---|
| Repo-wide line coverage >= 85% | FAIL (4.04% in the only available artifact) |
| Changed files line coverage >= 85% / no regression | FAIL (changed files absent from the available artifact; no evidence of coverage) |
| Branch coverage | Not applicable to PowerShell (Pester does not measure branches) |

Resolution path: the FAIL is cleared when the CI `PowerShell QC` coverage artifact for the PR head shows >= 85% for each changed file with no changed-line regression versus the main baseline (`evidence/baseline/ci-coverage-main.2026-10-12T14-33.md`: HostTooling 94.74%, HostBootstrapWorkspace 100%, HostBootstrap 100%, publish-sideloaded-extension 100%). Per the caller's classification, AC-17 in the feature-audit remains pending-CI; the policy-audit coverage rows are recorded as FAIL because a coverage artifact exists and does not meet the floor. The CI gate must confirm the following before merge:

- Line coverage >= 85% for each changed file: `HostTooling.psm1`, `HostBootstrapWorkspace.psm1`, `HostBootstrap.psm1`, `publish-sideloaded-extension.ps1`.
- No changed-line regression against the main baseline (`evidence/baseline/ci-coverage-main.2026-10-12T14-33.md`: HostTooling 94.74%, HostBootstrapWorkspace 100%, HostBootstrap 100%, publish-sideloaded-extension 100%).
- No branch threshold applies to PowerShell (Pester measures line and command coverage only).

Risk observation (non-blocking): the new `Stream` branch and the new forwarding branches each have dedicated tests, so no uncovered new line was identified by inspection.

## Evidence Location Compliance

- `git diff --name-only origin/main...HEAD` contains no path under `artifacts/`; grep for `^artifacts/` returned no match.
- All evidence files are under `docs/features/active/2026-10-11-host-tools-manifest-and-bootstrap-behavior-887/evidence/{baseline,regression-testing,qa-gates,other}/`, which are canonical kinds.
- No EVIDENCE_LOCATION_OVERRIDE_REJECTED condition arose. The `validate_evidence_locations.py` script was not run; the diff-path scan above was used instead (non-blocking process note).
- Result: PASS.

## Findings

| ID | Severity | Description |
|---|---|---|
| PA-1 | non-blocking | Three QA-gate artifacts (`poshqc-analyze`, `poshqc-format`, `pass-after-fix`, `ci-coverage-main`) carry filename timestamps that differ from the recorded modification time. Each artifact discloses the estimate in a `Timestamp note`. The evidence-and-timestamp convention expects filename timestamps taken from the system clock. No corrective action required for merge; use the system clock in later artifacts. |
| PA-2 | BLOCKING | PowerShell coverage rows are FAIL: repo-wide 4.04% in the only available artifact and no per-file data for the four changed production files. Cleared by the CI `PowerShell QC` coverage artifact for the PR head (see `remediation-inputs.2026-10-12T15-00.md`). |

BLOCKING findings: 1 (PA-2, resolved at the CI gate).
