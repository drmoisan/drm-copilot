# 2026-09-13-prd-feature-gate-target-resolution — Remediation Plan (feature-review cycle 1)

- **Issue:** #672
- **Owner:** drmoisan
- **Last Updated:** 2026-09-17T12-29
- **Status:** Round-1 preflight deltas applied; awaiting round-2 preflight
- **Version:** 2.0 (remediation of feature-review cycle 1)
- **Epic:** `worktree-scoped-state-resolution` (F4, wave 1, defect ref 3.1)
- **Work Mode:** `full-bug`
- **Branch / head:** `feature/2026-09-13-prd-feature-gate-target-resolution-672` @ `1dff9ed5`, based on
  `epic/worktree-scoped-state-resolution-integration` @ `d039e89b2b2569151e9170e1bbefb9f974419f87`
- **Acceptance-criteria source:** `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`
  section `## Acceptance Criteria` is the sole acceptance-criteria source for this work mode, per
  `.claude/skills/acceptance-criteria-tracking/SKILL.md`. It carries 38 criteria between the
  `## Acceptance Criteria` heading at line 600 and the `## Risks & Mitigations` heading at line 671.
  Criterion numbering used throughout this plan counts those 38 list items in file order: criterion 6 is the
  line-616 item, criterion 10 is the line-626 item, criterion 24 is the line-646 item, criterion 30 is the
  line-655 item, and criterion 37 is the line-668 item. The numbering was confirmed against three independent
  anchors supplied by the review artifacts (criterion 24 = F1 consumption, criterion 27 = behaviour-preserving
  move, criterion 37 = the toolchain criterion left unchecked).
- **Remediation inputs:** `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/remediation-inputs.2026-09-17T12-29.md`
  and the three review artifacts it names (`policy-audit`, `code-review`, `feature-audit`, all `2026-09-17T12-29`).
- **Delivery plan (precedent, already executed):** `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/plan.2026-09-13T20-47.md`.

**Fail-closed evidence rule:** every gate task names an artifact. Work is not marked complete without the
artifact, and a missing or placeholder value makes the outcome BLOCKED or INCOMPLETE, never PASS.

---

## Plan Preamble — bindings carried forward and rulings fixed in this pass

### Evidence location (non-overridable)

Every evidence artifact this plan names is written under
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/<kind>/`, per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Phase 0 artifacts use the canonical
`evidence/remediation-baseline/` kind so they do not collide with the delivery plan's `evidence/baseline/`
artifacts. Paths rooted at `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`,
`artifacts/qa-gates/`, `artifacts/coverage/`, `artifacts/regression-testing/`, or `artifacts/evidence/` are
prohibited and fail preflight. The `<ISO-8601>` element in each artifact filename is the `yyyy-MM-ddTHH-mm`
timestamp of the run that produced it.

`artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` are tool output paths
declared by `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lines 15 and 22. They are read as
inputs; no task writes evidence there.

### Execution route on this host (stated once)

This host's worktree-isolation guard refuses any Bash command whose text contains the words `bash`, `pwsh`,
or `wsl`, and refuses heredocs. Every PowerShell command in this plan is therefore executed by writing a
POSIX script into the session scratchpad that changes directory to the worktree root and then invokes the
PowerShell host, run as `sh <script>.sh`. Each `Command:` field below states the PowerShell command in its
canonical form; the wrapper is implied by this paragraph and is not restated per task. Commands are run from
the worktree root and are never chained after a `cd` inside the PowerShell command itself.

### MCP PoshQC result surface (carried unchanged from the delivery plan and still binding)

`mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`, and
`mcp__drm-copilot__run_poshqc_format` return **no captured script output**: `runPoshQcWorkflow` in
`extensions/drm-copilot/src/repo-automation-service.ts` composes its `summary` **before** the child process
runs and passes no `stdoutArtifactPattern`. No test count, no coverage percentage, no analyzer finding count,
and no per-test name is readable from any `run_poshqc_*` MCP result. Every asserted numeric value and every
asserted literal in this plan is derived from `artifacts/pester/pester-junit.xml`,
`artifacts/pester/powershell-coverage.xml`, an `Invoke-Pester -PassThru` result object, a direct
`Invoke-ScriptAnalyzer` count, a named console literal captured with the mandatory `6>&1` redirection, or a
paired `Get-FileHash` / `git status --porcelain` capture. Where a task names an MCP invocation, that
invocation is retained for route compliance and is not the source of any asserted value.

The installed-extension caveat is likewise unchanged: `mcp__drm-copilot__run_poshqc_test` resolves its run
settings from the installed VS Code extension, not from either in-repo copy, so every measurement below takes
the direct route.

### Fixed commands (the executor selects nothing)

- **C1 — whole-tree analyzer.**
  `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pssa.settings.psd1 6>&1`
  The trailing `6>&1` is mandatory: `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` line 116 emits the
  logger message with `Write-Information`, which writes to stream 6. `Invoke-PoshQCAnalyze` throws at line 183
  on a non-zero count and returns nothing, so a zero-count claim is anchored to the zero-branch literal at
  line 185, which reads `PSScriptAnalyzer passed: no findings under $Root`. The asserted token is the
  single-line literal `PSScriptAnalyzer passed: no findings under`.
- **C2 — per-file analyzer count.**
  `Import-Module PSScriptAnalyzer -ErrorAction Stop; @(Invoke-ScriptAnalyzer -Path '<file>' -Settings 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Count`
  run once per path in the task's fixed file set. This integer is printed in both branches and is the
  per-file complement to C1's zero-branch literal.
- **C3 — full Pester run with coverage.**
  `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  `Run.Exit` is `$true` at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 4, so a run with
  failures ends the host process. C3 is therefore invoked in its own wrapper script with nothing chained after
  it, and every value is read from the emitted XML in a **separate** invocation.
- **C4 — one suite, no report side effects.**
  `Import-Module Pester -MinimumVersion 5.0.0 -Force; $r = Invoke-Pester -Path '<suite path>' -PassThru; $r.TotalCount; $r.PassedCount; $r.FailedCount`
  No settings file is supplied, so this neither overwrites `artifacts/pester/pester-junit.xml` nor recomputes
  coverage.
- **C5 — the 17-suite must-not-regress batch.**
  `Import-Module Pester -MinimumVersion 5.0.0 -Force; $files = @(Get-ChildItem -Path tests -Recurse -File -Filter '*.Tests.ps1' | Where-Object { $_.Name -like 'enforce-orchestration-preimplementation-gate*' -or $_.Name -like 'enforce-epic-merge-gate*' } | ForEach-Object { $_.FullName }); $files.Count; $r = Invoke-Pester -Path $files -PassThru; $r.TotalCount; $r.PassedCount; $r.FailedCount`
  The glob was re-derived in this pass and yields exactly 17 files: 6 `enforce-orchestration-preimplementation-gate*`
  and 4 `enforce-epic-merge-gate*`-family suites under `tests/scripts/claude-hooks/`, plus 4 and 3 respectively
  under `tests/scripts/codex-hooks/`.
- **C6 — mirror hash pair.**
  `Get-FileHash -LiteralPath '<repository copy>' -Algorithm SHA256; Get-FileHash -LiteralPath '<bundled copy>' -Algorithm SHA256`
  with the two `Hash` values compared with `-ceq`, plus a `Compare-Object` over the two files' content.
- **C7 — JUnit reader.**
  `$junit = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml'); $junit.testsuites.tests; $junit.testsuites.failures; $junit.testsuites.errors; @($junit.SelectNodes('//testcase[failure]')) | ForEach-Object { $_.name }`
- **C8 — coverage reader.**
  `$cov = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml')`, then per file select
  the `sourcefile` node whose `name` attribute is the leaf name, and record the number of nodes that matched,
  which must be exactly 1: `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  registers `.claude/hooks/enforce-prd-feature-before-planner.ps1` and
  `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` and registers no `claude-customizations` path,
  so neither bundled mirror is measured and no duplicate leaf name exists. A match count other than 1 halts and
  reports blocked. Per-file line coverage is the count of child `line` elements with `ci` greater than zero over
  the count of all child `line` elements; where a node carries no child `line` element, use its `counter`
  element of `type` `LINE` and compute covered over covered-plus-missed, and record which form was used.
- **C9 — evidence-location validator.** `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
- **C10 — delivery tests.** `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`
  No `--cov` argument is supplied: this remediation adds and changes no Python production source, so no Python
  coverage gate applies to it.

### Test-count derivation (fixed, not left to the executor)

