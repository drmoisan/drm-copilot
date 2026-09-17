# 2026-09-13-prd-feature-gate-target-resolution (Plan)

- **Issue:** #672
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-13T23-08 (measured local clock reading, supplied by the calling session; it replaces the round-4 `23-45` stamp, which was 40 minutes ahead of the machine clock)
- **Status:** Revised for preflight round 9
- **Version:** 1.8
- **Epic:** `worktree-scoped-state-resolution` (F4, wave 1, defect ref 3.1)
- **Work Mode:** `full-bug`
- **Acceptance-criteria source:** `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md` section `## Acceptance Criteria` is the sole acceptance-criteria source for this work mode, per `.claude/skills/acceptance-criteria-tracking/SKILL.md`. It carries 38 criteria, counted directly between the `## Acceptance Criteria` heading at line 600 and the `## Risks & Mitigations` heading at line 671. `user-story.md` is intentionally absent and is not consulted.
- **Research record:** `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/research/2026-09-13T21-05-prd-feature-gate-target-resolution-research.md`
- **Revision record:** round 1 preflight delta applied from `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-1-delta.2026-09-13T21-50.md`. Three items in that delta were re-derived against the tree and found to be incorrect as supplied; the corrections are recorded in this plan's `## Round 1 delta — items corrected during re-derivation` section below. Round 2 preflight delta applied from `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-2-delta.2026-09-13T22-40.md`; that round adjudicated all three of the round-1 corrections in this plan's favour and they are retained unchanged. The round-2 application record is at `## Round 2 delta — application record` below. Round 3 preflight delta applied from `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-3-delta.2026-09-13T22-37.md`; that round adjudicated the round-2 corrections N5 and N6 in this plan's favour and they are retained unchanged. The round-3 application record is at `## Round 3 delta — application record` below. Round 4 preflight delta applied from `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-4-delta.2026-09-13T23-05.md`; that round adjudicated the round-3 `[P2-T1]` placement deviation, the widened parity-test clause, the `current-session-id` safety finding, and all five findings N7-N11 in this plan's favour, and they are retained unchanged. The round-4 application record is at `## Round 4 delta — application record` below. A round-5 unsatisfiable-acceptance remediation was applied on top of that: the `run_poshqc_*` MCP tools return no captured script output, so five tasks asserted values with no readable source and two named a route-conditional source. Three preamble sections were added — `### MCP PoshQC result surface, and the unconditional direct measurement route`, `### Test-count and coverage derivation (fixed, not left to the executor)`, and `### Analyzer-finding-count derivation (fixed, not left to the executor)` — and `[P0-T4]`, `[P0-T5]`, `[P1-T7]`, `[P2-T10]`, `[P4-T21]`, `[P6-T2]`, `[P6-T3]`, and `[P6-T5]` now derive every asserted value from `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, or a named console literal. No acceptance condition was weakened, no MCP invocation was removed, and no task ID, ordering, phase structure, batch-budget reasoning, or evidence path changed. Round 6 preflight returned `PREFLIGHT: REVISIONS REQUIRED` with `CONVERGENCE: NO FURTHER ROUNDS EXPECTED` and six defects, each supplied as verbatim replacement text at a single named location: an unsatisfiable one-node-per-identifier rule for the two `-ForEach`-bound identifiers, an unsourced changed-line set in `[P6-T5]`, an analyzer literal written to stream 6 with no redirection stated, a `[P2-T8]` acceptance that could not fail, an overall-coverage comparison spanning two denominators, and an aggregate derivation silent on the per-file fallback form. All six are applied in round 7 and recorded at `## Round 6 delta — application record` below. No acceptance condition was weakened, no MCP invocation was removed, and no task ID, ordering, phase structure, batch-budget reasoning, or evidence path changed in that round either. Round 7 preflight confirmed all eight round-7 spans, passed the plan validator gate, and returned `PREFLIGHT: REVISIONS REQUIRED` with `CONVERGENCE: NO FURTHER ROUNDS EXPECTED` and three defects, each confined to a single named span: `[P6-T5]`'s hunk-header rule covered only the `+c,d` spelling and not the count-omitted `+c` spelling that `--unified=0` emits for a single-line edit; `[P3-T4]` did not state the two-row `-ForEach` binding that `[P4-T21]`'s fixed node count of two depends on; and `[P4-T21]`'s closing sentence conflated the eighteen fixed identifiers with the Phase 3 fail-before count. All three are applied in round 8 and recorded at `## Round 7 delta — application record` below. The `[P6-T5]` delta was applied with one adaptation: the supplied text cited this repository's `.claude/hooks` history as the observation site, which no tool available to the planner in this pass can query, so the citation was re-derived to a `git diff -U0` output already recorded in the tree and the sentence now names that artifact and its two hunk headers. No acceptance condition was weakened, no MCP invocation was removed, and no task ID, ordering, phase structure, batch-budget reasoning, or evidence path changed in that round either. Round 9 remediates that round-8 adaptation and changes nothing else: the calling session ran `git log -n 60 --unified=0 -p -- .claude/hooks` from the worktree root and supplied the three post-image spelling counts it emits, so `[P6-T5]`'s hunk-header sentence now cites the history of the directory this change set modifies, and the substituted citation to another feature's evidence artifact is removed from `[P6-T5]` and from the round-7 application record. Those counts are attributed to the calling session's run rather than re-derived by the planner, which has no shell in this pass. Every other clause of the round-8 hunk-header sentence is carried byte-unmodified, no acceptance condition was weakened, and no task ID, ordering, phase structure, batch-budget reasoning, or evidence path changed.

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

---

## Plan Preamble — bindings, rulings, and constraints the executor must not overturn

### Evidence location (non-overridable)

Every evidence artifact this plan names is written under
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/<kind>/`,
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Paths rooted at `artifacts/baselines/`,
`artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`, or `artifacts/evidence/`
are prohibited and fail preflight. The `<ISO-8601>` element in each artifact filename is the
`yyyy-MM-ddTHH-mm` timestamp of the run that produced it.

The file-size ledger at `evidence/other/file-size-ledger.md` is the single exception to the
timestamped-filename convention, because two tasks append to one ledger; each block inside it carries its
own `Timestamp:` line.

`artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` are tool output paths
declared by `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lines 15 and 22. They are read
as inputs by evidence tasks; they are not evidence-artifact destinations and no task writes evidence there.

### MCP PoshQC result surface, and the unconditional direct measurement route

`mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`, and
`mcp__drm-copilot__run_poshqc_format` return **no captured script output**.
`extensions/drm-copilot/src/repo-automation-service.ts` lines 355-380 define `runPoshQcWorkflow`, which
destructures `{ args, bundledRelativePath, summary }` from `buildPoshQcWorkflowArguments` at lines 366-369
and passes that **precomposed** `summary` to `executeScript` at lines 371-379 with no
`stdoutArtifactPattern`. The contrasting form is `newPotentialEntry` at lines 223-236, which does pass
`stdoutArtifactPattern: /^Created:\s*(.+)$/im` at line 234. The child process's stdout reaches the VS Code
extension output channel and never enters the MCP result. No test count, no coverage percentage, no
analyzer finding count, and no per-test name is readable from any `run_poshqc_*` MCP call. Every asserted
numeric value and every asserted literal in this plan is therefore derived from a file on disk or from the
console output of a directly invoked command, never from an MCP result. Where a task text names an
`mcp__drm-copilot__run_poshqc_*` invocation, that invocation is retained for route compliance and is not
the source of any asserted value.

**The installed-extension caveat is unconditional, not a runtime contingency.**
`mcp__drm-copilot__run_poshqc_test` resolves its Pester run settings from the **installed VS Code
extension**, not from either in-repo copy. `spec.md` lines 732-733 assign the extension rebuild, reinstall,
and push-down to the epic's delivery feature and not to this one, so the installed extension carries
pre-change settings for the whole of this feature's execution and the `CodeCoverage.Path` entry added by
`[P2-T6]` cannot become visible to it during this feature. Because that is a fact about the epic's work
allocation rather than a runtime contingency, every test and coverage measurement in this plan is taken by
the direct route below, run from the worktree root **through the PowerShell tool**, which is the single
execution route for it — the executor selects nothing:

`Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

This reads the repository-side settings by construction: `PoshQC.psm1` line 3 sets `$script:PesterSettings`
from its own module root, `Invoke-PoshQCTest` is exported at `PoshQC.psm1` line 143 and declared at
`PoshQC.Testing.psm1` line 151, and its `-SettingsPath` parameter (`PoshQC.Testing.psm1` line 156) is bound
explicitly here so no default can redirect it. `-ScanFolders` is deliberately omitted:
`PoshQC.Testing.psm1` lines 305-318 fall back to the persisted scan configuration and then to the settings'
own `Run.Path`, which reproduces the MCP runner's folder scope. `[P0-T5]`, `[P1-T7]`, `[P2-T10]`,
`[P4-T21]`, `[P6-T3]`, and `[P6-T5]` record this command verbatim in their `Command:` field and name no
alternative route for the values they assert.

`[P2-T8]` keeps its probe and its recorded finding unchanged. Its purpose is to determine whether the new
sibling enters the coverage denominator when the MCP runner is used, and that determination remains
meaningful. What this section removes is the conditionality of the downstream routing, not the probe.

### Test-count and coverage derivation (fixed, not left to the executor)

`Invoke-PoshQCTest` does not accept `-PassThru` and returns no result object, and `Run.Exit` is `$true` at
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 4, so a failing run ends the session
before any value could be read from a return value and a process exit code carries no count. Read the
counts **after** the run from the JUnit report the same settings file enables at lines 12-15: line 12 opens
`TestResult = @{`, line 13 is `Enabled = $true`, line 14 is `OutputFormat = 'JUnitXml'`, and line 15 is
`OutputPath = 'artifacts/pester/pester-junit.xml'`. Load it as
`$junit = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml')`:

- **Total, failed, and error counts** are the `tests`, `failures`, and `errors` attributes on that
  document's `testsuites` element: `$junit.testsuites.tests`, `$junit.testsuites.failures`, and
  `$junit.testsuites.errors`. The **passed** count is `tests` minus `failures` minus `errors`, computed and
  recorded as an integer. Record all four integers in `Output Summary:`.
- **Per-test results** are read from the `testcase` elements of the same report, enumerated as
  `$junit.SelectNodes('//testcase')`. Match a case by its `name` attribute **containing** the `It` text
  quoted in this plan, and treat the **absence of a child `failure` element** on the matched node as the
  pass condition. Each named `It` must match **at least one** node, and **every** matched node must carry
  no child `failure` element. The expected node count is fixed per identifier rather than assumed to be
  one, because Pester emits one `testcase` node per `-ForEach` row and expands the `name` attribute only
  where the `It` name carries a `<Property>` template. Sixteen of the eighteen identifiers expect exactly
  one node. `resolves the required document set for each work mode` expects **four**, one per work-mode
  row bound by `[P4-T17]`. `allows an absolute path to the target feature folder` expects **two**, one per
  modelled cwd value bound by `[P3-T4]`. A match count differing from the identifier's fixed expected
  count in either direction, and any matched node carrying a child `failure` element, fails the asserting
  task; neither is an occasion to relax the match. Record the full `name` attribute value of
  one matched node verbatim in the artifact, so the report's own spelling of the attribute is documented.

Coverage is read from the CoverageGutters report the same settings file enables at lines 17-22: line 17
opens `CodeCoverage = @{`, line 18 is `Enabled = $true`, line 21 is `OutputFormat = 'CoverageGutters'`, and
line 22 is `OutputPath = 'artifacts/pester/powershell-coverage.xml'`.

- **Per-file line coverage.** Select the `sourcefile` node whose `name` attribute is the file's leaf name
  **and** whose parent `package` node's `name` attribute ends with the file's directory, because the same
  hook filename appears under both `.claude/hooks` and `.codex/hooks`. Line coverage is the count of that
  node's child `line` elements whose `ci` attribute is greater than zero, divided by the total count of its
  child `line` elements. If the node carries no child `line` elements, use its `counter` element of `type`
  `LINE` and compute `covered / (covered + missed)`. Record which of the two forms was used.
- **Overall line coverage.** This figure has no JUnit source and is printed by no console summary this plan
  can read. It is derived from the same coverage report by the same mechanism, aggregated: for **every**
  `sourcefile` node in the report, take the covered-line count and the total-line count by the per-file
  rule above — child `line` elements whose `ci` is greater than zero over all child `line` elements,
  falling back to the node's `counter` element of `type` `LINE` and `covered / (covered + missed)` only
  for a node that carries no child `line` element — then sum each of the two counts over all nodes and
  divide the first sum by the second. Record how many nodes were aggregated and how many of them used the
  fallback form, so the aggregate is reproducible by a third party from the same report. Record the two
  summed integers beside the percentage.

This derivation governs `[P0-T5]`, `[P1-T7]`, `[P2-T10]`, `[P4-T21]`, and `[P6-T3]`. For `[P4-T21]`'s
eighteen named `It` identifiers, the per-test rule above is the derivation: match on the `testcase`
element's `name` attribute and treat absence of a child `failure` element as the pass condition. It is
consistent with tasks already in this plan rather than new to it: `[P0-T6]` and `[P5-T5]` already read
their per-suite pass and fail counts from the same JUnit report.

### Analyzer-finding-count derivation (fixed, not left to the executor)

No analyzer finding count can be read from `mcp__drm-copilot__run_poshqc_analyze`, for the reason stated
above, and the analyzer writes no report file. The count is derived from the repository-side module,
imported directly and run from the worktree root **through the PowerShell tool**:

`Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pssa.settings.psd1 6>&1`

The trailing `6>&1` is mandatory rather than stylistic. `PoshQC.Analyzer.psm1` line 116 emits the logger's
message with `Write-Information`, which writes to stream 6; the literal the zero-findings branch asserts
therefore reaches stream 6 and not the success stream. Without the redirection the literal's presence in
captured output depends on whether the capturing host renders stream 6, and a host that does not would make
`[P1-T7]`, `[P4-T21]`, and `[P6-T2]` fail on a clean tree. `6>&1` merges the stream into the success stream
so the literal is captured on every route. The four governed tasks record this command with the redirection
in their `Command:` field.

`Invoke-PoshQCAnalyze` is declared at `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` line 83 and exported
at `scripts/powershell/PoshQC/PoshQC.psm1` line 140. Its `-SettingsPath` parameter is declared at
`PoshQC.Analyzer.psm1` line 88 with the default `$script:PssaSettings`, which `PoshQC.psm1` line 2 sets
from the module root; it is bound explicitly here so no default can redirect it.
`scripts/powershell/PoshQC/settings/pssa.settings.psd1` exists in this tree. The function returns no value
and throws on a non-zero count, so nothing can be read from a return value. The observation is the captured
console output, and it differs by branch:

- **Zero findings.** `PoshQC.Analyzer.psm1` line 185 invokes the logger with
  `"PSScriptAnalyzer passed: no findings under $Root"`, and the default `$Logger` at lines 114-117 is
  `Write-Information $Message -InformationAction Continue`, so the literal
  `PSScriptAnalyzer passed: no findings under` reaches the console. Record the finding count as `0`
  together with that literal quoted verbatim from the captured output. The literal is the failable
  observable: a run that has findings never prints it, because line 183 throws before line 185 is reached.
- **Non-zero findings.** `PoshQC.Analyzer.psm1` lines 181-183 print the findings with
  `$results | Format-Table -AutoSize` at line 182 — each row carrying the finding's rule name and file
  path — and then throw `PSScriptAnalyzer reported $($results.Count) issue(s).` at line 183. Record the
  integer from that message and the rule name and file path of each printed row.

Because the zero branch prints a literal rather than an integer, each governed task **additionally** records
a per-file integer count, which is printed in both branches, for each file in its own fixed file set:

`Import-Module PSScriptAnalyzer -ErrorAction Stop; @(Invoke-ScriptAnalyzer -Path '<file>' -Settings 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Count`

The `<file>` element is substituted with each repository-relative path in the task's fixed file set below.
Those sets are fixed here and are not chosen by the executor. Only `.ps1` and `.psm1` files are listed,
because `Invoke-PoshQCAnalyze` filters its file list to those two extensions at `PoshQC.Analyzer.psm1`
line 132, so the two `pester.runsettings.psd1` copies are outside the analyzer's scope and are not counted:

| task | fixed file set |
| --- | --- |
| `[P0-T4]` | `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` (4 files; these are the files that exist before this feature changes anything) |
| `[P1-T7]` | the four above plus `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` (5 files) |
| `[P4-T21]` | the five above plus `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` and `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` (7 files) |
| `[P6-T2]` | the same 7 files as `[P4-T21]` |

This derivation governs `[P0-T4]`, `[P1-T7]`, `[P4-T21]`, and `[P6-T2]`.

### Upstream dependency F1 — identifiers bind at execution time

F1 (`target-worktree-resolution-module`, wave 0) delivers a `.claude/lib/` module providing target
derivation, path normalisation, and a distinct ambiguity reason code. Its module path, exported function
names, and reason-code literal are **not settled at planning time** and are **not guessed anywhere in this
plan**. Task P0-T8 reads F1's merged source and records those identifiers into
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/f1-identifier-binding.<ISO-8601>.md`.
Every later task that needs a spelling takes it from that artifact. No acceptance condition in this plan
searches for an F1 identifier literal, because no such literal can be quoted here.

P0-T8 is a fail-closed halt gate. If F1's module is absent from `.claude/lib/`, or if the three required
capabilities are not exported, execution halts and reports blocked. Local re-implementation of any of the
three capabilities is prohibited by `spec.md` line 70 and is not an available fallback.

### Change-budget route (spec risk R3) — batch split, operationalised by an explicit reset at each boundary

`.claude/rules/powershell.md` lines 39-40 cap direct mode at 2 production PowerShell files and any batch at
3 production files and 3 test files. This change set is 4 production PowerShell files (the hook, its new
sibling, and their two bundled mirrors) plus 2 `.psd1` settings files, which
`.claude/hooks/enforce-powershell-batch-budget.ps1` also classifies as production (line 273 matches
`.ps1|.psm1|.psd1`; line 284 classifies only `tests/**/*.ps1` and `*.Tests.ps1` as test). The helpers
extraction is mandatory, so the conflict cannot be removed by narrowing scope. **The route taken is the
batch split**, not an override and not a router hand-off.

The batch split is not merely declarative. `enforce-powershell-batch-budget.ps1` is registered as a
PreToolUse hook on `Write|Edit` at `.claude/settings.json` line 144. Its counter is **session-scoped, not
phase-scoped**: it persists the set of distinct production paths already written into
`<root>/.claude/state/powershell-batch-budget.<resolved-session-id>.json` (composed at line 366 from the
state directory joined at line 352), rehydrates it on every subsequent write (lines 369-376), and denies at
line 297 once the production list has reached `prodCap`, which the entry point sets to 3 at line 426.
`<root>` is `(Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)` (lines 210, 269, 315), which is the
worktree root containing `.claude/hooks`, not the process working directory. Without an explicit reset the
cumulative production count reaches 3 at the first bundled-mirror write and every later production write in
this plan is denied. Line 296 states the reset: delete the state file. Each batch below is therefore opened
by an explicit boundary task that removes the state file before the batch's first write.

| batch | phase | opened by | production files in the batch |
| --- | --- | --- | --- |
| A1 | Phase 0 | `[P0-T10]` (reset only if its enumeration is non-empty; `.claude/state` held no file in the planning worktree, and `[P0-T7]` clears the directory before this boundary runs) | `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` |
| A2 | Phase 1 | no reset needed (same two files as A1; a repeat edit consumes no new slot, per line 289) | the same two files |
| B | Phase 2 | `[P2-T1]` | the two bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` |
| C | Phase 2 | `[P2-T4]` | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (plus `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, which is not a PowerShell file and consumes no slot) |
| D | Phase 4 | `[P4-T1]` | the repository hook and its sibling |
| E | Phase 5 | `[P5-T1]` | the two bundled mirrors |

Test files are counted separately against a cap of 3 and never exceed 3 per batch. The three test files in
scope are `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` (new),
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` (amended), and
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` (amended). Three
distinct test paths is exactly at the cap and is permitted, because line 293 denies only a new path arriving
when the list has already reached the cap; the boundary resets clear the test list as well.

### Intermediate parity window (stated so it is not misread as a defect)

Phase 0 creates `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` in the repository tree before
its bundled mirror exists, and Phase 4 changes the repository hook before Phase 5 re-mirrors it. During those
windows `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` is expected to fail. The delivery
tests are asserted green at Phase 2, Phase 5, and Phase 6 only. No task in Phase 0, Phase 1, Phase 3, or
Phase 4 asserts them.

A second, unrelated mechanism can also fail the bundled-payload parity test: the repository writes runtime
state under `.claude/state/`, which `.gitignore` line 68 ignores and which has no bundled counterpart. Three
hooks write there — `enforce-powershell-batch-budget.ps1` composes
`powershell-batch-budget.<session-id>.json` at lines 362-366, the `SessionStart` hook
`persist-session-id.ps1` writes `current-session-id` at line 161, and
`enforce-python-batch-budget.ps1` composes `python-batch-budget.<session-id>.json` at line 363 — and
`test_push_down_claude_resource_contracts.py` enumerates `.claude` without honouring `.gitignore`. Every task
that asserts that test green removes **every** file under `.claude/state` first, not only the batch-budget
file. The batch-boundary tasks keep the narrower batch-budget filter, because a boundary reset is about
budget slots rather than about payload parity.

### Search-assertion form (mandatory for every acceptance condition in this plan)

Every `Select-String` acceptance condition in this plan is executed as
`Select-String -SimpleMatch -Pattern '<token>' -Path '<path>'`, with the pattern in single quotes.
`-SimpleMatch` is mandatory: without it `$` is a regex end-of-line anchor and `(` opens a group, so tokens
such as `$true`, `$PWD`, `$segments[0..3]`, and `param(` either match nothing whatever the file contains or
raise a parse error. An acceptance condition run without `-SimpleMatch` is void and must be re-run.

Two further rules apply to every search assertion here:

- **Expected counts are derived from the file's actual content, not from an idealised zero.** A token that
  legitimately occurs inside the delivered file is asserted at its true count, with the qualifying property
  (such as indentation or enclosing construct) recorded from the `Select-String` output, rather than being
  asserted at zero and failing correctly-written code.
- **Every zero-match assertion carries a named control.** Where a task asserts a zero-match result and treats
  it as a discriminator, the task also records a control count: the same `-SimpleMatch` search run against the
  named tracked file listed below, whose non-zero match count is recorded in the same artifact. A zero result
  on the target file is only evidence when the same search returns non-zero on the control.

| asserted token | control file (verified to contain it in this tree) |
| --- | --- |
| `git worktree` | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` line 3 |
| `Get-Location` | `.claude/hooks/persist-session-id.ps1` line 161 |
| `$PWD` | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` lines 75 and 291 |
| `Resolve-Path` | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` line 6 |
| `New-Item` | `.claude/hooks/persist-session-id.ps1` line 96 |
| `Push-Location` | `scripts/powershell/Publish-DrmCopilotExtension.ps1` lines 259, 281, 309 |
| `GetTempPath` | `.claude/hooks/check-powershell-test-purity.ps1` line 107 |
| `$env:TEMP` | `.claude/hooks/check-powershell-test-purity.ps1` line 108 |
| `Set-Location` | `docs/features/completed/2026-06-16-pre-claude-session-script-189/spec.md` — see the note below |
| `-MockWith { $true }` | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` lines 293, 306, 319, 332 (4 occurrences) |
| `return $candidates[0]` | the pre-change `.claude/hooks/enforce-prd-feature-before-planner.ps1` at lines 290 and 307 (2 occurrences), recorded by `[P0-T3]` before the file is edited |
| `uses the earliest candidate` | the pre-change `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` at lines 97 and 105 (2 occurrences), recorded by `[P0-T3]` before the file is edited |
| `falls back to orchestrator-state.json` | the pre-change `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` at line 107 (1 occurrence), recorded by `[P0-T3]` before the file is edited |

`Set-Location` note: a whole-tree search in this worktree returns **no PowerShell file containing
`Set-Location`** — it appears only in Markdown documents. Its control is therefore drawn from a tracked
Markdown file. The control's only purpose is to prove the search mechanism matches when the token is present,
and the file type is immaterial to that. This is recorded rather than hidden, because the round-1 plan text
claimed all seven purity tokens "are present elsewhere in the tracked tree", and for `Set-Location` that claim
is false for PowerShell files.

### Rulings carried from `spec.md` and the research record — do not overturn

1. **Truncation.** The epic's prohibition on segment-count truncation covers truncation used as a substitute
   for locating the containing worktree. It does **not** cover depth normalisation. The depth-collapsing block
   at `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 272-277 was delivered by the completed fix
   for issue #518 and must survive byte-unmodified. Deleting it re-opens #518. Only the prefix-discarding half
   — the unanchored match pattern beginning at the literal `docs` at line 252, consumed by the
   `[regex]::Matches` call at line 253 — is replaced by F1's normalisation.
2. **Work-mode marker semantics as they are, not as the epic paraphrases them.** The gate does **not** fail
   closed to `full-feature` on a missing or malformed marker. Lines 398-410 are a distinct decision path that
   denies with its own reason and runs **no** required-file probe. The `default` arm of
   `Get-PrdFeatureRequiredFile` at line 185 returns `spec.md` alone and must never name `user-story.md`.
   "Fail closed to full-feature" is a producer-side lifecycle rule and must not be imported into the gate.
3. **Anti-pattern.** No task in this plan changes prompt construction. The originating run's first hypothesis
   — that child prompts omitted the folder path — was disproved; every child prompt named its own folder. The
   defect is in the hook's resolution, not in its callers.
4. **No Codex mirror.** Full enumeration of `.codex/hooks/` confirms no mirror of this hook and no differently
   named analogue. This feature carries zero Codex parity work. A reviewer should not look for one.
5. **No Python in the enforcement path.** The hook and its sibling are PowerShell only.
6. **`quality-tiers.yml` does not exist at the repository root** in this tree. No task and no acceptance
   condition in this plan depends on it. The uniform gates apply regardless.
7. **PowerShell coverage is line coverage only.** Pester measures no branch coverage, so no branch-coverage
   threshold is asserted anywhere in this plan (`.claude/rules/quality-tiers.md`,
   `.claude/rules/powershell.md` line 64).
8. **Unbound-target composition (binding ruling).** Target resolution has **three** distinguishable states,
   and collapsing any two of them breaks the feature. The composition sites are
   `Find-PrdFeatureFolderFromPrompt`'s return value, `Get-PrdFeatureIssueContent`'s `"$FeatureFolder/issue.md"`
   at line 107, and `Get-PrdFeatureMissingFile`'s `"$FeatureFolder/$name"` at line 329.

   - **State A — a target is bound or derived.** The injection parameter added by `[P4-T3]` is bound to a
     non-empty value, or F1's derivation returns a target. Composition anchors to that root: the target root
     is prefixed when it differs from the modelled session root, and the bare repo-relative spelling is kept
     when the resolved root and the session root coincide.
   - **State B — no derivation input.** The injection parameter is unbound **and** the payload carries no
     field F1's derivation reads. This is the state of every case in both existing suites. All three
     composition sites emit the bare repo-relative spelling they emit today, unchanged. The ambiguity branch
     is **not** taken in this state.
   - **State C — explicit no-target.** F1's derivation ran against a payload that did carry the field it
     reads and reported that no target can be determined, and the session root is not the derived target. The
     ambiguity deny added by `[P4-T5]` fires here, and only here.

   Composing an absolute prefix unconditionally is **prohibited**: it breaks every existing decision-level
   case at once, and the failure presents as a mass suite failure at `[P4-T21]` rather than as a located
   defect. Taking the ambiguity branch on the unbound-parameter path alone is equally prohibited, because it
   collapses State B into State C and the three-way distinction the feature exists to establish is lost.

   What binds this ruling is exact-equality assertions, which tolerate no prefix. They are:
   - three existence mocks keyed with `-eq` on a bare repo-relative path, at
     `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` lines 124,
     156, and 187;
   - ten `Should -Be` equalities on `Find-PrdFeatureFolderFromPrompt`'s return value — at
     `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` lines 205 and 208, and at
     `...FolderResolution.Tests.ps1` lines 33, 40, 47, 53, 77, 94, 102, and 110. The last three are
     re-specified by `[P4-T14]` and `[P4-T15]`; the other seven must keep passing unmodified.

   The reason-string assertions across both suites are **not** what binds this ruling, and this plan does not
   claim they are: every one of them uses a substring form (`-Match`, `-BeLike '*...*'`, or
   `String.IndexOf`) — for example `...FolderResolution.Tests.ps1` lines 341-342 and 389-390, and
   `...Tests.ps1` lines 132-133, 152-153, and 391 — so each tolerates a prefixed root. Stating this
   accurately matters: an executor told that the reason strings pin the bare spelling would over-constrain
   State A, where a prefixed root is required.

   If F1's derivation does not itself distinguish State B from State C, the hook draws the distinction from
   whether the envelope carried the field F1 reads, which `[P0-T9]` determines and records. `[P0-T8]` records
   which of the two mechanisms applies.

### Highest regression risk and how this plan sequences against it

A change that resolves the target correctly but stops checking the document converts a false denial into a
false approval, which is the more serious failure mode. The plan keeps the document-presence check provably
exercised through three guards that are separate tasks with separate acceptance conditions: a zero-invocation
count on the ambiguity branch (`[P3-T6]`, `[P4-T5]`), exact positive invocation counts on allow rows
(`[P4-T16]`), and a keyed existence mock shared across positive and negative rows with no blanket always-true
mock (`[P4-T18]`).

### No-temp-file test pattern (mandatory)

Temporary files and directories are prohibited in tests. The compliant pattern established in this repository,
and the one every new case in this plan follows, has four parts, with
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` lines 25-34
as the exemplar: synthetic absolute prefixes declared as bare string literals never derived from the
environment, the current directory, the script file location, or a source-control query; an injection parameter
on the decision function so disk is never read; an existence mock keyed on the full composed path; and rows
bound with `-ForEach` over a discovery-time array, because a value assigned inside an `It` body is not visible
from Pester's discovery phase. The process working directory is never changed and no directory is created.
cwd is modelled as data.

### Named test identifiers this plan fixes

The following `It` names do not exist in the tree yet. Each is quoted here verbatim so the executor creates it
with exactly this text and so later acceptance conditions can name it. The list carries **eighteen** names:
the fifteen fixed in revision 1.0, plus the item-worktree regression guard added by `[P3-T3]` and the two
re-specified positional-fallback cases renamed by `[P4-T15]`.

1. `observes a test-scope mock across the dot-source boundary`
2. `allows when the target root holds the required document`
3. `denies with the missing-document reason when the document is absent under the target root`
4. `denies with the ambiguity code when the target cannot be resolved`
5. `emits an ambiguity code distinct from the missing-document and marker reasons`
6. `denies rather than validating against a sibling session checkpoint`
7. `denies rather than selecting the earliest candidate on an unresolved tie`
8. `denies with the ambiguity reason when the folder is absent from the target root`
9. `runs no existence probe on the ambiguity branch`
10. `probes once on a full-bug allow row`
11. `probes twice on a full-feature allow row`
12. `allows an absolute path to the target feature folder`
13. `allows the session-root fallback when the derived target is the session root`
14. `prefers the derived target when it occurs later in the prompt`
15. `resolves the required document set for each work mode`
16. `allows when the modelled cwd is the item worktree`
17. `denies when the checkpoint is absent and the tie cannot be resolved against the derived target`
18. `denies when the checkpoint names a folder that is not a candidate`

The two `Context` names this plan fixes are `cross-file mock resolution smoke` and `target resolution matrix`.

### Round 1 delta — items corrected during re-derivation

Three items supplied in the round-1 preflight delta were re-derived against the current tree in this pass and
are not applied as supplied. Each correction is recorded here so a later reviewer does not re-open it.

1. **D11, checkpoint-fallback line range.** The delta reports the unconditional checkpoint fallback at lines
   367-369 and calls the plan's 368-370 an off-by-one. Re-derived: line 367 is
   `$folder = Find-PrdFeatureFolderFromPrompt -Prompt $prompt`, line 368 is `if (-not $folder) {`, line 369 is
   `$folder = Get-PrdFeatureCheckpointFolder`, line 370 is `}`, and line 371 is blank. The plan's original
   range 368-370 is correct and is retained; the delta's descriptive improvement (naming the three lines) is
   applied on top of it. Removing 367-369 as the delta directs would delete the prompt-resolution assignment
   and leave a dangling brace.
2. **D11, preamble ruling 1 pattern-literal line.** The delta moves the pattern literal from line 252 to line
   251. Re-derived: line 251 is the comment `# Allow forward or backslash separators...`, line 252 is
   `$pattern = 'docs[\\/]+features[\\/]+active[\\/]+[^\s"''`]+'`, and line 253 is the `[regex]::Matches` call.
   The plan's original 252 is correct and is retained; the `[regex]::Matches` companion citation is corrected
   to line 253.
3. **D1, `spec.md` retention citation.** The delta cites `spec.md` line 353 as requiring the single-candidate
   return be retained. Re-derived: line 352 reads "Candidate selection: a single distinct candidate is used
   directly; multiple candidates are" and line 353 reads "disambiguated against the derived target; an
   unresolved tie denies with the ambiguity code rather". The retention requirement is on line **352**; line
   353 carries the ambiguity-denial requirement. Both are cited at their correct lines.

Three further defects of the same classes the delta reports were found in this pass and are applied; they are
listed under `## Findings added in this pass` at the end of this plan.

---

### Phase 0 — Baseline capture, F1 identifier binding, and early risk probes

- [x] [P0-T1] Read the repository policy files in the order defined by `.claude/skills/policy-compliance-order/SKILL.md`: `CLAUDE.md`, then `.claude/rules/general-code-change.md`, then `.claude/rules/general-unit-test.md`, then `.claude/rules/powershell.md`, then `.claude/rules/quality-tiers.md`, then `.claude/rules/tonality.md`, then `.claude/rules/plan-acceptance-gates.md`. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/baseline/phase0-instructions-read.md` containing the fields `Timestamp:`, `Policy Order:`, and an explicit line-per-file list of the seven paths read. Acceptance: the artifact exists and contains all three field labels and all seven paths.

- [x] [P0-T2] Capture the pre-change worktree state. Run `git rev-parse HEAD` and `git status --porcelain` from the worktree root and write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/baseline/baseline-worktree-state.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the resolved HEAD commit and the verbatim porcelain output (or the literal `clean` when the porcelain output is empty). Acceptance: the artifact exists, carries all four field labels, and its `Output Summary:` names a 40-character commit identifier. This task runs before any file in the repository is modified, so the porcelain output is the untouched baseline.

- [x] [P0-T3] Record the pre-change line-count ledger for the six files this feature touches: `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. In the same artifact record the pre-change control count for the token `return $candidates[0]`, measured as `Select-String -SimpleMatch -Pattern 'return $candidates[0]' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'`, which `[P4-T8]` compares against. In the same artifact record a second pre-change control count, for the token `uses the earliest candidate`, measured as `Select-String -SimpleMatch -Pattern 'uses the earliest candidate' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1'`, which `[P4-T15]` compares against; its pre-change value in the current tree is 2, at that file's lines 97 and 105. In the same artifact record a third pre-change control count, for the token `falls back to orchestrator-state.json`, measured as `Select-String -SimpleMatch -Pattern 'falls back to orchestrator-state.json' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1'`, which `[P4-T13]` compares against; its pre-change value in the current tree is 1, at that file's line 107. All three controls are measured here because each is a pre-change count that the citing task cannot reproduce once the text it counts has been changed. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/baseline/baseline-file-size-ledger.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` giving one measured integer per path plus the three control counts. Acceptance: the artifact records 6 measured integers and **three** control counts; and its `Output Summary:` reports the measured count for `.claude/hooks/enforce-prd-feature-before-planner.ps1` together with an explicit comparison against the research record's figure of 448, stated as `MATCHES` or `DIFFERS-BY-N`. A `DIFFERS` result does not fail this task; it is recorded as citation drift, and every later task that cites a line number in that file is re-derived before it runs.

- [x] [P0-T4] Capture the baseline PowerShell analyzer state. Invoke `mcp__drm-copilot__run_poshqc_analyze` for route compliance, then derive every asserted value by the analyzer-finding-count derivation fixed in this plan's preamble, because that MCP call returns no captured script output and therefore no finding count. Run the direct `Invoke-PoshQCAnalyze` command stated there and capture its console output, and run the per-file `Invoke-ScriptAnalyzer` count command once for each of the four paths in this task's fixed file set as the preamble table lists them. All three are read-only invocations; do not invoke the formatter in Phase 0, because the formatter rewrites tracked source and a baseline captured after it has repaired pre-existing drift is a blanket waiver. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/baseline/baseline-poshqc-analyze.<ISO-8601>.md` with `Timestamp:`, `Command:` naming all three commands verbatim, the direct analyzer command recorded in the redirected `6>&1` form the preamble fixes, `EXIT_CODE:`, and `Output Summary:` recording the whole-tree branch observable — either the literal `PSScriptAnalyzer passed: no findings under` quoted from the captured output with the finding count recorded as `0`, or the integer from the `PSScriptAnalyzer reported` throw message together with each printed finding's rule name and file path — and the four per-file integer counts, one per path. Acceptance: the artifact carries all four field labels, its `Output Summary:` records exactly one of the two whole-tree branch observables and not both, and it records four per-file integer counts, none of them a placeholder such as `UNVERIFIED`. A non-zero baseline finding count does not fail this task; it is the baseline. It does, however, have a consequence the executor must not discover later: `[P1-T7]`, `[P4-T21]`, and `[P6-T2]` each require a zero whole-tree count and zero per-file counts, so pre-existing findings recorded here are remediated before the first of those gates runs, or that gate reports blocked. Record that consequence in this artifact whenever the baseline count is non-zero.

- [x] [P0-T5] Capture the baseline Pester state with coverage enabled. Invoke `mcp__drm-copilot__run_poshqc_test` for route compliance, then run the direct `Invoke-PoshQCTest` command fixed in this plan's preamble, which is the run every asserted value here is derived from; that runsettings file sets `CodeCoverage.Enabled` to `$true` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 18) and emits coverage to `artifacts/pester/powershell-coverage.xml` (line 22) and the JUnit report to `artifacts/pester/pester-junit.xml` (line 15). Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/baseline/baseline-poshqc-test.<ISO-8601>.md` with `Timestamp:`, `Command:` naming both commands verbatim, `EXIT_CODE:`, and `Output Summary:` recording four numeric values derived by the preamble's test-count and coverage derivation: total tests, passed, and failed, all three read from the `testsuites` element of `artifacts/pester/pester-junit.xml` together with the `errors` attribute the passed count is computed from, and the overall line-coverage percentage aggregated over every `sourcefile` node of `artifacts/pester/powershell-coverage.xml` with its two summed integers recorded beside it. Additionally record the per-file baseline line-coverage percentage for `.claude/hooks/enforce-prd-feature-before-planner.ps1`, computed from the covered-line and total-line counts for that path in `artifacts/pester/powershell-coverage.xml`, keyed on the full directory path of the enclosing element rather than on the bare file name. Acceptance: the artifact records five numeric values plus the `errors` integer and the two aggregate sums, none of them a placeholder such as `UNVERIFIED`; every one of them is derived from `artifacts/pester/pester-junit.xml` or `artifacts/pester/powershell-coverage.xml` as the preamble fixes, and none is taken from an MCP result or a console summary, neither of which carries any of these values.

- [x] [P0-T6] Capture the baseline state of the six PowerShell suites this feature must not regress: `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`. The last two are required by `spec.md` line 637, which demands the epic merge gate's suites pass unmodified. Read their pass and fail counts from the `artifacts/pester/pester-junit.xml` produced by `[P0-T5]` rather than re-running the suite. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/baseline/baseline-unmodified-gates.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` giving a pass count and a fail count per suite. Acceptance: the artifact records six pass counts and six fail counts, one pair per named suite.

- [x] [P0-T7] Capture the baseline state of the three Python delivery tests by running `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`. No `--cov` argument is supplied because this feature adds and changes no Python production source, so no Python coverage gate applies to it. Immediately before the pytest invocation, remove every file under `.claude/state` using the unfiltered pipeline defined in `[P2-T1]`, and record the pre-removal file names and the post-removal verification count of `0` in this task's artifact. This is required, not optional: the `SessionStart` hook `.claude/hooks/persist-session-id.ps1` (registered at `.claude/settings.json` line 84) writes `<cwd>/.claude/state/current-session-id` at its line 161, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` with `rglob("*")` at lines 51-60 while excluding only `.claude/settings.local.json` and `.claude/agent-memory/**` at lines 130-134, so a session-id state file already present at baseline reports `Repo file missing from bundle:` and makes this task's `EXIT_CODE: 0` acceptance unsatisfiable before this feature has modified anything. No production PowerShell write precedes this task, so the removal cannot mask a budget effect. Because this removal also clears any batch-budget state file left by an earlier session, `[P0-T10]`'s enumeration may legitimately observe `none` where it would otherwise have named one; that is the expected consequence of this task running first and is not a contradiction between the two tasks. The artifact's `Command:` and `EXIT_CODE:` fields record the pytest invocation. The removal and verification commands and their own exit codes are recorded separately in `Output Summary:`, under `[P2-T1]`'s exit-code attribution, so a `1` from an enumeration against an absent `.claude/state` accompanied by a verified count of `0` is not read as a failure of this task. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/baseline/baseline-delivery-tests.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the passed and failed counts. Acceptance: the artifact carries all four field labels and `EXIT_CODE: 0`, establishing that the delivery tests are green before this feature modifies anything, and it records the pre-removal `.claude/state` file names (or the literal `none`) together with the post-removal verification count of `0`.

- [x] [P0-T8] Bind F1's concrete identifiers. Enumerate `.claude/lib/` for the module F1 merged onto `epic/worktree-scoped-state-resolution-integration`, read its `Export-ModuleMember -Function` list and its ambiguity reason-code definition, and write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/f1-identifier-binding.<ISO-8601>.md` recording, as five labelled fields, the module's repository-relative path, the exported function name for target derivation, the exported function name for path normalisation, the ambiguity reason-code literal exactly as F1 spells it, and the **state-B/state-C discriminator**: whether the derivation function returns a value that distinguishes "no input to derive from" (preamble ruling 8 state B) from "explicit no-target" (state C), recorded as `F1-DISTINGUISHES: YES` with the two returned values named, or `F1-DISTINGUISHES: NO`, in which case the hook draws the distinction from the envelope-field finding recorded by `[P0-T9]`. Acceptance: the artifact records five non-blank values, each named export appears in F1's `Export-ModuleMember -Function` list, and the discriminator field carries exactly one of the two permitted values. **Halt gate:** if `.claude/lib/` contains no such module, or if any one of the three capabilities is not exported, stop execution and report blocked. Do not substitute a local implementation, a guessed spelling, or a placeholder; `spec.md` line 70 prohibits re-implementing any of the three capabilities in this feature. **Second halt arm:** if the discriminator field records `F1-DISTINGUISHES: NO` and `[P0-T9]` records `ENVELOPE-ROOT-FIELD: NONE`, no production discriminator between preamble ruling 8's state B and state C exists, the ambiguity deny would be reachable only through the test-only injection parameter, and `spec.md` line 610 could not be satisfied in production. Halt and report blocked rather than proceeding; do not substitute the unbound-parameter path, which preamble ruling 8 prohibits. Because `[P0-T9]` runs after this task, this arm is evaluated as soon as `[P0-T9]` records its determination and before `[P0-T10]` starts, which `[P0-T9]`'s own text repeats so the evaluation is not lost once this task is checked off.

- [x] [P0-T9] Determine whether F1's target derivation consumes a root-level field of the PreToolUse envelope, by reading the parameter list and body of the target-derivation function named in the `[P0-T8]` artifact. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/pretooluse-envelope-capture.<ISO-8601>.md` recording the determination as exactly one of `ENVELOPE-ROOT-FIELD: <field names>` or `ENVELOPE-ROOT-FIELD: NONE`. When the determination is a field list, capture one real PreToolUse envelope for an `Agent` delegation into the same artifact. Acceptance: the artifact exists, carries one of the two determination forms and no other, and when the form is a field list the captured envelope is present in the same artifact. The research record item K3 notes that no hook in this repository reads an envelope working-directory field today and no captured payload exists in the tree, so this task closes an open item rather than confirming an assumption. This determination is an input to preamble ruling 8's state-B/state-C discriminator. On recording the determination, immediately evaluate `[P0-T8]`'s second halt arm against it: if this artifact records `ENVELOPE-ROOT-FIELD: NONE` and the `[P0-T8]` artifact records `F1-DISTINGUISHES: NO`, halt and report blocked before starting `[P0-T10]`.

- [x] [P0-T10] Record the change-budget route. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/change-budget-route.<ISO-8601>.md` restating the batch table from this plan's preamble, naming the route as the batch split, and stating explicitly that no override was requested or assumed, that neither `CLAUDE_POWERSHELL_BUDGET_PROD` nor `CLAUDE_POWERSHELL_BUDGET_TEST` was set, and that `powershell-change-budget-router` was not invoked. The same artifact states the reset mechanism by which each batch boundary is realised: the session's batch-budget state file, which `.claude/hooks/enforce-powershell-batch-budget.ps1` composes at line 366 as `<root>/.claude/state/powershell-batch-budget.<resolved-session-id>.json`, is removed before the first write of each new batch, per the reset instruction the hook itself states at line 296. Because the resolved session id is not knowable at planning time, the boundary tasks enumerate the state directory by filter rather than composing a file name. Record in this artifact the resolved state-directory path and the enumerated file names present at Phase 0, or the literal `none` when the directory does not exist or holds no matching file. `[P0-T7]` runs earlier in this phase and clears every file under `.claude/state`, so `none` is the expected observation here whenever `[P0-T7]` has run; record whichever case applied. This task is also batch A1's boundary: if the enumeration is non-empty, remove the enumerated files using the **filtered** batch-budget enumeration and removal pipeline stated in `[P2-T1]` below, re-run the verification enumeration, and record both the pre-reset contents and the post-reset count of `0` in this artifact, so `[P0-T12]`'s production write is not denied by production slots consumed before this plan's execution began. **Halt branch:** if a state file is enumerated but cannot be removed, halt and report blocked rather than proceeding into batch A1 with an unknown remaining budget. No file was present under `.claude/state` in the planning worktree, though the round-3 review observed `current-session-id` present in sibling checkouts, so the directory may well exist in the executor's worktree; the removal branch exists because the executor session may carry prior PowerShell writes. Acceptance: the artifact names all six batches A1, A2, B, C, D, and E, states a production-file count at or under 2 for each PowerShell batch and at or under 3 for batch C, names the state-directory path, and records either the enumerated state-file names together with a post-reset count of `0`, or the literal `none`.

- [x] [P0-T11] Attempt to reproduce decision-matrix row 3 (an absolute path to the target feature folder denies) against the unmodified hook, using the H1 hypothesis from the research record section A.7: a prompt carrying an absolute-form citation together with a second, distinct `docs/features/active/...` citation, with the checkpoint seam mocked to return a folder that is not among the candidates. Write the attempt and its outcome to `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/absolute-path-reproduction.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact exists, carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records the observed outcome as exactly one of `REPRODUCED` or `NOT-REPRODUCED`. This task is an investigation, not a fail-before row; neither outcome is a failure and no `[expect-fail]` evidence obligation attaches to it, so no `ExpectedExitCode:` field is required or meaningful here. **Fallback ruling, binding either way:** if the row cannot be reproduced, this plan proceeds on the positive requirement — the fixed gate must allow an absolute path to the target folder when the required document is present under the containing worktree — and no later acceptance condition in this plan depends on the reproduction succeeding or failing. Progress is not gated on this task's outcome. If the reproduction cannot be shown, also record `WhyFailingRunImpossible:` in the same artifact so the negative claim is auditable.

- [x] [P0-T12] (Batch A1) Create `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` containing only `Find-PrdFeatureFolderFromPrompt`, moved verbatim from `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 219-308, together with a comment-based-help block. The sibling contains no **file-scope** `param()` block, no `#Requires` directive, and no entrypoint, following `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`. Add the single line `. (Join-Path $PSScriptRoot 'enforce-prd-feature-before-planner-helpers.ps1')` to the parent at file scope, immediately after the `Import-Module` line at line 78 and before the first function definition. This minimal move exists to create the dot-source boundary that `[P0-T13]` probes; the remaining three functions move in Phase 1. Acceptance: the sibling file exists and contains exactly one `function ` declaration; `Select-String -SimpleMatch -Pattern '#Requires'` and `Select-String -SimpleMatch -Pattern 'exit 0'` over the sibling each return zero matches, with their controls taken from the parent hook, which carries `exit 0` at line 448 and whose sibling suite files carry `#Requires` at lines 1-2; `Select-String -SimpleMatch -Pattern 'param('` over the sibling returns exactly **one** match, which is the moved function's own indented parameter block and not a file-scope declaration — the match's full line text is recorded in the `[P0-T13]` artifact and must begin with whitespace. A zero-match assertion on `param(` is invalid here and must not be substituted: every advanced function in the moved code legitimately declares one. Acceptance additionally requires that the parent no longer declares `Find-PrdFeatureFolderFromPrompt`.

- [x] [P0-T13] Add the cross-file mock resolution smoke case and run it. In a `Context` named `cross-file mock resolution smoke` inside `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, add one `It` named `observes a test-scope mock across the dot-source boundary` that dot-sources both `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` explicitly, registers `Mock -CommandName Get-PrdFeatureCheckpointFolder` (a function that remains in the parent), calls `Find-PrdFeatureFolderFromPrompt` (now defined in the sibling) with a single-candidate prompt, and asserts both the returned folder and `Should -Invoke -CommandName Get-PrdFeatureCheckpointFolder -Times 0 -Exactly`. Acceptance: the named `It` runs and passes. **Halt gate:** if it fails, the assumption recorded as spec risk R4 is wrong; stop before moving any further function and report blocked, because the remainder of the extraction would break roughly 40 existing mocked cases at once. Record the outcome, and the `[P0-T12]` `param(` match line text, in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/cross-file-mock-smoke.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the `It` and its result.

### Phase 1 — Batch A2: complete the helpers extraction in the repository copies, with no behaviour change

- [x] [P1-T1] Move `Resolve-PrdFeatureWorkMode` (`.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 120-153) and `Get-PrdFeatureRequiredFile` (lines 155-187) into `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` with no behavioural edit. The accepting regex, its legacy `full` normalisation, and the `switch` arms move byte-for-byte. Acceptance: the `default` arm in the sibling still reads `default { return [string[]]@('spec.md') }`; `Select-String -SimpleMatch -Pattern 'user-story.md'` over the sibling returns exactly **three** matches, which are the two occurrences inside `Get-PrdFeatureRequiredFile`'s comment-based help (pre-move lines 162 and 169) and the one inside its `'full-feature'` switch arm (pre-move line 182), with zero matches on the `default` arm line — the sibling's own file-level help block written by `[P1-T3]` must not introduce a fourth occurrence; and the existing cases in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` covering `Resolve-PrdFeatureWorkMode` (lines 212-248) and `Get-PrdFeatureRequiredFile` (lines 250-274) pass unmodified.

- [x] [P1-T2] Move `Get-PrdFeatureMissingFile` (`.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 310-335) into the sibling with no behavioural edit at this stage. `Get-PrdFeatureFileExistence`, `Get-PrdFeatureIssueContent`, and `Get-PrdFeatureCheckpointFolder` stay in the parent so the existing suites' mock-resolution surface does not move. Acceptance: the sibling declares exactly four functions, the parent declares `Get-PrdFeatureFileExistence`, `Get-PrdFeatureIssueContent`, `Get-PrdFeatureCheckpointFolder`, and `Invoke-PrdFeatureBeforePlannerDecision`, and no function name is declared in both files.

- [x] [P1-T3] Write the sibling's comment-based-help block so it states the dot-sourced relationship and the headroom rationale, following the form at `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` lines 1-18. Acceptance: the sibling begins with a comment-based-help block carrying a `.SYNOPSIS` section and naming `enforce-prd-feature-before-planner.ps1` as its parent, and the block contains no occurrence of the token `user-story.md`, so the count asserted by `[P1-T1]` remains three.

- [x] [P1-T4] Verify the parent's preserved seams after the extraction: the `Import-Module` of `HookPayload.psm1`, the dot-source line, and the entrypoint guard `if ($MyInvocation.InvocationName -eq '.')` are all present, in that order, and the guard is unchanged from its pre-change text. Acceptance: `Select-String -SimpleMatch -Pattern '$MyInvocation.InvocationName' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'` returns exactly one match, which is the pre-change guard at line 440, and the file still ends with `exit 0`.

- [x] [P1-T5] Amend both existing suites to dot-source the sibling explicitly in addition to the parent, following the rationale at `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` lines 34-42, so a later change to the parent's dot-source line cannot silently redirect the assertions. Edit the `BeforeAll` block at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` lines 5-8 and the `BeforeAll` block at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` lines 20-23. Acceptance: each `BeforeAll` dot-sources two resolved paths, and both suites pass. Note for every later task that cites a line number in either suite: this edit shifts all subsequent line numbers in both files, so the cited ranges are re-derived before the citing task runs.

- [x] [P1-T6] Measure the delivered line counts of `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` and append them to `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/file-size-ledger.md`. This ledger filename deliberately carries no timestamp element: `[P4-T20]` appends a second block to the same file, and two differently timestamped filenames would be two different files. Each appended block carries its own `Timestamp:` line, so the single ledger file records both the Phase 1 and the Phase 4 measurements in order. Acceptance: both measured counts are at or under 500, and the artifact records both as integers under a `Timestamp:`-bearing Phase 1 block. The research record's projection is roughly 266 for the parent and roughly 211 for the sibling; the binding requirement is the 500-line cap measured on the delivered files, not the projection.

- [ ] [P1-T7] Run the extraction-only gate: invoke `mcp__drm-copilot__run_poshqc_analyze`, then `mcp__drm-copilot__run_poshqc_test`, both for route compliance, then run the direct `Invoke-PoshQCAnalyze` and `Invoke-PoshQCTest` commands fixed in this plan's preamble, in that order, which are the runs every asserted value here is derived from. Also run the per-file `Invoke-ScriptAnalyzer` count command once for each of the five paths in this task's fixed file set as the preamble table lists them. This gate runs before Phase 3 adds any deliberately-failing case, so a green result is achievable here. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/batch-a2-gate.<ISO-8601>.md` with `Timestamp:`, `Command:` naming every command run verbatim, the direct analyzer command recorded in the redirected `6>&1` form the preamble fixes, `EXIT_CODE:`, and `Output Summary:` recording the analyzer branch observable, the five per-file analyzer integer counts, and the `tests`, `failures`, and `errors` integers read from the `testsuites` element of `artifacts/pester/pester-junit.xml` together with the passed count computed from them. Acceptance: the `Output Summary:` quotes the literal `PSScriptAnalyzer passed: no findings under` from the captured output of the direct analyzer run, all five per-file analyzer counts are 0, and the JUnit `failures` and `errors` attributes are both 0 with `tests` recorded as a non-zero integer, proving the extraction changed no behaviour. The `Output Summary:` must not report the analyzer as clean on the strength of an exit code or an MCP result, neither of which carries a finding count.

### Phase 2 — Batches B and C: bundled mirrors and delivery registration for the extraction

- [x] [P2-T1] Open batch B by removing the session batch-budget state file before batch B's first production write. Enumerate and remove with `Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('PRE-RESET ' + $_.FullName + ' ' + (Get-Content -Raw $_.FullName)); Remove-Item -LiteralPath $_.FullName -Force }`, run from the worktree root through the PowerShell tool, or through the Bash tool as a single-quoted `pwsh -NoProfile -Command '<the same pipeline>'`. The file name is enumerated by filter rather than composed, because the resolved session id is not knowable at planning time: `.claude/hooks/enforce-powershell-batch-budget.ps1` resolves it at lines 139-173 from `CLAUDE_SESSION_ID`, then `.claude/state/current-session-id`, then a worktree-derived identifier. Then verify absence with `Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count`. Acceptance: the verification enumeration reports a count of `0`, and the pre-reset file names with their `prodFiles` and `testFiles` contents (or the literal `none` when zero files were enumerated) are recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/batch-boundary-b.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. **Exit-code attribution:** `Get-ChildItem` against a non-existent `-Path` leaves `$?` false even under `-ErrorAction SilentlyContinue`, so `pwsh -Command` maps it to exit 1; an `EXIT_CODE: 1` accompanied by a verified count of `0` is a pass, not a failure, and the artifact states which of the two cases applied. The pre-reset `prodFiles` list recorded here is expected to name `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, written by `[P0-T12]` and Phase 1, and the expected exit code is therefore 0. No file was present under `.claude/state` in the planning worktree, so the zero-file branch remains a tolerated alternative; record whichever case applied. `[P0-T7]`'s unfiltered removal does not invalidate the expectation above, because `[P0-T12]` and the Phase 1 edits are production PowerShell writes that run between the two tasks and cause the budget hook to recreate its state file. **Halt branch:** if the state file is enumerated but cannot be removed, halt and report blocked rather than proceeding into a batch whose writes the budget hook will deny.

  **Filtered versus unfiltered enumeration.** The pipeline above is filtered and is the batch-budget reset: it removes only `powershell-batch-budget.*.json`, which is what a batch boundary needs, and this task's acceptance governs that filtered reset only. A second, **unfiltered** pipeline is defined here for the delivery-test tasks, which must clear every file under `.claude/state`: `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('PRE-RESET ' + $_.FullName); Remove-Item -LiteralPath $_.FullName -Force }`, verified with `Get-ChildItem -Path .claude/state -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count`. Both pipelines run from the worktree root through the PowerShell tool, or through the Bash tool as a single-quoted `pwsh -NoProfile -Command '<the same pipeline>'`, and both carry the same exit-code attribution and the same halt branch. `[P0-T10]`, `[P2-T4]`, `[P4-T1]`, and `[P5-T1]` use the filtered pipeline. `[P0-T7]`, `[P2-T9]`, `[P5-T4]`, and `[P6-T4]` use the unfiltered one.

  Running from the worktree root matters: `.claude/state` must resolve under the same root the parity test computes as `REPO_ROOT` at `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` line 21, which is the worktree root containing `.claude/hooks`. The unfiltered enumeration is deliberately non-recursive: all three writers place flat files directly under `.claude/state` — `persist-session-id.ps1` line 161, `enforce-powershell-batch-budget.ps1` line 366, and `enforce-python-batch-budget.ps1` line 363 — and none of them creates a subdirectory there. If a delivery-test task nonetheless reports `Repo file missing from bundle:` for a path under `.claude/state` after a verified count of `0`, the assertion message names the offending path; re-run both enumerations with `-Recurse`, record that in the same artifact, and only then treat the failure as a plan defect.

  One consequence of the unfiltered pipeline is expected rather than anomalous: it also removes `current-session-id`, so a batch-budget hook invoked afterwards resolves the worktree-derived identifier at `.claude/hooks/enforce-powershell-batch-budget.ps1` lines 162-173 and writes its state under a different file name. That direction is permissive and never blocking — the hook denies only when it rehydrates a list that has already reached the cap, at lines 293-297 — and the filtered `powershell-batch-budget.*.json` enumeration matches either name, so every later boundary still clears it. A boundary task whose pre-reset list is empty, or names a file under the worktree-derived identifier, records the observed list and proceeds; neither observation is a halt condition.

- [x] [P2-T2] (Batch B) Update `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` so it is text-identical to the repository copy at `.claude/hooks/enforce-prd-feature-before-planner.ps1`. Acceptance: `Compare-Object -ReferenceObject (Get-Content -LiteralPath '.claude/hooks/enforce-prd-feature-before-planner.ps1') -DifferenceObject (Get-Content -LiteralPath 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1')` produces zero difference objects. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` is not asserted here: it asserts over every repo `.claude` file in one function and exposes no per-path outcome, and the bundled sibling it also requires is created by `[P2-T3]`. It is asserted at `[P2-T9]`, after `[P2-T3]` closes the window. An equal line count alone is not accepted as evidence of text identity: two files of equal length can differ on any line, and `spec.md` line 659 requires text-identical counterparts.

- [x] [P2-T3] (Batch B) Create `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` text-identical to `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`. Acceptance: the bundled file exists and `Compare-Object` over the two files' content produces zero difference objects.

- [x] [P2-T4] Open batch C by removing the session batch-budget state file before batch C's first production write, using the same **filtered** batch-budget enumeration, removal, verification, exit-code attribution, and halt branch as `[P2-T1]`. Acceptance: the verification enumeration reports a count of `0`, and the pre-reset contents are recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/batch-boundary-c.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The pre-reset `prodFiles` list recorded here is expected to name the two bundled mirrors written by `[P2-T2]` and `[P2-T3]`, which is the direct evidence that the boundary is doing real work rather than being decorative; record the observed list whatever it contains.

- [x] [P2-T5] (Batch C) Register the new sibling in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` by adding the entry `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` to the `paths` array, beside the existing `-helpers` entries at lines 36, 40, 42, and 46 and the existing parent entry at line 47. Acceptance: `Select-String -SimpleMatch -Pattern 'enforce-prd-feature-before-planner-helpers.ps1'` over `core.json` returns exactly one match, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q` exits 0 with both `test_bundled_claude_files_are_listed_in_some_pack_manifest` and `test_documented_exceptions_remain_absent_from_every_manifest` passing.

- [x] [P2-T6] (Batch C) Add `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` to the `CodeCoverage.Path` array in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, beside the existing parent entry at line 237, with a short rationale comment in the established style, so the new production file stays in the coverage denominator per the Coverage Exclusion Policy. Acceptance: `Select-String -SimpleMatch -Pattern 'enforce-prd-feature-before-planner-helpers.ps1'` over that file returns exactly one match.

- [x] [P2-T7] (Batch C) Add the identical entry to the `CodeCoverage.Path` array in `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. Acceptance: `Select-String -SimpleMatch -Pattern 'enforce-prd-feature-before-planner-helpers.ps1'` over that file returns exactly one match, and `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` exits 0 with `test_poshqc_bundled_module_files_match_repo_root_sources` passing.

- [x] [P2-T8] Confirm the new sibling actually enters the coverage denominator before any later task depends on it. Invoke `mcp__drm-copilot__run_poshqc_test`, then search the emitted `artifacts/pester/powershell-coverage.xml` with `Select-String -SimpleMatch -Pattern 'enforce-prd-feature-before-planner-helpers.ps1'` and, as a control, with `Select-String -SimpleMatch -Pattern 'enforce-prd-feature-before-planner.ps1'`, which the pre-change settings already list at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 237 and which must return a non-zero count. Record both match counts in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/coverage-denominator-check.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact records both match counts as integers and records the determination as exactly one of `MCP-READS-REPO-SETTINGS: YES` (both counts non-zero) or `MCP-READS-REPO-SETTINGS: NO` (the sibling count is zero while the control count is non-zero), and no other form. A zero **control** count is a third case and fails this task, because a control that cannot match leaves neither determination supported; re-run the control search and record the result before proceeding. This task is a determination and not a gate: neither `YES` nor `NO` blocks progress, because the preamble makes the direct measurement route unconditional for every downstream measurement task. The fallback paragraph below states what a `NO` determination records; it changes no downstream routing.

  **Fallback, named rather than left to the executor to invent.** If the sibling's count is zero while the control is non-zero, the MCP runner is not reading the repository-side runsettings edited by `[P2-T6]`. The reason that outcome is expected rather than hypothetical, and the ruling that makes the direct route unconditional for every measurement task in this plan, are stated in the preamble section `### MCP PoshQC result surface, and the unconditional direct measurement route`; that section carries the `spec.md` lines 732-733 work-allocation fact this paragraph previously carried. In that case record the finding in this artifact. The direct command, which the preamble requires unconditionally of `[P2-T10]`, `[P6-T3]`, and `[P6-T5]` and which this task also uses when it records the finding, is run from the worktree root **through the PowerShell tool**, the single execution route for it — the executor selects nothing here, in the same way `[P2-T1]` names the route for its own command:

  `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

  This reads the repository-side settings by construction: `PoshQC.psm1` line 3 sets `$script:PesterSettings` from its own module root, `Invoke-PoshQCTest` is exported at `PoshQC.psm1` line 143, and its `-SettingsPath` parameter (`PoshQC.Testing.psm1` line 156) is bound explicitly here so no default can redirect it. `-ScanFolders` is deliberately omitted: `PoshQC.Testing.psm1` lines 305-318 fall back to the persisted scan configuration and then to the settings' own `Run.Path`, which reproduces the MCP runner's folder scope. This command is recorded verbatim in the `Command:` field of `[P2-T10]`, `[P6-T3]`, and `[P6-T5]` unconditionally, per the preamble section named above, rather than only when a fallback is in force. Do not record a placeholder coverage value and do not drop the per-file figure: `spec.md` line 667 requires line coverage at or above 85 percent for both production files, read per file from the Pester coverage report.

- [x] [P2-T9] Run the three Python delivery tests together with `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/batch-bc-delivery-tests.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording passed and failed counts. Acceptance: `EXIT_CODE: 0`, a failed count of 0, and an `Output Summary:` naming `test_bundled_claude_payload_contains_all_repo_runtime_contracts` as passing, closing the intermediate parity window opened in Phase 0; this is the task that asserts that test, which `[P2-T2]` defers here. The artifact also records the pre-removal `.claude/state` file names (or the literal `none`) together with the post-removal verification count of `0`. Immediately before the pytest invocation, remove any runtime state files under `.claude/state` using the **unfiltered** `.claude/state` pipeline defined in `[P2-T1]`, recording the pre-removal file names and the post-removal verification count of `0` in this task's artifact. This is required, not optional: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` with `rglob("*")` at lines 51-60 and excludes only `.claude/settings.local.json` and `.claude/agent-memory/**` at lines 130-134, so it does not honour the `.gitignore` entry for `.claude/state/` at line 68 and reports `Repo file missing from bundle:` for any file it finds there. The filtered batch-budget pipeline is not sufficient here. `.claude/hooks/persist-session-id.ps1` is registered as a `SessionStart` hook at `.claude/settings.json` line 84 and writes `<cwd>/.claude/state/current-session-id` at its line 161, and `enforce-python-batch-budget.ps1` can have left `python-batch-budget.<id>.json` from an earlier session in the same worktree. Neither file name matches `powershell-batch-budget.*.json`, and either one on its own produces `Repo file missing from bundle:`. This removal is safe at this point because no production PowerShell write follows it inside the same batch. The artifact's `Command:` and `EXIT_CODE:` fields record the pytest invocation. The removal and verification commands and their own exit codes are recorded separately in `Output Summary:`, under `[P2-T1]`'s exit-code attribution, so a `1` from an enumeration against an absent `.claude/state` accompanied by a verified count of `0` is not read as a failure of this task.

- [ ] [P2-T10] Re-run the coverage-bearing test command so the new sibling enters the coverage denominator, using the direct `Invoke-PoshQCTest` command fixed in this plan's preamble, which is the single route for this task and is named unconditionally rather than as a fallback. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/batch-bc-gate.<ISO-8601>.md` with `Timestamp:`, `Command:` naming that command verbatim, `EXIT_CODE:`, and `Output Summary:` recording the `tests`, `failures`, and `errors` integers read from the `testsuites` element of `artifacts/pester/pester-junit.xml` together with the passed count computed from them, plus the per-file line-coverage percentage for both `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, each computed from `artifacts/pester/powershell-coverage.xml` keyed on the full directory path of the enclosing element rather than on the bare file name. Acceptance: the JUnit `failures` and `errors` attributes are both 0 with `tests` recorded as a non-zero integer, and two numeric per-file percentages are recorded, neither of them a placeholder. This is the post-extraction, pre-behaviour-change coverage reading that `[P6-T5]` compares against.

### Phase 3 — Fail-before rows in the new companion suite (expect-fail)

Every task in this phase except `[P3-T1]`, `[P3-T3]`, `[P3-T4]`, and `[P3-T9]` adds a case that is expected to fail against the current hook. No phase-level green gate runs in this phase; the next green gate is `[P4-T21]`, after the behaviour change lands.

- [x] [P3-T1] Write the header of `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`: a comment-based block recording the placement decision (both existing suites are close enough to the 500-line cap that the matrix plus its regression guards does not fit in either, measured at 431 and 419 lines) and the determinism statement (no temporary file or directory is created, the process working directory is never changed, and no absolute path is derived from the environment, the current directory, the script file location, or a source-control query). Declare two synthetic roots as bare string literals modelling the coordinating session and the item's worktree. Acceptance: the file exists at the named path, its header contains both the placement decision and the determinism statement, and the two synthetic root literals are plain assignments with no call to `Resolve-Path`, `Get-Location`, or `git`.

- [x] [P3-T2] [expect-fail] Add the state-1 row as an `It` named `allows when the target root holds the required document`: a payload whose prompt names the target feature folder while the modelled session root is a different worktree, the resolved target supplied through the injection parameter, and the existence mock answering true only for the path composed against the target root. Assert the decision is `allow`. Acceptance: the named `It` exists and fails against the current hook, and its failure message is recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/fail-before.<ISO-8601>.md`. This row is the defect's direct proof; it fails today because the probe composes against the session root.

- [x] [P3-T3] Add the item-worktree regression-guard row required by `spec.md` line 627 as an `It` named `allows when the modelled cwd is the item worktree`: the same payload and the same intended target folder as the `[P3-T2]` row, with the modelled session root set equal to the item worktree rather than to a different worktree, the existence mock answering true only for the bare repo-relative path the hook composes in state B, the modelled session root and the target root coinciding so that no prefix is applied, asserting the decision is `allow`. This row deliberately omits the injection parameter: it models preamble ruling 8's state B, in which the composition emits the bare repo-relative spelling and the current hook already allows. It is therefore excluded from `[P3-T9]`'s parameter-binding-error accounting as well as from its fail count. This is the **relative** path form at item-worktree cwd, which `[P3-T4]` does not cover (that row is the absolute form) and which `[P3-T2]` does not cover (that row models a different session root). Acceptance: the named `It` exists and passes against the current hook, establishing it as a retained regression guard rather than a fail-before row, and its passing outcome is recorded in the `[P3-T9]` artifact alongside the failing rows. This row is excluded from the `[P3-T9]` count of rows required to fail, and it carries no `[expect-fail]` tag, because a passing outcome is its required outcome.

- [x] [P3-T4] Add the absolute-path row as an `It` named `allows an absolute path to the target feature folder`, bound with `-ForEach` over a discovery-time array of exactly **two** rows, one per modelled cwd value declared by `[P3-T1]`, with the required document present under the containing worktree on both rows. The two-row `-ForEach` binding is fixed here and is not an implementation choice: the preamble's per-test rule fixes this identifier's expected `testcase`-node count at two, Pester emits one node per `-ForEach` row, and a single `It` body carrying two act-and-assert pairs would emit one node and fail `[P4-T21]` in its differs-in-either-direction arm, where relaxing the match is prohibited. The `It` name carries no `<Property>` template, so both nodes carry the same `name` attribute, which the containing-match rule accommodates. Acceptance: the named `It` exists, is bound with `-ForEach` over two rows, and its observed outcome against the current hook — pass or fail — is recorded in the `[P3-T9]` artifact for each of the two rows. This row is stated positively as the fixed gate's required behaviour, so neither outcome is a failure of this task, it carries no `[expect-fail]` tag, and it is excluded from the `[P3-T9]` count of rows required to fail. It does not depend on `[P0-T11]`'s reproduction outcome.

- [x] [P3-T5] [expect-fail] Add the three ambiguity rows as `It` blocks named `denies rather than validating against a sibling session checkpoint`, `denies rather than selecting the earliest candidate on an unresolved tie`, and `denies with the ambiguity reason when the folder is absent from the target root`. Each asserts a deny whose reason begins with the `PRD_FEATURE_BLOCKED:` prefix and embeds the ambiguity reason code read from the `[P0-T8]` binding artifact. Acceptance: the three named `It` blocks exist and fail against the current hook, and each failure message is recorded in the `[P3-T9]` artifact. No acceptance condition in this task quotes an F1 identifier literal; the expected code is read from the binding artifact at implementation time.

- [x] [P3-T6] [expect-fail] Add the ambiguity-branch zero-invocation guard as an `It` named `runs no existence probe on the ambiguity branch`, asserting `Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 0 -Exactly` on the unresolvable-target path, following the idiom at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` lines 360-371 (the `It` named `does not invoke the file-existence probe in the indeterminate branch`). Acceptance: the named `It` exists and fails against the current hook, which has no ambiguity branch, and its failure message is recorded in the `[P3-T9]` artifact.

- [x] [P3-T7] [expect-fail] Add the two ambiguity-reason rows as `It` blocks named `denies with the ambiguity code when the target cannot be resolved` and `emits an ambiguity code distinct from the missing-document and marker reasons`. The first asserts a deny whose `permissionDecisionReason` carries the `PRD_FEATURE_BLOCKED:` prefix and embeds the ambiguity reason code read from the `[P0-T8]` binding artifact. The second asserts that code differs from the missing-document reason substring and from the indeterminate-work-mode reason substring, and that it occurs as a single literal. Acceptance: both named `It` blocks exist and fail against the current hook, which has no ambiguity branch, and each failure message is recorded in the `[P3-T9]` artifact. No F1 identifier literal is quoted in this task; the expected code is read from the binding artifact at implementation time. These two rows carry `spec.md` line 610's requirement and its distinctness clause, which `[P4-T5]`'s acceptance names; without this task they are required to pass but authored by nothing.

- [x] [P3-T8] [expect-fail] Add the missing-document row as an `It` named `denies with the missing-document reason when the document is absent under the target root`: the target root resolved through the injection parameter, the existence mock answering false for the required-document path composed against that root, asserting a deny whose reason leads with the resolved feature folder and then names the missing document list, the work mode, and the existing remedy, and retains the `PRD_FEATURE_BLOCKED:` prefix. Acceptance: the named `It` exists and fails against the current hook, and its failure message is recorded in the `[P3-T9]` artifact, and the asserted reason text matches the pre-change reason at `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 426-428 apart from the resolved-folder value.

- [x] [P3-T9] Write the fail-before evidence artifact `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/fail-before.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode:`, and `Output Summary:` naming each of the **ten** `It` blocks added in `[P3-T2]` through `[P3-T8]` and its observed outcome. Acceptance: the artifact names ten `It` blocks and records a failure for **eight** of them — every row except `allows when the modelled cwd is the item worktree` from `[P3-T3]` and `allows an absolute path to the target feature folder` from `[P3-T4]`, which are recorded with their observed outcomes but are excluded from the count of rows required to fail, per those tasks' own acceptance text. Eight recorded failures establish fail-before for the behaviour change.

  Additionally, for each row that failed: the injection parameter that the Phase 3 rows that bind it use is added by `[P4-T3]`, so a row binding it against the Phase 3 hook fails with a parameter-binding error rather than with a composition-path assertion failure. Record which of the two failure modes was observed. `[P3-T3]`'s row is excluded from this parameter-binding-error accounting as well as from the fail count, because it deliberately omits the injection parameter, per its own acceptance text. For the rows whose failure is a parameter-binding error, additionally record the same row's observed decision and reason when run with the parameter omitted, so the artifact carries at least one behavioural observation of the pre-change composition path per row rather than only a binding diagnostic.

### Phase 4 — Batch D: target-resolution behaviour change and regression amendments

- [x] [P4-T1] Open batch D by removing the session batch-budget state file before batch D's first production write, using the same **filtered** batch-budget enumeration, removal, verification, exit-code attribution, and halt branch as `[P2-T1]`. Acceptance: the verification enumeration reports a count of `0`, and the pre-reset contents are recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/batch-boundary-d.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P4-T2] Import F1's module into `.claude/hooks/enforce-prd-feature-before-planner.ps1` using the established form `Import-Module (Join-Path $PSScriptRoot '../lib/...') -Force`, on a new line beside the existing `HookPayload.psm1` import at line 78, with the module path taken from the `[P0-T8]` binding artifact. Use the unguarded form, not the guarded lazy-import variant: an unresolvable resolution module is itself the target-not-resolvable state and must fail the gate closed rather than degrade to a permissive path. Acceptance: `Select-String -SimpleMatch -Pattern 'Import-Module (Join-Path $PSScriptRoot' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'` returns exactly two matches, neither inside a `try` block; and the same `-SimpleMatch` search over both `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` for each of the tokens `git worktree`, `Get-Location`, `$PWD`, and `Resolve-Path` returns zero matches, proving no worktree-discovery logic was re-implemented locally. Record, in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/no-reimplementation.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, the control match count for each of those four tokens from the named control file in the preamble's control table, so a zero result on the two hook files is distinguished from a search that cannot match.

- [x] [P4-T3] Add an injection parameter for the resolved target to `Invoke-PrdFeatureBeforePlannerDecision`, following the `-CheckpointRaw` precedent and its `ContainsKey`-based binding discipline at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 346-360 (the parameter declarations and their binding rationale) and line 412 (`$PSBoundParameters.ContainsKey($injected)`), so an explicitly supplied empty value suppresses the seam rather than falling through to disk. Acceptance: the hook's `param()` block declares the new parameter, and the binding decision is made with `$PSBoundParameters.ContainsKey` rather than with a truthiness test; `Select-String -SimpleMatch -Pattern '$PSBoundParameters.ContainsKey' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'` returns at least one match.

- [x] [P4-T4] Derive the call's target from the tool-call payload by passing the envelope root (`$envelope.Envelope`, surfaced by `Resolve-ClaudeHookToolInput` on its `Envelope` member at `.claude/lib/hook-payload/HookPayload.psm1` line 481 and currently unread by this hook) together with the nested `tool_input` object to F1's target-derivation function named in the `[P0-T8]` binding artifact. Make no change to `.claude/lib/hook-payload/HookPayload.psm1`. Acceptance: `Select-String -SimpleMatch -Pattern '$envelope.Envelope' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'` returns at least one match, confirming the hook now reads the envelope root; and `.claude/lib/hook-payload/HookPayload.psm1` is absent from the changed-file set enumerated at this task's own point in the sequence by the same two-command union `[P5-T6]` defines — porcelain status plus the diff anchored on the `[P0-T2]` baseline commit, run here under the same anchor precondition `[P5-T6]` states — with that union verified non-empty by its naming `.claude/hooks/enforce-prd-feature-before-planner.ps1`, which `[P4-T2]` modifies before this task runs. Enumerating the union here rather than deferring the clause to `[P5-T6]` keeps this task's outcome decidable when it runs; `[P5-T6]` re-verifies the same constraint over the Phase 5 change set.

- [x] [P4-T5] Add the ambiguity deny branch. Per preamble ruling 8 it is taken only in state C: target derivation returns an explicit no-target result **and** the session root is not the derived target. It must not be taken in state B, where the injection parameter is unbound and the payload carries no derivation input. On the state-C path, return a deny whose `permissionDecisionReason` is the `PRD_FEATURE_BLOCKED:` prefix followed by F1's ambiguity reason code and an explanatory clause naming the ambiguity, and `return` before any document probe runs. Acceptance: the `It` named `denies with the ambiguity code when the target cannot be resolved` passes; the `It` named `runs no existence probe on the ambiguity branch` passes; and the `It` named `emits an ambiguity code distinct from the missing-document and marker reasons` passes, asserting the code is a single greppable literal and that the reason differs from both the missing-document reason and the indeterminate-work-mode reason. The distinctness is asserted against the value read from the `[P0-T8]` binding artifact, not against a literal quoted in this plan.

- [x] [P4-T6] Remove the unconditional post-prompt fallback to the session-root checkpoint at `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 368-370, comprising the guard `if (-not $folder) {` at line 368, the assignment `$folder = Get-PrdFeatureCheckpointFolder` at line 369, and its closing brace at line 370. Line 367 is the prompt-resolution assignment `$folder = Find-PrdFeatureFolderFromPrompt -Prompt $prompt` and is retained; removing it would leave the decision path with no folder source at all. The checkpoint is consulted only when the call genuinely has no target **and** the session root is the derived target. Acceptance: the `It` named `denies rather than validating against a sibling session checkpoint` passes. The single-worktree topology is not converted from allow to deny; that property is asserted by the `It` named `allows the session-root fallback when the derived target is the session root`, which `[P4-T13]` creates by renaming the existing case, so it is verified at `[P4-T13]` and not here. Until `[P4-T13]` runs, the pre-rename case `falls back to orchestrator-state.json when prompt has no folder reference` is expected to fail; record that observation in this task rather than treating it as a regression.

- [x] [P4-T7] In `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, replace the prefix-discarding half of `Find-PrdFeatureFolderFromPrompt` with F1's path normalisation, which returns a repo-relative form by locating the containing worktree, and retain the depth-collapsing half byte-unmodified. The block that was at hook lines 272-277 — the split-and-filter at line 272, the fewer-than-four-segment rejection at lines 273-275, and `$truncated = ($segments[0..3] -join '/')` at line 277 — is carried across unchanged. The function's return spelling is bound by preamble ruling 8: in state B it returns the bare repo-relative form it returns today. Acceptance: the `Context` block `folder resolution by four-segment truncation` at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` lines 25-80 passes byte-unmodified, including its four pinned prompt forms (folder alone; folder plus a `research/` artifact; folder plus an `evidence/` artifact; nested artifact alone) and its degenerate-token rejection; the `Context` block `preserved gate behavior` at the same file's lines 203-282 passes byte-unmodified, including its five cases covering full-feature `spec.md` absence, full-bug `spec.md` absence, full-feature `user-story.md` absence by name, minor-audit with neither prerequisite present, and the legacy `full` marker normalisation, both `Context` blocks being required by `spec.md` line 639; and `Select-String -SimpleMatch -Pattern '$segments[0..3]'` over the helpers file returns exactly one match.

- [x] [P4-T8] Change the multi-candidate disambiguator from the session-root checkpoint to the F1-derived target, and change the positional fallback that currently returns the earliest-occurring candidate into an ambiguity denial. Acceptance: the `It` named `denies rather than selecting the earliest candidate on an unresolved tie` passes; and `Select-String -SimpleMatch -Pattern 'return $candidates[0]'` over `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` returns **exactly one** match, down from the two the pre-change parent carried at lines 290 and 307 and which `[P0-T3]` recorded as the control count. The surviving match is the single-distinct-candidate return at pre-change line 290, which `spec.md` line 352 requires be retained ("a single distinct candidate is used directly"); the removed match is the positional tie-break at pre-change line 307, whose removal `spec.md` line 353 requires. A zero-match assertion is invalid here and must not be substituted: it would demand deleting behaviour the spec preserves.

- [x] [P4-T9] Compose the `issue.md` probe path against the resolved target root in `Get-PrdFeatureIssueContent`, whose current composition is `"$FeatureFolder/issue.md"` at `.claude/hooks/enforce-prd-feature-before-planner.ps1` line 107. The function name, parameter name, and the fact that it stays in the parent are unchanged, so existing suites keep mocking it. The composition is governed by preamble ruling 8: the target root is prefixed only in state A with a differing root. Acceptance: the `It` named `denies with the ambiguity reason when the folder is absent from the target root` passes, proving the marker-is-broken reason is no longer emitted for a folder probed at the wrong root; and the existing `Context` block `indeterminate work-mode marker` at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` lines 284-372 still passes, proving the marker branch is still reachable when the folder does exist under the resolved target root.

- [x] [P4-T10] Compose each required-document probe path against the resolved target root in `Get-PrdFeatureMissingFile`, whose current composition is `$candidate = "$FeatureFolder/$name"` at pre-extraction line 329. Leave the missing-set computation, the required-document mapping, and the missing-document reason text unchanged apart from the resolved-folder value. The composition is governed by preamble ruling 8. Acceptance: the `It` named `allows when the target root holds the required document` passes, and the `It` named `denies with the missing-document reason when the document is absent under the target root` passes, asserting the reason leads with the resolved feature folder, then names the missing document list, the work mode, and the existing remedy, and retains the `PRD_FEATURE_BLOCKED:` prefix.

- [x] [P4-T11] Verify the unbound-target composition ruling holds across the existing decision-level cases. Run both existing suites and confirm that every case that binds no resolved target still passes: specifically the three cases whose existence mock keys with `-eq` on a bare repo-relative path at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` lines 124, 156, and 187, and every case in the `Context` blocks `decision equivalence and the reproduction differential` (lines 114-201), `preserved gate behavior` (lines 203-282), `indeterminate work-mode marker` (lines 284-372), and `block message` (lines 374-418). Acceptance: all cases in those four `Context` blocks pass with their files unmodified apart from the `BeforeAll` edit made by `[P1-T5]`, and the count of passing cases in each block is recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/unbound-target-composition.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. A failure here means the composition prefixes unconditionally; correct the composition rather than the tests.

- [x] [P4-T12] Verify that `Find-PrdFeatureFolderFromPrompt`'s own return spelling is unchanged for every existing unit case, which preamble ruling 8 binds and which both `[P4-T7]` and `[P4-T8]` modify. Run the `Context` named `Find-PrdFeatureFolderFromPrompt` at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` lines 197-210 and confirm its four cases pass with the file unmodified apart from the `BeforeAll` edit made by `[P1-T5]`: `returns $null for empty prompt`, `returns $null when no docs/features/active path is present`, `returns the folder when one is present` (line 205 asserts `Should -Be 'docs/features/active/abc-1'`, an exact equality that fails the moment normalisation prefixes a root), and `strips .md suffix to a folder parent` (line 208, the same exact equality). Also confirm the three path-capture cases in the same file at lines 118-134, 136-154, and 156-164 pass, including the `Should -Not -Match 'checkpoint-folder'` discriminator at line 133. Acceptance: all seven named cases pass and their individual outcomes are recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/find-folder-return-spelling.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. This region is the second set of exact-equality pins on the changed function and is covered by no other task in this plan; `[P4-T7]`'s acceptance covers only the equivalent region in the FolderResolution suite.

- [x] [P4-T13] Amend, rather than delete, the existing checkpoint-fallback case in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` — the `It` currently named `falls back to orchestrator-state.json when prompt has no folder reference` (at lines 107-116 before the `[P1-T5]` `BeforeAll` edit shifts them), which currently asserts the silent session-root fallback as intended behaviour. Re-specify it as the `It` named `allows the session-root fallback when the derived target is the session root`. Replace that case's blanket existence mock — the only `Mock -CommandName Get-PrdFeatureFileExistence` inside it, at pre-shift line 109, written `-MockWith { $true }` — with one keyed on the full composed path, so the amended case cannot pass on a probe that always answers true. Acceptance: `Select-String -SimpleMatch -Pattern 'falls back to orchestrator-state.json' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1'` returns zero matches, with its control count taken from the pre-change file recorded by `[P0-T3]` (1 occurrence, at pre-change line 107), proving the pre-rename name is gone rather than that the search cannot match; the re-specified `It` passes; and its existence mock compares against a fully composed path rather than returning a constant.

- [x] [P4-T14] Re-specify, rather than delete, the deterministic-selection case in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` — the `It` currently named `prefers the checkpoint folder when it occurs later in the prompt` (at lines 89-95 before the `[P1-T5]` `BeforeAll` edit shifts them), in which the preferred folder deliberately occurs later in the prompt than the other candidate. Rename it to `prefers the derived target when it occurs later in the prompt` and drive it from the F1-derived target rather than the session-root checkpoint. Acceptance: the renamed `It` passes and the preferred folder still occurs later in the prompt than the competing candidate, so the selection rule remains distinguishable from plain earliest-occurrence.

- [x] [P4-T15] Re-specify the two positional-fallback cases that sit beside the case `[P4-T14]` renames, in the same `Context` named `deterministic selection among two feature folders`: the `It` currently named `uses the earliest candidate when the checkpoint folder is absent` (at lines 97-103 before the `[P1-T5]` edit shifts them) and the `It` currently named `uses the earliest candidate when the checkpoint folder is not a candidate` (at lines 105-111). Both currently assert that an unresolved multi-candidate tie returns the earliest-occurring candidate, which is exactly the behaviour `[P4-T8]` removes; left as they are, `[P4-T21]`'s zero-Pester-failure acceptance is unsatisfiable. Rename them to `denies when the checkpoint is absent and the tie cannot be resolved against the derived target` and `denies when the checkpoint names a folder that is not a candidate` respectively, state the denial each now asserts, and drive both from the F1-derived target. Acceptance: neither original `It` name remains in the file, `Select-String -SimpleMatch -Pattern 'uses the earliest candidate'` over that file returns zero matches with its control count taken from the pre-change file recorded by `[P0-T3]` (2 occurrences, at pre-change lines 97 and 105), which `[P0-T3]` measures because by the time this task runs the pre-change text is gone and the control cannot be reproduced here; and both re-specified cases pass under their new names.

- [x] [P4-T16] Add the positive-direction invocation-count guards as `It` blocks named `probes once on a full-bug allow row` and `probes twice on a full-feature allow row`, asserting `Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 1 -Exactly` and `-Times 2 -Exactly` respectively, matching the required-document set for each row's work mode. Acceptance: both named `It` blocks pass, so an implementation that returns `allow` without probing fails the suite. This is the missing half of the zero-invocation assertion and no equivalent assertion exists in the tree today.

- [x] [P4-T17] Add the work-mode rows as an `It` named `resolves the required document set for each work mode`, bound with `-ForEach` over a discovery-time array covering `full-feature` (requires `spec.md` and `user-story.md`), `full-bug` (requires `spec.md`), `minor-audit` (requires neither), and legacy `full` (normalises to `full-feature`), each exercised against the resolved target root. Acceptance: the named `It` passes for all four rows, and the existing work-mode cases at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` lines 212-274 pass unmodified, including the two pins at lines 267-269 and 271-273 on the `default` arm returning `spec.md` alone.

- [x] [P4-T18] Place every row of the `Context` named `target resolution matrix` on the same resolved-target root, differing only in whether the existence mock answers true for that exact composed path, extending the keyed-mock idiom at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` lines 122-125. Acceptance: `Select-String -SimpleMatch -Pattern '-MockWith { $true }' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1'` returns zero matches, proving no row uses a blanket always-true existence mock; the control count for the same `-SimpleMatch` search against `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` is recorded in the same artifact and must be non-zero (4 occurrences at lines 293, 306, 319, and 332 in the current tree); and every existence mock in the new file compares against a fully composed path. Without `-SimpleMatch` this search cannot fail, because `$` is a regex end-of-line anchor and the pattern would match nothing on any file content including one carrying a blanket mock; this is the guard `spec.md` line 622 exists to establish, so a run without `-SimpleMatch` is void. Record the result in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/blanket-mock-guard.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P4-T19] Verify the new suite's no-temporary-file and no-working-directory properties by running `Select-String -SimpleMatch` over `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` for each of the tokens `New-Item`, `Set-Location`, `Push-Location`, `Get-Location`, `$PWD`, `GetTempPath`, and `$env:TEMP`. For each of the seven tokens, record in the same artifact the control match count from a `-SimpleMatch` search of the named control file in the preamble's control table, so a zero result on the new suite is distinguished from a search that cannot match. Also record the outcome of the `check-powershell-test-purity.ps1` PreToolUse hook; note that its forbidden-pattern list at `.claude/hooks/check-powershell-test-purity.ps1` lines 99-117 covers only `GetTempPath` and `$env:TEMP` of these seven, so the hook's pass is a partial and not a complete substitute for the seven searches. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/test-purity.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: all seven searches return zero matches on the new suite, all seven control counts are non-zero, and the artifact records all fourteen results individually.

- [x] [P4-T20] Measure the delivered line counts of `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` after the behaviour change. Measure four further delivered files in the same block, so that every production and test file in the change set is covered as `spec.md` line 653 requires: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. The last three of the four are measured as a completeness obligation rather than as a live risk: in the current tree both `pester.runsettings.psd1` copies are 293 lines and the bundled hook is 448, so the entries each task adds cannot approach the cap. Append the measurements to `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/file-size-ledger.md`, appending a second timestamped block below the Phase 1 block rather than creating a second file. Acceptance: all nine measured counts are at or under 500 and are recorded as integers under a `Timestamp:`-bearing Phase 4 block, and the Phase 1 block written by `[P1-T6]` is still present in the same file.

- [ ] [P4-T21] Run the batch-D gate: invoke `mcp__drm-copilot__run_poshqc_analyze`, then `mcp__drm-copilot__run_poshqc_test`, both for route compliance, then run the direct `Invoke-PoshQCAnalyze` and `Invoke-PoshQCTest` commands fixed in this plan's preamble, in that order, which are the runs every asserted value here is derived from. Also run the per-file `Invoke-ScriptAnalyzer` count command once for each of the seven paths in this task's fixed file set as the preamble table lists them. This is the first phase gate scheduled after the deliberately-failing cases added in Phase 3 are made to pass, so a green result is achievable here. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/batch-d-gate.<ISO-8601>.md` with `Timestamp:`, `Command:` naming every command run verbatim, the direct analyzer command recorded in the redirected `6>&1` form the preamble fixes, `EXIT_CODE:`, and `Output Summary:` recording the analyzer branch observable, the seven per-file analyzer integer counts, the `tests`, `failures`, and `errors` integers read from the `testsuites` element of `artifacts/pester/pester-junit.xml` together with the passed count computed from them, and one line per fixed `It` identifier giving the identifier, its observed matched-node count, and its derived result. Acceptance: the `Output Summary:` quotes the literal `PSScriptAnalyzer passed: no findings under` from the captured output of the direct analyzer run; all seven per-file analyzer counts are 0; the JUnit `failures` and `errors` attributes are both 0 with `tests` recorded as a non-zero integer; and each of the **eighteen** fixed `It` identifiers listed in this plan's preamble is recorded as passing, derived by the preamble's per-test rule — the identifier text matches the `name` attribute of the number of nodes the preamble fixes for that identifier among those returned by `$junit.SelectNodes('//testcase')`, and every one of those nodes carries no child `failure` element. **Twenty-two** matched nodes are required in total: sixteen identifiers at one node each, `resolves the required document set for each work mode` at four, and `allows an absolute path to the target feature folder` at two. A match count differing from an identifier's fixed expected count fails this gate in either direction. The artifact also records the full `name` attribute value of one matched node verbatim. This is the sole proof that the eight Phase 3 fail-before rows went green and that the remaining ten fixed identifiers pass alongside them, so no part of it may be recorded from an MCP result or a console summary, neither of which carries a per-test name.

### Phase 5 — Batch E: bundled mirrors of the behaviour change and must-not-regress verification

- [ ] [P5-T1] Open batch E by removing the session batch-budget state file before batch E's first production write, using the same **filtered** batch-budget enumeration, removal, verification, exit-code attribution, and halt branch as `[P2-T1]`. Acceptance: the verification enumeration reports a count of `0`, and the pre-reset contents are recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/batch-boundary-e.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P5-T2] (Batch E) Update `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` so it is text-identical to the repository copy after the behaviour change. Acceptance: `Compare-Object` over the two files' content produces zero difference objects. An equal line count alone is not accepted as evidence of text identity.

- [ ] [P5-T3] (Batch E) Update `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` so it is text-identical to the repository copy after the behaviour change. Acceptance: `Compare-Object` over the two files' content produces zero difference objects.

- [ ] [P5-T4] Run the three Python delivery tests with `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/batch-e-delivery-tests.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: `EXIT_CODE: 0`, a failed count of 0, and the `Output Summary:` names `test_bundled_claude_payload_contains_all_repo_runtime_contracts` as passing, closing the second intermediate parity window. The artifact also records the pre-removal `.claude/state` file names (or the literal `none`) together with the post-removal verification count of `0`. Immediately before the pytest invocation, remove any runtime state files under `.claude/state` using the **unfiltered** `.claude/state` pipeline defined in `[P2-T1]`, recording the pre-removal file names and the post-removal verification count of `0` in this task's artifact. This is required, not optional: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` with `rglob("*")` at lines 51-60 and excludes only `.claude/settings.local.json` and `.claude/agent-memory/**` at lines 130-134, so it does not honour the `.gitignore` entry for `.claude/state/` at line 68 and reports `Repo file missing from bundle:` for any file it finds there. The filtered batch-budget pipeline is not sufficient here. `.claude/hooks/persist-session-id.ps1` is registered as a `SessionStart` hook at `.claude/settings.json` line 84 and writes `<cwd>/.claude/state/current-session-id` at its line 161, and `enforce-python-batch-budget.ps1` can have left `python-batch-budget.<id>.json` from an earlier session in the same worktree. Neither file name matches `powershell-batch-budget.*.json`, and either one on its own produces `Repo file missing from bundle:`. This removal is safe at this point because no production PowerShell write follows it inside the same batch. The artifact's `Command:` and `EXIT_CODE:` fields record the pytest invocation. The removal and verification commands and their own exit codes are recorded separately in `Output Summary:`, under `[P2-T1]`'s exit-code attribution, so a `1` from an enumeration against an absent `.claude/state` accompanied by a verified count of `0` is not read as a failure of this task.

- [ ] [P5-T5] Verify the six unmodified PowerShell gates pass with no edit to their files: `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`. Read their pass and fail counts from `artifacts/pester/pester-junit.xml` produced by `[P4-T21]` and compare them against the `[P0-T6]` baseline artifact. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/unmodified-gates.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` giving six baseline and six post-change pass counts, one pair per suite. Acceptance: each suite's post-change pass count is greater than or equal to its baseline and each fail count is 0. The two epic-merge-gate suites are required here by `spec.md` line 637.

- [ ] [P5-T6] Verify the must-not-regress file-set constraints by enumerating the full changed-file set from two commands run from the worktree root, neither of them chained after a `cd`: `git status --porcelain --untracked-files=all`, which reports uncommitted modifications and untracked files, and `git diff --name-only $baselineHead`, binding `$baselineHead` to the 40-character commit identifier recorded in the `[P0-T2]` artifact, which reports every path changed since the pre-change baseline whether or not it has since been committed. The union of the two outputs is the changed-file set this task enumerates. Both are required: porcelain status reports nothing once a phase has been committed, and a name-listing diff cannot report an untracked file. A `git add --dry-run` companion is not used: the pre-implementation gate classifies `git add` as a staging command at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` line 140 and denies it for a pathspec outside the orchestration-bookkeeping trees. **Anchor precondition:** the anchored diff describes this plan's change set only while `$baselineHead` remains an ancestor of `HEAD`. Confirm that first with `git merge-base --is-ancestor $baselineHead HEAD`, run from the worktree root and not chained after a `cd`, which exits 0 when the anchor is an ancestor, including the case where nothing has been committed and the two are the same commit. If it exits non-zero the branch was re-anchored after `[P0-T2]` ran, the diff additionally reports paths introduced by that re-anchoring which no task in this plan touches, and the four negative clauses below would fail against files outside this change set; halt and report blocked rather than excluding paths by judgement. Record this command and its exit code in the artifact alongside the other two. Acceptance: the enumerated union is non-empty and names at least `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, and `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, which is what distinguishes a genuine enumeration from an empty one; and within that union, no path matches `enforce-orchestration-preimplementation-gate`, none matches `enforce-epic-merge-gate`, none is `.claude/lib/hook-payload/HookPayload.psm1`, and none lies under `.codex/`. All three named paths exist by the time this task runs: `[P0-T12]` creates the helpers sibling, `[P3-T1]` creates the companion suite, and `[P4-T2]` through `[P4-T10]` modify the parent hook. Record the enumerated union in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/change-set-boundary.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing every changed path, recording both enumeration commands verbatim and both of their exit codes as well as the ancestry check's, and state in the same artifact that `.codex/hooks/` contains no mirror of this hook so this feature carries no Codex parity work and a reviewer should not look for one.

### Phase 6 — Final QC loop, coverage verification, and acceptance-criteria check-off

Run steps `[P6-T1]` through `[P6-T4]` in order. If any step fails or changes a tracked file, restart the loop from `[P6-T1]`. The loop completes only when all four steps pass in a single uninterrupted pass. Type checking is not applicable to PowerShell and is deliberately absent from the loop (`.claude/rules/powershell.md` line 17).

- [ ] [P6-T1] Formatting. Record `git status --porcelain` immediately before and immediately after invoking `mcp__drm-copilot__run_poshqc_format`, because the formatter rewrites tracked PowerShell source in place and exits 0 whether or not it changed anything, so the exit code alone cannot distinguish a clean run from a repairing one. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-format.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying both porcelain captures verbatim and an explicit statement of whether the two differ. Acceptance: the artifact carries both captures and the two captures are **identical**, which is the only outcome that demonstrates a clean formatting pass. If they differ, the formatter repaired drift: this task does not pass, the repair is committed to the batch it belongs to, and the loop restarts at `[P6-T1]`. Recording the two captures without comparing them is not a passing outcome.

- [ ] [P6-T2] Linting. Invoke `mcp__drm-copilot__run_poshqc_analyze` for route compliance, then run the direct `Invoke-PoshQCAnalyze` command fixed in this plan's preamble, which is the run every asserted value here is derived from, and run the per-file `Invoke-ScriptAnalyzer` count command once for each of the seven paths in this task's fixed file set as the preamble table lists them. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-analyze.<ISO-8601>.md` with `Timestamp:`, `Command:` naming every command run verbatim, the direct analyzer command recorded in the redirected `6>&1` form the preamble fixes, `EXIT_CODE:`, and `Output Summary:` recording the analyzer branch observable — either the literal `PSScriptAnalyzer passed: no findings under` quoted from the captured output with the finding count recorded as `0`, or the integer from the `PSScriptAnalyzer reported` throw message together with each printed finding's rule name and file path — and the seven per-file integer counts, one per path. Acceptance: the `Output Summary:` quotes the literal `PSScriptAnalyzer passed: no findings under` from the captured output, the recorded whole-tree finding count is 0, and all seven per-file integer counts are 0. A non-zero count in either form restarts the loop at `[P6-T1]` after remediation. An exit code or an MCP result is not accepted in place of the literal, because neither carries a finding count.

- [ ] [P6-T3] Testing with coverage. Run the direct `Invoke-PoshQCTest` command fixed in this plan's preamble, which is the single route for this task and is named unconditionally rather than as a fallback; it runs with `CodeCoverage.Enabled` set to `$true` per `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 18, emits `artifacts/pester/powershell-coverage.xml` per line 22, and emits `artifacts/pester/pester-junit.xml` per line 15. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-test.<ISO-8601>.md` with `Timestamp:`, `Command:` naming that command verbatim, `EXIT_CODE:`, and `Output Summary:` recording six numeric values derived by the preamble's test-count and coverage derivation: total tests, passed, and failed, all three read from the `testsuites` element of `artifacts/pester/pester-junit.xml` together with the `errors` attribute the passed count is computed from; the overall line-coverage percentage aggregated over every `sourcefile` node of `artifacts/pester/powershell-coverage.xml` with its two summed integers recorded beside it; and the per-file line-coverage percentage for `.claude/hooks/enforce-prd-feature-before-planner.ps1` and for `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, both computed from the covered-line and total-line counts for those paths in the same coverage report, keyed on the full directory path of the enclosing element rather than on the bare file name. Record no branch-coverage value: Pester measures line and command coverage only, so a branch percentage is never printed and no branch gate applies. Acceptance: the JUnit `failures` and `errors` attributes are both 0 with `tests` recorded as a non-zero integer, and six numeric values plus the two aggregate sums are recorded, none of them a placeholder; every one of them is derived from `artifacts/pester/pester-junit.xml` or `artifacts/pester/powershell-coverage.xml`, and none from an MCP result or a console summary.

- [ ] [P6-T4] Delivery tests. Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` and write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-delivery-tests.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording passed and failed counts. Acceptance: `EXIT_CODE: 0`, a failed count of 0, and a recorded pre-removal `.claude/state` file list (or the literal `none`) together with the post-removal verification count of `0`. Immediately before the pytest invocation, remove any runtime state files under `.claude/state` using the **unfiltered** `.claude/state` pipeline defined in `[P2-T1]`, recording the pre-removal file names and the post-removal verification count of `0` in this task's artifact. This is required, not optional: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` with `rglob("*")` at lines 51-60 and excludes only `.claude/settings.local.json` and `.claude/agent-memory/**` at lines 130-134, so it does not honour the `.gitignore` entry for `.claude/state/` at line 68 and reports `Repo file missing from bundle:` for any file it finds there. The filtered batch-budget pipeline is not sufficient here. `.claude/hooks/persist-session-id.ps1` is registered as a `SessionStart` hook at `.claude/settings.json` line 84 and writes `<cwd>/.claude/state/current-session-id` at its line 161, and `enforce-python-batch-budget.ps1` can have left `python-batch-budget.<id>.json` from an earlier session in the same worktree. Neither file name matches `powershell-batch-budget.*.json`, and either one on its own produces `Repo file missing from bundle:`. This removal is safe at this point because no production PowerShell write follows it inside the same batch. The artifact's `Command:` and `EXIT_CODE:` fields record the pytest invocation. The removal and verification commands and their own exit codes are recorded separately in `Output Summary:`, under `[P2-T1]`'s exit-code attribution, so a `1` from an enumeration against an absent `.claude/state` accompanied by a verified count of `0` is not read as a failure of this task.

- [ ] [P6-T5] Coverage delta and threshold verification. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/coverage-comparison.<ISO-8601>.md` reporting, as labelled numeric fields: the baseline line coverage for `.claude/hooks/enforce-prd-feature-before-planner.ps1` from the `[P0-T5]` artifact; the post-extraction reading for both production files from the `[P2-T10]` artifact; the post-change reading for both production files from the `[P6-T3]` artifact; the overall baseline and post-change line coverage, each of them the aggregate the preamble's coverage derivation fixes and each carried across from the `[P0-T5]` and `[P6-T3]` artifacts with its two summed integers; and the line coverage of the new and changed lines in both production files. The changed-line set is not selected by the executor. It is the set of post-image line numbers reported by `git diff --unified=0 $baselineHead -- .claude/hooks/enforce-prd-feature-before-planner.ps1 .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, run from the worktree root and not chained after a `cd`, with `$baselineHead` bound to the 40-character commit identifier recorded in the `[P0-T2]` artifact and under the same `git merge-base --is-ancestor $baselineHead HEAD` anchor precondition and halt branch that `[P5-T6]` states. Each hunk header carries a post-image field of the form `+c,d` or `+c`; the pre-image field varies independently and is not read. A `+c,d` field names the range `c` through `c + d - 1`, and `+c,0` names an empty range contributing no line. Git omits the count when it is 1, so a `+c` field names the single post-image line `c`. Both spellings occur under `--unified=0` in the history of the directory this change set modifies: `git log -n 60 --unified=0 -p -- .claude/hooks`, run from the worktree root, emits 451 post-image fields of the `+c,d` form, 235 of the count-omitted `+c` form including `@@ -116 +121 @@`, `@@ -156,0 +173 @@` and `@@ -110 +282 @@`, and 20 of the empty-range `+c,0` form including `@@ -16,2 +19,0 @@` and `@@ -226 +267,0 @@`. Single-line edits to the hook are expected in this change set, so neither spelling may be treated as the exceptional case; an executor that implements only the `+c,d` form meets headers it has no rule for and the changed-line set reverts to judgement. The union of those ranges per file is that file's changed-line set. New-and-changed-line coverage for a file is the count of its changed lines that appear as a child `line` element with `ci` greater than zero under its `sourcefile` node in `artifacts/pester/powershell-coverage.xml`, divided by the count of its changed lines that appear as a child `line` element under that node at all; lines the coverage report does not analyze, such as comments and blank lines, are outside both counts. Record the two integers beside each percentage, and record the diff command and its exit code in the same artifact. Because `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` is created by this plan, its changed-line set is the whole file and its new-and-changed-line coverage equals its per-file coverage; record that identity rather than treating the match as an error. Name in the `Command:` field the direct `Invoke-PoshQCTest` command fixed in this plan's preamble, verbatim, which is the command that produced the post-change reading and is named unconditionally rather than as a fallback. Acceptance: every reported value is numeric and none is a placeholder; the post-change per-file line coverage is at or above 85 percent for both production files, as `spec.md` line 667 requires; the overall post-change line coverage is not lower than the overall baseline, or, when it is lower, the artifact records the overall post-change aggregate recomputed with the `sourcefile` node for `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` excluded and that recomputed figure is not lower than the overall baseline. The two aggregates are taken over different denominators by construction, because `[P0-T5]` measures the baseline before `[P0-T12]` creates the sibling and before `[P2-T6]` adds it to `CodeCoverage.Path`. The recomputation is the like-for-like comparison and is stated so a denominator change is not recorded as a coverage regression. It is not a waiver: the sibling's own per-file figure is separately gated at 85 percent by the clause above, and both aggregates are recorded with their two summed integers either way; and the new-and-changed-line coverage is recorded for both files. No branch-coverage figure is reported, because Pester does not measure it.

- [ ] [P6-T6] Record the loop-completion statement. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-loop.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming, in order, the four steps `[P6-T1]` through `[P6-T4]` and the artifact path each produced, and stating how many complete passes of the loop were required. Acceptance: the artifact names four steps and four artifact paths and states that the final pass completed with zero failures and zero file changes. `EXIT_CODE: SKIPPED` is not a valid outcome for any of `[P6-T1]` through `[P6-T4]`; each command is executed and recorded.

- [ ] [P6-T7] Check off acceptance criteria individually in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md` under `## Acceptance Criteria`, per `.claude/skills/acceptance-criteria-tracking/SKILL.md`. `spec.md` is the sole acceptance-criteria source for this `full-bug` feature; `issue.md` and `user-story.md` are not acceptance-criteria sources here. Change only `- [ ]` to `- [x]` and do not alter any criterion's text. Check each criterion off as its verifying task passes, one at a time; do not batch. Leave any criterion that cannot be verified unchecked and document the gap. Acceptance: every criterion checked off names, in the execution log, the plan task and the evidence artifact that verified it, and no criterion is checked off without one.

- [ ] [P6-T8] Emit the acceptance-criteria status summary required at completion by `.claude/skills/acceptance-criteria-tracking/SKILL.md`, reporting the source file path, the total criterion count, the checked-off count, the remaining count, and the text of every remaining unchecked criterion. Acceptance: the summary reports a total of 38 criteria, matching the count of `- [ ]`/`- [x]` lines between the `## Acceptance Criteria` heading at `spec.md` line 600 and the `## Risks & Mitigations` heading at line 671, and the checked-off and remaining counts sum to 38.

---

## Findings added in this pass

These were found by the sibling-region re-check required on every revision round and were not in the round-1
delta. Each is applied above.

1. **N1 — a second exact-equality region on the changed function had no covering task.** `[P4-T7]` and
   `[P4-T8]` both modify `Find-PrdFeatureFolderFromPrompt`. The round-1 plan named the FolderResolution
   suite's truncation `Context` as the guard, and the round-1 delta added the decision-level cases. Neither
   covered `Context 'Find-PrdFeatureFolderFromPrompt'` at
   `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` lines 197-210, which unit-tests
   that function's return value directly with `Should -Be 'docs/features/active/abc-1'` at lines 205 and 208.
   Added as `[P4-T12]`; preamble ruling 8 is extended to bind the function's own return spelling, not only the
   two composition sites the delta named.
2. **N2 — `param(` cannot be asserted at zero.** The round-1 delta corrected `[P0-T12]`'s `param(` token for
   regex-fragility but left the zero-match expectation. Every advanced function in the moved code declares a
   `param(` block, so under `-SimpleMatch` the corrected search returns one match and the task would fail on
   correct code. `[P0-T12]` now asserts the true count with the indentation property recorded.
3. **N3 — text-identity asserted by line count.** `[P2-T2]`, `[P2-T3]`, `[P5-T2]`, and `[P5-T3]` asserted
   "both files report the same measured line count", which two differing files of equal length satisfy, while
   `spec.md` line 659 requires text-identical counterparts. All four now assert a zero-difference
   `Compare-Object`. `[P6-T1]` had the same shape — it recorded two porcelain captures without requiring them
   to match — and now requires identity.
4. **N4 — `Set-Location` is not a discriminator.** `[P4-T19]`'s claim that each of its seven tokens "is
   present elsewhere in the tracked tree" is false for `Set-Location`, which no PowerShell file in this tree
   contains, so the round-1 delta's control-count requirement was unsatisfiable for it as written. The
   preamble's control table records the substitute control and the reason.

## Round 1 delta — application record

| # | applied | note |
|---|---|---|
| D1 | yes | citation corrected from `spec.md` line 353 to line 352 for the retention clause; line 353 retained for the removal clause |
| D2 | yes | preamble block added; all seven tokens corrected; `param(` additionally corrected for its unsatisfiable zero expectation (N2) |
| D3 | yes | inserted as `[P4-T15]`; both renamed `It` names fixed verbatim in the preamble list |
| D4 | yes | inserted as `[P3-T7]` and `[P3-T8]`; `[P3-T9]` counts re-derived to ten named and eight required to fail |
| D5 | yes | reset mechanism verified against the hook source and against prior art; state-file path enumerated by filter rather than composed from a `<session-id>` placeholder; exit-code-1 attribution recorded |
| D6 | yes | inserted as `[P3-T3]`; `[P4-T7]`, `[P0-T6]`, `[P5-T5]` extended |
| D7 | yes | ruling 8 added and extended to a third composition site; `[P4-T11]` added; reason-string assertions re-derived as substring-form and therefore not binding |
| D8 | yes | applied verbatim |
| D9 | yes | applied to `[P0-T11]`, `[P3-T4]`, `[P3-T9]` |
| D10 | yes | applied to `[P3-T9]` |
| D11 | partially | the descriptive improvements are applied; two of the three line-range corrections are rejected as off-by-one in the delta's own direction and are recorded above |
| D12 | yes | `[P2-T8]` added with a fallback command verified against `PoshQC.psm1` line 3, line 143, and `PoshQC.Testing.psm1` lines 156 and 305-318 |
| D13 | yes | applied verbatim |
| D14 | yes | applied to `[P1-T6]`, `[P4-T20]`, and the preamble |
| D15 | yes | applied verbatim, with the `[P5-T5]` reference renumbered to `[P5-T6]` |

## Round 2 delta — application record

| # | applied | note |
|---|---|---|
| Priority 1 (three disputed citations) | n/a | adjudicated in this plan's favour; 368-370, the pattern literal at 252 with `[regex]::Matches` at 253, and `spec.md` 352/353 are retained unchanged |
| B1 | yes | appended to `[P2-T9]`, `[P5-T4]`, `[P6-T4]`; preamble intermediate-parity-window paragraph added |
| B2 | yes | `[P2-T2]`'s pytest clause replaced with the deferral to `[P2-T9]`; `[P2-T9]` now names the test explicitly |
| B3 | yes | `[P4-T6]`'s second acceptance clause replaced; the pre-rename failure is recorded rather than treated as a regression |
| B4 | yes | second control added to `[P0-T3]`; see N5 for the reconciliation with L2 that makes the count three rather than two |
| B5 | yes | applied to `[P3-T3]` and `[P3-T9]`; `[P3-T3]`'s "same resolved target" phrase additionally corrected to "same intended target folder" (N6) |
| M1 | yes | second halt arm added to `[P0-T8]`, with the evaluation point stated because `[P0-T9]` runs after it |
| M2 | yes | `[P2-T1]`'s inverted expectation replaced |
| M3 | yes | re-derived independently: the two comment-based-help occurrences are at lines 162 and 169; corrected |
| L1 | yes | `[P3-T8]` now requires the named `It` to fail, matching its `[expect-fail]` tag |
| L2 | yes | `[P4-T13]`'s first clause replaced with the `-SimpleMatch` zero-match search plus its `[P0-T3]` control |
| L3 | yes | four paths added to `[P4-T20]`; its acceptance now requires nine measured counts |
| L4 | yes | `[P0-T10]` given the reset and halt branch; the batch table's A1 row updated to name it |
| coverage-route micro-gap | yes | the `[P2-T8]` fallback command now names the PowerShell tool as its single execution route |

## Findings added in the round-2 revision pass

These were found by the sibling-region re-check required on every revision round and were not in the round-2
delta. Each is applied above.

5. **N5 — B4 and L2 disagree on `[P0-T3]`'s control count.** B4 states that `[P0-T3]`'s acceptance requires
   "6 measured integers and **two** control counts". L2 then requires a further pre-change control from the
   same task, for the token `falls back to orchestrator-state.json`, which `[P4-T13]` cannot measure itself
   once the rename has landed. Applying both as written leaves `[P0-T3]` asserting two controls while three
   tasks read a control from it. `[P0-T3]` therefore records **three** controls and its acceptance requires
   three. All three are pre-change counts whose subject text a later task removes, so none can be measured at
   the point of use.
6. **N6 — `[P3-T3]`'s opening phrase contradicted B5's own insertion.** B5's inserted sentence states that the
   row omits the injection parameter, while the task's first sentence required "the same payload and the same
   resolved target as the `[P3-T2]` row" — and `[P3-T2]` supplies its target through that parameter. The
   phrase is corrected to "the same payload and the same intended target folder", which states the shared
   fixture without implying the parameter is bound.

## Round 3 delta — application record

| # | applied | note |
|---|---|---|
| Priority 1 (the twelve round-2 defects) | n/a | reported closed by the reviewer, B1 partially; the residue is carried by B6 |
| N5, N6 | n/a | upheld by the reviewer as fresh work and retained unchanged |
| B6 delta 1 | yes | `[P2-T1]` now defines a second, unfiltered `.claude/state` pipeline beside the filtered batch-budget one and states which tasks use which. Placed at the end of the task rather than mid-paragraph, so the task's own `Acceptance:` line stays bound to the filtered reset it was written for |
| B6 delta 2 | yes | `[P2-T9]`, `[P5-T4]`, and `[P6-T4]` point at the unfiltered pipeline, record the post-removal verification count of `0`, and cite the `SessionStart` writer; each acceptance now requires that record |
| B6 delta 3 | yes | `[P0-T7]` carries the same removal immediately before its pytest invocation, with the record required by its acceptance |
| B6 delta 4 | yes | the preamble's intermediate-parity-window paragraph names both writers and separates parity clearing from batch-boundary resets |
| L5 | yes | `[P2-T2]` names the node ID in place of the dangling "That test" |
| L6 | yes | `[P0-T9]` carries the evaluation instruction for `[P0-T8]`'s second halt arm |
| L7 | yes | `[P3-T3]`'s mock-keying phrase restated for the bare state-B spelling |
| L8 | yes | `[P3-T9]`'s failure-mode instruction scoped to rows that failed |
| AC12, AC33, and the AC26 narrowing | no | the reviewer recorded these as imprecise but not wrong and requiring no plan change. The AC-MAPPING rows are left unchanged rather than restructured, because editing a mapping row to carry commentary risks the disagreement class the record exists to prevent |

## Findings added in the round-3 revision pass

These were found by the sibling-region re-check required on every revision round and were not in the round-3
delta. Each is applied above.

7. **N7 — the two stated evaluation points for `[P0-T8]`'s second halt arm did not match.** L6's supplied text
   halts "before starting `[P0-T10]`", while `[P0-T8]` said the arm is evaluated "before any Phase 1 work
   begins". The two are compatible but not identical, and an executor reading only `[P0-T8]` would defer the
   evaluation past `[P0-T10]`. `[P0-T8]` now states the same point as `[P0-T9]`.
8. **N8 — defining two pipelines in `[P2-T1]` made every unqualified pointer to it ambiguous.** The four
   batch-boundary tasks `[P0-T10]`, `[P2-T4]`, `[P4-T1]`, and `[P5-T1]` referred to "the pipeline stated in
   `[P2-T1]`" without qualification. Left as they were, they would carry the same stated-scope-versus-bound-
   pipeline disagreement B6 reports, in the opposite direction. All four now name the filtered batch-budget
   pipeline explicitly.
9. **N9 — `[P0-T7]`'s new removal changes what `[P0-T10]` can observe.** `[P0-T7]` runs earlier in Phase 0 and
   now clears every file under `.claude/state`, so `[P0-T10]` observes an existing but empty directory rather
   than an absent one, and its enumeration is empty whenever `[P0-T7]` has run. `[P0-T10]`'s `none` branch
   previously read as covering only a missing directory. Both tasks now state the interaction, and
   `[P0-T10]`'s acceptance remains satisfiable through its `none` branch.
10. **N10 — the unfiltered removal also deletes `current-session-id`, which is a batch-budget input.** This was
    checked rather than assumed. `.claude/hooks/enforce-powershell-batch-budget.ps1` resolves the session id
    from `CLAUDE_SESSION_ID`, then from that file, then from a worktree-derived identifier (lines 139-173), and
    the hook denies only when it rehydrates a list that has already reached its cap (lines 293-297). Losing the
    file can therefore only start a fresh list under a different state-file name; it cannot deny a write. The
    filtered `powershell-batch-budget.*.json` enumeration matches either name, so later boundaries still clear
    it. The one visible effect is that a later boundary task's pre-reset list may be empty or carry the
    worktree-derived name, which no acceptance condition depends on. `[P2-T1]` records this so it is not
    mistaken for a budget failure.
11. **N11 — the unfiltered enumeration's root and its non-recursive form both needed stating.** The parity test
    computes its root from the test file's own location at
    `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` line 21, so a removal run from a
    subdirectory would clear a different `.claude/state` than the one the test enumerates. All three writers
    place flat files directly under `.claude/state`, so `-File` without `-Recurse` is complete against the
    writers that exist; `[P2-T1]` states the diagnostic step to take if a nested file ever appears, so the
    verification count of `0` is not read as proof against a case it cannot see.

## Round 4 delta — application record

| # | applied | note |
|---|---|---|
| B6, L5-L8 | n/a | reported closed by the reviewer |
| the `[P2-T1]` placement deviation and the widened "for any file it finds there" clause | n/a | upheld by the reviewer and retained unchanged |
| the `current-session-id` safety finding | n/a | independently verified SAFE with no denial path; the reviewer additionally confirmed that the unfiltered removal closes the one theoretical denial vector, a worktree-derived name colliding with a stale at-cap state file. No plan change |
| N7-N11 | n/a | upheld by the reviewer as fresh work and retained unchanged |
| B7 | yes | `[P5-T6]` now enumerates the union of `git status --porcelain --untracked-files=all` and `git diff --name-only $baselineHead` anchored on the `[P0-T2]` baseline commit, and its acceptance carries a non-emptiness floor naming the three paths the plan itself creates or modifies. The `git add --dry-run` rationale and the Codex-parity statement are retained verbatim |
| L9 | yes | the preamble's intermediate-parity-window paragraph now reads "Three hooks write there" and names `enforce-python-batch-budget.ps1` at line 363 as the third |
| L10 | yes | `[P0-T7]`, `[P2-T9]`, `[P5-T4]`, and `[P6-T4]` each state that `Command:` and `EXIT_CODE:` record the pytest invocation and that the removal and verification legs carry their own exit codes in `Output Summary:` |
| `Last Updated` | yes | set to the caller-measured reading `2026-09-13T23-08`; the monotonic-successor disclosure is removed because the value is now measured |

## Findings added in the round-4 revision pass

These were found by the sibling-region re-check required on every revision round and were not in the round-4
delta. Each is applied above.

12. **N12 — `[P4-T4]`'s second acceptance clause inherited B7 by reference and was also not decidable when it
    ran.** The clause read "absent from the changed-file set that `[P5-T6]` enumerates". `[P4-T4]` is in Phase 4
    and `[P5-T6]` is in Phase 5, so the referenced set does not exist when `[P4-T4]` is checked off, and a
    reference-only pointer would have carried whichever enumeration `[P5-T6]` ended up defining without stating
    when it is evaluated. The clause now enumerates the same two-command union at its own point in the sequence,
    carries its own non-emptiness floor naming `.claude/hooks/enforce-prd-feature-before-planner.ps1` (modified
    by `[P4-T2]`, which runs first), and states that `[P5-T6]` re-verifies the constraint in Phase 5.
13. **N13 — the anchored diff over-reports if the branch is re-anchored after `[P0-T2]`.** `git diff
    --name-only $baselineHead` describes this plan's change set only while `$baselineHead` is an ancestor of
    `HEAD`. If the branch is rebased mid-execution, the anchor is no longer an ancestor, the diff reports the
    symmetric difference including paths the re-anchoring introduced, and the four negative clauses can fail
    against files this plan never touched. This is the opposite failure direction to B7 — a false failure rather
    than a vacuous pass — and it is not covered by the delta's text. `[P5-T6]` now confirms the anchor first
    with `git merge-base --is-ancestor $baselineHead HEAD`, which exits 0 in the normal case and in the
    nothing-committed case where the two are the same commit, and halts and reports blocked when it does not.
    The halt is stated rather than an exclusion rule, because letting the executor exclude paths by judgement
    would reintroduce an acceptance condition the executor selects its own evidence against.

## Round 6 delta — application record

| # | applied | note |
|---|---|---|
| D1a | yes | the preamble's per-test rule now fixes an expected node count per identifier instead of assuming one, and states the `-ForEach` mechanism that makes four and two the correct counts for two identifiers |
| D1b | yes | `[P4-T21]`'s `Output Summary:` now records the observed matched-node count beside each identifier and its derived result |
| D1c | yes | `[P4-T21]`'s acceptance now requires twenty-two matched nodes in total and fails on any per-identifier count that differs from its fixed expectation in either direction |
| D2 | yes | `[P6-T5]` now derives the changed-line set from an anchored `git diff --unified=0` under `[P5-T6]`'s ancestry precondition, states the post-image range arithmetic and the two counts, and records the whole-file identity for the sibling this plan creates |
| D3 | yes | the analyzer command carries `6>&1`, with the stream-6 rationale stated; `[P0-T4]`, `[P1-T7]`, `[P4-T21]`, and `[P6-T2]` each record the redirected form in `Command:` |
| D4 | yes | `[P2-T8]`'s acceptance is restated as a two-valued determination with a third, failing case for a zero control count; its probe, its control search, and its verbatim direct command are unchanged |
| D5 | yes | `[P6-T5]`'s overall-coverage clause admits a like-for-like recomputation with the sibling's `sourcefile` node excluded, with the denominator-ordering reason stated and the per-file 85 percent gate retained |
| D6 | yes | the aggregate derivation now applies the per-file rule including its `counter`-element fallback to every node, and records the node count and the fallback-form count |

---

## Round 7 delta — application record

| # | applied | note |
|---|---|---|
| Defect 1 | yes; round-8 citation adaptation reversed in round 9 | `[P6-T5]`'s hunk-header rule now covers the `+c,d`, `+c,0`, and count-omitted `+c` post-image spellings, states that the pre-image field varies independently and is not read, and states that an executor implementing only `+c,d` reverts the changed-line set to judgement. The supplied text cited this repository's `.claude/hooks` history as the observation site; because no tool available to the planner can query git history, the round-8 pass substituted an already-recorded `git diff -U0` output from an unrelated feature folder. Round 9 restored the originally supplied `.claude/hooks` citation, with the three post-image spelling counts supplied by the calling session from its own `git log -n 60 --unified=0 -p -- .claude/hooks` run, and removed the substituted citation. The binding force is unchanged in both rounds: neither spelling may be treated as the exceptional case. |
| Defect 2 | yes, verbatim | `[P3-T4]` is replaced wholesale. It now fixes the two-row `-ForEach` binding, states why the binding is not an implementation choice (`[P4-T21]`'s differs-in-either-direction arm, which prohibits relaxing the match), notes that the `It` name carries no `<Property>` template so both nodes share one `name` attribute, and requires the observed outcome to be recorded per row. Every clause of the superseded text — the identifier, the containing-worktree document precondition, the both-outcomes-acceptable ruling, the absence of an `[expect-fail]` tag, the `[P3-T9]` fail-count exclusion, and the independence from `[P0-T11]` — is retained. |
| Defect 3 | yes, verbatim | `[P4-T21]`'s closing sentence now names the eight Phase 3 fail-before rows and the remaining ten fixed identifiers separately, instead of describing all eighteen fixed identifiers as Phase 3 fail-before cases. Both figures were re-derived in this pass: Phase 3 adds ten `It` blocks across `[P3-T2]` through `[P3-T8]`, `[P3-T9]` requires eight of them to fail, and eighteen minus eight is ten. |
| `[P3-T9]` | no edit, as directed | re-derived and confirmed: its exclusion clause already reads "which are recorded with their observed outcomes", in the plural, so the two-row `[P3-T4]` binding needs no change there. |

---

## Planner internal review record

This record is written into the plan artifact so it travels with the plan. The same record is emitted in the
planner's handoff message. It is a planner-side declaration and is not a substitute for executor preflight
clearance.

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS

CITATION: .claude/hooks/enforce-powershell-batch-budget.ps1 | lines 347-350 non-PowerShell early return; 352 state dir join; 362-363 directory creation; 366 state-file composition `powershell-batch-budget.$resolvedSessionId.json`; 139-173 session-id resolution order (env, then `current-session-id` file at 150-160, then worktree-derived identifier at 162-173); 293-297 deny on a rehydrated list at cap, with the reset instruction in the reason at 296
CITATION: .claude/hooks/enforce-python-batch-budget.ps1 | line 345 non-`.py` early return; 349 state dir join; 356 `current-session-id` path; 363 state-file composition `python-batch-budget.$resolvedSessionId.json`
CITATION: .claude/hooks/persist-session-id.ps1 | line 161 state-file path composed from `(Get-Location).Path` and `.claude/state/current-session-id`; 104-115 `env-file` arm writes the state file after ensuring the directory; 116-122 `state-file` arm does the same; 96 `New-Item` control
CITATION: .claude/settings.json | line 79 `SessionStart` block; line 84 `pwsh -NoProfile -File .claude/hooks/persist-session-id.ps1`; line 128 `Write|Edit` matcher; 136 `enforce-python-batch-budget.ps1`; 144 `enforce-powershell-batch-budget.ps1`
CITATION: tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py | lines 51-60 `list_scoped_files` rglob enumeration; 21 `REPO_ROOT = Path(__file__).resolve().parents[3]`; 25 SCOPED_ROOTS = (.claude,); 118 test function; 130-134 exclusion list; 136-139 missing-from-bundle assertion
CITATION: .claude/skills/identify-session-id/SKILL.md | resolution order at lines 18-38: `CLAUDE_SESSION_ID` primary, `.claude/state/current-session-id` secondary, newest-mtime transcript tertiary
CITATION: .gitignore | line 68 `.claude/state/`
CITATION: .claude/hooks/enforce-prd-feature-before-planner.ps1 | line 367 prompt-resolution assignment retained; 368-370 unconditional checkpoint fallback removed by `[P4-T6]`
CITATION: .claude/hooks/enforce-prd-feature-before-planner.ps1 | lines 162 and 169 comment-based-help `user-story.md`; line 182 `full-feature` switch arm; line 185 `default` arm returning `spec.md` alone
CITATION: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | line 107 `It 'falls back to orchestrator-state.json when prompt has no folder reference'`; line 109 blanket `-MockWith { $true }`; line 118 sibling case `prefers the prompt-derived folder over the checkpoint folder`
CITATION: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | lines 97 and 105 `uses the earliest candidate` (2 occurrences); line 89 sibling case `prefers the checkpoint folder when it occurs later in the prompt`
CITATION: .claude/lib/ | no target-worktree-resolution module present; 32 `.psm1` files across blast-radius, cleanup-manifest, codex-routing, discovery-validation, hook-payload, mermaid, model-routing, orchestrator-state, project-file-merge, requirements
CITATION: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | line 140 `$isStaging = @('add', 'commit').Where({ Test-CommandLineInvocation ... -CommandWord 'git' ... })`, the classification that makes both `git add` and `git commit` staging commands and is the reason `[P5-T6]` uses no `git add --dry-run` companion; lines 132-137 the implementation-command pattern list, whose first entry is gated on `$isStaging` at line 143
CITATION: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 and tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | neither path exists in this tree; each is created by a task that quotes its full path verbatim (`[P0-T12]` and `[P3-T1]` respectively), so the `[P5-T6]` non-emptiness floor names two paths this plan itself creates and one, `.claude/hooks/enforce-prd-feature-before-planner.ps1`, that exists now and is modified from `[P0-T12]` onward
CITATION: .claude/state/ | no file present in this planning worktree, re-derived in the round-4 pass by a glob of `.claude/state/*` that returned no match, which is also the state `[P2-T1]`'s exit-code attribution and the `[P0-T7]`, `[P2-T9]`, `[P5-T4]`, and `[P6-T4]` `EXIT_CODE:` clarification are written against. The reviewer recorded `current-session-id` present in the sibling checkout, in the main checkout, and across agent worktrees, so the executor's worktree is expected to hold one and the plan does not assume an empty directory
CITATION: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1 | 448 lines
CITATION: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | 293 lines
CITATION: extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | 293 lines
CITATION: docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md | line 600 `## Acceptance Criteria`; line 610 state-3 ambiguity criterion; line 653 500-line cap; line 671 `## Risks & Mitigations`; 38 criteria between them. Re-derived in the round-4 pass for the three criteria B7 affects: line 636 (AC17) requires that no file matching `enforce-orchestration-preimplementation-gate*` is modified by this change set and that its suites pass unmodified; line 637 (AC18) requires that `enforce-epic-merge-gate.ps1` is not modified by this change set and that its suites pass unmodified; line 662 (AC34) requires that no Codex mirror is added or expected. All three are "not modified by this change set" constraints, so each depends on the change-set enumeration being genuine, which is what the `[P5-T6]` non-emptiness floor now establishes

CITATION: scripts/powershell/PoshQC/PoshQC.Analyzer.psm1 | line 83 `Invoke-PoshQCAnalyze` declaration; line 88 `-SettingsPath` with the `$script:PssaSettings` default; lines 114-117 the default `$Logger` scriptblock, whose line 116 is `Write-Information $Message -InformationAction Continue` and therefore writes to stream 6, which is why the direct analyzer command carries `6>&1`; line 132 the `.ps1`/`.psm1` file filter; lines 181-183 the non-zero branch (`Format-Table` at 182, `throw "PSScriptAnalyzer reported ... issue(s)."` at 183); line 185 the zero-findings logger call reached only when line 181's guard is false
CITATION: .claude/hooks | post-image hunk-header spellings in `git log -n 60 --unified=0 -p -- .claude/hooks`, run from the worktree root: 451 `+c,d`, 235 count-omitted `+c` including `@@ -116 +121 @@`, `@@ -156,0 +173 @@` and `@@ -110 +282 @@`, and 20 empty-range `+c,0` including `@@ -16,2 +19,0 @@` and `@@ -226 +267,0 @@`. These counts are supplied by the calling session from its own run of that command and are attributed to it; the planner has no shell in this pass and did not re-derive them. This is the directory `[P6-T5]`'s changed-line derivation operates on
CITATION: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | line 4 `Run.Exit = $true`; lines 12-15 the JUnit `TestResult` block; lines 17-22 the CoverageGutters `CodeCoverage` block; line 237 the `CodeCoverage.Path` entry for `.claude/hooks/enforce-prd-feature-before-planner.ps1`, which is the only entry for this hook family in the current tree — the sibling entry is added by `[P2-T6]`, which is the ordering `[P6-T5]`'s like-for-like aggregate recomputation is written against

AC-INVENTORY: AC01, AC02, AC03, AC04, AC05, AC06, AC07, AC08, AC09, AC10, AC11, AC12, AC13, AC14, AC15, AC16, AC17, AC18, AC19, AC20, AC21, AC22, AC23, AC24, AC25, AC26, AC27, AC28, AC29, AC30, AC31, AC32, AC33, AC34, AC35, AC36, AC37, AC38

AC-MAPPING: AC01 | IMPLEMENTATION: [P4-T10] | TESTS: It 'allows when the target root holds the required document' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC02 | IMPLEMENTATION: [P4-T10] | TESTS: It 'denies with the missing-document reason when the document is absent under the target root' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC03 | IMPLEMENTATION: [P4-T5] | TESTS: It 'denies with the ambiguity code when the target cannot be resolved' and It 'emits an ambiguity code distinct from the missing-document and marker reasons' | EVIDENCE: evidence/other/f1-identifier-binding.md and evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC04 | IMPLEMENTATION: [P4-T6] | TESTS: It 'denies rather than validating against a sibling session checkpoint' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC05 | IMPLEMENTATION: [P4-T8] | TESTS: It 'denies rather than selecting the earliest candidate on an unresolved tie' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC06 | IMPLEMENTATION: [P4-T9] | TESTS: It 'denies with the ambiguity reason when the folder is absent from the target root' and Context 'indeterminate work-mode marker' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC07 | IMPLEMENTATION: [P4-T5] | TESTS: It 'runs no existence probe on the ambiguity branch' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC08 | IMPLEMENTATION: [P4-T16] | TESTS: It 'probes once on a full-bug allow row' and It 'probes twice on a full-feature allow row' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC09 | IMPLEMENTATION: [P4-T18] | TESTS: Context 'target resolution matrix' | EVIDENCE: evidence/qa-gates/blanket-mock-guard.md
AC-MAPPING: AC10 | IMPLEMENTATION: [P4-T10] | TESTS: It 'allows when the target root holds the required document' | EVIDENCE: evidence/regression-testing/fail-before.md
AC-MAPPING: AC11 | IMPLEMENTATION: [P3-T3] | TESTS: It 'allows when the modelled cwd is the item worktree' | EVIDENCE: evidence/regression-testing/fail-before.md
AC-MAPPING: AC12 | IMPLEMENTATION: [P3-T4] | TESTS: It 'allows an absolute path to the target feature folder' | EVIDENCE: evidence/regression-testing/absolute-path-reproduction.md
AC-MAPPING: AC13 | IMPLEMENTATION: [P4-T6] | TESTS: It 'denies rather than validating against a sibling session checkpoint' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC14 | IMPLEMENTATION: [P4-T10] | TESTS: It 'denies with the missing-document reason when the document is absent under the target root' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC15 | IMPLEMENTATION: [P4-T17] | TESTS: It 'resolves the required document set for each work mode' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC16 | IMPLEMENTATION: [P4-T10] | TESTS: It 'denies with the missing-document reason when the document is absent under the target root' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC17 | IMPLEMENTATION: [P5-T6] | TESTS: enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 via [P5-T5] | EVIDENCE: evidence/regression-testing/change-set-boundary.md and evidence/regression-testing/unmodified-gates.md
AC-MAPPING: AC18 | IMPLEMENTATION: [P5-T6] | TESTS: enforce-epic-merge-gate.Tests.ps1 and enforce-epic-merge-gate.TriggerScoping.Tests.ps1 via [P0-T6] and [P5-T5] | EVIDENCE: evidence/baseline/baseline-unmodified-gates.md and evidence/regression-testing/unmodified-gates.md
AC-MAPPING: AC19 | IMPLEMENTATION: [P4-T13] | TESTS: It 'allows the session-root fallback when the derived target is the session root' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC20 | IMPLEMENTATION: [P4-T7] | TESTS: Context 'folder resolution by four-segment truncation' and Context 'preserved gate behavior' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC21 | IMPLEMENTATION: [P4-T14] | TESTS: It 'prefers the derived target when it occurs later in the prompt' | EVIDENCE: evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC22 | IMPLEMENTATION: [P1-T1] | TESTS: enforce-prd-feature-before-planner.Tests.ps1 lines 212-274 via [P4-T17] | EVIDENCE: evidence/qa-gates/batch-a2-gate.md and evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC23 | IMPLEMENTATION: [P1-T2] | TESTS: PreToolUseSchema.Contract.Tests.ps1 via [P5-T5] | EVIDENCE: evidence/regression-testing/unmodified-gates.md
AC-MAPPING: AC24 | IMPLEMENTATION: [P4-T2] | TESTS: the four no-reimplementation token searches in [P4-T2] | EVIDENCE: evidence/qa-gates/no-reimplementation.md
AC-MAPPING: AC25 | IMPLEMENTATION: [P4-T2] | TESTS: [P4-T21] full Pester run | EVIDENCE: evidence/other/f1-identifier-binding.md and evidence/qa-gates/batch-d-gate.md
AC-MAPPING: AC26 | IMPLEMENTATION: [P1-T2] | TESTS: [P1-T7] extraction-only gate | EVIDENCE: evidence/regression-testing/cross-file-mock-smoke.md and evidence/qa-gates/batch-a2-gate.md
AC-MAPPING: AC27 | IMPLEMENTATION: [P1-T1] | TESTS: enforce-prd-feature-before-planner.Tests.ps1 lines 212-274 | EVIDENCE: evidence/qa-gates/batch-a2-gate.md
AC-MAPPING: AC28 | IMPLEMENTATION: [P4-T20] | TESTS: the nine delivered-file line-count measurements in [P4-T20] and the two in [P1-T6] | EVIDENCE: evidence/other/file-size-ledger.md
AC-MAPPING: AC29 | IMPLEMENTATION: [P0-T13] | TESTS: It 'observes a test-scope mock across the dot-source boundary' | EVIDENCE: evidence/regression-testing/cross-file-mock-smoke.md
AC-MAPPING: AC30 | IMPLEMENTATION: [P3-T1] | TESTS: the seven purity token searches in [P4-T19] | EVIDENCE: evidence/qa-gates/test-purity.md
AC-MAPPING: AC31 | IMPLEMENTATION: [P5-T2] and [P5-T3] | TESTS: test_bundled_claude_payload_contains_all_repo_runtime_contracts | EVIDENCE: evidence/qa-gates/batch-bc-delivery-tests.md and evidence/qa-gates/batch-e-delivery-tests.md
AC-MAPPING: AC32 | IMPLEMENTATION: [P2-T5] | TESTS: test_bundled_claude_files_are_listed_in_some_pack_manifest | EVIDENCE: evidence/qa-gates/batch-bc-delivery-tests.md
AC-MAPPING: AC33 | IMPLEMENTATION: [P2-T6] and [P2-T7] | TESTS: test_poshqc_bundled_module_files_match_repo_root_sources | EVIDENCE: evidence/qa-gates/coverage-denominator-check.md
AC-MAPPING: AC34 | IMPLEMENTATION: [P5-T6] | TESTS: the two-command change-set enumeration in [P5-T6] | EVIDENCE: evidence/regression-testing/change-set-boundary.md
AC-MAPPING: AC35 | IMPLEMENTATION: [P1-T2] | TESTS: enforcement-hooks-no-python-invocation.Tests.ps1 via [P5-T5] | EVIDENCE: evidence/regression-testing/unmodified-gates.md
AC-MAPPING: AC36 | IMPLEMENTATION: [P2-T6] and [P2-T7] | TESTS: [P6-T3] coverage-bearing Pester run | EVIDENCE: evidence/qa-gates/final-qc-test.md and evidence/qa-gates/coverage-comparison.md
AC-MAPPING: AC37 | IMPLEMENTATION: [P6-T1] through [P6-T4] | TESTS: [P6-T3] coverage-bearing Pester run | EVIDENCE: evidence/qa-gates/final-qc-format.md, evidence/qa-gates/final-qc-analyze.md, evidence/qa-gates/final-qc-test.md, evidence/qa-gates/final-qc-delivery-tests.md, evidence/qa-gates/final-qc-loop.md
AC-MAPPING: AC38 | IMPLEMENTATION: [P3-T1] | TESTS: [P4-T21] full Pester run naming the eighteen fixed It identifiers | EVIDENCE: evidence/qa-gates/batch-d-gate.md

AC-INVENTORY key: AC01 through AC38 are the thirty-eight `- [ ]` criteria in `spec.md` between the
`## Acceptance Criteria` heading at line 600 and the `## Risks & Mitigations` heading at line 671, numbered in
file order: AC01 = line 608, AC02 = 609, AC03 = 610, AC04 = 614, AC05 = 615, AC06 = 616, AC07 = 620,
AC08 = 621, AC09 = 622, AC10 = 626, AC11 = 627, AC12 = 628, AC13 = 629, AC14 = 630, AC15 = 631, AC16 = 635,
AC17 = 636, AC18 = 637, AC19 = 638, AC20 = 639, AC21 = 640, AC22 = 641, AC23 = 642, AC24 = 646, AC25 = 647,
AC26 = 651, AC27 = 652, AC28 = 653, AC29 = 654, AC30 = 655, AC31 = 659, AC32 = 660, AC33 = 661, AC34 = 662,
AC35 = 666, AC36 = 667, AC37 = 668, AC38 = 669. Evidence paths above are shown relative to
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/` and carry the `<ISO-8601>` element
stated in the task that writes them.

UNRESOLVED-GAPS: NONE
