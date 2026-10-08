# Research: PoshQC coverage denominator not reproducible (#527) and zero consumer coverage (#623 item 1)

- Issue: #527 (canonical), consolidated with item 1 of #623
- Branch: `bug/poshqc-coverage-denominator-not-reproducible-527`
- Timestamp: 2026-09-29T15-40
- Mode: preparation (research only; no production or test file was changed)

## 0. Sources and access limits

- `gh issue view 527 --comments` and `gh issue view 623` could not be run: this research session has no shell tool. The public issue pages were read with WebFetch instead. WebFetch returned the #527 body and the #623 item 1 text, and reported no comments on either issue. The owner comment dated 2026-09-29 that proposes the consolidated hypothesis therefore comes only from the delegation prompt. It could not be re-read independently.
- #623 item 1 (WebFetch summary): "The bundled `mcp__drm-copilot__run_poshqc_test` coverage capture writes `artifacts/pester/powershell-coverage.xml` with zero covered lines for every file in the repository" despite passing suites; the repro supplied explicit scan folders. Items 2 and 3 of #623 are out of scope.
- The Pester internals below were read from the Pester `5.6.1` tag (`src/functions/Coverage.ps1`) via WebFetch, because `Install-PoshQCTool` pins that version (`scripts/powershell/PoshQC/PoshQC.psm1:55-58`).

## 1. Current state: how PoshQC builds the Pester coverage configuration

### 1.1 Settings resolution

- `scripts/powershell/PoshQC/PoshQC.psm1:1-3` sets `$script:PesterSettings = Join-Path $ModuleRoot 'settings/pester.runsettings.psd1'`. The settings file is always resolved **relative to the directory the module was loaded from**, never relative to the workspace.
- `PoshQC.Testing.psm1:156` defaults `-SettingsPath` to `$script:PesterSettings`. No shipped entry point passes `-SettingsPath` (see 2.1). As a result, the settings copy is decided by which module copy was imported.
- `PoshQC.psm1:113-132` loads the four sub-modules (`FileDiscovery`, `ScanConfig`, `Analyzer`, `Testing`) by AST-parsing each file and dot-sourcing the cached scriptblock. A new sub-module must be added to this list.
- Export surface: `PoshQC.psm1:136-146` (`Export-ModuleMember`) and `PoshQC.psd1:11-20` (`FunctionsToExport`). The manifest list omits `Get-PoshQCScanConfigFolder`. The templates import the `.psd1`, so that function is internal-only on the bundled path. This does not affect the fix, provided any new function stays internal and tests use `InModuleScope`.

### 1.2 `Invoke-PoshQCTest` flow (`PoshQC.Testing.psm1`)

| Step | Lines | Behavior |
| --- | --- | --- |
| Root default | 290-292 | `$Root = $PWD.ProviderPath` when not supplied. A supplied relative `-Root` (for example `.`) is **not** resolved to an absolute path. |
| Load settings | 296-301 | `Import-PowerShellDataFile` of the settings copy, then `New-PesterConfiguration -Hashtable`. |
| Run paths | 302, 170-189 | `Run.Path` entries are joined to `$Root`, with no existence check. |
| Coverage paths | 304, 215-240 | Every `CodeCoverage.Path` entry that is not rooted is joined to `$Root`. |
| Scan folders | 305-318 | Explicit `-ScanFolders` wins. Otherwise `Get-PoshQCScanConfigFolder` reads `config/poshqc-scan.json`, and failing that the settings `Run.Path` is kept. **Scan folders replace only `Run.Path`. They never affect `CodeCoverage.Path`.** |
| Coverage prune | 338-367 | Entries are joined to `$Root` again. Entries for which `Test-Path` is false are removed and each removal is logged (`Pruned nonexistent code coverage path:`, line 355). If no entry survives, coverage is disabled (361-365), because an empty enabled path set makes Pester instrument every `Run.Path` directory. |
| Output path | 369-381 | `artifacts/pester/powershell-coverage.xml` is joined to `$Root`. |
| Test enumeration | 393-398 | `*.Tests.ps1` under the effective `Run.Path`, excluding `DefaultExcludedDirs` (`PoshQC.psm1:5-9`), sorted by `FullName`. |
| Pester | 400, 261-281 | Runs through the global-session trampoline. |
| Koverage copy | 402-418, 42-129 | `Convert-PoshQCCoverageToRelative` only strips the root prefix from the XML text (lines 107-115). It does not change counters. |

