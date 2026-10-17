# Research: host bootstrap does not install poetry (Issue #930)

- Work mode: minor-audit. Research only; no source changes.
- Timestamp note: the researcher toolset had no shell or clock access, so this filename timestamp is an estimate (the folder already holds `plan.2026-10-15T15-45.md`), not a host-clock read.

## Current State

All line numbers refer to files in this worktree.

### Call graph of `Invoke-BootstrapHost` (`scripts/dev-tools/HostBootstrap.psm1:303-460`)

| Order | Line | Step |
|---|---|---|
| 1 | 333-339 | Precondition errors: non-Windows host, winget missing (both `Write-Error -ErrorAction Stop`) |
| 2 | 341-343 | `Resolve-WorkspaceRoot`, `Initialize-WorkspaceRoot` (HostBootstrapWorkspace) |
| 3 | 345 | `Install-WslIfMissing` |
| 4 | 347-349 | `Get-HostManifest`, `Get-WingetPackagesFromManifest` (throws on empty list, :199-202), `Get-ProjectRepositoriesFromManifest` |
| 5 | 351-355 | RunOnce registration (Apply and EnableAutoResumeAfterReboot only) |
| 6 | 359-361 | winget loop: `Install-WithWinget -Id $pkg.id -Name $pkg.name -ApplyMode:$Apply` per manifest entry |
| 7 | 363-366 | Session PATH refresh: `Get-SessionPathFromMachineAndUser`, then `Set-HostEnvironmentVariable ... -Target Process` |
| 8 | 369-380 | Graphite CLI via npm (needs node from step 6 on PATH from step 7) |
| 9 | 382-387 | Apply: `Install-HostPowerShellModule` per manifest module |
| 10 | 389-393 | Apply: `Sync-ProjectsFromManifest` |
| 11 | 395-414 | Apply and not `-SkipProjectPoetryInstall`: `Resolve-ProjectRepoRoot`, then `Invoke-HostBootstrapPoetry -PoetryArgs install --no-interaction` inside Push-Location. A failure is caught and reported as `[WARN] Poetry dependency install failed; python quality tools may be unavailable` (:404-406) |
| 12 | 419-433 | Dry run: Would-lines, including `- Would install Python project dependencies via poetry` (:431) |
| 13 | 435-459 | Apply: `Invoke-HostBootstrapVerifyScript` (verify-host.ps1), RunOnce cleanup |

### Where poetry is used or referenced

- `Install-WithWinget` (`:36-86`): probes `Get-Command $Name` (:53); the `catch` (:77-85) calls `Install-PoetryWithPip` only when `$Name -eq "poetry"`.
- `Install-PoetryWithPip` (`:117-160`): returns `[OK]` if poetry exists (:128-131). In dry run it prints `- Would install poetry using python -m pip install --user poetry` (:133-136). In apply mode it requires `python` on PATH (throws `python is required to install poetry fallback`, :138-141). It runs `python -m pip install --user poetry` with `-StreamToHost` (:144) and throws on a nonzero exit (:145-147). It then adds the pip user-scripts directory to the User Path (:149-154) and refreshes the Process Path (:156-159). The function is exported (:462).
- `Invoke-HostBootstrapPoetry` (`HostBootstrapWorkspace.psm1:253-283`): runs `poetry`, falls back to `python -m poetry`, throws `python is required to execute poetry` when neither exists. This is a second fallback for step 11 only.
- Verification: `HostVerification.psm1` `Get-PoetryVersionInfo` (:17-60) accepts `poetry` or `python -m poetry`. `minimumVersions.poetry` (2.3.2) is read at `HostVerification.psm1:149-152`, not by bootstrap.
- `verify-host.ps1` is invoked at step 13, so verification currently reports poetry missing on a host that lacks it.

### Ordering constraint

Python must be installed and visible on the Process PATH before `Install-PoetryWithPip` runs in apply mode. `python` comes from the winget loop (`Python.Python.3.13`, manifest line 6), and the PATH refresh at `:363-366` is what makes a freshly installed python visible. The poetry step must therefore run after `:366`, not inside or immediately after the loop body. It must also run before step 11 and before verification. Placing it after `:366` and before the Graphite block (`:368`) satisfies all three.

