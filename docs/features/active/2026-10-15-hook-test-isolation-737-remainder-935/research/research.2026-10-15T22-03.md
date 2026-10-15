# Research: hook-test isolation remainder from #737 (Issue #935)

- Issue: #935
- Branch: `bug/hook-test-isolation-737-remainder-935`
- Base: `origin/main` at `adb9aa5f0`
- Mode: preparation (research only; no source, test, or configuration change)
- Timestamp source: this agent had no shell tool, so the filename stamp was read from the UTC time service `timeapi.io` (`2026-10-15T22:03:27Z`) immediately before the write, not from the host clock. The executor should note this deviation from the evidence-and-timestamp convention (host clock required) if the stamp is audited.

## Sources Read

| Source | Use |
|---|---|
| `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/issue.md` | Scope (F-3, N-2, F-6, F-1/F-2, I-3) |
| `docs/features/potential/promoted/2026-10-15-hook-test-isolation-737-remainder.md` | Lifecycle record (same body; Work Mode `minor-audit`) |
| `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/code-review.2026-10-09T06-46.md` | Findings F-1..F-6, N-1, N-2, I-1..I-3 |
| `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/other/process-spawning-report.2026-10-09T05-29.md` | AC-5 report baseline (6 lines, DEV-2 not in report) |
| `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/issue.md` | AC-34..AC-42, `## Note Dispositions` (#737 rows), `## Operator Follow-ups` 4, 5, 6, 10, 11 |
| `.../903/evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md` and `.../903/evidence/qa-gates/ps-rows.2026-10-13T13-43.md` | Withhold decision; the seven flagged suites; CI run 38404520141 |
| `.../903/research/p8b-review-nits-565-736-732-737-903.2026-10-11T10-52.md` sections 3.12-3.20 | F-1/F-2 design, I-3 list |
| `https://github.com/drmoisan/drm-copilot/commit/4e8d9f92d63c686f64f9f97e975448dc126c92f1.diff` (fetched) | Exact withheld F-1/F-2 implementation (see Item 1) |
| Guard sources under `tests/scripts/claude-hooks/`: `EpicStateIsolation.Helpers.ps1`, `.Discovery.Helpers.ps1`, `.Compliance.Helpers.ps1`, `.Baseline.Helpers.ps1`, and the five `enforce-gate-suites.EpicStateIsolation.*.Tests.ps1` suites | Current predicate, detector, and fixtures |
| The seven flagged suites, read in full or by structural grep | Root cause per suite |
| `docs/features/potential/promoted/2026-10-15-subagentstop-hook-uncaught-error-exits-1.md` (#928), `...-subagentstop-artifact-gates-review-notes-905.md` (#929), `...-hook-coverage-attribution-gaps.md` (#936) | Concurrency |
| `.claude/rules/powershell.md` line 31; `.github/instructions/powershell-code-change.instructions.md` line 53 | F-6 policy text |

No feature folder for #928, #929, or #936 exists under `docs/features/active/` (Glob `docs/features/*/*{928,929,936}*/**` returned no files), so their file lists are inferred from the promoted records only.

## Current State Analysis

### Guard architecture (verified by reading)

- `Get-EpicStateDiscoveredSuite` enumerates every `*.Tests.ps1` directly in `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`. Current population: 156 Claude suites and 64 Codex suites (220 AC-4 rows).
- A suite acquires requirements only through its loaded-source closure, which `Get-EpicStateLoadedSourceClosure` seeds exclusively from `hooks/<name>.ps1` string literals (`Get-EpicStateHookLiteral`, Discovery.Helpers lines 125-140). A suite with no such literal, or whose literal names a file with no seam, has zero requirements and cannot fail AC-4.
- `Get-EpicStateSuiteCompliance` (Compliance.Helpers lines 121-139) evaluates `Get-EpicStateIsolationFinding` once per requirement and reports only the first finding (`$form1[0]`). A finding can therefore mask later findings for the same seam.
- `Get-EpicStateIsolationFinding` (Helpers lines 409-438) evaluates every outermost `BeforeAll`. In each block it selects the hook dot-source with `Get-EpicStateIsolationHookDotSource` (lines 154-179): (i) a dot-source whose argument holds a `hooks/<name>.ps1` literal; (ii) a dot-source referencing a variable bound to such a literal; (iii) otherwise the first dot-source. Step (iii) is the F-2 fallback.
- `Get-EpicStateIsolationDirectCommand` (lines 181-201) treats only `ScriptBlockAst`, `ScriptBlockExpressionAst`, and `FunctionDefinitionAst` ancestors as nested. This is the F-1 gap.
- `Get-EpicStateProcessSpawningHook` (Discovery.Helpers lines 219-236) reports a suite only when it both contains a process-start token and names a hook by literal. This is the process-spawning half of F-3.

### Line counts of files in scope (primary: Grep count of `^`; cross-check: Grep multiline count of `\n`; both agree for every file below)

| File | Lines |
|---|---|
| `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` | 474 |
| `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` | 267 |
| `tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1` | 207 |
| `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` | 179 |
| `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1` | 197 |
| `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1` | 280 |
| `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` | 350 |
| `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` | 333 |
| `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1` | 123 |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | 500 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 500 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 500 |
| `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` | 500 |
| The seven flagged suites | 128, 341, 196, 236, 114, 205, 213 (order as listed in Item 1) |

## Item 1 - F-1/F-2 (Operator Follow-up 10)

### Withheld implementation recovered from commit 4e8d9f92d

The withhold commit removed 25 lines and added 3 in `EpicStateIsolation.Helpers.ps1`, removed 138 lines from `...Branches.Tests.ps1`, 8 from `...Predicate.Tests.ps1`, and 12 from `...EpicStateIsolation.Tests.ps1` (183 deletions, 3 insertions in total, matching `f1-f2-decision.2026-10-13T13-44.md`). The withheld helper was therefore 496 lines. The reverse of that diff is:

1. `Get-EpicStateIsolationHookDotSource`: doc text changed to "...(ii) otherwise the dot-source whose argument references a variable that the suite binds to such a literal. The first in source order wins within a step. $null when no dot-source identifies the hook (issue #903, #737 F-2)."; the final `return $candidates[0]` becomes `return $null`.
2. New function, inserted after `Get-EpicStateIsolationHookDotSource` (20 lines including a trailing blank line):

   ```powershell
   function Test-EpicStateIsolationConditionalAncestor {
       # Pure (issue #903, #737 F-1): true when Node is an if, switch, loop, try, or trap that may skip Command, except a single-clause if with no else whose condition is one Get-Command <Name> pipeline naming the Command's target.
       [OutputType([bool])]
       param([Parameter(Mandatory)] [System.Management.Automation.Language.Ast] $Node, [Parameter(Mandatory)] [System.Management.Automation.Language.CommandAst] $Command)
       if ($Node -isnot [System.Management.Automation.Language.IfStatementAst]) {
           return ($Node -is [System.Management.Automation.Language.SwitchStatementAst] -or $Node -is [System.Management.Automation.Language.LoopStatementAst] -or
               $Node -is [System.Management.Automation.Language.TryStatementAst] -or $Node -is [System.Management.Automation.Language.TrapStatementAst])
       }
       if ($Node.Clauses.Count -ne 1 -or $null -ne $Node.ElseClause) { return $true }
       $condition = $Node.Clauses[0].Item1
       if ($condition -isnot [System.Management.Automation.Language.PipelineAst] -or $condition.PipelineElements.Count -ne 1) { return $true }
       $guard = $condition.PipelineElements[0]
       if ($guard -isnot [System.Management.Automation.Language.CommandAst] -or $guard.GetCommandName() -ne 'Get-Command' -or $guard.CommandElements.Count -lt 2) { return $true }
       $targets = switch ($Command.GetCommandName()) {
           'Mock' { (Get-EpicStateIsolationMockBinding -Command $Command).CommandName }
           'Register-EpicStateBaselineMock' { Get-EpicStateIsolationStringConstant -Node $Command }
       }
       return -not (@($targets) -contains (Get-EpicStateIsolationElementText -Element $guard.CommandElements[1]))
   }
   ```

3. `Get-EpicStateIsolationDirectCommand`: inside the ancestor `while` loop, after the existing nested-type check, `if (Test-EpicStateIsolationConditionalAncestor -Node $parent -Command $command) { $nested = $true; break }`.
4. `Get-EpicStateIsolationFinding`: directly after the `$dotSource = ...` assignment, `if ($dotSources.Count -gt 0 -and $null -eq $dotSource) { 'no dot-source loads the hook' }`.
5. Fixture binding: `$script:UnderTest = Join-Path $PSScriptRoot 'hooks/enforce-x.ps1'` added as the first `BeforeAll` line of fixtures that dot-source `$script:UnderTest` (6 in Branches, 8 in Predicate, 12 in the legacy guard), so step (ii) identifies the hook once the fallback is removed.
6. Branches rows (one 132-line block): `F-1 non-compliant <Branch>` for `ESR mock inside if ($false)`, `ESR mock inside try/catch`, `ESR mock inside a Get-Command guard naming another seam` (each expects `Mock of Get-EpicScopeCheckpointText missing from outermost BeforeAll`); `F-1 compliant <Branch>` for `ESR mock inside a matching Get-Command guard` and `baseline helper inside a matching Get-Command guard` (zero findings); `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` (fixture dot-sources only `Helper.ps1`).

CI run 38404520141 passed all of these rows (`ps-rows.2026-10-13T13-43.md`: F-1 rows 6 passed, F-2 row 1 passed, Predicate AC-8 rows 6 passed). Only the full-population Discovery rows failed.

### Why each flagged suite fails (current main, by reading)

Every CI message was `<suite>: seam <name>: no dot-source loads the hook`. Each of the seven suites has a non-empty requirement set (it is in the literal population and registers baseline mocks) and at least one outermost `BeforeAll` whose dot-sources are not identified by step (i) or (ii). They fall into three shapes.

| # | Suite (repository-relative) | Lines | Shape | Root cause |
|---|---|---|---|---|
| 1 | `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` | 128 | A (root-variable composition) | Three `-ForEach $script:Runtimes` Describes dot-source `(Join-Path $script:RepoRoot "$HookRoot/<name>.ps1")` (lines 45, 66, 90); `HookRoot` is bound by the hashtable to `'.claude/hooks'`/`'.codex/hooks'`, which contains no `hooks/<name>.ps1` literal. The fourth Describe (line 111) uses a literal and is identified. The suite is in the population only through that literal (`enforce-pr-author-skill.ps1`). |
| 2 | `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` | 341 | A | Same `"$HookRoot/<name>.ps1"` form in the promotion-gate (line 40) and preimplementation-gate (line 189) Describes. |
| 3 | `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` | 196 | B (hook loaded only inside `It`) | Outermost `BeforeAll` dot-sources only `../claude-runtime/HookDependencyGraph.Helpers.ps1` and `EpicStateIsolation.Baseline.Helpers.ps1` (lines 38-39). Hooks are run per row through `Get-HookInvocationPath` (`&` at line 116, `.` at line 173). Hook literals exist only as reason-prefix table keys (lines 72-101). |
| 4 | `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` | 236 | B | Same: `BeforeAll` lines 39-40 dot-source helpers only; hooks are run in `It` (lines 72, 106, 176, 197). |
| 5 | `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` | 114 | C (no hook load) | Hook paths are data for a line-cap scan (lines 35-46); the only dot-source is `EpicStateIsolation.Baseline.Helpers.ps1` (line 21). No hook is loaded anywhere. |
| 6 | `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` | 205 | C | Hook paths are data for configuration and manifest assertions (lines 31-42, 163-175); the only dot-source is the Baseline helper (line 6). |
| 7 | `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` | 213 | B | `BeforeAll` lines 38-39 dot-source helpers only; hooks run in `It` (lines 101, 157, 185). |

All seven pass today only because step (iii) treats the first dot-source as the hook load. For shapes B and C that first dot-source is a test helper, which is the false-pass class F-2 targets in the abstract, but in these suites no hook is loaded in the `BeforeAll` at all, so no mock placement in that block can be "after the hook".

The F-1 rule does not add findings to these suites: every conditional mock in them is either the exact matching `if (Get-Command X ...) { Register-EpicStateBaselineMock -Seam 'X' ... }` shape, or a conditional `Mock Get-EpicScopeCheckpointText` (consumers lines 71-75, Issue824Regression lines 198-200) whose seam is also named by an unconditional `Register-EpicStateBaselineMock` call, so `Get-EpicStateIsolationHelperSeam` satisfies it. Because compliance reports only `$form1[0]`, this is a reading-based conclusion and must be confirmed by the post-change CI run.

### Suites on current main newly flagged beyond the seven

Method (reading, not execution): F-2 can only flag a suite that (a) has a non-empty requirement set and (b) has an outermost `BeforeAll` with at least one dot-source and no dot-source identified by step (i) or (ii). Suites with requirements are those that carry baseline mocks (109 files contain `Register-EpicStateBaselineMock` or `Invoke-EpicStateInterceptionProbe`, including helpers and guard suites). The dot-source inventory of `tests/scripts/claude-hooks/*.Tests.ps1` (390 dot-source lines) and the `$hookPath`/`$script:UnderTest` bindings were checked for every suite that merged after run 38404520141 and carries baseline mocks:

- `validate-orchestrator-output.Envelope`, `.Reentry`, `.human-interaction`, `.model-routing`, `.artifact-type-dispatch`, `.Tests`: `$hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'` (step ii) or a literal `subagentstop-envelope.ps1` dot-source (step i). Identified.
- `enforce-pr-author-skill.DocsOnly`, `.DocsOnly.Decision`, `.DocsOnly.Exemption` (#901): `$script:UnderTest` bound to a `.claude/hooks/enforce-pr-author-skill.ps1` literal. Identified.
- `validate-task-researcher-output.Coverage.Tests.ps1` dot-sources two helpers at lines 183-184 inside a row body, and its literal dot-sources are in their own Describes (lines 218, 277); it carries no baseline mock, so it has no requirement the change could fail.

Conclusion: no suite beyond the seven is expected to be flagged by F-1/F-2 on current main. This is unverified until the Discovery suite runs in CI with the change.

### Candidate approaches

1. **Edit the seven suites** (for example, bind `$script:HookPath` to a `hooks/<name>.ps1` literal in shape A, and add a hook dot-source to the outermost `BeforeAll` in shapes B and C). Shape A is a 3-6 line change per suite. Shapes B and C cannot be made compliant this way: shape B suites iterate every registered hook per row and are designed to load the hook only under a failing-dependency mock; shape C suites load no hook. This also edits three `hook-dependency-failure*` suites that #928 is likely to touch (SubagentStop exit-2 rows).
2. **Refine the predicate so it describes the shapes correctly (recommended)**:
   - **R1 - root-variable identification.** Generalize the hook-literal test used by steps (i) and (ii) into `Test-EpicStateIsolationHookReference -Node -SuiteAst`, true when the node holds (a) a `hooks/<name>.ps1` literal (current rule), (b) an expandable string `"$<var>/<name>.ps1"` or `"$<var>\<name>.ps1"`, or (c) a `Join-Path <expr> '<name>.ps1'` call (positional or `-ChildPath`), where `<var>`, or a variable inside `<expr>`, is bound (assignment or hashtable entry, using the existing `Get-EpicStateIsolationVariableKey` binding rule, one level of variable indirection) to an expression holding a string whose value ends with a `hooks` path segment (regex `(^|[\\/])hooks[\\/]?$`), or (d) a `Join-Path ... -AdditionalChildPath ..., 'hooks', '<name>.ps1'` segment list. Shape A suites become identified; no suite edit.
   - **R2 - helper-only blocks.** When a block has dot-sources, none is identified, and every one is a test-helper load (a dot-source whose argument holds a string literal whose leaf matches `\.Helpers\.ps1$` and which is not a hook reference), emit no F-2 finding and use the last helper dot-source as the ordering anchor for `Get-EpicStateIsolationHelperSeam` and `Get-EpicStateIsolationPairFinding`. The requirement presence rules (null mock or helper form for every seam, module import without `-Force`) still apply. Shapes B and C become compliant with no suite edit; a block that holds any non-helper, unidentified dot-source (the AC-8 and F-2 false-pass shape) still produces `no dot-source loads the hook`.
   - Reapply the withheld F-1 function, call, F-2 `return $null`, F-2 finding, fixture bindings, and Branches rows exactly as recovered above, with the F-2 finding guarded by `-not $helperOnly`.
3. **Exempt the seven suites by a list.** Rejected: the Discovery suite asserts that no hard-coded suite list exists (`AC-2 no hard-coded suite list in N2`), and a list would silently exempt future edits.

Rejected alternatives summary: approach 1 cannot express shapes B and C and overlaps #928's likely files; approach 3 contradicts AC-2.

### Recommended disposition (Item 1)

Deliver F-1 and F-2 with refinements R1 and R2. Residual, documented limit: a hook loaded only inside `It` bodies (shape B) is outside the guard's `BeforeAll` model; its module seams are still covered by the baseline mocks (module-scope mocks are registered without the hook), but hook-local seams guarded by `if (Get-Command X)` are runtime no-ops in those suites. Record this in the `EpicStateIsolation.Helpers.ps1` header.

Line budget: 474 (current) + 22 (withheld F-1/F-2) = 496, and R1 plus R2 add about 50 lines, which exceeds 500. Split first: move the hook-reference functions (`Test-EpicStateIsolationHookLiteral`, `Get-EpicStateIsolationVariableKey`, `Test-EpicStateIsolationVariableBoundToHook`, `Get-EpicStateIsolationHookDotSource`, current lines 96-179, 84 lines) into a new `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` together with the new R1 and helper-classification functions (estimate 150-165 lines), and dot-source it from the top of `EpicStateIsolation.Helpers.ps1` so the four consumers (`Discovery`, `Predicate`, `Branches`, legacy guard) need no new dot-source line. Estimated result: `EpicStateIsolation.Helpers.ps1` about 425 lines.

File list (Item 1):

- Edit `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` (474 -> about 425)
- Create `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` (about 160)
- Edit `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1` (197 -> 335 with the recovered rows and bindings)
- Edit `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1` (280 -> 288)
- Edit `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` (350 -> 362)
- Create `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1` (R1 and R2 rows plus the F-3 detector rows of Item 2; about 200)
- No edit to any of the seven flagged suites.

## Item 2 - F-3 (Operator Follow-up 4)

### Detector extension design

Reuse `Test-EpicStateIsolationHookReference` from Item 1 through one new pure function, `Get-EpicStateIsolationHookReference -Ast` (in `EpicStateIsolation.HookReference.Helpers.ps1`), returning one record per hook reference in a load position with `Name` (or `*` when the leaf is not a literal), `Form` (`Literal`, `RootVariable`, `Segment`, `Dynamic`), and `Root` (`.claude/hooks`, `.codex/hooks`, or `$null`). Load positions: dot-source (`.`) and call (`&`) arguments, `Import-Module` path arguments, `ProcessStartInfo` `FileName`/`ArgumentList.Add` arguments, process-start cmdlet `-FilePath`/`-ArgumentList` arguments, and assignments to a variable later used in one of those positions. A `Join-Path` used only for reading or hashing (for example `Get-FileHash`, `Get-Content`, `ParseFile`) is not a load and is not reported.

Two consumers in `EpicStateIsolation.Discovery.Helpers.ps1`:

1. `Get-EpicStateProcessSpawningHook` returns the union of literal names and non-literal references when the suite spawns a process, with `*(<root>)` for a dynamic leaf.
2. New `Get-EpicStateVariableHookLoad -SuiteText` returns the non-literal hook loads whose names are not already in the literal closure, and `Get-EpicStateVariableHookLoadReport` (in `EpicStateIsolation.Compliance.Helpers.ps1`) formats `REPORT-VARIABLE-LOAD: <path> loads <names>`.

A new Discovery row `AC-5b variable-built hook-load report <Surface>` writes these lines to the information stream and never fails, matching the AC-5 contract for process-spawning suites. The `EpicStateIsolation.Discovery.Helpers.ps1` header paragraph (lines 16-19) is rewritten to state the new detection and the remaining limit (variable-built loads are reported, not added to the closure).

### Suites the extension newly detects (by reading)

Suites with no `hooks/<name>.ps1` literal (outside the closure-bearing population): 25 Claude and 8 Codex (derivation in `## Numeric Derivation Evidence`). Of these, the load-position rule detects:

| Surface | Suite | Form | Hooks loaded |
|---|---|---|---|
| Claude | `enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1` | RootVariable (Context BeforeAll) | `enforce-orchestration-preimplementation-gate-epic-resolution.ps1` (Codex) |
| Claude | `check-python-test-purity.Tests.ps1` | Segment | `check-python-test-purity.ps1` |
| Claude | `check-powershell-test-purity.Tests.ps1` | Segment | `check-powershell-test-purity.ps1` |
| Claude | `enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` | RootVariable (`$Surface`) | `enforce-orchestration-preimplementation-gate-helpers.ps1` |
| Claude | `enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1` | RootVariable | same |
| Claude | `enforce-orchestration-preimplementation-gate-targets.Tests.ps1` | RootVariable (two levels) | `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `enforce-orchestration-preimplementation-gate-targets.ps1` |
| Claude | `enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1` | RootVariable (two levels) | same three |
| Claude | `enforce-powershell-batch-budget.Tests.ps1`, `enforce-powershell-batch-budget-routing.Tests.ps1` | Segment | `enforce-powershell-batch-budget.ps1` |
| Claude | `enforce-python-batch-budget.Tests.ps1`, `enforce-python-batch-budget-routing.Tests.ps1` | Segment | `enforce-python-batch-budget.ps1` |
| Claude | `enforce-promotion-mcp-only.Issue824.Tests.ps1` | RootVariable (expandable) | `enforce-promotion-mcp-only.ps1` |
| Claude | `hook-command-invocation-operands.Tests.ps1`, `hook-command-invocation.Issue824.Tests.ps1`, `hook-command-payload.Tests.ps1` | RootVariable (expandable) | `hook-command-invocation.ps1` |
| Claude | `hook-command-scanner.Issue824.Tests.ps1` | RootVariable (expandable) | `hook-command-scanner.ps1` |
| Claude | `hook-command-parser.AcceptanceCases.Tests.ps1` | RootVariable | five gates (epic and parallel worktree-removal, merge, promotion, preimplementation) |
| Claude | `PreToolUseSchema.Contract.Tests.ps1` | RootVariable | 15 hooks (lines 48-160) |
| Claude | `persist-session-id.Tests.ps1`, `validate-bash.Tests.ps1` | Segment | `persist-session-id.ps1`, `validate-bash.ps1` |
| Codex | `model-profile-attestation.Tests.ps1` | RootVariable | `record-subagent-routing-attestation.ps1`, `enforce-codex-model-routing.ps1` |
| Codex | `legacy-codex-hook-contracts.Tests.ps1` | RootVariable + Dynamic spawn | preimplementation gate, batch budgets, file mapping, review coverage; `*(.codex/hooks)` |
| Codex | `epic-provenance.Tests.ps1` | RootVariable | five attestation and routing hooks |
| Codex | `epic-execution-gates.Tests.ps1` | RootVariable + spawn | planning-only, wave barrier, merge, worktree removal |
| Codex | `codex-python-batch-budget-routing.Tests.ps1`, `codex-powershell-batch-budget-routing.Tests.ps1` | Segment | batch-budget hooks |
| Codex | `codex-pretooluse-transport.Tests.ps1` | RootVariable + Dynamic spawn | preimplementation gate, file mapping, completion consistency; `*(.codex/hooks)` |
| Codex | `codex-bundle-hook-probe.Tests.ps1` | Dynamic spawn (bundle root) | `*(.codex/hooks)` |

Not detected (no hook reference in a load position): `enforce-gate-suites.EpicStateIsolation.Tests.ps1` (fixtures only), `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` and `enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` (hash and text parity reads), `PreToolUsePayload.Contract.Tests.ps1` (text reads), `subagentstop-envelope-orchestrator-family.Registration.Tests.ps1` (`ParseFile` only).

Existing closure-bearing suites that also load hooks by root variable (their report lines appear only for hooks outside their literal closure): Claude `hook-command-consumers.Issue824`, `hook-command-invocation.Issue824Regression`, `feature-review-coverage-thresholds`, `hook-command-invocation`, `hook-command-scanner`; Codex `codex-pretooluse-integration` (its current report names `validate-bash.ps1` only because of a mock string literal at line 244; the extension adds `enforce-epic-wave-barrier.ps1` and `*(.codex/hooks)`), `codex-batch-budget-hooks`, `codex-evidence-and-checkpoint-hooks`, `codex-test-purity-hooks`, `hook-command-scanner`, `hook-command-invocation`.

Newly reported process-spawning suites: Codex `legacy-codex-hook-contracts`, `epic-execution-gates`, `codex-pretooluse-transport`, `codex-bundle-hook-probe`. Claude `check-powershell-test-purity.Tests.ps1` and `enforce-promotion-mcp-only.Issue824.Tests.ps1` contain the process-start token only as test data; the text-level spawn test already reports such suites when they hold a literal, so the extension will add them as report lines that are false positives (report-only, harmless).

### Do the newly detected suites comply?

None of the 28 newly detected suites (20 Claude, 8 Codex) carries `Register-EpicStateBaselineMock` or an interception probe, except the Probe harness (verified by the per-file count of those two names: neither appears in any of the other 27). Whether they would fail AC-4 if their variable-built loads joined the closure depends on the seam census of the loaded hooks, which was not executed. Indicators (functions named `*Checkpoint*`, `artifacts/` literals, or worktree-resolution imports, found by Grep in 33 hook files under `.claude/hooks`) and the seams already registered by sibling suites show that at least the preimplementation gate (`Get-CheckpointContent`, `Get-EpicCheckpointContent`, `Get-ParallelCheckpointContent` in `enforce-orchestration-preimplementation-gate.Tests.ps1` line 11), the worktree-removal and merge gates, the completion-consistency and checkpoint-monotonic hooks, and the batch-budget hooks (`Invoke-PowerShellBatchBudgetHook`, `Invoke-PythonBatchBudgetHook` registered in `hook-dependency-failure.Claude.Tests.ps1`) carry seams. Enforcement would therefore require baseline mocks and probe rows in an estimated 15 or more suites, plus new requirements in existing members such as `hook-command-consumers.Issue824.Tests.ps1`. `legacy-codex-hook-contracts.Tests.ps1` is at 497 lines and would need a split first.

### Recommended disposition (Item 2)

Deliver detection as report-only in this item: the shared reference recognizer, the process-spawning union, the `AC-5b` variable-load report row, the header update, and fixture rows for each form (RootVariable bare, RootVariable expandable, two-level binding, Segment, Dynamic spawn, non-load `Join-Path` ignored, and a non-vacuity row asserting at least one report line per surface on the committed tree). Record closure enforcement of variable-built loads as an operator follow-up with the generated report as its evidence. Rationale: enforcement roughly doubles the closure-bearing population with an unmeasured write set, needs at least one pre-split, and touches `tests/scripts/claude-hooks` while #928 and #929 run.

File list (Item 2): `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` (shared with Item 1), `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` (267 -> about 305), `tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1` (207 -> about 220), `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (333 -> about 345, one report row), `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1` (shared with Item 1).

## Item 3 - I-3 (Operator Follow-up 11)

### The four files named by #737 and the P8b research

`tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`. All four are still exactly 500 lines.

### Exhaustive scan: test files at 490 lines or more

Scope: every file under `tests/scripts/claude-hooks` (163), `tests/scripts/codex-hooks` (64), `tests/scripts/claude-runtime` (16), and `tests/scripts/claude-lib` (88, recursive). 17 files are at 490 lines or more:

| Directory | File | Lines | Edited by this item |
|---|---|---|---|
| claude-hooks | `enforce-epic-worktree-removal-gate.Tests.ps1` | 500 | Split (I-3) |
| claude-hooks | `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 500 | Split (I-3) |
| claude-hooks | `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 498 | No |
| claude-hooks | `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | 497 | No |
| claude-hooks | `enforce-completion-consistency.Tests.ps1` | 493 | No |
| claude-hooks | `enforce-powershell-batch-budget.Tests.ps1` | 490 | No |
| codex-hooks | `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 500 | Split (I-3) |
| codex-hooks | `legacy-codex-hook-contracts.Tests.ps1` | 497 | No (would need a split before any F-3 enforcement) |
| codex-hooks | `epic-child-worktree-launcher.Tests.ps1` | 495 | No |
| codex-hooks | `enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` | 492 | No |
| claude-runtime | `EnforcementHooksNoPythonInvocation.Helpers.ps1` | 500 | Split (I-3) |
| claude-runtime | `test-name-uniqueness.Tests.ps1` | 495 | No |
| claude-lib | `blast-radius/BlastRadiusConfig.Tests.ps1` | 500 | No (outside hook-test scope; operator note) |
| claude-lib | `worktree-resolution/WorktreeItemResolution.Tests.ps1` | 498 | No |
| claude-lib | `blast-radius/BlastRadius.Tests.ps1` | 492 | No |
| claude-lib | `orchestrator-state/OrchestratorState.Tests.ps1` | 491 | No |
| claude-lib | `blast-radius/BlastRadius.Conflict.Tests.ps1` | 490 | No |

None of the F-1/F-2/F-3 edits in Items 1 and 2 touches any of these 17 files; the only guard file that would exceed 500 (`EpicStateIsolation.Helpers.ps1`, 474 -> 496 -> about 546 unsplit) is handled by the Item 1 split. A fifth file at exactly 500 lines exists (`tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1`) that the P8b research did not list.

### Proposed splits (four I-3 files)

1. `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` has two top-level Describes: lines 23-428 and the manifest-branch Describe at lines 430-500 (own `BeforeAll`). Move lines 430-500 to new `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1` with the standard `#Requires` header, a synopsis, and a `baseline mock interception probe` row (the moved block complies by the helper form, so the Discovery `AC-6` row will require a probe). Result: about 429 and 85 lines.
2. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`: file-scope case tables (lines 26-92), one Describe whose `BeforeAll` spans lines 95-151, and Contexts `cross-file mock resolution smoke` (154-164), `call-target resolution seam` (166-234), and `target resolution matrix` (236-499). Move the two smaller Contexts (lines 154-234) to new `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1` with a `BeforeAll` holding the hook dot-source, the Baseline helper, the two `Register-EpicStateBaselineMock` lines, `. $script:Helpers`, and `$script:TargetFeatureFolder`, plus a probe row. The matrix and its factories (`New-PlannerPayload`, `New-ModelledTarget`) stay. Result: about 419 and 110 lines. The N-2 call at line 101 stays in the original file.
3. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`: one Describe; `BeforeAll` lines 22-70 including three helper functions (lines 32-69); Contexts for #539 (73-308), #671 (309-444), #663 (445-499). Move the three helper functions to new `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1` (dot-sourced after the hook and the Baseline helper; the `.Helpers.ps1` suffix keeps it a test-helper load under R2), keep the #539 Contexts, and move the #671 and #663 Contexts to new `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1` with the same short `BeforeAll` and a probe row. Result: about 272, 50, and 215 lines.
4. `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`: move the allowlist declaration (lines 61-67 region), the `ALLOWLIST POLICY` header paragraph (from line 14), and the four allowlist functions `Get-PythonInvocationAllowlist` (69-82), `Test-PythonInvocationAllowlistMatch` (426-444), `Select-UnallowedPythonInvocationFinding` (446-471), `Get-UnusedPythonInvocationAllowlistEntry` (473-500) to new `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1` (sibling naming of the existing `...ScanRoots.Helpers.ps1`), dot-sourced from the top of the original helper so neither consumer (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, 488 lines; `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` line 37, 492 lines) changes. Result: about 390 and 120 lines.

Each split must keep sibling `Describe`/`Context`/`It` names free of case-only collisions (`tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`), keep per-test counts equal before and after (moved rows only, plus one probe row per new hook suite), and pass the Discovery guard.

### Recommended disposition (Item 3)

Split the four named files as above in this item, as pure moves. Record the other 13 files at 490-499 lines and `BlastRadiusConfig.Tests.ps1` (500, outside hook-test scope) as an operator note; split each before its next edit.

## Item 4 - N-2 (Operator Follow-up 5)

Current call sites: 322 lines with `Register-EpicStateBaselineMock ... -Surface` in 47 files (45 consuming suites plus `enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1` with 10 and `...Discovery.Tests.ps1` with 5 fixture lines). The parameter semantics are already documented at the definition (`EpicStateIsolation.Baseline.Helpers.ps1` lines 37-42: "-Surface 'Codex' requests script-scope mocking for every seam; Claude suites use it for hook-local seams (issue #903, #737 N-2)"), which AC-41 of #903 delivered.

A rename would touch 47 files, including seven at 490 lines or more (`enforce-epic-worktree-removal-gate.Tests.ps1` 500, `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` 500, Codex `...command-exemption.Tests.ps1` 500, `...CommandExemption.Tests.ps1` 498, Claude `...mode-resolution.Tests.ps1` 497, Codex `...epic-scope.Tests.ps1` 492, `enforce-completion-consistency.Tests.ps1` 493), the three `hook-dependency-failure*` suites (likely #928 files), and Codex preimplementation-gate suites in #936's area. `Invoke-EpicStateInterceptionProbe -Surface` is a true surface selector and would keep its name, so the two helpers would diverge. A `[Alias('Scope')]` on the parameter would add a second name for the same switch without removing the first.

Recommended disposition: close as no action. The helper comment already resolves the readability concern; the rename's churn and concurrency overlap outweigh its benefit.

## Item 5 - F-6 (Operator Follow-up 6)

- `.claude/rules/powershell.md` line 31: "Avoid global state and mutable script-scoped variables; pass data explicitly."
- `.github/instructions/powershell-code-change.instructions.md` line 53 (authoritative per `CLAUDE.md`): "Avoid global state and mutable script-scoped variables unless required; pass data explicitly."
- `EpicStateIsolation.Discovery.Helpers.ps1` lines 21-22 already name `$script:EpicStateParseCache` as a deliberate, deterministic, test-session-only memo exception (#903 AC-39).

The authoritative instruction already permits a required exception, and the memo is documented at its definition. The `.claude/rules/` mirror omits the "unless required" qualifier, which is a mirror drift rather than a missing exception.

Recommended disposition: no change in this item (policy files must not be modified here). Record for the operator: (a) no named memo-cache exception is needed because the authoritative text already says "unless required"; (b) the `.claude/rules/powershell.md` line 31 wording drifts from its authoritative source and may be aligned in a policy-owned change.

## Behavior Semantics

- F-1: a `Mock` or `Register-EpicStateBaselineMock` under an `if`, `switch`, loop, `try`, or `trap` ancestor is not direct, except a single-clause `if` with no `else` whose condition is exactly one `Get-Command <Name>` command and `<Name>` is the mock target (or one of the helper's string constants). Nested direct-command exclusion also applies to `Import-Module` and dot-sources.
- F-2: no first-dot-source fallback. A block with dot-sources, none identified (literal, bound literal, R1 root variable or segment), and at least one that is not a `.Helpers.ps1` test-helper load yields `no dot-source loads the hook`. A block whose dot-sources are all test helpers is anchored at the last helper dot-source (R2).
- F-3: report only; a report line never fails a row; a missing or unparseable suite still yields its existing finding.
- Ordering: R2's anchor is the last helper dot-source so mocks must follow every helper load.

## Testing Implications

- Fail-first: (1) the recovered F-1/F-2 rows fail against the current helper (as in #903, Phase 6); (2) a Discovery run with F-1/F-2 reapplied and without R1/R2 should reproduce exactly the seven findings of run 38404520141, recorded as fail-before evidence; (3) the R1 and R2 rows fail against the F-2-only predicate; (4) the F-3 detector rows fail against the current `Get-EpicStateProcessSpawningHook`.
- Pass-after: Branches, Predicate, legacy guard, new HookReference suite, Discovery (220 AC-4 rows plus AC-6 probe rows, including the new split suites) pass in CI on both jobs.
- I-3: before/after per-suite Passed counts must match for moved rows; new hook suites add one probe row each.
- All inputs in memory; no temporary files, no clock, no process start in new tests.

## Automation Feasibility

All steps are automatable. Format, analyze, and test through the PoshQC MCP tools (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`) on every changed `.ps1` file and suite. MCP results carry no per-test output or coverage text, so per-row results (Discovery, Branches, HookReference rows) and per-file coverage come only from the PR CI artifacts (`poshqc-test-results`, `poshqc-linux-hook-test-results`, and the Pester coverage file). The F-3 report lines are read from the CI log information stream or from a CI-run census step. No step requires an operator except the follow-up decisions listed below.

## Concurrency

| Item | Likely files (from promoted records; no feature folder exists) | Overlap with this proposal |
|---|---|---|
| #928 (SubagentStop uncaught error exits 1) | The nine SubagentStop validators under `.claude/hooks/`, their bundle mirrors, and one test per validator, likely in `tests/scripts/claude-hooks/validate-*-output*.Tests.ps1`; possibly `hook-dependency-failure.Claude.Tests.ps1` and `hook-dependency-failure.SpecialCases.Tests.ps1` (SubagentStop exit-2 rows) | No file in the proposed write set. Indirect: the tightened predicate (F-1, F-2 with R1/R2) applies to any suite #928 adds or edits; a new suite must dot-source its hook by literal, bound literal, or root variable, or use only `.Helpers.ps1` helpers. |
| #929 (artifact-gate review notes) | `validate-prd-feature-output.Tests.ps1`, `validate-task-researcher-output.Coverage.Tests.ps1`, `validate-discovery-artifact-gate.Tests.ps1`, the seven suites defining `New-SubagentStopEnvelopeJson` (`validate-task-researcher-output.Tests.ps1`, `...Coverage.Tests.ps1`, `validate-prd-feature-output.Tests.ps1`, `...Coverage.Tests.ps1`, `validate-pr-author-output.Tests.ps1`, `...Coverage.Tests.ps1`, `validate-discovery-artifact-gate.Tests.ps1`), and a likely new shared builder | No file in the proposed write set. Indirect: a shared builder dot-sourced in a `BeforeAll` should use the `.Helpers.ps1` suffix so R2 classifies it as a test helper. |
| #936 (hook coverage attribution) | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` line 41 and `...-epic-scope.ps1` lines 206-207 tests, likely in Codex preimplementation-gate suites | Same suite family as the Codex command-exemption split; no shared file identified. `enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` dot-sources `EnforcementHooksNoPythonInvocation.Helpers.ps1`; the I-3 split keeps that path and its functions stable. |

## Proposed Write Set

Create:

- `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1`
- `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1`

Edit:

- `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1`
- `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1`
- `tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
- `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/` documents and `evidence/<kind>/` artifacts (spec, plan, evidence)

Delete: none.

Not edited (explicitly): the seven flagged suites, every file under `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, and `config/`, and the 13 other files at 490-500 lines.

## Risks

- R2 is a deliberate relaxation of the withheld F-2 for helper-only blocks. A suite could load a hook through a `.Helpers.ps1` file and pass on presence alone. Mitigation: the header records the limit; F-3 reports variable-built loads.
- The "no additional suite flagged" conclusion and the "no F-1 finding masked behind F-2" conclusion are from reading; `Get-EpicStateSuiteCompliance` reports only the first finding per seam. Confirm with the CI Discovery run and record per-suite results.
- R1 can change which dot-source is identified in a block that holds both a root-variable hook load and a later literal load, which can move the ordering anchor. Confirm with the full-population run.
- The F-3 report will contain false positives where the process-start token or a `hooks` segment appears only as data (`check-powershell-test-purity.Tests.ps1`, `enforce-promotion-mcp-only.Issue824.Tests.ps1`); report-only by design.
- Moving functions out of `EnforcementHooksNoPythonInvocation.Helpers.ps1` changes line numbers referenced by `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json` (`...Helpers.ps1:328`). The fixture is a historical record; confirm `BlastRadius.HistoricalRuns.Tests.ps1` and `test_blast_radius_historical_runs.py` do not resolve that line against the current file.
- Suites added by #928/#929 later in this run are judged by the tightened predicate; a nonconforming dot-source shape will fail their Discovery row.
- The research filename stamp came from an HTTP time service, not the host clock (see header).

## Operator Follow-ups (to record)

1. F-3 enforcement: add variable-built hook loads to the closure and bring the newly detected suites into compliance, using the `AC-5b` report as the measured list; split `legacy-codex-hook-contracts.Tests.ps1` (497) first.
2. Shape-B limit: hook-local seams in suites that load hooks only inside `It` are not isolated by `Get-Command`-guarded registrations.
3. F-6: `.claude/rules/powershell.md` line 31 omits "unless required" present in the authoritative `.github/instructions/powershell-code-change.instructions.md` line 53.
4. I-3 residue: 13 files at 490-499 lines and `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` at 500; split before next edit.

## Numeric Derivation Evidence

### N1 - Suites flagged by F-1/F-2 (7)

- Complete Family: Discovery `AC-4` rows that fail with F-1/F-2 applied over the Claude and Codex hook-suite population.
- Exhaustive Search Scope: all 220 suites in `tests/scripts/claude-hooks/*.Tests.ps1` and `tests/scripts/codex-hooks/*.Tests.ps1` as run by CI run 38404520141.
- Inclusion Rules: a failing `AC-4` testcase in `pester-junit-linux-hooks.xml`.
- Exclusion Rules: rows other than Discovery `AC-4`.
- Primary Search Strategy or Query Expression: failing testcase list recorded in `.../903/evidence/qa-gates/ps-rows.2026-10-13T13-43.md` (testcase-name scan of the CI JUnit file).
- Primary Member Set: `hook-command-consumers.Issue824`, `hook-command-invocation.Issue824Regression`, `hook-dependency-failure.Claude`, `hook-dependency-failure.SpecialCases`, `session-root-reads-850.Constraints` (claude-hooks); `codex-epic-runtime-contracts`, `hook-dependency-failure.Codex` (codex-hooks).
- Primary Count: 7.
- Cross-check Search Strategy or Query Expression: static reading of each suite's outermost `BeforeAll` dot-sources against steps (i)/(ii), restricted to suites that carry baseline mocks (Grep `Register-EpicStateBaselineMock|Invoke-EpicStateInterceptionProbe`, 109 files) and the 390-line dot-source inventory of `tests/scripts/claude-hooks/*.Tests.ps1`.
- Cross-check Member Set: the same seven suites (shapes A, B, C in Item 1).
- Cross-check Count: 7.
- Member-set Comparison: identical sets. The cross-check is reading-based and found no additional member on current main.

### N2 - Test files at 490 lines or more (17)

- Complete Family: every file in `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, `tests/scripts/claude-runtime`, `tests/scripts/claude-lib` (recursive), 331 files.
- Exhaustive Search Scope: the four directories above, all file types present (`.ps1`).
- Inclusion Rules: line count >= 490.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Grep `^` with `output_mode: count` per directory.
- Primary Member Set: the 17 files in the Item 3 table.
- Primary Count: 17 (claude-hooks 6, codex-hooks 4, claude-runtime 2, claude-lib 5).
- Cross-check Search Strategy or Query Expression: Grep `\n` with `multiline: true`, `output_mode: count` per directory.
- Cross-check Member Set: the same 17 files with identical counts.
- Cross-check Count: 17.
- Member-set Comparison: identical. The only per-file difference across all 331 files is `enforce-pr-author-skill.TargetResolution.Tests.ps1` (128 vs 127, no trailing newline), far below the threshold.

### N3 - Suites outside the literal closure population (25 Claude, 8 Codex)

- Complete Family: `*.Tests.ps1` directly in `tests/scripts/claude-hooks` (156) and `tests/scripts/codex-hooks` (64).
- Exhaustive Search Scope: both directories, every suite.
- Inclusion Rules: no `hooks/<name>.ps1` reference.
- Exclusion Rules: helper and case files (`*.Helpers.ps1`, `*.Cases.ps1`).
- Primary Search Strategy or Query Expression: Grep count `(^|[^A-Za-z0-9_-])hooks/[A-Za-z0-9._-]+\.ps1` with glob `*.Tests.ps1`; complement of 131 (Claude) and 56 (Codex) matching files.
- Primary Member Set: Claude: legacy guard, Probe, `check-python-test-purity`, `check-powershell-test-purity`, `...-helpers.ChainEscape`, `...-helpers.OperandNormalization`, `...-helpers.Parity`, `...-targets.Parity`, `...-targets`, `...C1bCoverage`, `enforce-powershell-batch-budget`, `...-routing`, `enforce-promotion-mcp-only.Issue824`, `enforce-python-batch-budget`, `...-routing`, `hook-command-invocation-operands`, `hook-command-invocation.Issue824`, `hook-command-parser.AcceptanceCases`, `hook-command-scanner.Issue824`, `hook-command-payload`, `PreToolUseSchema.Contract`, `persist-session-id`, `PreToolUsePayload.Contract`, `subagentstop-envelope-orchestrator-family.Registration`, `validate-bash`. Codex: `codex-bundle-hook-probe`, `codex-powershell-batch-budget-routing`, `codex-pretooluse-transport`, `codex-python-batch-budget-routing`, `epic-execution-gates`, `epic-provenance`, `legacy-codex-hook-contracts`, `model-profile-attestation`.
- Primary Count: 25 and 8.
- Cross-check Search Strategy or Query Expression: Grep `files_with_matches` `(\.claude/hooks/|\.codex/hooks/|['"/]hooks/)[A-Za-z0-9._-]+\.ps1`, complement against the directory listing.
- Cross-check Member Set: same complements (131 and 56 matching files, listed by name).
- Cross-check Count: 25 and 8.
- Member-set Comparison: identical sets.

### N4 - N-2 call sites (322 lines in 47 files)

- Complete Family: calls of `Register-EpicStateBaselineMock` that pass `-Surface` under `tests/`.
- Exhaustive Search Scope: `tests/` recursive.
- Inclusion Rules: a line holding both the helper call and `-Surface` (all calls in the tree are single-line).
- Exclusion Rules: `Invoke-EpicStateInterceptionProbe -Surface` (a true surface selector) and the helper definition.
- Primary Search Strategy or Query Expression: Grep count `Register-EpicStateBaselineMock\b.*-Surface`.
- Primary Member Set: 47 files listed by the Grep (45 consuming suites, Probe, Discovery).
- Primary Count: 322.
- Cross-check Search Strategy or Query Expression: Grep count `-Seam\b.*-Surface\b` (only the helper takes both, in that order).
- Cross-check Member Set: the same 47 files with identical per-file counts.
- Cross-check Count: 322.
- Member-set Comparison: identical.

Numbers in this section support the dispositions; no numeric acceptance criterion is proposed for `spec.md` beyond N1 (zero findings after the change on the seven named suites) and N2 (the four named I-3 files at or below 500 after the split).