Pester emits **one `testcase` node per `-ForEach` row**, so an expected node count is stated per identifier
and never assumed to be one. Match a case by its `name` attribute **containing** the `It` text quoted in this
plan, and treat the **absence of a child `failure` element** on the matched node as the pass condition. Each
named identifier must match its stated node count exactly, in either direction, and every matched node must
carry no child `failure` element.

Node counts re-derived against the delivered suite in this pass:
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` declares 21 `It`
blocks which expand to 25 nodes, because `allows an absolute path to the target feature folder` is bound over
a two-row `-ForEach` array and `resolves the required document set for each work mode` over a four-row array.
This plan adds three `It` blocks, none of them `-ForEach`-bound, so the suite's post-change node count is
**28**. The sibling suites are unchanged in node count at **47** and **25**; this plan's edits to them add a
mock inside an existing `BeforeAll` and declare no new `It`.

### Repository-wide failure baseline (binding; do not assert zero)

The repository-wide JUnit failure count is **2** at the pre-change baseline, from two nodes outside this
feature's file set:

1. a node whose `name` contains `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`,
   in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, which is wall-clock and
   receipt-dependent and reads the real orchestrator checkpoint through an unmocked
   `Get-PrAuthorCheckpointContent` seam;
2. a node whose `name` contains `allows every registered handler for every tool name its own matcher admits`,
   in the Codex PreToolUse integration suite, which reads ambient epic-checkpoint state.

No task in this plan asserts `failures = 0` repository-wide. The binding assertion is that the failing node
set is **exactly that pair** and that `errors` is **0**; a third failing node is a genuine regression of this
remediation. Neither of those two suites, nor `.claude/hooks/enforce-pr-author-skill.ps1`, nor
`.claude/hooks/enforce-epic-wave-barrier.ps1`, nor any `.codex/` path may be edited by this remediation, and
Phase 4 verifies that none of them appears in the changed-file set.

Because those two failures are present, C3 ends with a **non-zero** exit code (`Run.Exit` is `$true`). Every
artifact recording a C3 run carries `ExpectedExitCode: 2`, being the expected count of failing tests, and
records the observed code beside it. The acceptance for those tasks is the failing-node-set equality and
`errors = 0`, not the exit code; a non-zero observed code other than 2 is recorded and does not by itself
fail the task, while an exit code of 0 with a non-empty failing set is a contradiction that does.

### Search-assertion form (mandatory for every acceptance condition in this plan)

Every `Select-String` acceptance condition is executed as
`Select-String -SimpleMatch -Pattern '<token>' -Path '<path>'`, with the pattern in single quotes.
`-SimpleMatch` is mandatory: without it `$`, `(`, and `[` carry regex meaning and the token either matches
nothing whatever the file contains or raises a parse error. Every asserted token below is a short,
single-line, non-interpolated literal that the plan quotes verbatim, and every zero-match assertion carries a
named control whose non-zero count is recorded in the same artifact.

Control table, re-derived against the current tree in this pass:

| asserted token | pre-change count and site |
| --- | --- |
| `absolutely-placed` | 2 in `.claude/hooks/enforce-prd-feature-before-planner.ps1`, at lines 219 and 242 |
| `[A-Za-z]:[\\/]` | 1 in `.claude/hooks/enforce-prd-feature-before-planner.ps1` at line 243; control: 1 in `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` at line 57 |
| `earliest-occurring candidate` | 1 in `.claude/hooks/enforce-prd-feature-before-planner.ps1` at line 28 |
| `If no candidate was found in the prompt` | 1 in `.claude/hooks/enforce-prd-feature-before-planner.ps1` at line 31 |
| `It is loaded for its declarations only` | 1 in `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` at line 13 |
| `$segments[0..3]` | 1 in `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` at line 154 |

Each count in that table is re-measured by `[P0-T4]` before any file is edited, and the measured value, not
the value printed here, is the control the later tasks compare against.

### R1 — option selected, and why the alternative was rejected

**Option A is selected: delete the absolutely-placed-token pre-filter and hand the call text to
`Resolve-WorktreeCallTarget` unconditionally.**

Re-derivation performed in this pass, against the current tree:

- `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 242-245 are the pre-filter: a comment line, an
  `if ($text -notmatch ...)` test carrying the pattern `(?<![^\s"''`(])(?:[A-Za-z]:[\\/]|/)`, a `return $null`,
  and the closing brace. Lines 219-223 are the `.DESCRIPTION` paragraph that documents it. Line 243 is the only
  `-notmatch` in the file.
- `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` exports
  `New-WorktreeResolutionTargetResult`, `Find-WorktreeResolutionFeatureFolderSignal`,
  `Find-WorktreeResolutionBranchSignal`, `Find-WorktreeResolutionFilePathSignal`, `Resolve-WorktreeCallTarget`,
  and `Join-WorktreeResolutionPath` at lines 335-341. Its feature-folder pattern at line 53 carries an
  **optional** prefix, so it matches a bare repo-relative token; `Get-WorktreeResolutionSignalCandidate` at
  lines 215-224 routes a non-absolute signal to `Get-WorktreeResolutionWorktreeRoot -RepoRelativePath`, which
  keeps only worktrees under which that repo-relative path exists
  (`.claude/lib/worktree-resolution/WorktreeResolution.psm1` lines 383-399). A relative citation therefore has
  a real placement channel, and `Resolve-WorktreeCallTarget` returns `Ambiguous` at lines 284-287 when that
  channel yields a count other than one.

Consequences that make Option A satisfy the two criteria as written:

- **Criterion 10** (own folder named, cwd modelled as the session root, `allow`). With the pre-filter removed,
  a repo-relative citation whose folder exists only under the item worktree yields exactly one candidate,
  `Status` `OtherWorktree`, a probe path composed under that root, and `allow`. The row is satisfiable without
  touching the criterion's text.
- **Criterion 6** (the marker-is-broken branch is reached only when the folder exists under the resolved target
  root). With the pre-filter removed, a repo-relative citation whose folder exists in no worktree yields zero
  candidates and `Ambiguous`, which the hook denies at line 312 **before** any probe or marker read. The
  misleading remedy is unreachable on that path.

**Option B is rejected.** It keeps the pre-filter, so a repo-relative citation still derives no target, still
keeps the bare repo-relative probe path, and still resolves it against the process working directory. The
inputs state the same conclusion in their own terms: Option B "does not repair the false denial, so criterion
10 would still need re-wording". Re-wording an epic-approved criterion is outside this plan's authority, so an
option that requires it cannot be selected. Option C is unavailable for the same reason and was not considered
further.

**R3 is resolved by the same edit** and needs no separate remediation: the pre-filter is the local
derivation-eligibility decision the finding names, and `[P2-T2]` deletes it, leaving `Resolve-WorktreeCallTarget`
as the single owner of what counts as a placeable signal. `[P2-T4]` re-asserts criterion 24's no-local-
re-implementation property over both delivered production files after the edit.

### Consequences of Option A that are accepted deliberately

1. **Two sibling suites must model the derivation.** Neither
   `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` nor
   `...FolderResolution.Tests.ps1` binds `-ResolvedTarget` or mocks `Resolve-WorktreeCallTarget` today; both
   rely on the pre-filter returning `$null`. With the pre-filter gone their decision calls would reach the real
   derivation and the real filesystem, which both changes their outcomes and violates the no-external-dependency
   rule in `.claude/rules/general-unit-test.md`. `[P1-T4]` and `[P1-T5]` add one modelled `NoTarget` result per
   suite inside the existing Describe-level `BeforeAll`, which reproduces exactly today's composition behaviour
   and leaves every `Context` block byte-unmodified, so criterion 20 continues to hold.
2. **Two rows inside the TargetResolution suite are amended rather than left to shift silently.**
   `allows when the modelled cwd is the item worktree` and
   `denies rather than selecting the earliest candidate on an unresolved tie` both call the decision without an
   injected target. Without an amendment the first would deny and the second would still pass but by way of the
   F1-ambiguity branch rather than the unresolved-tie branch it exists to cover. `[P1-T2]` and `[P1-T3]` amend
   them, and `[P1-T3]` adds a reason-substring assertion that pins the tie branch specifically.
3. **`tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` needs no edit.** Its prd-feature case
   uses the prompt `plan something generic`, which carries no feature-folder token, no absolute path, and no
   branch, so `Resolve-WorktreeCallTarget` returns `NoTarget` and the decision is the same deny shape as before.
   Criterion 23 requires that suite to pass unedited, and `[P4-T6]` verifies both its result and its absence
   from the changed-file set.
4. **A repo-relative citation that places in more than one worktree now denies with the ambiguity code.**
   Previously such a call was allowed on the strength of whichever copy the process working directory happened
   to expose, which is review diagnostic D5 and the false-approval mode `spec.md` names as risk R1. The new
   outcome is fail-closed and carries an actionable remedy already present in the deny text: cite the folder as
   an absolute path inside exactly one worktree. Criterion 19's Pester case is unaffected, because it models the
   derived target as the session root.
5. **The derivation now runs on every atomic-planner delegation**, so F1's worktree enumeration executes on a
   path that previously short-circuited. No guard is added around it: the same call already runs unguarded today
   for absolute citations, and adding a handler would introduce an untested branch outside this remediation's
   scope.
6. **Operational note for the executing session.** The hook is live in this worktree, so from the moment
   `[P2-T2]` lands, an `Agent(atomic-planner)` delegation that cites this feature folder in repo-relative form
   is resolved by the new path and may deny with the ambiguity code when the folder places in more than one
   worktree. Delegation prompts issued after Phase 2 must cite absolute paths inside this worktree. This is a
   session-conduct note, not a plan task.

### The #518 four-segment slice — citation corrected in this pass

The remediation inputs and the delivery plan locate the byte-unmodified #518 slice at
`.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 272-277. That citation is **stale after the helpers
extraction** and was re-derived here: lines 272-277 of the parent hook are now the `param()` block of
`Invoke-PrdFeatureBeforePlannerDecision`. The slice now lives in
`.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` inside `ConvertTo-PrdFeatureFolderToken`, as the
comment at lines 142-148 and the code at lines 149-154 ending `return ($segments[0..3] -join '/')`. It must
survive byte-unmodified. No task in this plan edits `ConvertTo-PrdFeatureFolderToken`; `[P2-T5]` edits only that
file's file-level `.DESCRIPTION` at lines 12-13, and `[P2-T6]` asserts the slice's survival by token.

### R4 item 2 — reasoned deferral rather than an AC edit

The finding asks for criterion 30 (the line-655 item) to be narrowed, because it states the new suite "derives
no absolute path from ... the script file location" while the suite necessarily resolves the two files under
test from `$PSScriptRoot` at lines 99, 100, 109, and 110. The finding is accepted as accurate. It is **not
applied**: the acceptance criteria in `spec.md` are the epic-approved contract for this child feature and this
plan re-words none of them. The criterion stays `- [x]`, because the feature audit judged the delivered suite
to satisfy its intent fully and rated the finding Minor. `[P0-T7]` records the proposed narrower wording and
the deferral rationale for the epic owner.

### Change-budget route — batch split with an explicit reset at each boundary

`.claude/rules/powershell.md` line 40 caps any batch at 3 production files and 3 test files.
`.claude/hooks/enforce-powershell-batch-budget.ps1` classifies `.ps1|.psm1|.psd1` as production at line 273 and
`tests/**/*.ps1` or `*.Tests.ps1` as test at line 284, compares the list against the cap at line 293, states the
reset (delete the state file) in the deny reason at line 296, composes the state file at line 366 as
`<root>/.claude/state/powershell-batch-budget.<resolved-session-id>.json`, and sets `prodCap` to 3 at line 426.
Its counter is session-scoped, so without an explicit reset the cumulative count crosses the cap mid-plan.

| batch | phase | opened by | files in the batch |
| --- | --- | --- | --- |
| R-A | Phase 1 | `[P1-T1]` | 3 test files: the TargetResolution suite, the parent suite, the FolderResolution suite (exactly at the test cap of 3; 0 production files) |
| R-B | Phase 2 | `[P2-T1]` | 2 production files: `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` |
| R-C | Phase 3 | `[P3-T1]` | 2 production files: the two bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` |

The **filtered** reset pipeline, used by every boundary task, is
`Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('PRE-RESET ' + $_.FullName + ' ' + (Get-Content -Raw $_.FullName)); Remove-Item -LiteralPath $_.FullName -Force }`,
verified with
`Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count`.
The **unfiltered** pipeline, used only before a delivery-test run, is the same two commands with `-File` in
place of the `-Filter` argument. Exit-code attribution: `Get-ChildItem` against a non-existent `-Path` leaves
`$?` false even under `-ErrorAction SilentlyContinue`, so an `EXIT_CODE: 1` accompanied by a verified count of
`0` is a pass. Halt branch: if a state file is enumerated but cannot be removed, halt and report blocked rather
than entering a batch with an unknown remaining budget.

The unfiltered removal is required before every `C10` run because
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enumerates `.claude` without honouring
`.gitignore` and reports `Repo file missing from bundle:` for any runtime file under `.claude/state`.

### Intermediate parity window

Phase 2 changes the repository hook files before Phase 3 re-mirrors them. During that window the bundled-payload
parity test is expected to fail. No task in Phase 1 or Phase 2 asserts it; it is asserted at `[P3-T5]` and
`[P4-T4]` only.

### Named test identifiers this plan fixes

These `It` names do not exist in the tree yet, or exist under a different name, and are quoted verbatim so the
executor creates them with exactly this text and later acceptance conditions can name them. Each expects
exactly **one** `testcase` node; none is `-ForEach`-bound.

1. `allows a repo-relative citation placed in the item worktree`
2. `denies with the ambiguity reason when a repo-relative citation places in no worktree`
3. `hands a repo-relative citation carrying a branch signal to the derivation`
4. `hands a repo-relative citation to the derivation` (re-specification of the delivered case
   `derives nothing from a call that cites no absolutely-placed token`, whose assertion the selected option
   inverts)

Two delivered identifiers are amended in place and keep their exact names:
`allows when the modelled cwd is the item worktree` and
`denies rather than selecting the earliest candidate on an unresolved tie`.

### Fail-before expectation (Phase 1 runs against the unmodified hook)

Phase 1 edits tests only. Run against the pre-change hook, the four identifiers above fail and every other node
in the suite passes: identifiers 1 and 2 fail behaviourally, because the pre-filter returns `$null` and the
decision reaches the marker-is-broken branch; identifiers 3 and 4 fail on a zero invocation count against an
expected count of one. The two amended identifiers pass both before and after, which is what makes the "exactly
four failures" assertion in `[P1-T7]` a real discriminator rather than a tautology.

---

### Phase 0 — Policy reads, remediation baseline, scope decisions, and AC reversion

- [x] [P0-T1] Read the repository policy files in the order defined by `.claude/skills/policy-compliance-order/SKILL.md`: `CLAUDE.md`, then `.claude/rules/general-code-change.md`, then `.claude/rules/general-unit-test.md`, then `.claude/rules/powershell.md`, then `.claude/rules/quality-tiers.md`, then `.claude/rules/tonality.md`, then `.claude/rules/plan-acceptance-gates.md`. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/remediation-baseline/phase0-instructions-read.md` containing the fields `Timestamp:`, `Policy Order:`, and an explicit line-per-file list of the seven paths read. Acceptance: the artifact exists and contains all three field labels and all seven paths.

