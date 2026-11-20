# Research: does current main still exhibit the #527 defect (PowerShell coverage denominator not reproducible)?

- Issue: #527 (canonical; absorbs item 1 of #623, now closed)
- Branch: `bug/poshqc-coverage-denominator-527-r2`
- Timestamp: 2026-10-17T12-35
- Mode: preparation (research only; no production, test, or configuration file was changed)
- Supersedes for current-state questions: `research/research.2026-09-29T15-40.md` (still the reference for the original root-cause analysis)

## 0. Sources and access limits

- Read in this session with file tools: `execution-environment` skill, `issue.md`, `spec.md`, `research/research.2026-09-29T15-40.md`, `evidence/qa-gates/determinism-comparison.2026-10-02T08-45.md`, `evidence/regression-testing/fail-first-fixture-run.2026-10-02T07-55.md`, `evidence/regression-testing/fail-first-fixture-check.2026-10-02T07-55.md`, `evidence/qa-gates/ac-checkoff-complete.2026-10-02T08-45.md`, `evidence/other/plan-deviations.2026-10-02T07-45.md`, `scripts/powershell/PoshQC/{PoshQC.Coverage,PoshQC.Testing,PoshQC.CoverageMerge,PoshQC.Shard}.psm1`, `scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `config/poshqc-coverage.json`, `config/poshqc-scan.json`, `.github/workflows/_poshqc.yml`, the three fixture files under `tests/fixtures/poshqc-consumer/`, and `.gitignore`.
- This session has no shell tool and no `gh`. Every run, count, hash, and CI figure in sections 2 and 3 is **orchestrator-measured on 2026-10-17** and was not re-run or independently re-derived here. Code behavior in section 1 is verified by reading the current files.
- The delegation prompt labels the issue severity "high". `issue.md` and `spec.md` both record **Medium** (checked box). The current GitHub label was not readable here; the discrepancy is unresolved and does not affect the verdict.

## 1. Current state (verified from code at current main)

| Element | Verified behavior | Source |
| --- | --- | --- |
| Population source | `Invoke-PoshQCTest` calls the `ResolveCoveragePopulation` seam, default `Resolve-PoshQCCoveragePopulation`. Precedence: caller-supplied settings `CodeCoverage.Path` (`settings`), else `config/poshqc-coverage.json` (`config`), else effective scan folders or `Run.Path` (`fallback`). A `CodeCoverage.Path` in the module-default settings file is ignored and logged. | `PoshQC.Coverage.psm1` (`Resolve-PoshQCCoveragePopulation`), `PoshQC.Testing.psm1` |
| Inputs to the population | Only the workspace root, the roots from the config file or scan folders, the directory contents under those roots, and the fixed exclusions. Test results, shard assignment, and the loaded module copy are not inputs. | `Get-PoshQCCoverageFileSet` |
| Ordering | Candidates are keyed by root-relative path, sorted ordinally, and de-duplicated case-insensitively, so enumeration order does not matter. | `Get-PoshQCCoverageFileSet` |
| Root handling | A relative `-Root` is resolved against `$PWD` once, at the top of `Invoke-PoshQCTest`, before any run, coverage, or output path is built. | `PoshQC.Testing.psm1` (absolute-root block) |
| Allow-list | Removed. `pester.runsettings.psd1` carries no `CodeCoverage.Path`; it sets `UseBreakpoints = $false` (#953). | `settings/pester.runsettings.psd1` |
| Coverage config | `config/poshqc-coverage.json`: `version` 1, roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`. | file |
| Observability | One log line before Pester runs: `Code coverage population: source=<source>; files=<n>`. It does not log the Pester version or the total line denominator. | `PoshQC.Testing.psm1` |
| Shard run | `-ShardIndex/-ShardCount` change only `Run.Path` (the test files). `CodeCoverage.Path` is set before sharding and is identical in every shard. | `PoshQC.Testing.psm1`, `PoshQC.Shard.psm1` |
| Merge guard | `Merge-PoshQCCoverageReport` throws unless every shard report lists the same set of package, sourcefile, and line-number triples. The aggregator then logs `Merged PowerShell line coverage: <covered> of <total> lines`. Each CI run therefore enforces, structurally, that the denominator does not depend on which tests a shard ran. | `PoshQC.CoverageMerge.psm1`, `_poshqc.yml` (job `poshqc`) |
| Pester range | `EnsureModule` requires Pester 5.9.0 to 5.99.99 and imports with `-MinimumVersion`/`-MaximumVersion`; `Install-PoshQCTool` pins 5.9.0 with exclusive upper bound 6.0.0. | `PoshQC.Testing.psm1`, `PoshQC.psm1` |
| Fixture output | `.gitignore` line 8 ignores `/tests/fixtures/poshqc-consumer/artifacts/`. The fixture holds `scripts/Sample.psm1`, `tests/scripts/Sample.Tests.ps1`, and a stand-in `.claude/hooks/validate-bash.ps1`; it has no `config/poshqc-coverage.json`. | `.gitignore`, fixture files |
| Unit coverage of the mechanism | `PoshQC.Coverage.Tests.ps1` asserts, with an injected tree (`scripts/Sample.psm1`, `tests/scripts/Sample.Tests.ps1`, `.claude/hooks/validate-bash.ps1`) and the shipped settings, that the population is exactly `scripts/Sample.psm1` (line 162). No automated test runs the committed fixture; fixture acceptance is manual evidence only (`grep` for `poshqc-consumer` outside `docs/` matches only `.gitignore`). | `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1` |
| File size | `PoshQC.Testing.psm1` is 479 physical lines in the Read output, under the 500 limit. | Read output |

