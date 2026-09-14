# 2026-09-13-preimplementation-gate-worktree-selector (Plan)

- **Issue:** #671
- **Parent (optional):** epic `worktree-scoped-state-resolution`, feature F2 (wave 0, complexity C3, `depends_on: []`)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-13T23-55
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** full-bug
- **Requirements source:** `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` only. `user-story.md` is correctly absent for a `full-bug` plan and must not be created. `issue.md` is context, not an acceptance-criteria source.

**Fail-closed evidence rule:** Every baseline, QA-gate, and coverage task below names its artifact path. If any named artifact is missing or is missing a required field, the verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Do not check a task box without its artifact on disk.

**Evidence location (non-overridable):** every artifact this plan produces resolves under
`docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/<kind>/`
where `<kind>` is one of `baseline`, `regression-testing`, `qa-gates`, `issue-updates`, `other`.
Paths under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`,
`artifacts/evidence/`, and `artifacts/coverage/` are forbidden for evidence output and no
instruction may override this clause.

---

## Change summary

`Test-ExemptOrchestrationSegmentToken` in `enforce-orchestration-preimplementation-gate-helpers.ps1`
requires the git subcommand to sit at token index 1, so `git -C <worktree> add <exempt-pathspec>`
denies and the issue-#539 orchestration-bookkeeping staging exemption is reachable only when the
invoking shell's current working directory is already the target worktree. This plan adopts the
spec's **Lexical Absolute-Canonical Selector (LACS)** design: exactly one `-C <selector>` is
permitted at token index 1 with the subcommand at index 3, when the selector satisfies the eight
purely lexical conditions L1 through L8. Everything after the subcommand is byte-unchanged.

Exactly one function body changes — the prologue of `Test-ExemptOrchestrationSegmentToken` — plus
one new predicate and one new constant block, all inside the helpers file, on four mirrored
surfaces.

## Verified scope (re-derived against the current tree, 2026-09-13)

Production PowerShell — four copies of one filename,
`enforce-orchestration-preimplementation-gate-helpers.ps1`, each **349 lines**:

1. `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
2. `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`

Test PowerShell — three files:

1. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` (296 lines, extend)
2. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (302 lines, extend)
3. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` (new)