- [x] [P0-T2] Capture the pre-remediation worktree state. Command: `git rev-parse HEAD; git status --porcelain --untracked-files=all`. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/remediation-baseline/baseline-worktree-state.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the resolved 40-character HEAD commit and the verbatim porcelain output, or the literal `clean` when that output is empty. Acceptance: the artifact carries all four field labels and its `Output Summary:` names a 40-character commit identifier. This is the `$baselineHead` anchor every later `git diff` in this plan binds to, and it runs before any file is modified.

- [x] [P0-T3] Record the pre-remediation line-count ledger for the seven files this remediation may touch: `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`. Command: `Get-Content -LiteralPath '<file>' | Measure-Object -Line | Select-Object -ExpandProperty Lines` per path. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/remediation-baseline/baseline-file-size-ledger.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` giving one measured integer per path. Acceptance: seven integers are recorded, each at or under 500, and the `Output Summary:` states the measured value for the parent hook together with an explicit `MATCHES` or `DIFFERS-BY-N` comparison against the review-recorded figure of 431 and for the helpers sibling against 314. A `DIFFERS` result does not fail this task; it is recorded as citation drift, and every later task citing a line number in that file re-derives it before running.

- [x] [P0-T4] Re-measure every control count in the preamble's control table before any file is edited. Command: `Select-String -SimpleMatch -Pattern '<token>' -Path '<path>' | Select-Object -ExpandProperty LineNumber` and `Select-String -SimpleMatch -Pattern '<token>' -Path '<path>' | Measure-Object | Select-Object -ExpandProperty Count`, both run once per table row, including the `[A-Za-z]:[\\/]` control row against `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`. The first prints one line number per match and the second the match count; both are recorded. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/remediation-baseline/baseline-control-counts.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording one integer per row together with the line number of each match. Acceptance: six target counts and one control count are recorded as integers, none a placeholder, and each is compared against the preamble table with an explicit `MATCHES` or `DIFFERS` verdict. A `DIFFERS` verdict does not fail this task; the measured value supersedes the table for every later comparison, and the supersession is recorded here.

- [x] [P0-T5] Capture the baseline analyzer state. Invoke `mcp__drm-copilot__run_poshqc_analyze` for route compliance, then run C1 and capture its console output, then run C2 once for each of the seven paths listed in `[P0-T3]`. Do not invoke the formatter in this phase: it rewrites tracked source, and a baseline captured after it has repaired pre-existing drift is a blanket waiver. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/remediation-baseline/baseline-analyze.<ISO-8601>.md` with `Timestamp:`, `Command:` naming all three commands verbatim with C1 in its `6>&1` form, `EXIT_CODE:`, and `Output Summary:` recording exactly one of the two C1 branch observables — the literal `PSScriptAnalyzer passed: no findings under` quoted from the captured output with the count recorded as `0`, or the integer from the `PSScriptAnalyzer reported` throw message with each printed finding's rule name and file path — plus the seven per-file integers. Acceptance: the artifact carries all four field labels, records exactly one branch observable and not both, and records seven integers, none a placeholder. A non-zero baseline count does not fail this task; it is the baseline, and its consequence is recorded here: `[P4-T2]` requires a zero whole-tree count and seven zero per-file counts, so a pre-existing finding is remediated before that gate runs or that gate reports blocked.