Production `.ps1`, `.psm1`, `.psd1`, and config files are unchanged between 3f766e3c and current main 18d6d1cc (orchestrator-measured, `git diff --stat` empty), so CI results at 3f766e3c describe current main.

## 2. Per-route evidence (orchestrator-measured, 2026-10-17)

Key hash = first 16 hex characters of the SHA-256 of the sorted list of JaCoCo `package|sourcefile` keys, normalized to repository-relative paths. "Diff" = per-file line-total differences against the reference report.

| Route | Source | Files | LINE total | Key hash | Diff | Covered | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| CI merged report, push on main, run 39030204156 (head 3f766e3c) | `ci.yml` job `poshqc` | 215 | 19095 | 360ba2de84f7d608 | reference | 17607 (92.21%) | Merged covered/total from the aggregator log |
| CI shards 1 to 3, run 39030204156 | `poshqc-shard` artifacts | 215 each | 19095 each | 360ba2de84f7d608 each | 0 | 11701 / 11072 / 11547 | Pass counts 3699 / 4165 / 3349 (different test subsets) |
| CI merged and shards 1 to 3, run 39004436897 | same | 215 | 19095 | 360ba2de84f7d608 | 0 | 12042 / 11340 / 11137 per shard | Pass counts 3481 / 3896 / 3816 (different shard assignment from the run above) |
| CI aggregator logs, runs 39030204156, 39029599568, 39006316242, 39004436897 | `Merged PowerShell line coverage` | 215 (`files=215` in every shard log) | 19095 | not hashed for the last two | n/a | 17607 | Four runs, one figure |
| CI aggregator logs, runs 39000065369, 38997293742, 38996377546 | same | 214 | 18990 | not recorded | n/a | 17499 | One production file was added between these and the runs above; the total moved by 105 lines |
| Local run A, Windows 11, PowerShell 7.6.6, Pester 5.9.0 | `Invoke-PoshQCTest -Root <absolute worktree root> -ScanFolders tests/scripts/powershell/PoshQC -DisableKoverageCopy`, current directory = worktree root | 215 (`source=config`) | 19095 | 360ba2de84f7d608 | 0 against the CI merged report | 669 | 188 passed; Pester: "27,998 analyzed Commands in 215 Files" |
| Local run B, same command | current directory = `tests/scripts` | 215 (`source=config`) | 19095 | 360ba2de84f7d608 | 0 | 669 | 188 passed |
| Installed extension 1.1.19 module, same command, same tree | import of the installed PoshQC copy | 215 | 19095 | not recorded | 0 | 689 | Predates #953 (no `UseBreakpoints = $false`, no Pester range). Numerator differs by 20 lines; denominator identical |
| Consumer fixture, branch module, `-Root <absolute>/tests/fixtures/poshqc-consumer -ScanFolders scripts,tests/scripts -DisableKoverageCopy` | self-hosted | 1 (`source=fallback`) | n/a (one file) | n/a | n/a | LINE covered 2, missed 0 | Coverage XML contains only `Sample.psm1`; `pester-junit.xml` tests=1, failures=0 |

