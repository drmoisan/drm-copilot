# Feature Audit — Issue #847 (PowerShell aggregate line coverage below floor)

- Timestamp: 2026-10-10T01-41
- Branch: `bug/powershell-aggregate-line-coverage-below-floor-847`
- Base: `main`; merge-base `460cd755de560b733be0c471d1d144e553fbe0e5`
- Head reviewed: `d2224baa86700fe445c87008228bd3efe56dd6f8`
- Work mode: `full-bug` (marker `- Work Mode: full-bug` in `issue.md:12`)
- AC source: `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/spec.md` (`## Acceptance Criteria`, AC-01..AC-15)

## Total Blocking Findings: 0

## Scope and Baseline

- Scope: full branch diff `git diff 460cd755de560b733be0c471d1d144e553fbe0e5...HEAD` (51 files: 19 changed PowerShell files plus 1 deleted, 31 Markdown files). No TypeScript, Python, or C# files changed.
- Baseline: `main` at `460cd755`, measured by CI run 38005028184 (`evidence/baseline/pwsh-test-coverage-baseline.2026-10-09T23-46.md`).
- Head measurement: CI run 38011932558 at `1c3d1a4c6`; PowerShell content identical to `d2224baa8` (`git diff --stat 1c3d1a4c6 HEAD` lists only Markdown).

| Metric | Baseline (CI run 38005028184 at `460cd755`) | Head (CI run 38011932558 at `1c3d1a4c6`, PowerShell-identical to `d2224baa8`) | Delta |
|---|---|---|---|
| Aggregate PowerShell line coverage | 13328/15738 = 84.69% (FAIL vs 85%) | 13918/15816 = 88.0% (PASS) | +590 covered, +3.31 points |
| Coverage population | `source=config; files=174` | `source=config; files=178` | +5 modules, -1 deleted helper |
| Pester tests | 6534, 0 failures | 6709, 0 failures | +175 |
| Target files (4) | 0/177, 0/153, 0/138, 0/43 | entry scripts 7/7, 7/7, 24/24; helper deleted; modules 94.74%-100% | all >= 85% |
| Files below 85% repo-wide | 42 | 38 | -4 |

## Acceptance Criteria Inventory

- Source file: `spec.md`, heading `## Acceptance Criteria` (checkbox format), resolved from work mode `full-bug`.
- Items: 15 (AC-01..AC-15).
- Checkbox state at review start: AC-01..AC-13 checked; AC-14 and AC-15 unchecked.
- Caller direction: AC-14 (PR description) and AC-15 (PR CI) are evaluated as pending later-stage criteria unless the branch prevents them.

## Acceptance Criteria Evaluation