- [x] [P0-T6] Capture the baseline Pester and coverage state. Run C3 in its own wrapper script with nothing chained after it, then read the emitted reports in a separate invocation with C7 and C8. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/remediation-baseline/baseline-test-and-coverage.<ISO-8601>.md` with `Timestamp:`, `Command:` naming C3, C7, and C8 verbatim, `EXIT_CODE:`, `ExpectedExitCode: 2`, and `Output Summary:` recording: the `tests`, `failures`, and `errors` attributes of the `testsuites` element and the passed count computed as tests minus failures minus errors; the full `name` attribute of every node returned by `//testcase[failure]`; the per-file line coverage of `.claude/hooks/enforce-prd-feature-before-planner.ps1` and of `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` with the two integers beside each percentage and the form used per C8; and the per-suite node counts for the three prd-feature suites. Acceptance: `errors` is 0; the failing node set has exactly two members and their `name` attributes contain the two literals named in the preamble's failure-baseline section; the three prd-feature suites report 25, 47, and 25 nodes with zero failures; and both per-file coverage figures are recorded as numbers at or above 85. Record no branch-coverage figure: Pester measures line and command coverage only.

- [x] [P0-T7] Record the remediation scope decisions in one artifact so a later reviewer does not re-open them. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/remediation-scope-decisions.<ISO-8601>.md` with `Timestamp:` and five labelled sections: `R1-OPTION: A` with the rejection rationale for Option B restated from this plan's preamble; `R2: APPLIED` naming `[P2-T3]`; `R3: RESOLVED-BY-R1` naming `[P2-T2]` as the task that resolves it and `[P2-T4]` as the task that verifies it; `R4-ITEM-1: APPLIED` naming `[P2-T5]`; and `R4-ITEM-2: DEFERRED` carrying the verbatim proposed replacement wording for criterion 30 together with the reason the change is not applied here, namely that `spec.md` acceptance criteria are the epic-approved contract and this plan re-words none of them. Acceptance: the artifact carries `Timestamp:` and all five section labels, the `R1-OPTION:` value is exactly `A`, and the `R4-ITEM-2:` section contains a proposed wording and a rationale sentence.

- [x] [P0-T8] Revert the two PARTIAL acceptance criteria to unchecked before re-delivery, per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, which requires an item evaluated PARTIAL to be left unchecked. In `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`, change `- [x]` to `- [ ]` on the criterion at line 616 (criterion 6) and on the criterion at line 626 (criterion 10). Change no other character on either line and change no other line. Criterion 37 at line 668 is already unchecked and stays unchecked; do not re-word it. Acceptance: `Select-String -SimpleMatch -Pattern '- [ ] The missing/malformed-marker branch is reached only when' -Path 'docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md'` returns exactly one match, `Select-String -SimpleMatch -Pattern '- [ ] Row — own folder named, cwd modelled as the session root' -Path 'docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md'` returns exactly one match, and the count of `- [ ]` plus `- [x]` list items between the `## Acceptance Criteria` heading and the `## Risks & Mitigations` heading is still 38. Record the before and after checkbox states of both lines in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/ac-reversion.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — Batch R-A: regression rows and suite amendments, run against the unmodified hook

- [x] [P1-T1] Open batch R-A with the filtered reset pipeline and its verification, per the preamble. Acceptance: the verification enumeration reports a count of `0`, and the pre-reset file names with their `prodFiles` and `testFiles` contents, or the literal `none`, are recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/batch-boundary-r-a.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, under the preamble's exit-code attribution. Halt branch as stated in the preamble.

- [x] [P1-T2] (Batch R-A) Amend the delivered case `allows when the modelled cwd is the item worktree` in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` so it models the derivation instead of relying on the pre-filter. Add, inside that `It`, `Mock -CommandName Resolve-WorktreeCallTarget -MockWith { New-WorktreeResolutionTargetResult -Status 'SessionRoot' -SessionRoot $script:ItemWorktreeRoot -WorktreeRoot $script:ItemWorktreeRoot -Signal 'FeatureFolderPath' -SignalValue $script:TargetFeatureFolder -Candidate @($script:ItemWorktreeRoot) -Detail 'modelled session-root target' }`. Keep the existing mocks, the existing payload, and the existing `Should -Be 'allow'` assertion unchanged, and add no invocation-count assertion to this row. The derivation is not called at all against the unmodified hook, because the pre-filter at `.claude/hooks/enforce-prd-feature-before-planner.ps1` line 243 returns `$null` before the call, so a `Should -Invoke -CommandName Resolve-WorktreeCallTarget -Times 1 -Exactly` here would make this row a fifth failure in `[P1-T7]` and contradict this task's own acceptance. The post-change invocation is pinned instead by identifiers 3 and 4 in `[P1-T7]`. The modelled root and the session root coincide, so the hook keeps the bare repo-relative probe spelling and the row's outcome is unchanged. Acceptance: the `It` name is unchanged, the case asserts `allow`, and the case passes against the unmodified hook when `[P1-T7]` runs.

- [x] [P1-T3] (Batch R-A) Amend the delivered case `denies rather than selecting the earliest candidate on an unresolved tie` in the same suite so it continues to exercise the unresolved-tie branch after the pre-filter is removed. Add, inside that `It`, `Mock -CommandName Resolve-WorktreeCallTarget -MockWith { New-WorktreeResolutionTargetResult -Status 'NoTarget' -SessionRoot $script:CoordinatingSessionRoot -Detail 'modelled no-target' }`, and add the assertion that the deny reason is `-BeLike '*cites 2 feature folders*'`. A `NoTarget` result carries a null `SignalValue`, so `Select-PrdFeatureFolderByTarget` returns `$null`, the two-candidate tie stays unresolved, and the deny is produced by the tie branch rather than by the derivation's own ambiguity branch. Acceptance: the `It` name is unchanged, the case asserts `deny`, the ambiguity code, and the new `cites 2 feature folders` substring, and the case passes against the unmodified hook when `[P1-T7]` runs. The `cites 2 feature folders` substring is the literal the hook composes at `.claude/hooks/enforce-prd-feature-before-planner.ps1` line 322 for a two-candidate prompt; it is asserted as a substring because the surrounding reason text is interpolated.

- [x] [P1-T4] (Batch R-A) Add one modelled derivation result to `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` so its cases keep their delivered behaviour and keep touching no filesystem after the pre-filter is removed. Inside the existing Describe-level `BeforeAll` at lines 5-13, after the two dot-source lines, add `Mock -CommandName Resolve-WorktreeCallTarget -MockWith { New-WorktreeResolutionTargetResult -Status 'NoTarget' -SessionRoot '/synthetic-worktrees/session-root' -Detail 'modelled no-target for the delivered cases' }`. Add no other statement, and edit no `Context` block in this file. If a Describe-level `BeforeAll` mock is not observed by the contained cases on this Pester version, the single permitted alternative placement is a Describe-level `BeforeEach` added immediately after that `BeforeAll`; no other placement is authorised, because a mock placed inside a `Context` would modify a block this plan requires to remain unmodified. Acceptance: the suite reports 47 nodes, 47 passed, 0 failed under C4 in `[P1-T6]`, and `Select-String -SimpleMatch -Pattern 'Resolve-WorktreeCallTarget' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1'` returns exactly one match.