Additional orchestrator-measured context:
- Issue #527 comments: triage on 2026-08-25 attributed the drift to the former per-file `CodeCoverage.Path` allow-list; the 2026-09-29 consolidation added #623 item 1 (#623 closed 2026-09-30); a later comment records that the `run_poshqc_test` MCP tool uses the installed extension's settings (deferred from #744).
- PR #821 (merged 2026-10-02, "Partially addresses #527") derived the population from `config/poshqc-coverage.json`. It left AC-01 run C (different current directory) and AC-11, AC-12, AC-13 (consumer fixture) open because no local `pwsh` was used.

### Reading of the evidence

1. The denominator is a function of the population only. Six full-population CI reports (merged and per shard, two runs) agree to the line on 215 files with 0 per-file differences, although the shards executed different test subsets (covered counts differ per shard by up to about 900 lines) and the second run assigned test files to shards differently. The local subset runs, with 188 tests and 669 covered lines, report the same 19095 total, so unexecuted files and unexecuted lines remain in the denominator.
2. The two denominator values seen across CI history (18990 and 19095) correspond to a documented tree change (214 to 215 files), not to variance.
3. The current directory does not change the denominator (run A against run B).
4. The invocation route does not change the denominator: self-hosted module in CI, self-hosted module locally, and the installed 1.1.19 module over the same tree all give 19095 over 215 files.
5. The numerator does depend on the collection mode (669 under profiler mode against 689 under breakpoint mode for the same 188 tests). This is the #953 change and is outside #527. It means covered counts and percentages recorded before and after the 1.1.20 release are not directly comparable, while denominators are.

## 3. Verdict

**Resolved in substance by PR #821 (derive the population from the workspace) and not regressed by PR #959 (profiler mode, sharding, merge, Pester pin).** Current main does not exhibit the #527 defect: the line-coverage denominator is reproducible across runs, shard assignments, current directories, and invocation routes (CI self-hosted, local self-hosted, installed 1.1.19). #959 did not change the population; it changed only how hits are collected (numerator) and which test files each process runs, and the merge guard now enforces cross-shard denominator equality on every CI run.

What remains is administrative, not a code defect: four acceptance criteria in `spec.md` are unchecked because the evidence that satisfies them did not exist when PR #821 merged. The evidence now exists as orchestrator measurements but is not yet recorded under `evidence/`.

## 4. Mapping of the four unchecked acceptance criteria

| AC | Requirement (abridged) | Evidence now available | Gap |
| --- | --- | --- | --- |
| AC-01 Deterministic derivation | Two self-hosted runs on the unchanged repo give an identical `<sourcefile>` set and root LINE total; a third run from a different current directory with the same absolute root matches; comparison recorded under `evidence/` | Local A and B (different current directory) match each other and the CI merged report: 215 files, 19095, key hash 360ba2de84f7d608, 0 per-file differences. CI runs 39030204156 and 39004436897 add six full-population reports that agree. | Not yet recorded under `evidence/`. The existing artifact `determinism-comparison.2026-10-02T08-45.md` is stale (174 files, 15738) and marked "run C pending". It must be superseded by a new timestamped artifact, not edited (the consumer selects the lexicographically greatest). |
| AC-11 Consumer fixture coverage | Fixture committed; self-hosted `Invoke-PoshQCTest -Root <fixture>` records covered LINE > 0 for the fixture's production file; JUnit zero failures; evidence shows the pre-fix run failing the check | Post-fix: `source=fallback; files=1`, only `Sample.psm1`, LINE covered 2, JUnit tests=1 failures=0. Pre-fix: `fail-first-fixture-run.2026-10-02T07-55.md` and `fail-first-fixture-check.2026-10-02T07-55.md` (SAMPLE_PRESENT=0, STANDIN_PRESENT=1, exit 1 as expected). | Post-fix run is not recorded under `evidence/`. The pre-fix evidence used the installed (pre-#821) MCP copy, which is the #623 configuration; this is acceptable for the "fails first" clause. |
| AC-12 Consumer isolation | No `<sourcefile>` refers to a drm-copilot file, including the stand-in `validate-bash.ps1` and any path outside the fixture tree | Coverage XML contains only `Sample.psm1`; no drm-copilot file and no stand-in. | The measured statement covers `sourcefile`; the record should also state the `package` attribute of that one file made fixture-root-relative (`scripts`) so "no path outside the fixture tree" is shown directly, not inferred. Structurally, fallback roots are joined to the fixture root, so a path outside the fixture cannot enter the population. |
| AC-13 Fixture output hygiene | After the fixture run, `git status --porcelain` shows no untracked or modified files from the run | `git status --porcelain --untracked-files=all` empty before and after; `git check-ignore -v` reports `.gitignore` line 8 `/tests/fixtures/poshqc-consumer/artifacts/`. | Not yet recorded under `evidence/`. The koverage copy (`-DisableKoverageCopy` omitted) lands in the same ignored directory; no extra path is introduced. |