Out of scope and not to be edited by any task in this plan: the four
`enforce-orchestration-preimplementation-gate.ps1` gate files (496 lines on the Claude pair and
**500 lines with zero headroom** on the Codex pair, both re-derived in this pass under the
`(Get-Content).Count` convention of governing paragraph 5; the Claude figure agrees with `spec.md`
line 194, which records 496 for the Claude bundle gate file), the four
`enforce-orchestration-preimplementation-gate-modes.ps1` files (480 Claude / 477 Codex),
`hook-command-invocation.ps1` on any surface (dot-sourced by `.claude/hooks/enforce-epic-merge-gate.ps1`,
so editing it would widen that gate's matcher), `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
and its mirror, any pack manifest, and any `.py` file other than running an existing test.

### Two corrections this plan carries against the epic manifest

- `docs/features/epics/worktree-scoped-state-resolution/epic.md` line 218 states the helpers file
  is 495 lines and line 217 concludes F2 "requires a helpers extraction". The helpers file is
  **349 lines** on every surface, verified by line count in this pass. The 495/496 figure belongs to
  the **gate** file. **No helpers extraction is required.**
- The epic manifest describes three surfaces. There are **four**. The fourth,
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, is hash-bound by
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 111, so omitting it fails CI.

## Ordering rationale (read before executing)

The production fix lands in Phase 1 and Phase 2, **before** the new Pester rows land in Phase 3.
This ordering is deliberate and is required for the acceptance conditions to be satisfiable:

- The fail-before evidence this bug requires is the **executed dot-source capture** in Phase 0, which
  spec acceptance criterion AC17 names explicitly and which states that a hand-trace does not satisfy
  it. The research artifact's R10 table is a deterministic hand-trace, not an executed run, because
  the research session had no shell tool.
- Adding the seven new allow rows before the production fix would make every intervening suite run
  exit non-zero, so any task between those two points that asserts a clean suite run could not exit 0.

## Authoring constraints the implementation must honour

- **Purity (INV-1).** The helpers module header contract at its lines 5–10 must survive verbatim.
  Spec acceptance criterion AC23 searches all four copies for the literals `git worktree`,
  `Test-Path`, `Start-Process`, `Resolve-Path`, `Invoke-Expression`, and `env:` and requires **no
  line** to match. This includes comment text. Do not write a comment that mentions `Test-Path`,
  `Resolve-Path`, or `env:` even to say the code avoids them.
- **Single axis (INV-2).** D4 rows 1–13 and 15–19 stay unchanged in text and behaviour. Only row 14's
  disposition narrows.
- **Selector absorption shape.** The absorption is inserted between the current lines 232 and 233
  and normalizes the local token array: when the selector predicate accepts the segment, the
  accepted selector option token and its value token are dropped from the local copy of the token
  array, so the subcommand is again at index 1 and operand collection again starts at index 2. This
  keeps the message-option handler from re-reading the selector value as an operand, and it keeps
  `$subcommand = $Token[1]` at line 233 and `$index = 2` at line 240 byte-unchanged. Rewriting line
  240 is prohibited: task [P5-T4] and the spec criterion beginning `The helpers diff is confined to
  one axis` both require every removed content line to fall inside the pre-change 227–236 block, and
  line 240 is outside it. Both anchor lines occur exactly once in the file, verified in this pass.
- **Codex suite helper names differ from the Claude suite.** The spec's "Envelope construction"
  section names the Claude helpers only. Re-derived in this pass: the Codex suite defines
  `ConvertTo-CodexExemptionToolInput` (line 27), `ConvertTo-CodexNotReadyCheckpointRaw` (line 38),
  and `Get-CodexExemptionDecisionForCommand` (line 54), and it passes bare mapped `tool_input` JSON
  rather than the outer PreToolUse envelope. New Codex rows must call
  `Get-CodexExemptionDecisionForCommand`.
- **New identifiers this plan instructs the executor to create**, quoted here verbatim so a search
  for them is a real assertion rather than a search for something the tree never had:
  `Test-ExemptOrchestrationSelector`, `$script:OrchestrationSelectorOptionName`,
  `PREIMPL_SELECTOR_UNMODELLED_OPTION`, `PREIMPL_SELECTOR_REPEATED`, `PREIMPL_SELECTOR_MALFORMED`,
  `PREIMPL_SELECTOR_NOT_ROOTED`, `PREIMPL_SELECTOR_TRAVERSAL`, `PREIMPL_SELECTOR_NOT_LITERAL`,
  `Accepted widening`, `LACS L1a`, `LACS L1b`, `LACS L2`, `LACS L3a`, `LACS L3b`, `LACS L4a`,
  `LACS L4b`, `LACS L5a`, `LACS L5b`, `LACS L6`, `LACS L7`, `LACS L8`,
  `issue #671 worktree selector allow cases`, `issue #671 worktree selector deny cases`,
  `keeps all four surface copies of the helpers module byte-identical by SHA256 hash`, and
  `keeps every surface copy of the helpers module under the 500-line cap`.
- **Search literals used verbatim by the acceptance conditions below**, quoted here so each search
  is a real assertion rather than a search for text the tree never carried:
  `function Test-ExemptOrchestrationSelector`, `Test-ExemptOrchestrationSelector -`,
  `OrchestrationSelectorOptionName`, `issue #671 LACS allow 1`, `issue #671 LACS allow 7`,
  `Get-ExemptionDecisionForCommand -Command`, `PathspecWildcardCharacters = [char[]]`,
  `if ($operands.Count -eq 0) {`, `$index = 2`, `$subcommand = $Token[1]`,
  `Pure string logic only: no disk, process, network, or environment access`, `Import-Module`,
  `Policy Order:`, `- [x] `, and `- [ ] `.
- **Untracked-file searches.** The new parity suite is untracked while this plan executes, so
  `git grep` cannot see it. Every assertion against a path this plan creates uses `Select-String`
  or `Test-Path`, never `git grep`.

## Toolchain

PowerShell order is format, then analyze, then test; type checking does not apply. Use
`mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and
`mcp__drm-copilot__run_poshqc_test`. Restart from format whenever any stage fails or changes a file,
and do not stop until all three pass in a single uninterrupted pass.

**Shell routing (verified in this worktree).** Issue every PowerShell step and every PowerShell-expressed
acceptance check through the PowerShell tool route, not the Bash tool. The worktree-isolation guard
refuses a Bash-tool command that names `pwsh`, and it also refuses Bash commands that name `git` inside a
compound or piped construct. This applies to the dot-source captures in [P0-T4] and [P5-T9], the three
`Copy-Item` mirrors in Phase 2, and every `Select-String`, `Get-FileHash`, `Get-Content`, `Test-Path`, and
`Get-ChildItem` acceptance expression in this plan. Where a read-only git command is required — the
`git status --porcelain` and `git diff --merge-base main` spans in Phase 0 and Phase 5 — issue it as a
single plain command from the worktree root rather than chaining it behind `cd` or a pipe.

**Recorded caveat (does not bite this change).** `mcp__drm-copilot__run_poshqc_test` resolves its
settings from the installed extension's payload rather than from the repository tree, so a newly
added `CodeCoverage.Path` entry can be ignored by it until the extension is rebuilt and reinstalled.
This design adds **no new production file**, and all four helpers copies that are measured are
already listed — `.codex/hooks/...-helpers.ps1` at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
line 135 and `.claude/hooks/...-helpers.ps1` at line 229 — so no runsettings edit is required and the
caveat does not apply. It is recorded so a later reader does not reintroduce the problem.

`CoveragePercentTarget = 0` in the runsettings means the runner does not fail on the coverage
percentage. The >= 85% line threshold is a policy gate evaluated against the emitted report, so the
numeric value must be captured and recorded rather than assumed. Pester reports command and line
coverage only; there is no PowerShell branch-coverage gate.

## Derivation of every asserted number, finding, and node result

**1. MCP result shape (fixed).** A PoshQC MCP tool result carries **no captured script output**.
`runPoshQcWorkflow` at `extensions/drm-copilot/src/repo-automation-service.ts` lines 355–380
destructures `{ args, bundledRelativePath, summary }` from `buildPoshQcWorkflowArguments` and calls
`executeScript` with **no** `stdoutArtifactPattern` property. Contrast `newPotentialEntry` at lines
223–236 of the same file, which passes `stdoutArtifactPattern: /^Created:\s*(.+)$/im` at line 234 and
can therefore extract a value out of stdout. The `summary` is composed by string substitution over a
fixed template **before** the child process runs, at
`extensions/drm-copilot/src/repo-automation-args.ts` lines 42–48, from the templates in
`POSH_QC_TOOL_CONFIG` at `extensions/drm-copilot/src/repo-automation-service-support.ts` lines 20–68:
`run_poshqc_analyze.summaryWithoutFolders` is the fixed string
`Ran bundled PoshQC analyze against '{workspaceRoot}'.` at line 44, and
`run_poshqc_test.summaryWithoutFolders` is `Ran bundled PoshQC test against '{workspaceRoot}'.` at
line 50. Neither template carries a finding, a count, a percentage, or a node result.
`RepoAutomationExecutionResult` at `extensions/drm-copilot/src/repo-automation-service-contract.ts`
lines 32–48 declares `tool`, `workspaceRoot`, `summary`, and the optional `artifacts`, `assetId`,
`bundledSourcePath`, `destinationPath`, `renderedTree`, `warnings`, and `targetRepository`; there is
**no `exitCode` field and no stdout field**. The PowerShell child's own output goes to the VS Code
extension output channel and never enters the MCP tool result.

Consequently, every `mcp__drm-copilot__run_poshqc_*` invocation named in this plan is retained as the
**policy-mandated route-compliance step** that `.claude/rules/powershell.md` requires, and the
`EXIT_CODE:` recorded for it is the **MCP call disposition** — `0` when the call returned a result,
non-zero when it raised. That disposition is the only fact the MCP result establishes. Every asserted
test count, pass/fail/skip count, per-node result, per-file analyzer finding, and coverage percentage
in this plan is derived from a readable on-disk artifact named in paragraphs 2 through 4 below, never
from the MCP result, and each such artifact is read after the run through the PowerShell tool route.
This paragraph governs [P0-T7], [P0-T8], [P3-T3], [P3-T5], [P3-T6], [P4-T3], [P5-T3], [P6-T2],
[P6-T3], [P6-T4], and [P6-T6]. It does **not** govern [P0-T6] or [P6-T1]: those invoke the write-mode
formatter and take their acceptance from a direct tree observation rather than from any tool-reported
value, which is the correct pattern for a write-mode tool whose exit code distinguishes nothing. The
two use different observations, and the difference is load-bearing. [P0-T6] runs against a clean
baseline, where a rewrite moves a file from unmodified to ` M`, so paired `git status --porcelain`
captures are a real assertion there. [P6-T1] runs after every file the formatter could rewrite is
already modified or untracked, and porcelain is unchanged by a rewrite of a file already in either
state, so [P6-T1]'s assertion is the paired per-file `Get-FileHash` values it names and its porcelain
pair is recorded only for the untracked-file view.

**2. Test-count and per-node-result derivation (fixed, not left to the executor).**
`Invoke-PoshQCTest` is declared at `scripts/powershell/PoshQC/PoshQC.Testing.psm1` line 151 and
accepts no `-PassThru`; it returns no result object. `Run.Exit` is `$true` at
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 4, so a failing run exits the
session and no in-session value survives it. Read the run **after** it completes, from the JUnit
report the same settings file writes at its lines 12–15, namely `artifacts/pester/pester-junit.xml`,
loaded with `[xml](Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml')`.

*Totals.* The root `testsuites` element carries the attributes `tests`, `failures`, `errors`, and
`disabled`. Record all four integers as the total, failed, errored, and skipped counts; the passed
count is `tests` minus `failures` minus `errors` minus `disabled`. A per-suite total comes from the
`testsuite` element whose `name` attribute ends with that suite's repository-relative path, which
carries its own `tests`, `failures`, `errors`, `skipped`, and `disabled` attributes.

*Per-node result.* Each `testcase` element carries a `name` attribute holding the **fully qualified**
node name — `<Describe>.<Context>.<It>`, where for a hook suite the `Describe` text itself begins with
the hook script's file name — plus a `status` attribute whose value is `Passed`, `Failed`, or
`Skipped`, and a `classname` attribute holding the absolute path of the owning `.Tests.ps1` file. This
shape is verified against the committed JUnit document at
`docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-pester-baseline-junit.2026-08-29T14-41.xml`,
whose root element at line 2 carries `tests`, `errors`, `failures`, and `disabled`, whose `testsuite`
element at line 3 carries its own `tests`, `errors`, `failures`, `skipped`, and `disabled`, and whose
`testcase` elements at lines 15–26 and 5371–5375 carry the `name`, `status`, and `classname`
attributes together with the `skipped` child element.

Because `name` is fully qualified, an equality test against a bare `It` label matches nothing. The
selection rule is therefore: select every `testcase` whose `classname` attribute, with `\` normalized
to `/`, ends with the asserted suite's repository-relative path, **and** whose `name` attribute ends
with `.` followed by the asserted `It` label. A node is recorded PASSED when **exactly one**
`testcase` matches that pair and its `status` attribute is the string `Passed`.

**Zero matching `testcase` elements is a FAILURE of the acceptance condition, not a pass**, and the
owning task is reported INCOMPLETE. Without that rule a renamed, misspelled, or never-created node
reads as clean. More than one match is likewise a failure: [P3-T4] requires the Codex label text to be
byte-identical to the Claude label text, so the `classname` scoping is what makes the selection
single-valued, and a multiple match proves the scoping did not apply. Record, for every asserted node,
the match count, the matched `classname`, and the observed `status` string. This derivation governs
[P0-T8], [P3-T3], [P3-T5], [P3-T6], [P4-T3], the suite clause of [P5-T3], [P6-T3], and [P6-T6].

**3. Analyzer-finding derivation (fixed, not left to the executor).** `Invoke-PoshQCAnalyze` is
declared at `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` line 83. It writes **no report file**: on
findings it prints a `Format-Table` and throws `PSScriptAnalyzer reported N issue(s).` at line 183,
and on a clean run it logs `PSScriptAnalyzer passed: no findings under <root>` through
`Write-Information` at line 185. Neither output reaches the MCP result. Its default `AnalyzeFile`
scriptblock at lines 99–102 is
`Invoke-ScriptAnalyzer -Path $Path -Settings $Settings -Severity Error, Warning, Information`.

The authoritative source for every per-file analyzer assertion in this plan is therefore a **direct**
call, one invocation per asserted path, issued through the PowerShell tool route after the
`mcp__drm-copilot__run_poshqc_analyze` route-compliance call:
`Invoke-ScriptAnalyzer -Path <path> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information`.
Record `@($findings).Count` for that path and, for each finding, its `RuleName`, `Severity`, `Line`,
and `Message`. A count of `0` with no finding rows is the passing state for a path; a non-zero count is
a finding that must be fixed before the loop closes.
`scripts/powershell/PoshQC/settings/pssa.settings.psd1` exists in this tree and is the settings file
named here.

Record the MCP call's disposition alongside the direct result. The two can diverge, because the MCP
route resolves its settings from the installed extension payload rather than from the repository tree
— the same mechanism the recorded caveat above describes. A divergence is recorded in the artifact and
does not by itself pass or fail the task; the direct run against the in-repo settings file is what
decides it. This derivation governs [P0-T7] and [P6-T2].

**4. Coverage derivation (fixed, not left to the executor).** Read
`artifacts/pester/powershell-coverage.xml`, written per
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lines 17–22, with
`[xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml')`. `OutputFormat` is
`CoverageGutters` at line 21, which is JaCoCo-shaped: `report > package > sourcefile > line`, with
`counter` elements carrying `type`, `covered`, and `missed`. This shape is verified against the
committed report at
`docs/features/completed/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/powershell-coverage.post-change.xml`,
whose report-level `counter` elements sit at lines 3777–3780, whose `package` elements at lines 5,
2021, 2097, 2342, 2613, 3310, and 3479 carry forward-slash directory-qualified `name` attributes, and
whose `sourcefile` elements carry `line` children with `nr`, `mi`, and `ci` attributes followed by the
file's own `counter` elements, as at lines 1990–2015.

*Repository-wide line coverage.* Take the **report-level** `counter` element of `type` `LINE` — the
`counter` child of the `report` root, not of any `package` or `sourcefile` — and compute
`covered / (covered + missed)`, expressed as a percentage to two decimal places. Record `covered`,
`missed`, and the percentage.

*Per-file line coverage.* Select the `sourcefile` node whose `name` attribute equals the file's leaf
name **and** whose parent `package` node's `name` attribute, with `\` normalized to `/`, ends with the
file's repository-relative directory. The disambiguation is **required**, not optional: the leaf name
`enforce-orchestration-preimplementation-gate-helpers.ps1` exists under `.claude/hooks`, under
`.codex/hooks`, and under both bundled trees
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks` and
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks`, so a leaf-name-only
match is ambiguous across four files. Per-file line coverage is that node's own `counter` element of
`type` `LINE`, `covered / (covered + missed)`.

*Changed-line coverage.* From the same selected `sourcefile` node, take the `line` children whose `nr`
attribute is a line number listed under the `Changed-line set:` heading of the [P5-T4] artifact, and
report the count with `ci` greater than `0` over the count of such `line` children present. That
heading enumerates the **post-change** line numbers of the added content lines of the helpers diff, and
that coordinate space is the one the report uses: a `line` child's `nr` is a line number in the current
file, so the removed-line enumeration [P5-T4] also carries — which names pre-change line numbers in the
base revision — is not the set read here and must not be substituted for it. A changed line number with
no `line` child in the report is recorded as not instrumented and is named individually by its `nr`; it
is never counted as covered. When the `Changed-line set:` heading is absent from the [P5-T4] artifact or
its list is empty, the ratio has no input: record that fact and report the owning task INCOMPLETE rather
than reporting an empty ratio as satisfied.

*Absent-`sourcefile` rule.* A file listed in `CodeCoverage.Path` can still emit **no** `sourcefile`
element, when the suites consume it in a way the coverage breakpoints do not bind to. This is recorded
precedent in this repository:
`docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-powershell-pester-coverage.2026-08-08T10-42.md`
lines 72–76 record five `.claude/lib/blast-radius/*.psm1` modules as
`UNMEASURED — no sourcefile entry emitted` despite being declared in `CodeCoverage.Path`. When the
selection above yields no `sourcefile` node for the helpers file, record that path as
`UNMEASURED — no sourcefile entry emitted`, state the `package` `name` values the report does contain,
and report the owning task **INCOMPLETE**. Do not report PASS, and do not substitute the
repository-wide percentage for the per-file value. Separately, if the report's `package` `name`
attributes are not directory-qualified — a narrowly scoped run can emit a bare leaf such as `hooks`, as
at
`docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/powershell-per-file-coverage.2026-08-08T22-50.xml`
line 5 — the disambiguation cannot be applied at all; record
`AMBIGUOUS — package names are not directory-qualified` and report the owning task INCOMPLETE rather
than guessing a node.

`CoveragePercentTarget` is `0` at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line
285, so the runner never fails a run on the percentage. The >= 85% line-coverage floor is therefore an
**explicit numeric comparison** against the value derived above, not an exit code. This derivation
governs [P0-T8], [P6-T3], and [P6-T4].

**5. Line-count caveat.** Every line count and every 500-line-cap assertion in this plan uses
`@(Get-Content -LiteralPath 'path').Count`. `Measure-Object -Line` counts non-empty lines only and
under-reports. This governs [P0-T3], [P1-T5], [P2-T5], [P4-T2], [P4-T3], and [P6-T3].

## Batch-budget scheduling

`.claude/hooks/enforce-powershell-batch-budget.ps1` denies the fourth distinct production PowerShell
file and the fourth distinct test PowerShell file per session. Classification at line 284: a path
matching `(^|/)tests/.*\.ps1$` or `\.Tests\.ps1$` is a test file; every other `.ps1`, `.psm1`, or
`.psd1` is production. Only distinct paths consume slots. Reset by deleting the state file under
`.claude/state/`; the deny message names the exact path.

- **Production side: one Write/Edit slot consumed** (the canonical copy in Phase 1); the three mirrors
  consume none because they are `Copy-Item`. The reset at [P2-T3] is retained as an unconditional
  safety point because budget state is keyed on the session id and survives across delegations.
- **Test side: 3 files against a cap of 3, zero slack.** A contingency reset is scheduled at
  [P4-T1], before the third test file is created.
- **The budget hook is registered on the `Write|Edit` matcher.** A mirror produced by `Copy-Item`
  inside a PowerShell session therefore consumes no slot, while the same mirror produced with the
  Write or Edit tool does. Phase 2 uses `Copy-Item` from the edited canonical file, which also
  guarantees byte-identity by construction rather than by careful retyping.
- **Observed counts routinely differ from this prediction**, because the state is keyed on the
  session id and survives across delegations within a session. Run the reset whenever a list is at
  cap, not only at the two scheduled points.

---

### Phase 0 — Policy reading, baseline capture, and executed fail-before reproduction

- [ ] [P0-T1] Read, in this order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, and `.claude/rules/plan-acceptance-gates.md`, then write `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/phase0-instructions-read.2026-09-13T22-40.md` containing a `Timestamp:` field, a `Policy Order:` field naming the six files in the order read, and an explicit list of the files read. Acceptance: that file exists and `Select-String -SimpleMatch -Pattern 'Policy Order:' -Path` that file returns exactly one line.
- [ ] [P0-T2] Read `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`, `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/research/2026-09-13T21-15-preimplementation-gate-worktree-selector-671-research.md`, and `docs/features/epics/worktree-scoped-state-resolution/epic.md`, then write `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/requirements-sources-read.2026-09-13T22-40.md` recording `Timestamp:`, the three paths, the count of acceptance criteria found in `spec.md`, and the two corrections this plan carries against the epic manifest (helpers file is 349 lines not 495; four surfaces not three). Acceptance: that artifact records the acceptance-criterion count as `24`.
- [ ] [P0-T3] Capture the baseline SHA-256 hash and line count of all twelve production hook copies — `enforce-orchestration-preimplementation-gate.ps1`, `enforce-orchestration-preimplementation-gate-helpers.ps1`, and `enforce-orchestration-preimplementation-gate-modes.ps1` under each of `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` — using `Get-FileHash` and `(Get-Content -LiteralPath <path>).Count`, into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/hook-surface-hashes-and-line-counts.2026-09-13T22-40.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact lists twelve rows, the four `-helpers.ps1` rows carry one single distinct hash value and a line count of `349` each, and the two Codex gate rows carry a line count of `500` each. Record the observed hash values in the artifact; do not copy any hash into a later task's acceptance condition, because a hard-coded hash goes stale the moment anything else lands.
- [ ] [P0-T4] [expect-fail] Execute the fail-before reproduction. In one `pwsh` session started at the worktree root, dot-source `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and call `Test-ExemptOrchestrationStagingCommand -CommandText` once per row of the table below, recording the returned boolean for each. The helpers file declares constants and functions only, so dot-sourcing executes nothing and leaves no residue; create no temporary file. Write the result to `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the artifact records rows 2 and 3 as `False` and records a value for every one of the twenty rows. Rows, extending the research artifact's eight-row block to cover LACS deny conditions L1a, L1b, L2, L3a, L3b, L4a, L4b, L5a, L5b, L7, and L8. Condition L6, the wildcard selector, is covered by the Pester deny row `issue #671 LACS L6 - wildcard in the selector` that [P3-T2] adds from the spec's "Matrix — new rows" table, and is deliberately absent here so the twenty-row numbering that [P1-T5] and [P5-T9] compare against stays fixed:

  1. `git add -- docs/features/active/x/spec.md` — expect `True`
  2. `git -C C:/some/worktree add -- docs/features/active/x/spec.md` — expect `False`
  3. `git -C C:/some/worktree commit -m "msg" -- docs/features/active/x/spec.md` — expect `False`
  4. `git add -A -- docs/features/active/x/spec.md` — expect `False`
  5. `git add -- src/foo.ts` — expect `False`
  6. `cd C:/some/worktree && git add -- docs/features/active/x/spec.md` — expect `False`
  7. `git add -- docs/features/active/x/spec.md | tee out.txt` — expect `False`
  8. `git add -- "docs/features/active/x/spec.md` — expect `False`
  9. `git -C /repo/wt add -- docs/features/active/x/spec.md` — expect `False` before the fix. This row is LACS allow row 2 (a POSIX-rooted absolute selector) and flips to `True` after the fix; it is not an invariant row.
  10. `git -CC:/repo/wt add -- docs/features/active/x/spec.md` — expect `False`
  11. `git -c core.worktree=C:/repo/wt add -- docs/features/active/x/spec.md` — expect `False`
  12. `git -C C:/repo/wt -C C:/repo/other add -- docs/features/active/x/spec.md` — expect `False`
  13. `git -C C:/repo/wt` — expect `False`
  14. `git -C C:/repo/wt -- docs/features/active/x/spec.md` — expect `False`
  15. `git -C subdir add -- docs/features/active/x/spec.md` — expect `False`
  16. `git -C //server/share/wt add -- docs/features/active/x/spec.md` — expect `False`
  17. `git -C C:/repo/wt/../other add -- docs/features/active/x/spec.md` — expect `False`
  18. `git -C C:/repo/./wt add -- docs/features/active/x/spec.md` — expect `False`
  19. `git -C C:/repo/wt:branch add -- docs/features/active/x/spec.md` — expect `False`
  20. `git -C "" add -- docs/features/active/x/spec.md` — expect `False`

- [ ] [P0-T5] Settle research open question Q1. Run `git -Cfoo status` once and record whether git reports an unknown option, into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/git-attached-selector-probe.2026-09-13T22-40.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode:` set to the observed value, and `Output Summary:` quoting git's message verbatim. This does not gate the design — LACS denies the attached spelling either way — it only makes the documented option table accurate. Acceptance: the artifact quotes git's verbatim response and states, in one sentence, whether the attached spelling is accepted. If the invocation is refused by a hook or guard rather than answered by git, record the refusal text verbatim under `Output Summary:`, set `ExpectedExitCode:` to the observed value, and report this task INCOMPLETE with its box left unchecked. The design does not depend on the answer, so an INCOMPLETE here does not block Phase 1.
- [ ] [P0-T6] Run `mcp__drm-copilot__run_poshqc_format` and record the baseline into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/poshqc-format.2026-09-13T22-40.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. This tool is write-mode: it rewrites files and exits 0 whether or not it changed anything, so the exit code alone distinguishes nothing. Record `git status --porcelain` output captured immediately before the invocation and again immediately after, and state in `Output Summary:` whether the two are byte-identical. Acceptance: the artifact carries both porcelain captures, an explicit statement of whether the formatter rewrote any tracked file, and a section headed `Formatter-rewritten paths:` that enumerates by repository-relative path every tracked file whose porcelain status changed between the two captures, or records the single word `none`. If that enumeration names any of the four gate files, any of the four modes files, or any copy of `hook-command-invocation.ps1`, record that fact in the artifact and report the run as INCOMPLETE rather than PASS, because the spec criteria beginning `The four gate files are byte-unchanged`, `The four modes files are byte-unchanged`, and `The epic-merge gate's matcher is not widened` each require an empty diff for those paths and pre-existing format drift on them must land as its own change.
- [ ] [P0-T7] Run `mcp__drm-copilot__run_poshqc_analyze` as the route-compliance step, then take the baseline analyzer findings from the direct-invocation derivation in governing paragraph 3. The MCP result carries no per-file finding and no diagnostic count, so it is not the source of any value asserted here. For each of the six paths in scope at baseline — the four copies of `enforce-orchestration-preimplementation-gate-helpers.ps1` under `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, plus `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` — issue one `Invoke-ScriptAnalyzer -Path <path> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information` and record `@($findings).Count` together with the `RuleName`, `Severity`, `Line`, and `Message` of every finding. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/poshqc-analyze.2026-09-13T22-40.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` recording the MCP call disposition, and `Output Summary:`. Acceptance: the artifact names all six paths by repository-relative path, records a numeric `@($findings).Count` for each, and carries exactly that many finding rows for each path, every row carrying all four of `RuleName`, `Severity`, `Line`, and `Message`. This is the baseline, so a non-zero count does not fail the task — but an absent path, a missing or non-numeric count, a row count that disagrees with the recorded count, or a finding row missing any of the four fields does fail it and is reported INCOMPLETE. The MCP disposition is recorded alongside and does not decide this task.
- [ ] [P0-T8] Run `mcp__drm-copilot__run_poshqc_test` in coverage-enabled mode as the route-compliance step, then derive every baseline number from the on-disk reports per governing paragraphs 2 and 4. The MCP result carries no count and no percentage, so it is not the source of any value asserted here. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/poshqc-test-coverage.2026-09-13T22-40.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` recording the MCP call disposition, and `Output Summary:` carrying: from `artifacts/pester/pester-junit.xml`, the root `testsuites` element's `tests`, `failures`, `errors`, and `disabled` attribute values and the passed count computed as `tests` minus `failures` minus `errors` minus `disabled`; the `name`, `classname`, and `status` of every `testcase` whose `status` attribute is `Failed`; and, from `artifacts/pester/powershell-coverage.xml`, the report-level `counter type="LINE"` `covered` and `missed` values with the baseline line-coverage percentage computed as `covered / (covered + missed)`. Also record the per-file line coverage of `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` under the disambiguated `sourcefile` selection rule, or `UNMEASURED — no sourcefile entry emitted` when that node is absent. Acceptance: `Output Summary:` carries five numeric test counts, a numeric `covered` and `missed` pair, and a numeric baseline line-coverage percentage; the placeholder `UNVERIFIED` is not an acceptable value for any of them; and the count of enumerated failing nodes equals the recorded `failures` value. This is the baseline, so a non-zero failed count does not fail this task, but the failing-node enumeration is mandatory because [P6-T3] compares against it. This condition fails when any of those numbers is absent or non-numeric, when the failing-node enumeration is shorter than the recorded `failures` value, or when a `testsuites` attribute named above is missing from the report.
- [ ] [P0-T9] Run the two Python push-down contract tests that pin the bundle parity this change depends on — `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` — and record the baseline into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/python-pushdown-contracts.2026-09-13T22-40.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying passed and failed counts. Acceptance: `Output Summary:` records a numeric passed count and a numeric failed count for the two files.
- [ ] [P0-T10] In `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`, change the acceptance-criterion line beginning `An **executed** fail-before capture exists at` from `- [ ]` to `- [x]`. Change no other character of that line and add or remove no criterion. Acceptance: `(Select-String -SimpleMatch -Pattern '- [x] ' -Path docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md).Count` equals `3`, and the total count of lines matching either `- [x] ` or `- [ ] ` in that file is still `29`.

### Phase 1 — LACS on the Claude canonical helpers copy

- [ ] [P1-T1] In `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, add a script-scoped constant block declaring `$script:OrchestrationSelectorOptionName` with the value `-C`, placed with the three existing constant blocks that occupy lines 20–37, together with a short comment citing D4 row 14 and this feature's spec. Do not modify `$script:OrchestrationBookkeepingTrees`, `$script:UnresolvableCommandCharacters`, or `$script:PathspecWildcardCharacters`. Acceptance: `Select-String -SimpleMatch -Pattern 'OrchestrationSelectorOptionName' -Path .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` returns at least one line, and `Select-String -SimpleMatch -Pattern 'PathspecWildcardCharacters = [char[]]' -Path` that same file still returns exactly one line.
- [ ] [P1-T2] In the same file, add the advanced function `Test-ExemptOrchestrationSelector` with `[CmdletBinding()]`, `[OutputType([bool])]`, a mandatory named `[string[]]` token parameter, and comment-based help citing D4 row 14 and this feature's spec. It implements exactly the eight lexical conditions L1 through L8 from the spec and emits the diagnostic tokens `PREIMPL_SELECTOR_UNMODELLED_OPTION`, `PREIMPL_SELECTOR_REPEATED`, `PREIMPL_SELECTOR_MALFORMED`, `PREIMPL_SELECTOR_NOT_ROOTED`, `PREIMPL_SELECTOR_TRAVERSAL`, and `PREIMPL_SELECTOR_NOT_LITERAL` through `Write-Debug`. It performs no disk, process, network, or environment access. Acceptance: `Select-String -SimpleMatch -Pattern 'function Test-ExemptOrchestrationSelector' -Path .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` returns exactly one line, and `Select-String -SimpleMatch` for each of the six diagnostic tokens returns at least one line in that file.
- [ ] [P1-T3] In the same file, absorb the selector in the prologue of `Test-ExemptOrchestrationSegmentToken`, inserting the absorption between the current lines 232 and 233. The current prologue sets `$subcommand = $Token[1]` at line 233 and starts operand collection with `$index = 2` at line 240; both lines must remain byte-unchanged. The inserted block examines the token at index 1: when it is the selector option and `Test-ExemptOrchestrationSelector` accepts the segment, the block rebuilds the local token array without the selector option token and its value token, so the subcommand is again at index 1 and operand collection again starts at index 2; when the token at index 1 is the selector option and the predicate rejects the segment, the function returns `$false`. The only pre-existing lines this task may remove or reword are the comment at lines 227–229, which no longer describes the behaviour accurately. Every branch below the prologue — the `--` separator handling at lines 246–251, the option handler at lines 253–274, the zero-operand check at lines 283–285, and the all-operands-exempt loop at lines 288–292 — keeps its existing text. Acceptance: `Select-String -SimpleMatch -Pattern 'Test-ExemptOrchestrationSelector -' -Path .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` returns at least one line inside the body of `Test-ExemptOrchestrationSegmentToken`; `Select-String -SimpleMatch -Pattern 'if ($operands.Count -eq 0) {' -Path` that file still returns exactly one line; `Select-String -SimpleMatch -Pattern '$index = 2' -Path` that file still returns exactly one line; and `Select-String -SimpleMatch -Pattern '$subcommand = $Token[1]' -Path` that file still returns exactly one line.
- [ ] [P1-T4] In the same file, add a comment block recording the nested-subdirectory escape as an accepted, measured widening, beginning with the literal `Accepted widening`, following the precedent record the gate file already carries at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 101–110. The comment states the measured exposure as seven Markdown test fixtures under the `resolve_execute_plan_prompt` fixture tree and notes that the epic's F1 resolution module composes upstream to close the escape later without a schema change. It must not contain the literals `Test-Path`, `Resolve-Path`, `Start-Process`, `Invoke-Expression`, `git worktree`, or `env:`. Acceptance: `Select-String -SimpleMatch -Pattern 'Accepted widening' -Path .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` returns at least one line, and `Select-String -SimpleMatch` for each of `git worktree`, `Test-Path`, `Start-Process`, `Resolve-Path`, `Invoke-Expression`, and `env:` returns no line in that file.
- [ ] [P1-T5] Verify the edited canonical copy in isolation: parse it with `[System.Management.Automation.Language.Parser]::ParseFile`, take its line count with `(Get-Content -LiteralPath .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1).Count`, and re-run the twenty-row reproduction from [P0-T4] against it. Write the result to `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/canonical-copy-check.2026-09-14T00-20.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the parse produces no error, the line count is at most `500`, rows 2, 3, and 9 now record `True`, and rows 1, 4 through 8, and 10 through 20 record the same value the [P0-T4] artifact recorded for them. If the added content exceeds roughly 150 lines, stop and report that the design has drifted beyond one axis rather than splitting the file.

### Phase 2 — Mirror the canonical copy to the three remaining surfaces

- [ ] [P2-T1] Copy `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` onto `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` with `Copy-Item` inside a PowerShell session, not with the Write or Edit tool. Acceptance: `(Get-FileHash -LiteralPath .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1).Hash` equals `(Get-FileHash -LiteralPath .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1).Hash`.
- [ ] [P2-T2] Copy the same canonical file onto `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` with `Copy-Item`. Acceptance: the two `Get-FileHash` values are equal.
- [ ] [P2-T3] Scheduled production-side batch-budget reset, between the third and the fourth production PowerShell file. Delete every PowerShell batch-budget state file under `.claude/state/` matching the name pattern `powershell-batch-budget.*.json`. Run this task unconditionally; deleting an absent state file is a no-op and is safe. If the budget hook has already denied an edit, the deny message names the exact state file path — delete that path. Acceptance: `Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue` returns zero items. Record the action in `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/batch-budget-reset.2026-09-14T00-20.md` with `Timestamp:`, `Command:`, and `EXIT_CODE:`.
- [ ] [P2-T4] Copy the same canonical file onto `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` with `Copy-Item`. Acceptance: the two `Get-FileHash` values are equal.
- [ ] [P2-T5] Record the post-mirror state of all four helpers copies into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/helpers-surface-parity.2026-09-14T00-20.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing each path with its `Get-FileHash` value and its `(Get-Content -LiteralPath <path>).Count` value. Acceptance: the four hash values collapse to exactly one distinct value and each line count is at most `500`.

### Phase 3 — LACS rows in the two command-exemption suites

- [ ] [P3-T1] In `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, add a new `Context 'issue #671 worktree selector allow cases'` block after the existing `Context 'issue #539 residual whole-command-text behaviour (D3 and D8)'` block that begins at line 245, containing the seven `-ForEach` allow rows the spec's "Matrix — new rows" table defines, in an `It 'allows <Label>'` shape, driving each decision through the existing `Get-ExemptionDecisionForCommand` helper defined at line 50 and asserting `permissionDecision` equals `allow`. Modify no existing `It` node and no existing `-ForEach` row. Acceptance: `Select-String -SimpleMatch -Pattern 'issue #671 LACS allow 1' -Path` that file returns exactly one line, and `Select-String -SimpleMatch -Pattern 'issue #671 LACS allow 7' -Path` that file returns exactly one line.
- [ ] [P3-T2] In the same file, add a new `Context 'issue #671 worktree selector deny cases'` block containing the seventeen `-ForEach` deny rows the spec's "Matrix — new rows" table defines, in an `It 'denies <Label>'` shape, each asserting `permissionDecision` equals `deny` and `permissionDecisionReason` matching `PREIMPLEMENTATION_GATE_BLOCKED`. Assert the decision only; never assert the `Write-Debug` diagnostic text, which is non-contractual. Acceptance: `Select-String -SimpleMatch` for each of the twelve tokens `LACS L1a`, `LACS L1b`, `LACS L2`, `LACS L3a`, `LACS L3b`, `LACS L4a`, `LACS L4b`, `LACS L5a`, `LACS L5b`, `LACS L6`, `LACS L7`, and `LACS L8` returns at least one line in that file.
- [ ] [P3-T3] Run `mcp__drm-copilot__run_poshqc_test` as the route-compliance step, then read the Claude command-exemption suite result from `artifacts/pester/pester-junit.xml` per the per-node derivation in governing paragraph 2. The MCP result carries no node result, so it is not the source of any value asserted here. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/claude-exemption-suite.2026-09-14T00-20.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` recording the MCP call disposition, and `Output Summary:` listing, for each asserted node, the `testcase` match count, the matched `classname`, and the observed `status` string, plus the asserted suite's `testsuite` element `tests`, `failures`, `errors`, `skipped`, and `disabled` attribute values. Acceptance: scoping every selection to `classname` values ending with `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, each of the seven `It` labels `allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand`, `allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector`, `denies issue #671 cd chain into the target worktree`, `denies issue #671 selector with a non-exempt pathspec operand`, `denies issue #671 selector with the tree-wide all flag`, `denies issue #671 selector with an absolute pathspec operand`, and `denies issue #671 selector with an output redirection` matches exactly one `testcase` whose `name` attribute ends with `.` followed by that label and whose `status` attribute is `Passed`; and the single `testsuite` element whose `name` attribute ends with that same repository-relative path carries `failures="0"` and `errors="0"`. A match count of `0` or greater than `1` for any of the seven, a `status` other than `Passed`, a non-zero `failures` or `errors` on that `testsuite`, or an absent `testsuite` element for that path fails this task and is reported INCOMPLETE, never PASS.
- [ ] [P3-T4] In `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, add the same two Contexts with byte-identical label text, placed after the existing `Context 'issue #539 residual whole-command-text behaviour (D3 and D8)'` block that begins at line 249, driving each decision through the Codex helper `Get-CodexExemptionDecisionForCommand` defined at line 54 rather than the Claude-side helper name. Modify no existing `It` node and no existing `-ForEach` row. Acceptance: `Select-String -SimpleMatch -Pattern 'issue #671 worktree selector allow cases' -Path` that file returns exactly one line, `Select-String -SimpleMatch -Pattern 'issue #671 worktree selector deny cases' -Path` that file returns exactly one line, and `Select-String -SimpleMatch -Pattern 'Get-ExemptionDecisionForCommand -Command' -Path` that file returns no line.
- [ ] [P3-T5] Run `mcp__drm-copilot__run_poshqc_test` as the route-compliance step, then read the Codex command-exemption suite result from `artifacts/pester/pester-junit.xml` per the per-node derivation in governing paragraph 2. The MCP result carries no node result, so it is not the source of any value asserted here. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/codex-exemption-suite.2026-09-14T00-20.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` recording the MCP call disposition, and `Output Summary:` listing, for each asserted node, the `testcase` match count, the matched `classname`, and the observed `status` string, plus the asserted suite's `testsuite` element `tests`, `failures`, `errors`, `skipped`, and `disabled` attribute values. Acceptance: scoping every selection to `classname` values ending with `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, each of the same seven `It` labels enumerated in [P3-T3] matches exactly one `testcase` whose `name` attribute ends with `.` followed by that label and whose `status` attribute is `Passed`; and the single `testsuite` element whose `name` attribute ends with that same repository-relative path carries `failures="0"` and `errors="0"`. The `classname` scoping is what makes this task distinct from [P3-T3], because [P3-T4] requires the two suites to carry byte-identical label text and an unscoped `name` match would therefore select two `testcase` elements. A match count of `0` or greater than `1` for any of the seven, a `status` other than `Passed`, a non-zero `failures` or `errors` on that `testsuite`, or an absent `testsuite` element for that path fails this task and is reported INCOMPLETE, never PASS.
- [ ] [P3-T6] Record the retained regression guards into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/exemption-regression-guards.2026-09-14T00-20.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: scoping every selection to `classname` values ending with the suite's repository-relative path, normalized to forward slashes, the artifact records for each of the two command-exemption suites the count of `testcase` elements whose `name` contains `.issue #539 fail-closed rule table deny cases.` as exactly `45`, the count whose `name` contains `.issue #539 orchestration-tree staging exemption allow cases.` as exactly `8`, and `status` as `Passed` for every one of those 53 elements; and it records `denies D4 row 14b - a directory-relocating option before the subcommand`, `denies D4 row 14c - a git-dir option before the subcommand`, and `denies D4 row 14d - a work-tree option before the subcommand` as matching exactly one `testcase` each per suite with `status` `Passed`, confirming zero assertion reversals. A recorded count other than `45` or `8`, a `status` other than `Passed`, or an absent `testsuite` element for either suite path fails this task and is reported INCOMPLETE, never PASS. The Context-scoped `name` containment is required rather than a bare token count: a naive count of `name` values containing `D4 row ` returns `46`, because the allow node `allows a backslash-spelled operand after separator normalization (D4 row 18)` carries that text, and a naive count of `name` values containing `allows ` returns `15` once [P3-T1] has added the seven new allow rows.
- [ ] [P3-T7] In `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`, change the acceptance-criterion lines beginning `The seven `, `The same seven allow rows`, `The chained-segment allow is pinned`, `The \`cd\`-chain denial is pinned`, `Each LACS condition L1 through L8`, and `The pathspec, option, and metacharacter restrictions are not weakened` from `- [ ]` to `- [x]`. Change no other character of any line and add or remove no criterion. Acceptance: `(Select-String -SimpleMatch -Pattern '- [x] ' -Path docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md).Count` equals `9`, and the total count of lines matching either `- [x] ` or `- [ ] ` in that file is still `29`.

### Phase 4 — Surface-parity suite

- [ ] [P4-T1] Contingency test-side batch-budget reset, run before the third distinct test PowerShell file is created. Delete every PowerShell batch-budget state file under `.claude/state/` matching the name pattern `powershell-batch-budget.*.json`. Run this unconditionally; deleting an absent state file is a no-op. Repeat it at any later point where the budget hook denies a test-file edit, whatever the plan predicted. Acceptance: `Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue` returns zero items.
- [ ] [P4-T2] Create `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` with `#Requires -Version 7.0` and `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`, resolving the repository root from `$PSScriptRoot` in `BeforeAll` in the manner the Codex contract suite uses at `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 6, and containing exactly two `It` nodes: `keeps all four surface copies of the helpers module byte-identical by SHA256 hash`, which compares `(Get-FileHash -LiteralPath <path>).Hash` across the four `-helpers.ps1` paths and asserts a single distinct value; and `keeps every surface copy of the helpers module under the 500-line cap`, which asserts `(Get-Content -LiteralPath <path>).Count` is at most 500 for each of the four copies, mirroring the expression the existing Codex contract test uses at its line 106. The suite creates no temporary file, starts no process, and makes no network call. Because this file is untracked while the plan executes, assert against it with `Select-String`, never with `git grep`. Acceptance: `Test-Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` returns `True`, and `Select-String -SimpleMatch -Pattern 'keeps all four surface copies of the helpers module byte-identical by SHA256 hash' -Path` that file returns exactly one line.
- [ ] [P4-T3] Run `mcp__drm-copilot__run_poshqc_test` as the route-compliance step, then read the parity suite result from `artifacts/pester/pester-junit.xml` per the per-node derivation in governing paragraph 2. The MCP result carries no node result, so it is not the source of any value asserted here. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/helpers-parity-suite.2026-09-14T00-20.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` recording the MCP call disposition, and `Output Summary:` listing, for each asserted node, the `testcase` match count, the matched `classname`, and the observed `status` string, plus the asserted suite's `testsuite` element `tests`, `failures`, `errors`, `skipped`, and `disabled` attribute values, and the post-change `@(Get-Content -LiteralPath <path>).Count` of each of the four helpers copies. Acceptance: scoping every selection to `classname` values ending with `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, each of the two `It` labels `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` and `keeps every surface copy of the helpers module under the 500-line cap` matches exactly one `testcase` whose `name` attribute ends with `.` followed by that label and whose `status` attribute is `Passed`; the single `testsuite` element whose `name` attribute ends with that same repository-relative path carries `failures="0"` and `errors="0"`; and each of the four recorded line counts is at most `500`. A match count of `0` — the state a newly created suite produces when the runner never picked it up — fails this task and is reported INCOMPLETE, never PASS.
- [ ] [P4-T4] In `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`, change the acceptance-criterion line beginning `Node \`keeps all four surface copies of the helpers module byte-identical by SHA256 hash\`` from `- [ ]` to `- [x]`. Change no other character of that line. Acceptance: `(Select-String -SimpleMatch -Pattern '- [x] ' -Path docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md).Count` equals `10`, and the total count of lines matching either `- [x] ` or `- [ ] ` in that file is still `29`.

### Phase 5 — Diff confinement and executed pass-after capture

- [ ] [P5-T1] Confirm the four gate files are byte-unchanged. Run `git status --porcelain` and `git diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, recording both into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/diff-confinement-gate-files.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the diff output is empty and the porcelain output lists none of the four gate paths.
- [ ] [P5-T2] Confirm the four modes files are byte-unchanged. Run `git status --porcelain` and `git diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, recording both into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/diff-confinement-modes-files.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the diff output is empty and the porcelain output lists none of the four modes paths.
- [ ] [P5-T3] Confirm the epic-merge gate's matcher is not widened. Run `git status --porcelain` and `git diff --merge-base main -- .claude/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1 .claude/hooks/enforce-epic-merge-gate.ps1`, then run `mcp__drm-copilot__run_poshqc_test` as the route-compliance step and read both merge-gate suites' results from `artifacts/pester/pester-junit.xml` per the per-node derivation in governing paragraph 2, because the MCP result carries no node result. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/diff-confinement-shared-parser.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying, for each of the two suites, the `testsuite` element's `name`, `tests`, `failures`, `errors`, `skipped`, and `disabled` attribute values. Acceptance: the diff output is empty, the porcelain output lists none of the five paths, and the JUnit report contains exactly one `testsuite` element whose `name` attribute, normalized to forward slashes, ends with `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` and exactly one whose `name` attribute ends with `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`, each carrying `failures="0"` and `errors="0"`. An absent `testsuite` element for either path fails this task and is reported INCOMPLETE, never PASS, because a suite the runner never executed would otherwise read as clean.
- [ ] [P5-T4] Confirm the helpers diff is confined to one axis. Run `git status --porcelain` and `git diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, and record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/diff-confinement-helpers.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: every removed content line in that diff — every line beginning with a single `-` that is not the `---` file header — has text that occurs within the pre-change lines 227–236 block quoted in the research artifact, and no hunk removes or modifies a line inside `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationStagingCommand`, or the three pre-existing `$script:` constant blocks. The artifact enumerates each removed line and states which of those regions it belongs to. The artifact also carries a section headed `Changed-line set:` enumerating, as a comma-separated list of post-change line numbers in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, every added content line in that diff — every line beginning with a single `+` that is not the `+++` file header — each number read from a `git diff --merge-base main --unified=0 -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` capture that this artifact also records alongside the default-context capture: at zero context, each hunk header `@@ -a,b +c,d @@` contributes exactly the consecutive post-image numbers `c` through `c + d - 1`, where `d` is that hunk's added-content-line count and is omitted from the header when it is `1`, and a hunk whose `d` is `0` removes only and contributes no number. The `--unified=0` capture is an additional recorded span in this same task, not a replacement for the default-context capture: the removed-line confinement assertion above reads the default-context capture, which carries the surrounding context lines that assertion needs, so both captures are recorded in this artifact. That list is the changed-line set [P6-T4] reads. It must be non-empty, and the count of numbers listed must equal the count of added content lines in the diff. The artifact also carries a line headed `Helpers hash at capture:` recording `(Get-FileHash -LiteralPath .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1).Hash` as observed at the moment the diff was taken, so a later task can tell whether the changed-line set is still current.
- [ ] [P5-T5] Confirm no existing test assertion is reversed. Run `git status --porcelain` and `git diff --merge-base main -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, and record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/diff-additive-only-test-suites.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the diff contains no removed content line — no line beginning with a single `-` that is not the `---` file header — and the artifact records the count of removed content lines as `0`.
- [ ] [P5-T6] Confirm the changed-path set. Run `git status --porcelain` and `git diff --merge-base main --name-only`, and record both into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/changed-path-set.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The name-listing diff enumerates tracked changes only and is blind to the new parity suite, which is why the porcelain capture is required in the same task. Acceptance: after removing from the union every path the [P0-T6] artifact enumerates under `Formatter-rewritten paths:`, the union contains exactly four production `.ps1` paths and all four end in `enforce-orchestration-preimplementation-gate-helpers.ps1`; contains the two bundled helpers paths as well as the two canonical ones; contains no path ending in `.py`; and contains the new parity suite path reported by the porcelain capture as untracked. The exclusion set is read from the named artifact, not selected by the executor; if that artifact records `none`, no path is excluded.
- [ ] [P5-T7] Confirm the helpers module's declared purity survives on all four copies. Acceptance: `Select-String -SimpleMatch -Pattern 'Pure string logic only: no disk, process, network, or environment access'` returns exactly one line in each of the four helpers copies; `Select-String -SimpleMatch` for each of `git worktree`, `Test-Path`, `Start-Process`, `Resolve-Path`, `Invoke-Expression`, and `env:` returns no line in any of the four copies; and `Select-String -SimpleMatch -Pattern 'Import-Module'` returns no line in any of the four copies. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/helpers-purity.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing each literal and its per-copy match count.
- [ ] [P5-T8] Confirm the accepted-widening record. Acceptance: `Select-String -SimpleMatch -Pattern 'Accepted widening'` returns at least one line in each of the four helpers copies, and the artifact `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/accepted-widening-record.2026-09-14T01-00.md` quotes the surrounding comment verbatim and confirms it states both the measured exposure (seven Markdown test fixtures under the `resolve_execute_plan_prompt` fixture tree) and the note that the epic's F1 resolution module composes upstream to close the escape later without a schema change. The artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [ ] [P5-T9] Execute the pass-after capture. Repeat the [P0-T4] procedure verbatim against the post-change tree, in one `pwsh` session started at the worktree root, dot-sourcing `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and calling `Test-ExemptOrchestrationStagingCommand -CommandText` for the same twenty rows in the same order. Create no temporary file. Write the result to `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/pass-after-lacs-repro.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: rows 2, 3, and 9 record `True`, and rows 1, 4 through 8, and 10 through 20 record exactly the values the [P0-T4] fail-before artifact recorded for them; the artifact states the row-by-row comparison explicitly.
- [ ] [P5-T10] In `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`, change the acceptance-criterion lines beginning `No existing assertion is reversed`, `The four gate files are byte-unchanged`, `The four modes files are byte-unchanged`, `The epic-merge gate's matcher is not widened`, `The helpers diff is confined to one axis`, `An **executed** pass-after capture exists`, `No Python leg is introduced`, `The change adds no new production file`, `The helpers module's declared purity survives`, and `The nested-subdirectory widening is recorded in the helpers file` from `- [ ]` to `- [x]`. Change no other character of any line and add or remove no criterion. Acceptance: `(Select-String -SimpleMatch -Pattern '- [x] ' -Path docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md).Count` equals `20`, and the total count of lines matching either `- [x] ` or `- [ ] ` in that file is still `29`.

### Phase 6 — Final QA loop

- [ ] [P6-T1] Run `mcp__drm-copilot__run_poshqc_format`. Immediately before and immediately after the invocation, record `(Get-FileHash -LiteralPath <path>).Hash` for each of the seven PowerShell files this plan touches — the four copies of `enforce-orchestration-preimplementation-gate-helpers.ps1` under `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, plus `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` — and capture `git status --porcelain` before and after. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/poshqc-format.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying both hash tables and both porcelain captures. This tool is write-mode and exits 0 whether or not it rewrote a file, and `git status --porcelain` cannot detect a rewrite of a file that is already modified — by this point all seven are — so the per-file hash pair is the assertion and the porcelain pair is recorded only for the untracked-file view. Acceptance: all seven before-and-after hash pairs are equal, and the two porcelain captures are byte-identical. If any hash pair differs, the formatter repaired drift: restart this phase from [P6-T1], and because line numbers in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` may have moved, re-run [P5-T4] to regenerate its `Changed-line set:` section before [P6-T4] reads it. This task is unconditional; `EXIT_CODE: SKIPPED` is not a passing outcome.
- [ ] [P6-T2] Run `mcp__drm-copilot__run_poshqc_analyze` as the route-compliance step, then take the post-change analyzer findings from the direct-invocation derivation in governing paragraph 3. The MCP result carries no per-file finding and no diagnostic count, so it is not the source of any value asserted here. Issue one `Invoke-ScriptAnalyzer -Path <path> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information` per asserted path, for each of the seven: the four copies of `enforce-orchestration-preimplementation-gate-helpers.ps1` under `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, plus `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/poshqc-analyze.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` recording the MCP call disposition, and `Output Summary:` naming all seven paths, each with its `@($findings).Count` and, where that count is non-zero, one row per finding carrying `RuleName`, `Severity`, `Line`, and `Message`. Acceptance: the artifact names all seven paths and records `@($findings).Count` as `0` for every one of them, with no finding rows. A non-zero count on any of the seven, a missing path, or a non-numeric count fails this task: fix the finding and restart the loop from [P6-T1]. The MCP disposition is recorded alongside; a divergence between it and the direct runs is recorded and does not by itself decide this task. This task is unconditional; `EXIT_CODE: SKIPPED` is not a passing outcome.
- [ ] [P6-T3] Run `mcp__drm-copilot__run_poshqc_test` in coverage-enabled mode over the repository test set as the route-compliance step, then derive every asserted number from the on-disk reports per governing paragraphs 2 and 4. The MCP result carries no count and no percentage, so it is not the source of any value asserted here. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/poshqc-test-coverage.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` recording the MCP call disposition, and `Output Summary:` carrying: from `artifacts/pester/pester-junit.xml`, the root `testsuites` element's `tests`, `failures`, `errors`, and `disabled` attribute values, the computed passed count, and the `name`, `classname`, and `status` of every `testcase` whose `status` attribute is `Failed`; from `artifacts/pester/powershell-coverage.xml`, the report-level `counter type="LINE"` `covered` and `missed` values and the post-change line-coverage percentage computed as `covered / (covered + missed)`; the baseline `covered`, `missed`, and percentage restated from the [P0-T8] artifact alongside them, so the change in coverage is attributable rather than absorbed; and the post-change `@(Get-Content -LiteralPath <path>).Count` of each of the four helpers copies. Acceptance, all four conditions: (a) the post-change `failures` value is less than or equal to the failed count the [P0-T8] artifact recorded, and the post-change `errors` value is less than or equal to the `errors` value the [P0-T8] artifact recorded, and no node in the post-change failing-node enumeration has a `classname` ending with `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, or `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, and no failing node's `name` attribute contains `issue #671`; (b) the post-change line-coverage percentage is a number at or above `85`; (c) both the baseline and the post-change percentages are recorded as numbers together with their `covered` and `missed` pairs; (d) each of the four recorded helpers line counts is at most `500`. A post-change `failures` value above the recorded baseline, or any failing node attributable to this change under (a), fails this task. Condition (a) is deliberately not an absolute failed count of `0`: the absolute count can legitimately be non-zero for reasons this change does not cause, as recorded at `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/evidence/baseline/phase0-powershell-pester-coverage.2026-08-08T10-42.md` lines 28–54, where a baseline failed count of 2 is caused by two hook suites reading the real, gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam. It is equally not softened to "the run succeeded": the comparison is against a recorded number and an attribution test, both of which a regression introduced by this change would fail. If the [P0-T8] baseline percentage is itself below `85`, the shortfall predates this change: record both numbers and report this task as INCOMPLETE rather than PASS, and do not check its box. Coverage on the changed lines of the helpers file is verified in [P6-T4] under the changed-line rule of governing paragraph 4. Placeholder values such as `UNVERIFIED` are not acceptable. This task is unconditional; `EXIT_CODE: SKIPPED` is not a passing outcome.
- [ ] [P6-T4] Write the coverage comparison into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/coverage-comparison.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording three numeric values: the baseline line-coverage percentage restated from the [P0-T8] artifact's recorded report-level `counter type="LINE"` `covered` and `missed` pair; the post-change line-coverage percentage restated from the [P6-T3] artifact's recorded report-level `counter type="LINE"` `covered` and `missed` pair; and the changed-line coverage of `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, read from `artifacts/pester/powershell-coverage.xml` by selecting the `sourcefile` node whose `name` attribute is `enforce-orchestration-preimplementation-gate-helpers.ps1` and whose parent `package` node's `name` attribute, normalized to forward slashes, ends with `.claude/hooks`, then taking its `line` children whose `nr` attribute is a line number listed under the `Changed-line set:` heading of the [P5-T4] artifact and reporting the fraction of those whose `ci` attribute is greater than `0`. Restate both `covered` and `missed` pairs verbatim in this artifact, not the percentages alone, so each restatement is checkable against its source artifact rather than merely asserted. Acceptance: all three values are numeric; the two restated `covered`/`missed` pairs match the pairs recorded in the [P0-T8] and [P6-T3] artifacts respectively; the post-change percentage is at or above `85`; and the changed-line value is `100%`, or, where it is below `100%`, every changed line whose `ci` is `0` and every changed line number with no `line` child in the report is named individually by its `nr` with a one-sentence statement of why the suites do not reach it. If the disambiguated `sourcefile` selection yields no node, record `UNMEASURED — no sourcefile entry emitted`, name the `package` `name` values the report does contain, and report this task INCOMPLETE rather than PASS; the `package` disambiguation is required because the same leaf filename exists on four surfaces. If that heading is absent or its list is empty, report this task INCOMPLETE rather than PASS. Before computing the ratio, compare `(Get-FileHash -LiteralPath .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1).Hash` against the value the [P5-T4] artifact records under `Helpers hash at capture:`. If the two differ, the file changed after the changed-line set was captured and that set is stale: re-run [P5-T4] against the current tree, record the regenerated `Changed-line set:` and the new hash there, and note the re-run in this artifact before computing the ratio. A ratio computed against a stale set is reported INCOMPLETE, never PASS. Pester measures command and line coverage only, so no branch-coverage value is recorded and no branch-coverage gate applies.
- [ ] [P6-T5] Run `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/python-pushdown-contracts.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying numeric passed and failed counts. Acceptance: the failed count is `0` and the artifact records `test_bundled_claude_payload_contains_all_repo_runtime_contracts` as passed. No Python file is edited by this plan; these tests are run because they assert the bundle parity this change depends on. This task is unconditional; `EXIT_CODE: SKIPPED` is not a passing outcome.
- [ ] [P6-T6] Record the cross-suite must-not-regress roll-up into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/must-not-regress-rollup.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, reading node results from the [P6-T3] run. Acceptance: nodes `blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)` and `blocks an implementation write when the checkpoint omits the feature folder` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` both report Passed; nodes `allows staging an epic document under the epics tree` and `allows a chained two-segment line whose every segment is independently exempt` report Passed in both command-exemption suites; node `keeps the canonical hooks byte-identical to their bundled copies` and node `parse-checks each root and bundled hook and keeps every file within 500 lines` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` both report Passed; and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` each report zero failed nodes. Scope every `testcase` selection to `classname` values ending with the named suite's repository-relative path, and every `testsuite` selection to `name` values ending with that path, both normalized to forward slashes. Record, for each asserted node, the match count and the observed `status` string, and for each of the three mode suites the `testsuite` element's `tests`, `failures`, `errors`, `skipped`, and `disabled` attribute values. A match count of `0` or greater than `1` for any asserted node, or an absent `testsuite` element for any of the three mode suites, fails this task and is reported INCOMPLETE, never PASS: a suite the runner never executed reports zero failed nodes and would otherwise read as clean.
- [ ] [P6-T7] Confirm the loop closed in a single pass. Record into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/toolchain-single-pass.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` the ordered sequence of [P6-T1], [P6-T2], and [P6-T3] invocations that completed without any restart, naming the artifact path of each. Acceptance: the artifact names one format invocation, one analyze invocation, and one test invocation that ran consecutively with no intervening file change and no failure, and states the count of restarts that preceded that final sequence.
- [ ] [P6-T8] In `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`, change the acceptance-criterion lines beginning `Gates still deny when a required document is genuinely absent`, `Epic and standalone topologies behave exactly as now`, `Bundled-payload mirroring is complete`, `No file exceeds the 500-line cap`, `Line coverage is at or above 85%`, and `The full PowerShell toolchain passes in a single pass` from `- [ ]` to `- [x]`. Change no other character of any line and add or remove no criterion. Acceptance: `(Select-String -SimpleMatch -Pattern '- [x] ' -Path docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md).Count` equals `26`, and the total count of lines matching either `- [x] ` or `- [ ] ` in that file is still `29`.

### Phase 7 — Acceptance-criteria reconciliation and closeout

- [ ] [P7-T1] Reconcile the acceptance-criteria state in `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` against the evidence on disk and write `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/acceptance-criteria-reconciliation.2026-09-14T01-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing all twenty-four acceptance criteria, the task that delivered each, and the evidence artifact path that backs each. Acceptance: `(Select-String -SimpleMatch -Pattern '- [x] ' -Path docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md).Count` equals `26` and the total count of lines matching either `- [x] ` or `- [ ] ` in that file is `29`, meaning all twenty-four acceptance criteria are checked and the two pre-existing `- [x]` metadata lines are unchanged. If any criterion is unmet, leave it unchecked and record the gap explicitly in this artifact; a reconciliation that reports an unmet criterion is INCOMPLETE, not PASS.
- [ ] [P7-T2] Write the issue-update mirror `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/issue-updates/issue-671.2026-09-14T01-00.md` with `Timestamp:`, the exact update text intended for issue #671 summarizing the LACS change, the four mirrored surfaces, the executed fail-before and pass-after captures, and the numeric coverage result, plus `PostedAs:` recording `body`, `comment`, or `unknown`. Acceptance: the file exists and carries a `PostedAs:` field with one of those three values.
- [ ] [P7-T3] Record the follow-up candidates, neither of which is in F2 scope, into `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/follow-up-candidates.2026-09-14T01-00.md` with `Timestamp:`: upstream closure of the nested-subdirectory escape once the epic's F1 target-worktree resolution module exists; and adding `enforce-orchestration-preimplementation-gate-modes.ps1` to the `$script:SharedModuleNames` array at `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 30, which today leaves that file outside the Codex parse check, 500-line check, byte-identity check, and pack-manifest assertion. Acceptance: the artifact names both candidates and states explicitly that neither is implemented by this change.