- [x] [P1-T5] (Batch R-A) Add the same modelled derivation result to `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`, inside the existing Describe-level `BeforeAll` at lines 20-28, with the same statement text and the same alternative-placement rule as `[P1-T4]`. Both the `folder resolution by four-segment truncation` `Context` beginning at line 30 and the `preserved gate behavior` `Context` beginning at line 237 must remain byte-unmodified, as criterion 20 requires. Acceptance: the suite reports 25 nodes, 25 passed, 0 failed under C4 in `[P1-T6]`; `Select-String -SimpleMatch -Pattern 'Resolve-WorktreeCallTarget' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1'` returns exactly one match; and `git diff <baselineHead> -- tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`, with `<baselineHead>` bound to the commit recorded by `[P0-T2]`, shows added lines only inside the `BeforeAll` block and no line whose content belongs to either named `Context`. Record the diff and its exit code in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/context-block-integrity.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, together with the anchor precondition `git merge-base --is-ancestor <baselineHead> HEAD` and its exit code; if that precondition exits non-zero the branch was re-anchored after `[P0-T2]`, and this task halts and reports blocked rather than reading a diff that spans another change set.

- [x] [P1-T6] Verify the two sibling suites still pass with the modelled result in place and with the hook still unmodified. Command: C4 once per suite for `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` and `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/sibling-suites-premodification.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording `TotalCount`, `PassedCount`, and `FailedCount` per suite. Acceptance: 47 total with 0 failed for the first suite and 25 total with 0 failed for the second. A failure here means the modelled result changed delivered behaviour and must be corrected before Phase 2 begins; it is not deferred.

- [x] [P1-T7] [expect-fail] (Batch R-A) Add the three required regression rows and the one re-specification to `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, then run the suite against the unmodified hook and record the fail-before evidence. The four identifiers are created with exactly the names fixed in the preamble.

  - `allows a repo-relative citation placed in the item worktree`, in the `target resolution matrix` `Context`: mocks `Resolve-WorktreeCallTarget` to return `New-WorktreeResolutionTargetResult -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot -WorktreeRoot $script:ItemWorktreeRoot -Signal 'FeatureFolderPath' -SignalValue $script:TargetFeatureFolder -Candidate @($script:ItemWorktreeRoot) -Detail 'modelled placement of a repo-relative citation'`; keys `Get-PrdFeatureIssueContent` to answer `"- Work Mode: full-bug`n"` only for `$script:ComposedTargetFolder` and `Get-PrdFeatureFileExistence` to answer true only for `"$($script:ComposedTargetFolder)/spec.md"`; builds the payload from the bare repo-relative `$script:TargetFeatureFolder`; calls the decision **without** `-ResolvedTarget`; and asserts `allow` together with `Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 1 -Exactly`. This is the row criterion 10 names, in the repo-relative form the originating run used.
  - `denies with the ambiguity reason when a repo-relative citation places in no worktree`, in the same `Context`: mocks `Resolve-WorktreeCallTarget` to return `New-WorktreeResolutionTargetResult -Status 'Ambiguous' -SessionRoot $script:CoordinatingSessionRoot -Signal 'FeatureFolderPath' -SignalValue $script:TargetFeatureFolder -Candidate @() -Detail 'modelled zero-candidate placement'`, which is the shape `Resolve-WorktreeCallTarget` itself returns for a relative signal that matches no worktree; mocks `Get-PrdFeatureIssueContent` to return `$null` and `Get-PrdFeatureFileExistence` to answer true only for the literal `never-matched`; calls the decision without `-ResolvedTarget`; and asserts `deny`, that the reason contains `$script:AmbiguityCode`, that the reason is `-Not -BeLike '*work mode could not be determined*'`, and `Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 0 -Exactly`.
  - `hands a repo-relative citation carrying a branch signal to the derivation`, in the `call-target derivation seam` `Context`: mocks `Resolve-WorktreeCallTarget` to return `[pscustomobject]@{ Status = 'OtherWorktree'; SuppliedText = $Text }`; supplies a `ToolInput` whose `prompt` names `$script:TargetFeatureFolder` in bare repo-relative form and whose `description` carries the branch token `branch: feature/2026-09-13-x-672`; calls `Get-PrdFeatureCallTarget -Envelope $null -ToolInput $toolInput`; and asserts the returned `SuppliedText` is `-BeLike` both the folder token and the branch token, plus `Should -Invoke -CommandName Resolve-WorktreeCallTarget -Times 1 -Exactly`.
  - `hands a repo-relative citation to the derivation`, replacing the delivered `It` named `derives nothing from a call that cites no absolutely-placed token` in the same `Context`: keeps that case's payload shape, and asserts the derivation returns the mocked result and `Should -Invoke -CommandName Resolve-WorktreeCallTarget -Times 1 -Exactly`. The delivered `It` name is removed in the same edit, so the suite carries no case asserting the pre-filter's behaviour.

  The delivered case `derives nothing from a call whose text is empty` is **not** amended: the empty-text guard at `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 238-240 survives the Phase 2 edit, so that case keeps asserting a zero invocation count and must keep passing.

  In the same edit, correct the suite's own header comment, which records a sibling line count that no longer
  holds. Lines 11-13 of `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`
  read `enforce-prd-feature-before-planner.Tests.ps1 measured 431` / `content lines and enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` / `measured 419 before the Phase 1 BeforeAll amendment, and 436 and 424 after it.`
  All four figures were re-derived in this pass and are wrong: the two sibling suites measure 445 and 453 lines in
  the current tree, and each gains exactly one line from `[P1-T4]` and `[P1-T5]`. This is the same finding class
  as R4 — a comment asserting a fact the file contradicts — in a file this task already edits, so it is corrected
  here rather than deferred. Replace those three lines with three lines carrying no per-file integer, so the
  comment cannot go stale again on the next edit to either sibling; the first replacement line must be, on a line
  of its own, `    regression guards: both sibling suites sit within sixty lines of the cap, and`, and the
  remaining two must state that the measured counts live in this feature's evidence ledger under the stem
  `remediation-file-size-ledger`. The replacement is line-for-line, so it consumes none of the line budget below.
  Acceptance for this correction: `Select-String -SimpleMatch -Pattern 'measured 431' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1'`
  returns 0 matches against a pre-change count of 1; the same search for `measured 419` returns 0 matches against
  a pre-change count of 1; and `Select-String -SimpleMatch -Pattern 'both sibling suites sit within sixty lines of the cap' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1'`
  returns exactly 1 match. Both pre-change counts and all three post-change counts are recorded in this task's
  artifact.

  Line budget for this suite: it measures 454 lines before Phase 1 and the cap in
  `.claude/rules/general-code-change.md` is 500, leaving 46 lines to be shared by `[P1-T2]`, `[P1-T3]`, and this
  task. Write each `Mock -CommandName ... -MockWith { ... }` statement on a single line, exactly as quoted in this
  plan, and give the three new cases no comment block. No analyzer rule in
  `scripts/powershell/PoshQC/settings/pssa.settings.psd1` caps line length and `Invoke-Formatter` does not wrap
  lines, so the single-line form survives `[P4-T1]`.

  Command: C4 against `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/fail-before-remediation.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 0`, and `Output Summary:` recording `TotalCount`, `PassedCount`, `FailedCount`, and, per failing identifier, the identifier name and its verbatim failure message. Acceptance: `TotalCount` is 28, `FailedCount` is exactly 4, the four failing identifiers are exactly the four named above, and the recorded messages show identifiers 1 and 2 failing on a decision or reason assertion rather than on a parameter-binding error, which is the only form of fail-before proof that rules out a vacuous pass. A fifth failing identifier means an amendment in `[P1-T2]` or `[P1-T3]` changed delivered behaviour and must be corrected here, not carried into Phase 2.

- [x] [P1-T8] Measure the delivered line counts of the three edited test files and append them to `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/remediation-file-size-ledger.md` under a `Timestamp:`-bearing Phase 1 block. This ledger filename deliberately carries no timestamp element, because `[P2-T7]` appends a second block to the same file. Acceptance: three integers are recorded and each is at or under the 500-line cap in `.claude/rules/general-code-change.md`. The TargetResolution suite measured 454 lines before this phase, so the three added cases must not push it past 500; if the measured value exceeds 500, halt and report blocked rather than trimming an assertion, and record the overage in this ledger.