### AC-01 and the full-suite question

- The AC text in `spec.md` does not use the words "full suite", but the plan's runs A and B were full-suite runs. The decision is whether subset runs justify closure.
- Subset runs justify it for the denominator. Reasons: (a) by code reading, the population resolver takes no test result as input; (b) the sharded CI evidence is itself a controlled experiment on test-independence: three processes with disjoint test sets and very different covered counts produced byte-identical key sets and per-file totals, in two runs with different shard assignments; (c) `Merge-PoshQCCoverageReport` fails the CI job if any shard disagrees, so the property is continuously enforced and not a one-off observation; (d) the local 188-test runs reproduced the full-suite CI total exactly.
- The CI merged report is a full-suite, self-hosted-route run of the same module on the same tree; it can serve as the full-suite leg. The local runs supply the different-current-directory leg, which CI cannot (the runner always starts in the checkout root).
- A comparison on the `<sourcefile>` attribute alone is too weak: that attribute is the leaf name, and at least `validate-feature-review-coverage` exists under both `.claude/hooks` and `.codex/hooks` (research 2026-09-29, N2). The comparison must use `package|sourcefile` keys normalized to repository-relative form, as the orchestrator's key hash did. The raw `package` attribute is an absolute directory path (the pre-fix fixture evidence shows `<ROOT>/tests/fixtures/poshqc-consumer/.claude/hooks`), so raw XML differs between hosts by design; normalization is required for any cross-environment comparison.

### Recommended execution-time re-verification

Keep it small and read-only; do not run the full local suite.
1. Re-run local A and B on the execution head with the same command and the targeted folder `tests/scripts/powershell/PoshQC`, from the worktree root and from a subdirectory, and record: population line, LINE total, files, key hash, and 0 per-file differences against the latest main CI merged report (by then the head may have moved; if a production PowerShell file was added, expect a new total and compare the two local runs plus the same-head CI report instead of the 19095 figure).
2. Add a third local current directory outside the repository tree (same absolute `-Root`) to match the spec's "different current directory" clause strictly.
3. Re-run the consumer fixture with the branch module, record the `package` attribute of the single file made fixture-root-relative, and re-run `git status --porcelain --untracked-files=all` and `git check-ignore -v`.
4. Optional, cheap, and the original #623 route: run the same fixture command with the installed 1.1.19 module imported instead of the branch module. Expected result is the same single-file population (the resolver in 1.1.19 is the #821 code, because 1.1.19 reports `files=215` for the repository). This is unverified for the consumer case.
5. No numeric count is proposed as a new `spec.md` assertion. The measured figures (215, 19095) change whenever a PowerShell file is added (214 and 18990 on earlier runs), so any closure criterion must compare runs with each other, not with a pinned number. No Numeric Derivation Evidence section is therefore required.

## 5. Remaining defects and risks