The coverage **population** is therefore exactly: (the settings copy's `CodeCoverage.Path` list) ∩ (entries that exist under `$Root`). It is independent of scan folders, `config/poshqc-scan.json`, and the workspace's own production files.

### 1.3 The allow-list (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`)

- `Run.Path = @('scripts', 'tests/powershell', 'tests/scripts')` (line 3). `CodeCoverage` block lines 17-328. `CoveragePercentTarget = 0` (line 327), so Pester itself never fails on coverage.
- `CodeCoverage.Path` (lines 23-325) is a hand-maintained per-file list with issue-number comments. It has 118 entries, 117 of them unique. `.claude/hooks/enforce-pr-author-skill.ps1` appears twice (lines 34 and 49). See the Numeric Derivation Evidence section.
- Lines 294-296 record the existing convention that bundle mirrors under `extensions/drm-copilot/resources/` are not measured and are guarded by byte identity instead.
- The file is listed as a shared surface in `config/blast-radius.json:13`, because nearly every PowerShell change appends to it. That makes it a recurring merge-conflict point.
- The README description (`scripts/powershell/PoshQC/README.md:68`, and the identical bundled copy) is stale: it describes globs (`scripts/dev-tools/*.ps1`, `scripts/powershell/**/*.psm1`, `src/**/*.ps1`) that no longer exist in the settings.

### 1.4 `config/poshqc-scan.json` participation

- Contents: `{"version": 1, "test": {"scanFolders": ["scripts", "tests/powershell", "tests/scripts"]}}` (lines 1-6).
- It is read from the **workspace** (`Get-PoshQCScanConfigFolder -Root $Root`, `PoshQC.ScanConfig.psm1:31-125`) on both the self-hosted and the bundled path. It is therefore the only PoshQC configuration that is already workspace-resident on every invocation path.
- The TypeScript writer `extensions/drm-copilot/src/poshqc-scan-config.ts:205-228` rewrites the entire document as `{version, test: {scanFolders}}` (lines 214-219). **Any additional top-level key would be silently dropped** the next time the folder picker saves.

### 1.5 Pester 5.6.1 coverage semantics (verified from source)

- `Resolve-CoverageInfo`: each path goes through `Resolve-Path -ErrorAction Stop`. Relative paths therefore resolve against `$PWD`, and one unresolvable entry aborts the whole set. This matches the comment at `PoshQC.Testing.psm1:347-350`.
- `Get-CodeCoverageFilePaths`: keeps only `.ps1` and `.psm1`. It excludes `*<Run.TestExtension>` (that is, `*.Tests.ps1`) unless the path itself is a test file, and recurses into directories when `RecursePaths` is set. Its output is neither sorted nor de-duplicated.
- `Get-CoverageBreakpoints`: `Group-Object -Property Path`, then one breakpoint per command (`continue commandLoop`). **Duplicate entries and case variants that group together do not double-count.** The duplicate at lines 34 and 49 is therefore harmless to the denominator.
- JaCoCo `LINE` counter: one count per distinct line that holds at least one analyzed command. The per-file denominator is a pure function of (file content, Pester's command analysis). It does not depend on which tests ran. `UseBreakpoints` changes how hits are collected, not which commands are counted.

Conclusion: for a fixed Pester version, **denominator = f(the set of files measured, the content of those files)**. Any variation must come from one of those two inputs.

## 2. Invocation paths and which settings copy each reads

### 2.1 Entry points

| Path | Module imported | Settings read | Citation |
| --- | --- | --- | --- |
| Self-hosted (CI, reviewers, `run-pester.ps1`) | `scripts/powershell/PoshQC/PoshQC.psd1` | repo copy `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `scripts/dev-tools/run-poshqc-suite.ps1:21-24`; `scripts/dev-tools/run-pester.ps1:11,14`; `.github/workflows/_poshqc.yml:38-42` |
| MCP `run_poshqc_test` (Claude Code) | `<package>/resources/powershell/PoshQC/PoshQC.psd1` inside `@danmoisan/drm-copilot-mcp` | the package's bundled copy | `.mcp.json:4-5` (`npx -y @danmoisan/drm-copilot-mcp`, **no version pin**); `packages/mcp-server/prepack.cjs:3,19-21` copies extension `resources/` into the package at pack time |
| VS Code extension commands | `<installed extension>/resources/powershell/PoshQC/PoshQC.psd1` | the installed extension's bundled copy | `extensions/drm-copilot/src/command-runtime.ts:294-300` ("Resolve scripts relative to the installed extension") |

- The MCP and extension routes run `resources/templates/run-poshqc-test.ps1` (`extensions/drm-copilot/src/repo-automation-service-support.ts:49`). That template imports `..\powershell\PoshQC\PoshQC.psd1` relative to itself (`extensions/drm-copilot/resources/templates/run-poshqc-test.ps1:22-23`) and calls `Invoke-PoshQCTest -Root $WorkspaceRoot -ScanFolders ...` (line 32). It never passes `-SettingsPath`.
- The child process runs with `cwd = workspaceRoot` (`command-runtime.ts:309-313`). `-WorkspaceRoot` is the tool's `workspace_root` argument (`repo-automation-args.ts:27`). Scan folders are forwarded as `-ScanFoldersJson` (`repo-automation-args.ts:28-40`).
- The bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/` holds `PoshQC.psm1`, `.psd1`, the four sub-modules, `README.md`, and `settings/{pester.runsettings,pssa.settings}.psd1`. `convert-poshqc-coverage.ps1` is **not** mirrored. The two runsettings copies are byte-identical at HEAD, as enforced by the parity test (3.1).

### 2.2 Relationship to `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md`

That potential bug describes the same mechanism: the MCP route reads the settings copy bundled in the published package, so repository edits to `CodeCoverage.Path` have no effect until a release ships and the npx cache picks it up. It is the **same root cause** as the #527 variance (a different settings copy produces a different measured set), seen from the "newly registered file is missing" side. Its preferred fix, "prefer a workspace-resident runsettings when present", would remove the version skew. It would not fix #623, because a consumer has no drm-copilot-shaped runsettings. The recommendation below makes the coverage population workspace-derived, which resolves both. After the fix, that potential bug is obsolete in substance. The plan should record it as superseded by #527 and not promote it separately.

## 3. Parity mechanism and tests that touch `CodeCoverage.Path`

### 3.1 Parity

- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:9-18` lists eight repo-root files, including both `.psd1` settings, that must be byte-equal to their `extensions/drm-copilot/resources/powershell/PoshQC/` mirrors (assertion at lines 79-81). No sync or push-down script generates the mirror. It is edited by hand in lockstep and guarded by this test.
- A new sub-module (for example `PoshQC.Coverage.psm1`) must be added to `POSHQC_PARITY_PATHS` and mirrored.

### 3.2 Tests that reference `CodeCoverage.Path` or the runsettings

- No test asserts on the **content** of the shipped allow-list. The only test that reads the real settings file is the parity test.
- Tests that drive `CodeCoverage.Path` behavior through injected settings (seams) are listed below. Each will need review, and some will need updates, if the pruning block (`PoshQC.Testing.psm1:338-367`) changes:
  - `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1` (lines 31-259; issue #409 pruning and disable semantics)
  - `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` (lines 115-154 assert `CodeCoverage.Path[0] == '/config-paths-root/src/**/*.ps1'`)
  - `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` (lines 224-273 capture `$Config.CodeCoverage.Path`)
  - `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` (lines 502-568 capture coverage paths)
  - `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` (lines 539-732, `$Hashtable.CodeCoverage.Path`)
  - `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1` (lines 67-131, `Path = $null`)
- References in comments only (no assertion): `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1:6`, `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1:6`, `tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1:9`, `tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1:9`.
- Blast-radius historical fixtures under `tests/fixtures/blast_radius/` cite the runsettings path as data. They are frozen fixtures and must not be edited.

## 4. Root-cause analysis

### 4.1 Symptom A (#527): three denominators

Evidence from the #500 feature folder (`docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/`):

| Denominator | Route | Files | Tests passed | Source |
| --- | --- | --- | --- | --- |
| 6020 | MCP (cycles 1-3), **and** self-hosted `Invoke-PoshQCTest -Root .` | 70 ("8,449 analyzed Commands in 70 Files") | 3113-3119 | `evidence/qa-gates/final-powershell-poshqc-test.2026-08-22T00-30.md:9,33-38`; `evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T04-46.md:40-44` |
| 5969 | MCP (cycle 4) | not recorded | 3362 | `evidence/qa-gates/final-powershell-poshqc-test.2026-08-23T02-59.md:2-4` |
| 6622 | self-hosted `scripts/dev-tools/run-poshqc-suite.ps1 -WorkspaceRoot .` | 79 | 3362 | `2026-08-23T04-45-audit/policy-audit.2026-08-23T04-45.md:102-104,285-292` |

Candidate causes, each tested against the code:

| Candidate | Status | Basis |
| --- | --- | --- |
| Different settings copy per route (repo vs npx-cached MCP package) | **Verified mechanism; consistent with all three observations** | Section 2.1. On 2026-08-22 the MCP route and the self-hosted route produced the same 6020 over 70 files, so the copies matched then. On 2026-08-23, with an identical test result (3362), the MCP route gave 5969 and the self-hosted route gave 6622 over 79 files. Same tree and same tests with different figures can only mean a different file set. `.mcp.json` does not pin the package version, so the npx-resolved copy is whatever the cache holds. |
| The tree changed between cycles 1-3 and cycle 4 (branch integrated `main`) | **Verified that the tree changed**; the "unchanged tree" premise in the issue does not hold across all three figures | The passed count moved from 3113 (2026-08-22T13-41) to 3361/3362 (2026-08-23T02-59), a change of +248 tests with no such change in #500's own diff. The allow-list delta from 70 to 79 files equals exactly the nine #501 registrations (`pester.runsettings.psd1:236-264`: `HookPayload.psm1`, six hooks, two helper siblings). |
| 5969 = old (70-entry) bundled list × post-#501 file contents; 6622 = new (79-entry) repo list × same contents | **Likely, unconfirmed** | Consistent with #501 relocating payload parsing out of the registered hooks, which shrinks their line counts, into the newly registered `HookPayload.psm1`. Confirming it would require the package version held in the npx cache on 2026-08-23 and per-file counters, which were not recorded. |
| Allow-list entries missing on disk | **Verified mechanism; not active at HEAD** | Missing entries are pruned (`PoshQC.Testing.psm1:352-356`), so the measured set shrinks silently apart from a log line. At HEAD all 117 unique entries exist (Numeric Derivation Evidence). |
| Relative-path and cwd dependence | **Verified mechanism; not the observed cause** | A relative `-Root` is never resolved (`PoshQC.Testing.psm1:290-292,343`), and Pester resolves relative paths against `$PWD`. A run with `-Root .` from a different cwd measures a different set. The recorded runs used `-Root .` from the worktree root or an absolute `workspace_root`. |
| Duplicates or path casing (`scripts/PowerShell` vs `scripts/powershell`) | **Ruled out as a denominator cause** | The directory on disk is `scripts/powershell`, and the list uses that casing. Pester groups by path before counting (1.5), so the duplicate at lines 34 and 49 does not double-count. |
| Pester version skew | **Unconfirmed; unlikely for these observations** | `Import-Module Pester` loads the highest installed version (`PoshQC.Testing.psm1:160-166`). The three figures came from one machine within about 24 hours. |
| Untracked or gitignored files | **Not a factor for the allow-list** (explicit file paths); **becomes relevant for any directory-based derivation** | `.claude/state/*.json` files are not `.ps1`/`.psm1`. In the main checkout, `.claude/worktrees/` contains nested worktrees full of `.ps1` files, so a derivation root must never be `.claude` itself. |

**Root cause (A):** the measured file set is not derived from the tree. It is a hand-maintained list whose version depends on which module copy the caller loaded: the repo copy on the self-hosted route, and a release-pinned copy (resolved by an unpinned npx cache) on the MCP and extension routes. That list is then filtered by on-disk existence. Two routes over the same tree therefore measure different sets, and the same route measures different sets as the list and the tree drift independently.

### 4.2 Symptom B (#623 item 1): zero coverage in a consumer repository

- A consumer that received push-down has the drm-copilot hook and library trees on disk. `extensions/drm-copilot/resources/claude-customizations/.claude/{hooks,lib}/` ships 46 hooks and 41 library files, and `resources/codex-and-agents-customizations/.codex/{hooks,scripts}/` ships 32 plus 10.
- On the MCP route the consumer runs with the **bundled drm-copilot allow-list**. The `scripts/dev-tools/*` and `scripts/powershell/*` entries do not exist in the consumer and are pruned. The `.claude/...` and `.codex/...` entries **do** exist (pushed-down copies) and survive. Coverage stays enabled, and Pester measures those pushed-down drm-copilot files.
- The consumer's own Pester suite does not execute drm-copilot hooks, so every measured file reports zero covered lines. The consumer's own production code is never in the population, because no route derives it.
- This matches the #623 wording: the XML is written (so the surviving set is non-empty) and zero lines are covered for every file. **Status: verified mechanism from code and bundle contents; unconfirmed against the consumer's actual XML**, which is not available to this session. The fixture verification in section 8 turns this into a reproducible, fail-first check.
- Variant: a consumer without push-down would have every entry pruned. Coverage would then be disabled (`PoshQC.Testing.psm1:361-365`) and no XML written, which differs from what #623 reported. That supports the push-down explanation.

**Shared cause (confirms hypothesis C):** in both symptoms, the population is the bundled, drm-copilot-specific `CodeCoverage.Path` list instead of a deterministic function of the workspace being measured.

## 5. Options for a deterministic population

Evaluation criteria: D = same tree and config give the same set; C = correct in a consumer repo; P = Coverage Exclusion Policy (no production file excluded); L = 500-line limit; B = backward compatibility.

| Option | D | C | P | L | B |
| --- | --- | --- | --- | --- | --- |
| 1. Keep the allow-list; add an existence and completeness guard test | Partial (still route-dependent) | **No** (list names drm-copilot files) | Only if the guard enumerates the tree | OK | Full |
| 2. Derive from effective test scan folders (`Run.Path`), minus tests | Yes, per input | Yes | **No for drm-copilot**: `.claude/*` and `.codex/*` are outside the scan folders, so 57+ currently measured files drop out. A caller that narrows `-ScanFolders` to a test directory loses coverage entirely. | OK | Changes the drm-copilot set |
| 3. Declarative `coverage` key inside `config/poshqc-scan.json` | Yes | Yes | Yes (include-only) | OK | The TypeScript writer (`poshqc-scan-config.ts:214-219`) drops the key on the next folder-picker save, so fixing it adds a TypeScript change and a Jest test |
| **4. Workspace coverage-roots config file plus fallback derivation (recommended)** | Yes | Yes | Yes (include-only, built-in exclusions limited to test and tooling paths) | Logic in a new sub-module keeps `PoshQC.Testing.psm1` under 500 | Explicit settings `CodeCoverage.Path` still honored |

### 5.1 Recommended design (option 4)

1. **Population source, in precedence order:**
   1. A non-empty `CodeCoverage.Path` in the loaded settings file. This keeps backward compatibility for standalone users with custom settings. Both shipped settings copies will carry **no** `Path`, so this branch is unused by drm-copilot and consumers.
   2. The roots listed in a workspace file `config/poshqc-coverage.json`, shaped as `{"version": 1, "roots": ["..."]}`. It is read from `$Root` with the same validation rules as `Get-PoshQCScanConfigFolder`: version 1, no blank, absolute, or `..` entries, and missing roots skipped with a warning. The file is include-only, with no `exclude` key, so it cannot exclude a production file.
   3. Fallback when that file is absent: the effective test roots (explicit `-ScanFolders`, else `config/poshqc-scan.json`, else settings `Run.Path`), with nonexistent roots skipped.
2. **Enumeration** (pure, behind seams): recurse each root and keep `.ps1` and `.psm1`. Exclude `*.Tests.ps1`, any path with a segment in `DefaultExcludedDirs` (`PoshQC.psm1:5-9`), and any path whose first root-relative segment is `tests`. Policy permits excluding `tests/**`. Normalize to absolute paths, de-duplicate case-insensitively on Windows, and sort ordinally. Reuse `Get-PoshQCFileList` (`PoshQC.FileDiscovery.psm1:23-78`), which already has `EnumerateFiles`, `ShouldExclude`, and `IsAllowedExtension` seams and sorts by `FullName`. Pre-filter roots by existence, because `Resolve-PoshQCScanFolder` throws on a missing folder (`PoshQC.FileDiscovery.psm1:120-127`).
3. **Resolve `$Root` to an absolute path** at the top of `Invoke-PoshQCTest`. This removes the cwd dependence.
4. **Empty population:** keep the existing behavior of disabling coverage and logging it (`PoshQC.Testing.psm1:361-365`). Pester instruments `Run.Path` when given an empty enabled set.
5. **Observability:** log the population source (settings, config file, or fallback) and the file count before invoking Pester. This makes a future drift visible in the run output, which answers the issue's "record the denominator" suggestion without adding a new artifact.
6. **drm-copilot config:** `config/poshqc-coverage.json` with roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`. Specific roots rather than `.claude`, to avoid `.claude/worktrees/` and `.claude/skills`. Bundle mirrors under `extensions/` stay out of the roots, following the byte-identity convention at `pester.runsettings.psd1:294-296`.
7. **Settings:** remove the `CodeCoverage.Path` list from both runsettings copies. Keep `Enabled`, `OutputFormat`, `OutputPath`, and `CoveragePercentTarget`.

Rejected alternatives, in brief:
- Option 1 cannot fix consumers.
- Option 2 drops measured drm-copilot files and couples coverage to test-discovery narrowing.
- Option 3 is equivalent to option 4 but needs a TypeScript writer change to survive the folder picker.
- A `git ls-files` enumeration would exclude untracked files, but it adds a git dependency and fails in non-git workspaces.
- Pointing Pester `CodeCoverage.Path` directly at directories would work natively, but it gives up PoshQC's control over exclusions and logging, and it includes untracked scratch files without visibility.

### 5.2 Risk: the population grows and the percentage may fall

At HEAD, 46 production PowerShell files under the recommended roots are **not** in the allow-list (Numeric Derivation Evidence): 6 `.claude/hooks`, 1 `.claude/lib`, 9 `.codex/hooks`, 7 `.codex/scripts`, 4 `scripts/powershell/PoshQC`, and 19 `scripts/dev-tools`. They are currently outside the denominator, which the Coverage Exclusion Policy already forbids. Once derived, they enter it. Their line counts and hit rates are unknown, so the aggregate line coverage may fall below 85%. The plan should:
- measure the derived population's coverage in Phase 0 on the self-hosted route before the fix, and record it as a baseline artifact;
- treat a sub-85% result as an explicit scope decision: add tests within this fix, or file a follow-up issue with the gap enumerated. It must not be handled by excluding files.

## 6. Behavior semantics and edge cases

- Same tree + same `config/poshqc-coverage.json` + same effective roots → identical sorted file list → identical denominator on every route (self-hosted, MCP, and extension), because all inputs are now workspace-resident.
- Consumer without `config/poshqc-coverage.json` → population = consumer files under its effective test roots, excluding `tests/**` → non-zero coverage for exercised files.
- Config present but every root missing → warn per root, then disable coverage with a log line. Do not throw: the `ScanConfig` equivalent throws (`PoshQC.ScanConfig.psm1:120-122`), but coverage must not abort a test run (#409 precedent). The plan must choose between this and a throw, and state which.
- Malformed JSON, wrong version, or blank, absolute, or `..` entries → fail fast, naming the file (matches `ScanConfig` behavior).
- Explicit non-empty settings `CodeCoverage.Path` → honored, logged as source `settings`.
- Case-insensitive duplicates across overlapping roots (for example `scripts` and `scripts/powershell`) → de-duplicated.

## 7. Files near the 500-line limit

| File | Lines | Note |
| --- | --- | --- |
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | 463 | 37 lines of headroom. Put the derivation in a new sub-module, not here. |
| `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` | 472 | Do not add cases here. |
| `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` | 579 | Already over the limit (pre-existing). Do not add to it. |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | 766 | Already over the limit (pre-existing). Do not add to it. |
| Others (`PoshQC.Analyzer.psm1` 254, `PoshQC.psm1` 147, `FileDiscovery` 138, `ScanConfig` 125) | under 300 | No constraint. |

Line counts come from ripgrep line counts over each file.

## 8. Testing implications

### 8.1 Seams available (no temporary files)

- `Invoke-PoshQCTest` exposes scriptblock seams for every I/O step (`PoshQC.Testing.psm1:160-285`). The established pattern is in `PoshQC.TestingCoveragePruning.Tests.ps1`: `InModuleScope PoshQC`, `Mock New-Item`, a path-discriminating `-TestPathExists`, injected `-LoadSettings` and `-BuildConfiguration`, and a capturing `-InvokePester`.
- `Get-PoshQCFileList` exposes `-EnumerateFiles`, `-ResolvePath`, and `-ShouldExclude`. `Get-PoshQCScanConfigFolder` exposes `-TestPathExists`, `-ReadContent`, and `-Logger`. The new coverage functions should follow the same shape: `-EnumerateFiles` returning `[pscustomobject]@{ FullName; Extension; Name }` fakes, and `-ReadContent` returning JSON text.
- `TestDrive:` is used nowhere under `tests/` (0 occurrences). The repository rule prohibits temporary files in tests (`.claude/rules/general-unit-test.md`), and `.claude/hooks/check-powershell-test-purity.ps1:105-109` blocks `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, and `$env:TMP`. Do not use `TestDrive`.
- Add a new `Invoke-PoshQCTest` seam (for example `-ResolveCoveragePopulation`) so existing tests can inject a fixed population.

### 8.2 Fail-first regression tests (unit, Pester)

1. **Route independence (#527):** run `Invoke-PoshQCTest` twice with an identical injected tree and workspace config but two different settings tables, simulating the repo copy and the bundled copy. Assert that the captured `CodeCoverage.Path` sets are equal. This fails today, because the population is copied from settings.
2. **Workspace-derived population (#623):** with an injected tree containing `scripts/Sample.psm1`, `tests/scripts/Sample.Tests.ps1`, and a pushed-down `.claude/hooks/validate-bash.ps1`, and with the shipped settings, assert that the captured population is `[<root>/scripts/Sample.psm1]`. This fails today: the population is `validate-bash.ps1` and `Sample.psm1` is absent.
3. **Determinism:** shuffle the injected enumeration order and assert the same sorted output. Also cover case-variant duplicates and overlapping roots.
4. Config validation, missing-root warnings, empty-population disable, settings-override precedence, and relative `-Root` resolution.

New test files belong in a new file, for example `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1`, mirroring the new sub-module. Existing pruning tests must be kept or adapted so #409 semantics stay covered.

### 8.3 Consumer verification without temporary files

- Add a committed fixture consumer tree, for example `tests/fixtures/poshqc-consumer/`:
  - `scripts/Sample.psm1`
  - `tests/scripts/Sample.Tests.ps1`, which imports `Sample.psm1` via `$PSScriptRoot`
  - a pushed-down stand-in `.claude/hooks/validate-bash.ps1` that reproduces the old failure
  - no `config/poshqc-coverage.json`, so the fallback path is exercised
- The fixture sits under `tests/fixtures/`, which is outside the repository's `Run.Path` (`scripts`, `tests/powershell`, `tests/scripts`), so the repo suite will not execute it. It sits under `tests/`, so it is excluded from the repo's own derived population. It still has to pass `Invoke-PoshQCFormat` and `Invoke-PoshQCAnalyze`, which scan the whole root.
- Acceptance evidence is produced by the **executor**, not by a unit test, on the self-hosted route:
  `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root ./tests/fixtures/poshqc-consumer"`
  Then parse `tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml`: assert `Sample.psm1` is present with covered LINE > 0 and `validate-bash.ps1` is absent. Also parse `pester-junit.xml` for zero failures. Run once before the fix to show the failure and once after.
- Side effect: the run writes `tests/fixtures/poshqc-consumer/artifacts/`. `.gitignore:6` ignores only `/artifacts`, so the plan must either add an ignore entry for the fixture's `artifacts/` directory or remove it after evidence capture. The first is preferred, because it is deterministic and prevents accidental commits.
- For #527 on the repo itself: run the self-hosted `Invoke-PoshQCTest -Root <abs repo root>` twice, and once more from a different cwd with an absolute `-Root`. Assert identical root `LINE` counter totals (missed + covered) and an identical per-file `<sourcefile>` set across all three runs. The MCP tool returns only a pre-composed summary and reads the installed or npx package copy, so it cannot serve as acceptance evidence for this change until a release ships.

### 8.4 Toolchains in scope

- PowerShell: format, analyze, then test, on the self-hosted module.
- Python: `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` after `POSHQC_PARITY_PATHS` is extended.
- TypeScript: no change is required under option 4. If option 3 is chosen instead, `extensions/drm-copilot/src/poshqc-scan-config.ts` and `extensions/drm-copilot/test/poshqc-scan-config.test.ts` join the scope.

## Numeric Derivation Evidence

These counts are diagnostic. Spec acceptance criteria should assert **set equality** (derived population equals enumerated production files under the configured roots), not fixed numbers, because the counts change whenever a PowerShell file is added.

### N1. `CodeCoverage.Path` entries in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: 118 entries, 117 unique

- Complete Family: every string element of the `CodeCoverage.Path` array (lines 23-325).
- Exhaustive Search Scope: the whole file, lines 1-335.
- Inclusion Rules: a line consisting only of a single-quoted path ending in `.ps1` or `.psm1`.
- Exclusion Rules: comment lines and the `Run.Path` array (line 3, a single inline array of folders, not files).
- Primary Search Strategy or Query Expression: manual line-by-line enumeration of the Read output of the file.
- Primary Member Set: lines 27-31, 34, 38-41, 44, 46-51, 54-57, 61, 64, 68, 72-73, 77, 81, 86, 89, 93-94, 98, 102-104, 108-109, 113-121, 126, 132-139, 143, 147, 149-150, 155-156, 174-180, 185, 190, 193, 199-201, 206-208, 211, 215, 220, 225-229, 235, 242-244, 248, 252, 254-258, 262-264, 271, 279, 286, 288, 297-300, 304-307, 313-314, 316, 318-319, 324.
- Primary Count: 118.
- Cross-check Search Strategy or Query Expression: ripgrep `^\s+'([^']+\.psm?1)'\s*$`, in content mode with `-o` (member list) and in count mode.
- Cross-check Member Set: the same 118 line numbers as the primary set, returned with their path text.
- Cross-check Count: 118.
- Member-set Comparison: identical line-number sets. Unique-path reduction: ripgrep `enforce-pr-author-skill\.ps1'` returns lines 34 and 49 with identical text, and no other path repeats in the enumerated list, giving 117 unique.

### N2. Production PowerShell files under the recommended roots: 163 total, 117 measured, 46 unmeasured

- Complete Family: `.ps1` and `.psm1` files under `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, and `scripts` in this worktree.
- Exhaustive Search Scope: those five roots, recursively.
- Inclusion Rules: extension `.ps1` or `.psm1`.
- Exclusion Rules: `.psd1` files (Pester does not measure them), `*.Tests.ps1` (none present in these roots), and `extensions/**` bundle mirrors (outside the roots).
- Primary Search Strategy or Query Expression: Glob `.claude/{hooks,lib}/**/*.{ps1,psm1}`, `.codex/**/*.{ps1,psm1}`, and `scripts/**/*.{ps1,psm1}`.
- Primary Member Set: `.claude/hooks` 46, `.claude/lib` 41, `.codex/hooks` 32, `.codex/scripts` 10, `scripts/dev-tools` 27, `scripts/powershell` 7 (`Publish-DrmCopilotExtension.ps1` plus six under `PoshQC/`), as listed in the tool output.
- Primary Count: 163.
- Cross-check Search Strategy or Query Expression: ripgrep `\S` in files-with-matches mode, with glob `*.{ps1,psm1}` for `.claude/` and `scripts/`, and `*.ps1` for `.codex/`.
- Cross-check Member Set: 87 files under `.claude/` (46 hooks + 41 lib; no other `.claude` subtree holds PowerShell in this worktree), 42 under `.codex/`, and 34 under `scripts/`, the same file names as the primary set.
- Cross-check Count: 87 + 42 + 34 = 163.
- Member-set Comparison: identical file sets per root. The measured subset equals N1's 117 unique entries, all of which appear in the enumerated set, so no entry is missing on disk at HEAD. Unmeasured = 163 − 117 = 46:
  - `.claude/hooks`: `validate-executor-output`, `validate-feature-review-coverage`, `validate-pr-author-output`, `validate-prd-feature-output`, `validate-required-artifact-output`, `validate-task-researcher-output`
  - `.claude/lib`: `requirements/GeneratedDocumentCounters.psm1`
  - `.codex/hooks`: `authorize-root-epic-invocation`, `codex-agent-profile-attestation`, `codex-authority-store`, `codex-epic-child-launch-attestation`, `enforce-codex-model-routing`, `enforce-epic-root-invocation`, `enforce-epic-wave-barrier`, `validate-codex-subagent-routing`, `validate-feature-review-coverage`
  - `.codex/scripts`: `epic-child-launch-contract`, `epic-child-launch-runtime`, `epic-child-persistence-runtime`, `epic-child-sandbox-preflight`, `launch-epic-child-wave`, `post-codex-worktree-session`, `resume-epic-child`
  - `scripts/powershell/PoshQC`: `PoshQC.psm1`, `PoshQC.FileDiscovery.psm1`, `PoshQC.Analyzer.psm1`, `convert-poshqc-coverage.ps1`
  - `scripts/dev-tools`: `DrmCopilotPromptSupport`, `Enter-DrmCopilotShell`, `activate`, `bootstrap-host.helpers`, `bootstrap-host`, `format-powershell`, `link-feature-docs`, `link-parent-child`, `load-openai-key`, `new-potential-entry`, `publish-sideloaded-extension`, `run-actionlint`, `run-pester`, `run-poshqc-suite`, `run-psscriptanalyzer`, `sync-agents-from-instructions`, `tree`, `verify-host`, `vscode-cli.helpers`

## Automation Feasibility

No step requires human interaction. Every change (PowerShell module, settings, config JSON, fixture tree, Python parity list, `.gitignore` entry) and every verification (self-hosted `Invoke-PoshQCTest` runs, XML parsing, the pytest parity test) can be performed by an executor with PowerShell and Poetry available. Two limits apply:
- The MCP `run_poshqc_test` route cannot demonstrate the fix until a release is published and the npx cache resolves it. Acceptance must rely on the self-hosted module, and the plan should state this explicitly.
- If the derived population falls below 85% line coverage (section 5.2), a scope decision is required. The planner can pre-decide it (tests within this fix, or a follow-up issue), so it need not block automation.

## Files a fix would touch

Production:
- `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` (new sub-module: population derivation and coverage-config reader)
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (absolute `$Root`; replace allow-list resolution and pruning at 338-367 with the derived population; new seam)
- `scripts/powershell/PoshQC/PoshQC.psm1` (add the sub-module to the load list at 113-118)
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (remove the `CodeCoverage.Path` list)
- `scripts/powershell/PoshQC/README.md` (correct the stale coverage description at line 68)
- `config/poshqc-coverage.json` (new; drm-copilot coverage roots)
- `.gitignore` (ignore `tests/fixtures/poshqc-consumer/artifacts/`, if that approach is chosen)

Bundled mirror (must stay byte-identical):
- `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Coverage.psm1` (new)
- `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`
- `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1`
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
- `extensions/drm-copilot/resources/powershell/PoshQC/README.md`

Tests and fixtures:
- `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1` (new; fail-first tests from 8.2)
- `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1` (adapt to the new population seam)
- `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` (review lines 115-154)
- `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` (review lines 224-273; do not grow it)
- `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` and `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` (review coverage-path cases only; both are already over 500 lines, so do not grow them)
- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (add `PoshQC.Coverage.psm1` to `POSHQC_PARITY_PATHS`)
- `tests/fixtures/poshqc-consumer/scripts/Sample.psm1`, `tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1`, `tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1` (new fixture tree)

Documentation disposition:
- `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md` (record it as superseded by #527)