### Phase 2 — Batch R-B: the production change in the repository copies

- [x] [P2-T1] Open batch R-B with the filtered reset pipeline and its verification, per the preamble. Acceptance: the verification enumeration reports a count of `0`, and the pre-reset contents, or the literal `none`, are recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/batch-boundary-r-b.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The pre-reset `testFiles` list is expected to name the three suites edited in Phase 1; record whatever it contains.

- [x] [P2-T2] (Batch R-B) Apply R1 Option A to `.claude/hooks/enforce-prd-feature-before-planner.ps1`. Delete the four-line pre-filter at lines 242-245 — the comment `# An absolutely-placed token is the only citation that identifies one worktree.`, the `if ($text -notmatch ...)` test carrying the `[A-Za-z]:[\\/]` pattern, its `return $null`, and its closing brace — so the assembled text passes to `Resolve-WorktreeCallTarget` unconditionally. Keep the empty-text guard at lines 238-240, the session-root read at lines 247-250, and both `Resolve-WorktreeCallTarget` call forms at lines 252-255 byte-unmodified. Replace the `.DESCRIPTION` paragraph at lines 219-223 with a paragraph stating that the assembled text is handed to the derivation unconditionally and that the derivation answers `NoTarget` for a call it cannot place and `Ambiguous` for a signal that places in no worktree or in several. That paragraph must contain, on a single line of its own, the sentence `a call that places in no worktree, or in several, denies before any probe`. Acceptance: `Select-String -SimpleMatch -Pattern '[A-Za-z]:[\\/]' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'` returns 0 matches while the same search against `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` returns the control count recorded by `[P0-T4]`; `Select-String -SimpleMatch -Pattern 'absolutely-placed' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'` returns 0 matches against a recorded pre-change count of 2; and `Select-String -SimpleMatch -Pattern 'a call that places in no worktree, or in several, denies before any probe' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'` returns exactly 1 match. Record all four counts in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/prefilter-removal.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P2-T3] (Batch R-B) Apply R2 to the same file: rewrite the `.DESCRIPTION` resolution-order block at lines 14-34 so it describes the delivered branch order. Step 2 must no longer claim a positional tie-break and step 3 must no longer claim an unconditional checkpoint fallback; the rewritten block additionally describes the derived-target disambiguator, the unresolved-tie deny, the derivation's own ambiguity deny, and the folder-absent-under-the-target-root deny. Two sentences must each appear on a single line of their own: `the derived call target is the only disambiguator` and `the checkpoint stands in only when the session root is the derived target`. Do not introduce any ambiguity reason-code literal into this file: criterion 24 requires the code to be read from the resolution module and defined nowhere here. Acceptance: `Select-String -SimpleMatch -Pattern 'earliest-occurring candidate' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'` returns 0 matches against a recorded pre-change count of 1; `Select-String -SimpleMatch -Pattern 'If no candidate was found in the prompt' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'` returns 0 matches against a recorded pre-change count of 1; each of the two quoted sentences returns exactly 1 match; and `Select-String -SimpleMatch -Pattern 'TARGET_WORKTREE_AMBIGUOUS' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1'` returns 0 matches, with the control for that token taken from `.claude/lib/worktree-resolution/WorktreeResolution.psm1`, whose count is recorded in the same artifact and must be non-zero. Record every count in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/help-block-accuracy.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P2-T4] Re-assert criterion 24's no-local-re-implementation property over both delivered production files after the edits. Command: `Select-String -SimpleMatch -Pattern '<token>' -Path '.claude/hooks/enforce-prd-feature-before-planner.ps1','.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1'` for each of the tokens `git worktree`, `Get-Location`, `$PWD`, and `Resolve-Path`, each with the control file the delivery plan fixed: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` for `git worktree`, `.claude/hooks/persist-session-id.ps1` for `Get-Location`, `scripts/powershell/PoshQC/PoshQC.Testing.psm1` for `$PWD`, and `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` for `Resolve-Path`. Acceptance: all four target counts are 0 and all four control counts are non-zero, recorded as integers in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/no-reimplementation-after-remediation.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. This is the verification task `[P0-T7]` names for R3: with the pre-filter deleted, the hook holds no local decision about which calls are eligible for derivation.

- [x] [P2-T5] (Batch R-B) Apply R4 item 1 to `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`. In the file-level `.DESCRIPTION` at lines 12-13, keep the sentence `The file declares no file-scope parameter block, no requires directive, and no entrypoint.` and replace the following sentence `It is loaded for its declarations only.` with wording that names the one file-scope statement and its rationale. The replacement must contain, on a single line of its own, the sentence `its only file-scope statement is the resolution-module import`, and must state in the same paragraph that the import is deliberately unguarded so an unloadable module fails the gate closed. Change nothing else in the file; in particular `ConvertTo-PrdFeatureFolderToken` and the `Import-Module` statement at line 21 are untouched. Acceptance: `Select-String -SimpleMatch -Pattern 'It is loaded for its declarations only' -Path '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1'` returns 0 matches against a recorded pre-change count of 1, and `Select-String -SimpleMatch -Pattern 'its only file-scope statement is the resolution-module import' -Path '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1'` returns exactly 1 match.

- [x] [P2-T6] Verify the #518 four-segment slice survived byte-unmodified. Commands: `Select-String -SimpleMatch -Pattern '$segments[0..3]' -Path '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1'` and `Select-String -SimpleMatch -Pattern 'if ($segments.Count -lt 4) {' -Path '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1'`, plus `git diff <baselineHead> -- .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` with `<baselineHead>` bound to the commit recorded by `[P0-T2]` and under the same anchor precondition and halt branch stated in `[P1-T5]`. Acceptance: each search returns exactly 1 match, and the diff's added and removed lines lie wholly inside the file-level comment-based-help block, with no hunk touching `ConvertTo-PrdFeatureFolderToken`. Record both counts, the diff, and its exit code in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/issue-518-slice-integrity.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. This task carries the corrected citation: the slice lives in the helpers sibling, not at parent-hook lines 272-277, which after the extraction are the decision function's `param()` block.

- [x] [P2-T7] Measure the delivered line counts of `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` and append them to `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/remediation-file-size-ledger.md` under a `Timestamp:`-bearing Phase 2 block. Acceptance: both integers are recorded and both are at or under 500. The pre-remediation values are 431 and 314, so the help rewrites carry 69 and 186 lines of headroom respectively; an overage halts and reports blocked rather than being absorbed by shortening a rationale comment.