| Item | Assessment | Production change warranted? |
| --- | --- | --- |
| Installed-extension version skew | The MCP and extension routes run the installed copy (1.1.19). 1.1.19 already contains the #821 derivation (denominator identical), so the original route skew is closed for the denominator. It lacks #953: it uses breakpoint mode (covered 689 against 669) and has no Pester range. Release 1.1.20 (merge commit 3f766e3c, PR #971) carries #953; installing it is an operator step. The numerator difference is the #953 subject, not #527. Consumer behavior through 1.1.19 was not measured (unverified). | No |
| Pester 5.6.1 coexisting with 5.9.0 | On a host with both, 1.1.20 imports only 5.9.0 or later (range) and 1.1.19 imports the highest installed (5.9.0 locally). A host whose only Pester is 5.6.1 under 1.1.19 could in principle measure with a different command analysis; whether 5.6.1 and 5.9.0 count the same analyzed commands and lines was not measured (unverified). 1.1.20 refuses such a host with an actionable message. Behavior when a lower Pester version is already loaded in the session before `Invoke-PoshQCTest` imports 5.9.0 was not examined (unverified). | No; the range check is the mitigation |
| Absolute package paths in the JaCoCo report | `package` is an absolute directory path in `powershell-coverage.xml`; the `.koverage.xml` copy strips the root prefix. This makes raw XML differ between hosts but does not change any count. Comparisons must normalize, as in section 4. | No |
| Untracked or scratch `.ps1` files under the configured roots | Enumeration is directory-based (`Get-ChildItem -Recurse -File -Force`), so an untracked `.ps1` or `.psm1` under `scripts`, `.claude/hooks`, `.claude/lib`, `.codex/hooks`, or `.codex/scripts` enters a local denominator and not the CI denominator. This was accepted in the spec's Risks section; the `files=<n>` log line makes it visible. It is a theoretical local-versus-CI difference and was not observed in the 2026-10-17 comparison (the worktree matched CI exactly). | No |
| Pester minor-version drift inside the range | The range admits any 5.x from 5.9.0. A future 5.x release could change command analysis and move the denominator for an unchanged tree. Not observed; the Pester version is not logged by `Invoke-PoshQCTest`. | No for #527; see follow-up 3 |
| Case-insensitive de-duplication | Files differing only by case under the roots collapse to one entry on a case-sensitive file system. PoshQC coverage runs on Windows in CI, where this cannot occur. | No |
| Spec bookkeeping | `spec.md` shows Status Draft, Version 0.2; four ACs unchecked; the plan carries open blockers P6-T9 to P6-T12, P6-T15 to P6-T19, P6-T31, P6-T41 to P6-T43, P6-T48 (`evidence/other/plan-deviations.2026-10-02T07-45.md`, "Open blockers carried forward"). | n/a |

No production code, test, configuration, or workflow change is warranted to satisfy #527.

## 6. Candidate approaches and recommendation

| Approach | Description | Assessment |
| --- | --- | --- |
| A. Evidence-only closure (recommended) | Record the orchestrator-measured determinism and fixture results under `evidence/`, supersede the stale determinism artifact, check the four ACs, and close the issue with a summary comment. | Matches the verified state: the code satisfies the criteria; only the recorded proof is missing. Smallest risk. |
| B. Add automation (a Pester test or CI step that runs the committed fixture and asserts the population) | Closes the manual-evidence gap permanently. | Requires a nested `Invoke-PoshQCTest` run inside the suite or a new CI step, with file-system output (the repository forbids temporary files in tests; fixture output goes to an ignored directory, which is a different constraint but still a new moving part). The population logic is already unit-tested with an injected tree (`PoshQC.Coverage.Tests.ps1`). Not needed to close #527. |
| C. Re-open the fix (change `Resolve-PoshQCCoveragePopulation` or settings) | No supporting evidence: no variance was observed. | Rejected. |

**Recommended scope: evidence-only closure (A). No production fix.**

### Files an evidence-only closure would write (all under `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/`)

Filenames carry the UTC write time in `yyyy-MM-ddTHH-mm`; each command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; no absolute path, host name, or scratchpad path; scratch locations written as `SCRATCH`.

1. `evidence/qa-gates/determinism-comparison.<UTC>.md` (new, supersedes the 2026-10-02T08-45 file): local runs A and B, CI merged and per-shard reports from two runs, CI history (214 to 215 files), installed 1.1.19, key hash and per-file difference counts. Closes AC-01.
2. `evidence/regression-testing/post-fix-fixture-run.<UTC>.md` (new): population line, JUnit totals, coverage XML contents. Closes AC-11 together with the existing pre-fix artifacts.
3. `evidence/regression-testing/post-fix-fixture-check.<UTC>.md` (new): single-file population with the root-relative `package` attribute, no stand-in, no drm-copilot file. Closes AC-12.
4. `evidence/qa-gates/fixture-output-hygiene.<UTC>.md` (new): `git status --porcelain --untracked-files=all` before and after, `git check-ignore -v` result. Closes AC-13.
5. `evidence/qa-gates/ac-checkoff-complete.<UTC>.md` (new, supersedes the 2026-10-02T08-45 file): all 18 ACs checked, 0 unchecked.
6. `evidence/issue-updates/closure-comment.<UTC>.md` (new): the text posted to #527 summarizing the verdict and the follow-up decisions.
7. `spec.md` (edit): check AC-01, AC-11, AC-12, AC-13; update Status and Last Updated.
8. `plan.2026-09-29T15-32.md` (edit): check the carried-forward blocker tasks that this evidence satisfies, with a deviation note that the runs used subset scope (AC-01) and the current-directory legs ran locally.
9. Folder disposition (move to `docs/features/completed/`, link updates, `issue.md` status line) is a separate orchestrator closure step and is not part of the evidence write set.