| AC | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|
| AC-01 | Pre-change baseline under `evidence/baseline/` with aggregate and the four per-file rows, naming the commit | PASS | `evidence/baseline/pwsh-test-coverage-baseline.2026-10-09T23-46.md`: commit `460cd755`, aggregate 13328/15738 = 84.69%, rows for `bootstrap-host.ps1` 0/177, `verify-host.ps1` 0/153, `publish-sideloaded-extension.ps1` 0/138, `bootstrap-host.helpers.ps1` 0/43; population line `source=config; files=174`. |
| AC-02 | Aggregate >= 85% from a full run with `source=config`, no narrowing, no `-ScanFolders`, no exclusion | PASS | `reduction.txt:3` `AGGREGATE covered=13918 missed=1898 total=15816 pct=88.0 PASS`; `poshqc-job.log:839` `Code coverage population: source=config; files=178`; coverage config files not in diff. Recorded in `evidence/qa-gates/coverage-aggregate.2026-10-10T01-18.md` (canonical kind; AC text says `evidence/coverage/`, see FA-N1). |
| AC-03 | Each new/modified production file >= 85% | PASS | `reduction.txt:4-11`: HostTooling 94.74, HostBootstrapWorkspace 100, HostBootstrap 100, HostVerification 100, SideloadedExtensionPublish 97.84, bootstrap-host.ps1 100, verify-host.ps1 100, publish-sideloaded-extension.ps1 100. Recorded in `evidence/qa-gates/coverage-per-file.2026-10-10T01-18.md`. |
| AC-04 | Entry-script `param` blocks unchanged from base | PASS | Reviewer side-by-side read of `git show 460cd755:<path>` vs head: bootstrap lines 1-18, verify lines 1-3, publish lines 1-51 (including `[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]` and both default expressions) are identical. Executor evidence `evidence/qa-gates/entry-param-block-parity.2026-10-10T01-18.md` (git-diff hunk method per the amendment instead of AST; operator-imposed). |
| AC-05 | Each entry script invoked with `&` per exit path, asserting output and `$LASTEXITCODE` | PASS | `reduction.txt:29-50`: tokens `AC05-BOOTSTRAP-DRYRUN-EXIT0`, `-NONWINDOWS-EXIT1`, `-NOWINGET-EXIT1`, `AC05-VERIFY-PASS-EXIT0`, `-ONEFAIL-EXIT1`, `-NOMANIFEST-EXIT1`, `AC05-PUBLISH-VSIX-OUTPUT`, `-WHATIF-NOSEAMS`, `-CODECOMMAND-BOUNDEMPTY`, `-CODECOMMAND-UNBOUND` each with 1 passing hit. Test code read in `bootstrap-host.Tests.ps1`, `verify-host.Tests.ps1`, `publish-sideloaded-extension.Tests.ps1`. |
| AC-06 | Tests demonstrate preserved behaviors (missing manifest both scripts, pip fallback, RunOnce set/clear, EPERM limit/backoff, step order) | PASS | `reduction.txt:51-95`: `AC06-BOOTSTRAP-NOMANIFEST-THROWS`, `AC06-VERIFY-NOMANIFEST-THROWS`, `AC06-POETRY-PIP-FALLBACK`, `AC06-NONPOETRY-RETHROW`, `AC06-RUNONCE-SET-APPLY-AND-RESUME`, `AC06-RUNONCE-NOT-SET-WITHOUT-BOTH` (2), `AC06-RUNONCE-CLEARED-AFTER-APPLY`, `AC06-EPERM-RETRY-LIMIT`, `AC06-EPERM-BACKOFF`, `AC06-NONEPERM-RETHROW`, `AC06-PUBLISH-STEP-ORDER`, `AC06-PUBLISH-SKIP-SWITCHES` (3), `AC06-PUBLISH-VSIX-MISSING-THROWS`, `AC06-PUBLISH-CODECOMMAND-NOTFOUND-THROWS`, `AC06-VERIFY-SECTION-ORDER`, `AC06-VERIFY-EXIT-BOUNDARY`, and others, all passing. Reviewer parity check in `code-review.2026-10-10T01-41.md` found no outcome difference (CR-N1 output timing is non-functional). |
| AC-07 | No temp files; all host calls mocked; recorded search | PASS | Reviewer grep of the 11 files: no `TestDrive:`, `New-TemporaryFile`, `GetTempPath`, `$env:TEMP`, `$env:TMP`. 75 fail-closed default mocks. Full suite 0 failures. Executor evidence `evidence/qa-gates/test-isolation-search.2026-10-10T01-18.md`. |
| AC-08 | No `Import-ScriptFunction`; publish test rewritten and keeps the scaffold Describe | PASS | Reviewer grep: no match in the 11 files. `publish-sideloaded-extension.Tests.ps1:131` `Describe "scaffold extension package identity"`. Executor evidence `import-scriptfunction-search.2026-10-10T01-18.md`. |
| AC-09 | Module-scope StrictMode and EAP Stop; no `exit` in modules; no `-Force` in entry imports | PASS | All 5 modules set both at lines 12-15; grep `^\s*exit\b` finds only the two entry scripts; no `Import-Module ... -Force` in entry scripts. Executor evidence `module-preference-and-exit-check.2026-10-10T01-18.md`. |
| AC-10 | `bootstrap-host.helpers.ps1` deleted and unreferenced outside `docs/features/**` | PASS | `git diff --name-status`: `D scripts/dev-tools/bootstrap-host.helpers.ps1`. Repository grep for `bootstrap-host.helpers`: 22 files, all under `docs/features/`. |
| AC-11 | Toolchain clean in one pass: format no changes, PSSA zero errors/warnings, full Pester zero failures; recorded in `evidence/qa-gates/` | PASS | CI run 38011932558: Format step all `Already formatted`, no error; `poshqc-job.log:832` PSSA no findings; `Tests Passed: 6699, Failed: 0`. Evidence `pwsh-format`, `pwsh-analyze`, `pwsh-test-full`, `toolchain-loop-closure` (all `2026-10-10T01-18`). |
| AC-12 | Every new/modified `.ps1`/`.psm1` <= 500 lines | PASS | `wc -l`: max 463 (`HostBootstrap.psm1`); all 19 files <= 500. |
| AC-13 | Diff lists no excluded path | PASS | `git diff --name-status 460cd755...HEAD` reviewed: no `.codex/`, `.claude/rules/`, `.github/instructions/`, `.claude/hooks/validate-feature-review-coverage.ps1`, `config/poshqc-coverage.json`, `scripts/powershell/PoshQC/**`, `quality-tiers.yml`, `.vscode/tasks.json`, `scripts/dev-tools/vscode-cli.helpers.ps1`. |
| AC-14 | Potential-issue entry exists describing the missing manifest and bash script, and the PR description references it | PENDING (later stage) | First clause met: `docs/features/potential/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md` describes both missing files and their readers. Second clause depends on the PR description, which does not exist yet. Nothing in the branch prevents it. |
| AC-15 | CI `poshqc` job passes on the PR head commit | PENDING (later stage) | No PR exists yet. Indicator: dispatched run 38011932558 on `1c3d1a4c6` passed format, analyze, and test; commits after it change only Markdown. Nothing in the branch prevents it. |