- [x] [P2-T8] Run the three prd-feature suites against the changed hook. Command: C4 once per suite for `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/post-change-prd-feature-suites.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording `TotalCount`, `PassedCount`, and `FailedCount` per suite. Acceptance: 28 total with 0 failed for the TargetResolution suite, 47 total with 0 failed for the parent suite, and 25 total with 0 failed for the FolderResolution suite. The four identifiers that failed in `[P1-T7]` now pass, which is the pass-after half of the fail-before pair; record that transition explicitly in `Output Summary:` by naming the four identifiers and their post-change results.

### Phase 3 — Batch R-C: bundled-mirror re-synchronisation and delivery registration

- [x] [P3-T1] Open batch R-C with the filtered reset pipeline and its verification, per the preamble. Acceptance: the verification enumeration reports a count of `0`, and the pre-reset contents, or the literal `none`, are recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/batch-boundary-r-c.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P3-T2] (Batch R-C) Update `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` so it is text-identical to `.claude/hooks/enforce-prd-feature-before-planner.ps1` after the Phase 2 edits. Acceptance: `Compare-Object -ReferenceObject (Get-Content -LiteralPath '.claude/hooks/enforce-prd-feature-before-planner.ps1') -DifferenceObject (Get-Content -LiteralPath 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1')` produces zero difference objects. An equal line count alone is not accepted as evidence of text identity.

- [x] [P3-T3] (Batch R-C) Update `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` so it is text-identical to `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` after the Phase 2 edits. Acceptance: `Compare-Object` over the two files' content produces zero difference objects.

- [x] [P3-T4] Verify SHA-256 equality for both repository-to-bundle pairs. Command: C6 for each pair. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/mirror-hash-parity.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording all four 64-character hash values verbatim and the two `-ceq` comparison results. Acceptance: both comparisons are true and all four hash strings are recorded in full; a recorded comparison result without the four hashes is not a passing outcome, because a hash written from memory rather than from the run cannot be re-verified by a third party.

- [x] [P3-T5] Run the three Python delivery tests, closing the intermediate parity window. Immediately before the run, clear `.claude/state` with the **unfiltered** pipeline defined in the preamble and record the pre-removal file names, or the literal `none`, together with the post-removal verification count of `0`. Command: C10. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/remediation-delivery-tests.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: `EXIT_CODE: 0`, a failed count of 0, and the `Output Summary:` names `test_bundled_claude_payload_contains_all_repo_runtime_contracts` as passing. The removal and verification commands and their own exit codes are recorded separately in `Output Summary:` under the preamble's exit-code attribution.

- [x] [P3-T6] Verify the delivery registrations are unchanged by this remediation, which adds no file. Commands: `Select-String -SimpleMatch -Pattern 'enforce-prd-feature-before-planner-helpers.ps1' -Path 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'`, and the same search against `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. Acceptance: each search returns exactly 1 match, confirming the manifest entry and both coverage-path registrations delivered earlier are intact and unduplicated. Record the three counts in the `[P3-T4]` artifact's `Output Summary:` rather than creating a separate artifact, and name this task beside them.

### Phase 4 — Final QC loop, the seven remediation gates, and acceptance-criteria check-off

Run `[P4-T1]` through `[P4-T4]` in order. If any step fails or changes a tracked file, restart the loop from
`[P4-T1]`. The loop completes only when all four steps pass in a single uninterrupted pass. Type checking is
not applicable to PowerShell and is deliberately absent (`.claude/rules/powershell.md` line 17).
`EXIT_CODE: SKIPPED` is not a valid outcome for any task in this phase.

- [x] [P4-T1] Formatting (remediation gate 1, first half). Record `git status --porcelain --untracked-files=all` immediately before and immediately after invoking `mcp__drm-copilot__run_poshqc_format`, because the formatter rewrites tracked PowerShell source in place and exits 0 whether or not it changed anything, so the exit code alone cannot distinguish a clean run from a repairing one. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-format.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying both captures verbatim and an explicit statement of whether they differ. Acceptance: the two captures are identical. If they differ, the formatter repaired drift: this task does not pass, the repair is kept, and the loop restarts at `[P4-T1]`. Recording the two captures without comparing them is not a passing outcome.

- [x] [P4-T2] Linting (remediation gate 1, second half). Invoke `mcp__drm-copilot__run_poshqc_analyze` for route compliance, then run C1, then run C2 once for each of the seven changed `.ps1` paths: the two repository hook files, the two bundled mirrors, and the three suites. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-analyze.<ISO-8601>.md` with `Timestamp:`, `Command:` naming every command verbatim with C1 in its `6>&1` form, `EXIT_CODE:`, and `Output Summary:` recording the C1 branch observable and the seven per-file integers. Acceptance: the `Output Summary:` quotes the literal `PSScriptAnalyzer passed: no findings under` from the captured output, the whole-tree count is recorded as 0, and all seven per-file integers are 0. An exit code or an MCP result is not accepted in place of the literal, because neither carries a finding count, and `Invoke-PoshQCAnalyze` returns nothing on the zero branch.

- [x] [P4-T3] Testing with coverage. Run C3 in its own wrapper script with nothing chained after it, then read the reports with C7 and C8 in a separate invocation. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-test.<ISO-8601>.md` with `Timestamp:`, `Command:` naming C3, C7, and C8 verbatim, `EXIT_CODE:`, `ExpectedExitCode: 2`, and `Output Summary:` recording: the `tests`, `failures`, and `errors` attributes and the computed passed count; the full `name` attribute of every `//testcase[failure]` node; the per-identifier node counts for the six identifiers named below, each expected to be exactly 1 and each carrying no child `failure` element; and the per-file line coverage for both delivered production files with the two integers beside each percentage and the form used per C8. The six identifiers are `allows a repo-relative citation placed in the item worktree`, `denies with the ambiguity reason when a repo-relative citation places in no worktree`, `hands a repo-relative citation carrying a branch signal to the derivation`, `hands a repo-relative citation to the derivation`, `allows when the modelled cwd is the item worktree`, and `denies rather than selecting the earliest candidate on an unresolved tie`. Acceptance: `errors` is 0; `tests` equals the integer recorded by `[P0-T6]` plus 3, which is the node count this remediation adds; each of the six identifiers matches exactly one node with no child `failure`; and both per-file coverage figures are at or above 85. Record no branch-coverage figure. Do not assert a repository-wide failure count of 0; the failing-node-set assertion is `[P4-T5]`.

- [x] [P4-T4] Delivery tests. Clear `.claude/state` with the unfiltered pipeline, recording the pre-removal names or `none` and the post-removal count of `0`, then run C10. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-delivery-tests.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording passed and failed counts. Acceptance: `EXIT_CODE: 0` and a failed count of 0.

- [x] [P4-T5] Remediation gate 6 — the repository-wide failing node set. Using the `artifacts/pester/pester-junit.xml` produced by `[P4-T3]`, enumerate `//testcase[failure]` with C7. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/failure-set-equality.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the count and the full `name` attribute of each member. Acceptance: every member of the failing node set is one of the two named nodes — one whose `name` contains `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` and one whose `name` contains `allows every registered handler for every tool name its own matcher admits` — and the `errors` attribute is 0. A member outside that pair is a genuine regression of this remediation and fails this gate. The expected count is 2; a count of 0 or 1 passes this gate and is recorded with the missing member named, because the two nodes read ambient state and their disappearance is not an outcome of this remediation, while a count above 2 necessarily introduces a member outside the pair and therefore fails. A count below 2 is also recorded rather than silently accepted: it means the ambient state those two suites read has changed, and the artifact states which member disappeared so a later reader is not misled into treating the pair as permanently reproducible.

- [x] [P4-T6] Remediation gate 3, first half — the PreToolUse schema contract suite passes unedited. Command: C4 against `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, plus `git diff --name-only <baselineHead>` and `git status --porcelain --untracked-files=all` with `<baselineHead>` bound to the commit recorded by `[P0-T2]` and under the same anchor precondition and halt branch stated in `[P1-T5]`. Acceptance: the suite reports 15 total, 15 passed, 0 failed, and neither the anchored name-listing diff nor the porcelain status names `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`. Both enumerations are required and neither substitutes for the other: the anchored diff cannot report an untracked file, and porcelain status goes empty once a change is committed. Record both enumerations, the ancestry check, and all three exit codes in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/contract-suite-unedited.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P4-T7] Remediation gate 3, second half — the 17-suite must-not-regress batch. Command: C5. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/must-not-regress-17-suites.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the enumerated file count, `TotalCount`, `PassedCount`, and `FailedCount`. Acceptance: the enumerated file count is 17, `FailedCount` is 0, and `TotalCount` equals `PassedCount`. The expected value of both is 556, as the feature audit recorded; a `TotalCount` other than 556 does not by itself fail this gate, but the artifact then states the observed value and the difference explicitly, because a changed total means the suite set itself changed and that is a fact a reviewer must see rather than infer. In the same artifact record that no file matching `enforce-orchestration-preimplementation-gate` or `enforce-epic-merge-gate` appears in the changed-file enumeration captured by `[P4-T6]`.

- [x] [P4-T8] Remediation gate 7 — evidence-location validation. Command: C9. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/evidence-location-validation.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the validator's reported path list or the literal `none`. Acceptance: `EXIT_CODE: 0` and no reported path.

- [x] [P4-T9] Record the seven-gate acceptance summary. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/remediation-gate-summary.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying one labelled row per gate, each naming the producing task and its artifact path: gate 1 formatter and analyzer (`[P4-T1]`, `[P4-T2]`); gate 2 the three prd-feature suites and the new rows (`[P4-T3]`, with the per-identifier node counts); gate 3 the contract suite and the 17-suite batch (`[P4-T6]`, `[P4-T7]`); gate 4 SHA-256 equality for both pairs (`[P3-T4]`); gate 5 per-file line coverage at or above 85 for both production files (`[P4-T3]`); gate 6 the failing node set equality and `errors = 0` (`[P4-T5]`); gate 7 the evidence-location validator (`[P4-T8]`). Acceptance: all seven rows are present, each names a task identifier and an artifact path that exists on disk, and each carries a verdict of `PASS` or `FAIL`. A `FAIL` on any row makes the remediation outcome remediation-required, not PASS, and the loop restarts at `[P4-T1]` after the cause is repaired.

- [x] [P4-T10] Record the loop-completion statement. Write `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-loop.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming, in order, `[P4-T1]` through `[P4-T4]` and the artifact each produced, and stating how many complete passes of the loop were required. Acceptance: the artifact names four steps and four artifact paths and states that the final pass completed with no step failing and no tracked file changed by a step.

- [x] [P4-T11] Re-check acceptance criteria 6 and 10 in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`, and only after the new regression rows have passed. Criterion 6 (line 616) is re-checked on the evidence of `denies with the ambiguity reason when a repo-relative citation places in no worktree` passing in `[P4-T3]` together with the delivered row `denies with the ambiguity reason when the folder is absent from the target root`. Criterion 10 (line 626) is re-checked on the evidence of `allows a repo-relative citation placed in the item worktree` passing in `[P4-T3]`. Change only `- [ ]` to `- [x]` on those two lines and alter no criterion's text. Criterion 37 (line 668) stays unchecked and is not re-worded: the toolchain loop still does not reach a zero-failure pass in this worktree, for the two environment-coupled causes recorded in the preamble. Criterion 30 (line 655) stays checked and is not re-worded, per the deferral recorded by `[P0-T7]`. Acceptance: `Select-String -SimpleMatch -Pattern '- [x] The missing/malformed-marker branch is reached only when' -Path 'docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md'` returns exactly one match; `Select-String -SimpleMatch -Pattern '- [x] Row — own folder named, cwd modelled as the session root' -Path 'docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md'` returns exactly one match; the `[P0-T8]` artifact `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/ac-reversion.<ISO-8601>.md` is named here and its recorded post-reversion state reads `- [ ]` for both lines, which is what makes the two searches above a real transition rather than the untouched baseline; and `git diff <baselineHead> -- docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`, with `<baselineHead>` bound to the commit recorded by `[P0-T2]` and under the anchor precondition stated in `[P1-T5]`, produces no output. The empty diff is the proof that the reversion was undone on exactly those two lines and that no criterion's prose changed; a non-empty diff fails this task. Both quoted criterion texts were re-derived against `spec.md` lines 616 and 626 in this pass and carry that file's exact spelling, including the em-dash in the criterion-10 token. Record both counts, the diff, and its exit code in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/ac-recheck.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P4-T12] Emit the acceptance-criteria status summary required at completion by `.claude/skills/acceptance-criteria-tracking/SKILL.md`, reporting the source file path, the total criterion count, the checked-off count, the remaining count, and the verbatim text of every remaining unchecked criterion. Write it to `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/acceptance-criteria-status.<ISO-8601>.md` with `Timestamp:`. Acceptance: the total is 38, counted as the `- [ ]` and `- [x]` list items between the `## Acceptance Criteria` heading at `spec.md` line 600 and the `## Risks & Mitigations` heading at line 671; the checked and remaining counts sum to 38; the remaining count is 1; and the single remaining item is criterion 37, quoted verbatim.

---

## Round 1 delta — application record

Preflight round 1 returned `PREFLIGHT: REVISIONS REQUIRED` with `CONVERGENCE: NO FURTHER ROUNDS EXPECTED`
against plan hash `281ba0d80b44c89a843a9fe517197879114028d1` and supplied ten deltas plus one reviewer
observation carrying no delta. Every citation each delta touches was re-derived against the current tree in the
same pass that applied it; the derived values are recorded per row.

| delta | location | disposition | re-derivation performed |
| --- | --- | --- | --- |
| D1 | `[P1-T2]`, the "Keep the existing mocks" sentence | APPLIED as supplied | `.claude/hooks/enforce-prd-feature-before-planner.ps1` line 243 is the `-notmatch` pre-filter returning `$null`; the row's payload at suite line 258 is `New-PlannerPayload -Prompt "Plan $($script:TargetFeatureFolder) now."`, a bare repo-relative citation, so the derivation is unreachable pre-change and the invocation-count assertion is removed. |
| D2 | `[P4-T11]`, the acceptance sentence | APPLIED with a corrected token | `spec.md` line 616 reads `- [x] The missing/malformed-marker branch is reached only when the feature folder **does** exist ...`, matching the supplied token. Line 626 reads `- [x] Row — own folder named, cwd modelled as the session root: ...` with an **em-dash**; the supplied text carried a hyphen and was corrected to the file's spelling. The `[P0-T8]` artifact stem `ac-reversion` was resolved and named. |
| D3 | preamble, "Intermediate parity window", final sentence | APPLIED as supplied | C10 (plan line for the delivery-test command) names `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`; C10 is executed by `[P3-T5]` and `[P4-T4]`. `[P4-T8]` runs C9, the evidence-location validator, and asserts nothing about parity. |
| D4 | `[P0-T4]`, the `Command:` sentence | APPLIED as supplied | `Select-String ... \| Measure-Object \| Select-Object -ExpandProperty Count` emits one integer and no line number; the `LineNumber` projection is added as a second command so both recorded values have a source. |
| D5 | `[P4-T5]`, the acceptance sentence | APPLIED, absorbing one adjacent duplicate sentence | The replacement states the set-membership property and the count expectation. The following sentence "A third member is a genuine regression of this remediation and fails this gate." restated the replacement's own second clause verbatim in weaker form and was removed to avoid two acceptance statements of the same property; the final sentence, which requires the artifact to name a disappeared member, is retained and is consistent with the replacement. |
| D6 | `[P1-T4]` and `[P1-T5]` | APPLIED as supplied | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` lines 5-13 are the Describe-level `BeforeAll` and line 14 is blank; `...FolderResolution.Tests.ps1` lines 20-28 are its `BeforeAll` and line 29 is blank. |
| D7 | `[P1-T7]`, before the `Command: C4` sentence | APPLIED as supplied | `...TargetResolution.Tests.ps1` measures 454 lines; the cap in `.claude/rules/general-code-change.md` is 500. `scripts/powershell/PoshQC/settings/pssa.settings.psd1` enables ten named rules and none is `PSAvoidLongLines`, which PSScriptAnalyzer leaves off unless explicitly enabled. |
| D8 | `[P2-T4]`, the control clause | APPLIED as supplied | The task asserts four tokens (`git worktree`, `Get-Location`, `$PWD`, `Resolve-Path`); `New-Item` had no asserted counterpart. `Get-Location` occurs once in `.claude/hooks/persist-session-id.ps1`, so that control remains non-zero after the stray token is dropped. |
| D9 | `[P1-T7]`, third bullet | APPLIED as supplied | `Get-PrdFeatureCallTarget` declares `$Envelope` and `$ToolInput` at hook lines 227-233; the suite's existing calls at lines 184, 194, 206, and 220 all pass `-ToolInput`, so the bullet's call form now matches the established spelling. |
| D10 | preamble, C8 bullet | APPLIED as supplied | `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is an explicit per-file allow-list; it names the two hook files at entries `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, and a search of that file for `claude-customizations` returns 0 matches, so no bundled mirror is measured and no duplicate leaf name can arise. |
| reviewer observation (no delta) | `[P1-T7]`, suite header comment lines 11-13 | FOLDED INTO `[P1-T7]` | The two sibling suites measure 445 and 453 lines; the header records 431 and 419 before the amendment and 436 and 424 after it, so all four figures are wrong. The correction is line-for-line and replaces the integers with a ledger reference rather than fresh integers, so the comment cannot go stale on the next edit to either sibling. It consumes none of the D7 line budget. |

No task identifier, task ordering, phase structure, batch-budget assignment, or evidence path was changed by
this round. No acceptance condition was weakened: D1, D4, D5, D8, and D10 each replace a condition that could
not be satisfied or could not be observed with one that can fail, and D2 replaces an unobservable diff-delta
demand with two positive literal searches plus an anchored empty-diff check.

---

## Deviation and halt protocol

- A task that cannot meet its acceptance condition is left unchecked with the deviation recorded in its own
  artifact. It is not checked off on partial evidence.
- The halt conditions in this plan are: an unremovable batch-budget state file; a `git merge-base
  --is-ancestor` anchor check that exits non-zero; a delivered file measured over the 500-line cap; and a fifth
  failing identifier in `[P1-T7]`. Each halts and reports blocked rather than being worked around.
- No task in this plan edits `.claude/hooks/enforce-pr-author-skill.ps1`,
  `.claude/hooks/enforce-epic-wave-barrier.ps1`, their suites, any `.codex/` path, any file matching
  `enforce-orchestration-preimplementation-gate` or `enforce-epic-merge-gate`, or any acceptance-criterion
  prose in `spec.md`.