## 7. Unrelated observations, candidate follow-ups

1. **Numerator comparability across the #953 boundary.** Covered counts and percentages recorded under breakpoint mode (extension 1.1.19 and earlier, and any baseline taken then) are not comparable with profiler-mode figures (669 against 689 on the same 188 tests). Reason: a "no regression on changed lines" comparison across the boundary would mix collection modes. Suggested action: note the boundary in the next coverage baseline, no code change.
2. **Install release 1.1.20 into the local VS Code extension.** The MCP `run_poshqc_test` tool serves the installed payload (1.1.19), so MCP-reported coverage keeps using breakpoint mode and no Pester range until the operator installs 1.1.20. Operator step, already known.
3. **Log the Pester version and the total line denominator in the `Code coverage population` line (or the summary).** Reason: the only residual denominator inputs not recorded in a run log are the Pester version and the summed line total; recording them would make a future drift attributable from the log alone, as the original issue proposed ("record the denominator alongside the percentage"). Small, optional, and not required by any open AC; it would touch a mirrored production file and its bundle copy, so it should be a separate item.
4. **No automated guard that the committed consumer fixture still yields a one-file population.** Reason: fixture acceptance is manual evidence; the unit test covers the logic with an injected tree. Worth a decision only if the fixture or the fallback path changes again.
5. **MCP results carry no output.** Already documented in the execution-environment brief; it is why none of the MCP-route claims above could be produced from the MCP tool.
6. **Severity field mismatch** (delegation says high; `issue.md` and `spec.md` say Medium). Confirm the GitHub label at closure so the closure comment and the folder records agree.

## Pre-Mortem

Assumes the recommended evidence-only closure is executed and later judged wrong or incomplete.

- **Review checklists:** A reviewer finds an AC checked without a matching artifact. Mitigation: each of AC-01, AC-11, AC-12, and AC-13 maps to one named evidence file in section 6, and the check-off artifact lists all 18 ACs with their evidence.
- **Coverage:** Closure is questioned because no new code was measured. Mitigation: no production code changes, so the 85% line threshold and the changed-line rule are unaffected; the AC-14 evidence from the earlier run stands. The measured aggregate (92.21% on 19095 lines) is recorded as evidence only, with no new gate.
- **Mirror parity:** An evidence-only closure touches no PoshQC file, so the bundled-parity test is unaffected. If follow-up 3 (logging the Pester version) is later taken, it changes a mirrored file and must update the `extensions/drm-copilot/resources/powershell/PoshQC/` copy in the same change.
- **File size:** The closure writes only Markdown, which is exempt. `PoshQC.Testing.psm1` is 479 lines, so follow-up 3 would leave only 21 lines of headroom and would need a new sub-module.
- **Test isolation:** The recommended re-verification runs only the existing PoshQC suite and the fixture. It adds no test and no temporary file, and fixture output goes to the ignored `tests/fixtures/poshqc-consumer/artifacts/` directory. If a fixture guard test is added (follow-up 4), it must still avoid temporary files and shared state.
- **CI-only behavior:** Local runs on Windows with a 188-test subset may differ from CI if the head has moved or a production PowerShell file was added. Mitigation: compare against a CI report from the same head, and compare the two local runs with each other. The CI shard merge guard cannot reproduce the different-current-directory leg, which therefore stays a local run.
- **Evidence:** Recorded figures could be stale or carry paths. Mitigation: orchestrator-measured values are labelled as such, filenames carry the UTC write time, and no artifact records an absolute path, host name, or scratchpad path (the token `SCRATCH` is used). Hashes use repository-relative normalized keys, and the stale 2026-10-02T08-45 artifacts are superseded, not edited.

## 8. Unverified items

- All figures in sections 2 and 3 are orchestrator-measured and were not reproduced here.
- Consumer-fixture behavior through the installed 1.1.19 module.
- Whether Pester 5.6.1 and 5.9.0 produce the same analyzed-command and line counts for this population.
- Behavior of the `Import-Module -MinimumVersion 5.9.0` step when a lower Pester version is already loaded in the host session.
- The current GitHub severity label for #527.
- Key hashes for CI runs 39029599568 and 39006316242 (only the aggregator totals were reported for those two runs).