## Summary

13 of 15 acceptance criteria pass on the branch as delivered; AC-14 and AC-15 are pending the PR stage and nothing in the branch prevents them. Aggregate PowerShell line coverage moves from 84.69% to 88.0%, every changed production file is at or above 85%, the toolchain is clean in CI, and the module extraction preserves the three scripts' parameters, messages, and exit codes. Blocking findings: 0. Non-blocking findings: 3.

## Acceptance Criteria Check-off

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/spec.md`
- Total AC items: 15
- Checked off (delivered): 13 (AC-01..AC-13, already checked by the executor; reviewer verdict PASS for each, so no check-off change was needed)
- Remaining (unchecked): 2
- Items remaining:
  - AC-14: A follow-up potential-issue entry exists under `docs/features/potential/` describing the missing `scripts/host-tools.manifest.json` (read by `bootstrap-host.ps1` and `verify-host.ps1`) and the missing `scripts/bash/bootstrap-host.sh` referenced by `bootstrap-host.ps1`, and the PR description references it. (PENDING: PR description)
  - AC-15: The CI `poshqc` job passes on the PR head commit (CI-dependent; verified from the PR checks). (PENDING: PR CI)
- Newly checked off by this review: none. AC-14 and AC-15 remain unchecked per the check-off protocol.

## Operator Decisions Applied (not findings)

- Folding and deleting `scripts/dev-tools/bootstrap-host.helpers.ps1` into the new modules is accepted.
- The missing host-tools manifest and bash bootstrap defect is out of scope and recorded as the potential entry above.
- Verification through PoshQC MCP tools and CI artifacts instead of local `pwsh` (`evidence/other/execution-amendment.2026-10-09T23-50.md`).

## Findings

### Blocking

None.

### Non-blocking

| ID | Finding | Recommendation |
|---|---|---|
| FA-N1 | AC-02 and AC-03 name `evidence/coverage/`; the records are in `evidence/qa-gates/`, which is the canonical location under `evidence-and-timestamp-conventions` (`coverage` is not a canonical kind). The criteria's substance is met. | State the reconciliation in the PR description. |
| FA-N2 | Bootstrap native-command output is now emitted after each process exits rather than streamed (code-review CR-N1). This is not listed among the spec's accepted non-functional changes. Outcomes, messages, and exit codes are unchanged. | List it as an accepted non-functional change in the PR description, or address in a follow-up. |
| FA-N3 | `issue.md:5` records the promoted path as `docs/features/active/powershell-aggregate-line-coverage-below-floor/`, which differs from the actual folder `2026-10-08-powershell-aggregate-line-coverage-below-floor-847`. Informational; generated by promotion tooling. | None required. |

## Assumptions

- PowerShell content at `1c3d1a4c6` (the CI-measured head) is identical to `d2224baa8`; verified with `git diff --stat 1c3d1a4c6 HEAD`, which lists only Markdown files.
- The CI coverage XML is the authoritative full-run artifact for AC-02/AC-03 per the operator amendment.