### Manifest (`scripts/host-tools.manifest.json`)

Winget entries: git, python (`Python.Python.3.13`), node, pwsh, gh, code. There is no poetry entry. `minimumVersions.poetry` = `2.3.2` is a verification pin only.

## Candidate Approaches

### Option (a): add a poetry winget entry

- Verifiable package ID: none. A repository-wide search found `Python.Poetry` only as an inline test fixture ID (`HostBootstrap.Tests.ps1:96,240,247`, `HostBootstrap.Invoke.Tests.ps1:54`). It appears in no production file and in no evidence artifact as a verified winget ID. #887 research (`research.2026-10-11T08-40.md:92`) states "do not list a poetry winget entry. Listing an unverified ID only to make winget fail and trigger the pip fallback would make an error path load-bearing." No winget query could be run from this toolset, so an ID cannot be verified and must not be invented.
- Even with a verified ID, poetry's official installers are pipx and the install script, and a winget package for it would depend on a third-party publisher. This was not verified here.
- Consequences: a manifest edit requires changes to `host-tools.manifest.Tests.ps1`, and on a host where winget fails, the pip fallback remains the only working path. Rejected.

### Option (b): call `Install-PoetryWithPip` directly after the winget loop (recommended)

- Add one call in `Invoke-BootstrapHost` after the PATH refresh (`:366`). `Install-PoetryWithPip` already handles idempotence (`[OK]` when present), dry run, PATH updates, and failure messages, so no new logic is needed.
- Manifest stays unchanged; no unverifiable data enters the repo.
- Fits repo conventions: the new step reuses an existing exported function with an existing mock seam (`Mock -CommandName Install-PoetryWithPip -ModuleName HostBootstrap` is already used at `HostBootstrap.Tests.ps1:94`).
- Limitation: pip availability. If `Get-Command python` resolves to the Microsoft Store alias (known pre-existing behavior, #887 research item 6, line 396), the pip run exits nonzero and the existing throw is raised. This is out of scope, matches the existing failure mode, and is unchanged by this fix.

### Recommendation

Option (b). Rationale: no verifiable winget ID exists in repository evidence; the code path is already implemented and tested in isolation; the change is a few lines; dry-run semantics come for free.

Proposed shape (illustrative, not code to commit verbatim):

```
$sessionPath = Get-SessionPathFromMachineAndUser
if ($sessionPath) { Set-HostEnvironmentVariable ... }

Install-PoetryWithPip -ApplyMode:$Apply     # new, after the PATH refresh
```

Failure semantics: let `Install-PoetryWithPip` throw in apply mode (fail fast, consistent with the winget loop at `:359-361`, which also throws). The later project install at `:402` already has its own warn-only handling and a `python -m poetry` fallback, so a thrown poetry install is the earlier and clearer signal.

## Behavior Semantics

- Poetry present on PATH: output `[OK] poetry already installed`; no pip call.
- Poetry absent, apply mode, python present: pip install, User Path updated, session Path refreshed.
- Poetry absent, apply mode, python absent: throw `python is required to install poetry fallback`.
- Poetry absent, dry run (no `-Apply`): output `- Would install poetry using python -m pip install --user poetry` and no host side effects (the dry-run branch at `:133-136` returns before touching python, so it works even when python is not yet installed in a dry run).
- Poetry already present from the winget loop (a future manifest entry named poetry): `Install-PoetryWithPip` prints `[OK]`; no double install.

### Should the winget-failure catch remain?

With the direct call, the catch (`HostBootstrap.psm1:77-82`) is unreachable for the committed manifest (no entry named poetry). Recommendation: keep it for this fix. Reasons: it is pinned by `AC06-POETRY-PIP-FALLBACK` (`HostBootstrap.Tests.ps1:91-101`) and `AC06-NONPOETRY-RETHROW` (`:103-110`); removing it expands the change beyond a minor-audit fix; a future manifest entry named poetry still gets a fallback; `Install-PoetryWithPip` is idempotent, so both paths coexist. Removing the dead branch can be a separate cleanup if wanted.

## Existing Tests and Impact

| File:line | Test | Impact |
|---|---|---|
| `HostBootstrap.Invoke.Tests.ps1:40-83` | `Describe 'Invoke-BootstrapHost'` BeforeEach. `Get-Command` mock returns only winget and npm (:42-48), so poetry and python are missing. `Invoke-HostNativeCommand` default mock throws (:21). | Every apply-mode case would reach the real `Install-PoetryWithPip`, which throws `python is required...` (python missing). Add `Mock -CommandName Install-PoetryWithPip -ModuleName HostBootstrap -MockWith { }` next to :69 (or a Get-Command/python fixture) or the apply cases at :166-270 fail |
| `HostBootstrap.Invoke.Tests.ps1:86-106` | `AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS` | Still passes. Dry run asserts `Times 0` for seams listed at :101; `Install-PoetryWithPip` is not in that list. The seam-list check does not cover it, so add `Install-PoetryWithPip` to a dry-run assertion only if the real function is left unmocked (see new tests) |
| `HostBootstrap.Invoke.Tests.ps1:120-134` | `AC07-DRYRUN-COMMITTED-MANIFEST` | Still passes. Its count filter is `- Would install * using winget id *` (:131); the pip dry-run line does not match it, so the winget-line count stays equal to the manifest count |
| `HostBootstrap.Invoke.Tests.ps1:212-224` | `installs packages, modules, Graphite CLI, and clones projects` | `Invoke-HostBootstrapWinget` `Times 2` (:217) is unchanged. The pip path does not call the winget wrapper |
| `HostBootstrap.Invoke.Tests.ps1:192-210`, `236-270` | poetry project-install cases | Unaffected once `Install-PoetryWithPip` is mocked in BeforeEach |
| `HostBootstrap.Tests.ps1:91-110` | winget poetry fallback and non-poetry rethrow | Unchanged if the catch is kept |
| `HostBootstrap.Tests.ps1:113-165` | `Describe 'Install-PoetryWithPip'` | Unchanged; the function is not edited |
| `host-tools.manifest.Tests.ps1` | manifest shape, :52-69 pins `minimumVersions.poetry` | Unchanged under option (b). No test asserts the absence of a poetry winget entry (grep of `oetry` in this file returns only :52-56, :127-128, :139, :164-165) |
| `HostBootstrapWorkspace.Tests.ps1:144-197` | `Invoke-HostBootstrapPoetry` | Unchanged |

No existing test pins "no direct poetry install". The only required test edit to existing files is the BeforeEach mock.

### New tests (placement)

All in `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` (currently ends after about 270+ lines; verify the exact length before editing):

1. Context `dry run`: with `Install-PoetryWithPip` left real in this one case (override the BeforeEach mock with a pass-through to the real function is not possible in Pester, so instead mock `Install-PoetryWithPip` and assert `Should -Invoke ... -Times 1 -Exactly -ParameterFilter { -not $ApplyMode }`). A second dry-run assertion on the exact output `- Would install poetry using python -m pip install --user poetry` belongs in `HostBootstrap.Tests.ps1` `Describe 'Install-PoetryWithPip'`, where it already exists at :119-124.
2. Context `apply`: poetry absent -> `Should -Invoke -CommandName Install-PoetryWithPip -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { $ApplyMode }`.
3. Ordering: use a `$script:calls` list appended by the `Install-PoetryWithPip` mock and by the `Set-HostEnvironmentVariable` Process-Path mock, and assert the Path refresh precedes the poetry install and the poetry install precedes `Invoke-HostBootstrapPoetry`. Without an ordering test the key constraint (python on PATH) is not guarded.
4. Failure propagation: mock `Install-PoetryWithPip` to throw and assert `Invoke-BootstrapHost -Apply` throws and `Invoke-HostBootstrapPoetry` is not invoked.
5. `-SkipProjectPoetryInstall` does not suppress the poetry tool install (the switch governs only the project install at :395); add one case asserting `Install-PoetryWithPip` is still invoked.

## File-Size Constraint

- `HostBootstrap.psm1`: 462 lines (confirmed by the final `Export-ModuleMember` at line 462 plus the trailing newline; the file view shows 462 lines). Limit 500; budget 38 lines. The change is 1 to 6 lines, so it fits.
- `HostBootstrap.Tests.ps1`: 320 lines per the task statement (the view read here stopped at 112; not re-counted). `HostBootstrap.Invoke.Tests.ps1`: the file extends beyond line 270, whose exact length was not counted. The new tests are estimated at 40 to 60 lines. The implementer must count lines before editing and, if the Invoke test file approaches 500, place the tests in a new `tests/scripts/dev-tools/HostBootstrap.Poetry.Tests.ps1` mirroring the module under test.

## Mirrors

Searches for `HostBootstrap`, `host-tools.manifest`, and `Install-PoetryWithPip` under `.claude/`, `.codex/`, `.github/`, `extensions/`, and `resources/` returned no files, and a glob for `**/*HostBootstrap*` and `**/*host-tools.manifest*` found only the two modules, the manifest, the four test files, and #887 evidence artifacts. No bundled or mirrored copy exists. (`.github/workflows` references only the `PowerShell QC` job, not these files.)

## Verification Approach

- PoshQC MCP tools: format, analyze, test on the changed `.psm1` and test files. Record outputs under the feature `evidence/` folders per the evidence conventions (baseline before the change, qa-gates after).
- Expect-fail evidence: new tests should fail against the unmodified module (the ordering and Install-PoetryWithPip invocation cases), then pass after the fix, as #887 did in `evidence/regression-testing/`.
- Per `.claude/rules/general-unit-test.md`, no temporary files in tests and no real process or registry use; use mocks only.
- CI: `ci.yml:23-24` calls `_poshqc.yml`; the job is `poshqc` with display name `PowerShell QC` (`_poshqc.yml:8-9`), on windows-latest per the task statement. It publishes `poshqc-test-results`. `poshqc-linux-hooks` (`_poshqc.yml:54`) is not relevant to these files.
- Coverage: line threshold governs (PowerShell has no branch gate); the one added statement in `Invoke-BootstrapHost` is covered by the new apply and dry-run cases.

## Automation Feasibility

No human interaction is required. The fix, tests, and verification (PoshQC MCP plus the CI `PowerShell QC` job) are all executable by agents. A real-host check that bootstrap installs poetry on a machine without it would require a clean Windows host and is not necessary for acceptance because every host seam is mocked in the unit tests; it is optional manual confirmation only.

## Open Risks

1. A Microsoft Store python alias can make `Get-Command python` succeed while pip fails; pre-existing, out of scope.
2. In a single run on a host lacking python, python is installed by winget and visible only after the PATH refresh at :363-366; the new call must stay after it. A same-session failure is still possible if the winget python installer requires a new shell for PATH; the existing RunOnce resume (:351-355) is the recovery path.

## Recommended Acceptance Criteria

- [ ] AC-1: `Invoke-BootstrapHost` calls `Install-PoetryWithPip -ApplyMode:$Apply` after the session PATH refresh and before the Graphite CLI step, project poetry install, and verification, so a host without poetry gets it installed in apply mode.
- [ ] AC-2: In dry run, bootstrap prints `- Would install poetry using python -m pip install --user poetry` when poetry is absent and performs no install, registry, or environment-variable write.
- [ ] AC-3: When poetry is already on PATH, bootstrap prints `[OK] poetry already installed` and does not run pip.
- [ ] AC-4: A failure of the poetry install in apply mode propagates as a terminating error and the project poetry install is not attempted.
- [ ] AC-5: `-SkipProjectPoetryInstall` does not suppress the poetry tool install.
- [ ] AC-6: `scripts/host-tools.manifest.json` is unchanged (no unverified poetry winget ID is added); the winget-failure pip fallback in `Install-WithWinget` is retained.
- [ ] AC-7: New Pester tests in the `HostBootstrap.Invoke.Tests.ps1` suite cover AC-1 through AC-5, including an ordering assertion; the existing Invoke tests are updated to mock `Install-PoetryWithPip` in BeforeEach; the new tests fail against the unmodified module and pass after the fix.
- [ ] AC-8: `HostBootstrap.psm1` and every touched test file stay at or under 500 lines.
- [ ] AC-9: PoshQC format, analyze, and test report no failures, and the `PowerShell QC` CI job passes with line coverage at or above the repository threshold.
