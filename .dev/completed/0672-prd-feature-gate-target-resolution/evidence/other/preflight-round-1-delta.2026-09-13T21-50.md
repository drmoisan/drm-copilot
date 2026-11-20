# Preflight Round 1 — Revision Delta (issue #672)

Timestamp: 2026-09-13T21-50
Source: `atomic-executor` under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
Plan under review: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/plan.2026-09-13T20-47.md`

PREFLIGHT: REVISIONS REQUIRED
CONVERGENCE: FURTHER ROUNDS LIKELY — D7 requires a design ruling the plan has not yet made (how probe composition behaves when the resolved target is unbound), and that ruling determines whether roughly 25 existing decision-level cases survive. D5 and D12 each require the planner to verify a mechanism against the tree before writing the corrective task. The resulting tasks will carry new citations that this pass has not observed.

## Baseline observations recorded by the reviewer

- The three Python delivery tests pass today (17 passed).
- `.claude/hooks/enforce-prd-feature-before-planner.ps1` measures 448 lines.
- `.codex/hooks/` contains no mirror of this hook (full enumeration, 30 files).

## Confirmed correct — NOT findings, do not "fix" these

- F1 dependency handling: no guessed identifier appears anywhere; every downstream task reads from the `[P0-T8]` artifact; the import is unguarded and fail-closed.
- No `--cov` token and no `git diff` anywhere in the plan (verified by grep).
- Every evidence path resolves under the feature's canonical `evidence/` tree; `artifacts/pester/*` appears only as a declared tool-output input.
- Phase 0 baselines `[P0-T2]`-`[P0-T7]` all precede the `[P0-T12]` production write, and no formatter runs in Phase 0.
- The delivery tests are asserted only at `[P2-T6]`, `[P5-T3]`, `[P6-T4]`.
- No gate runs between `[P2-T4]` and `[P2-T5]`, and none runs over the Phase 3 rows before Phase 4.
- The depth-collapsing block is correctly located at lines 272-277 and correctly preserved.
- The work-mode rulings match the code: the `default` arm at line 185 returns `spec.md` alone; lines 398-410 are a distinct no-probe path.
- No branch-coverage figure is demanded.
- No Python enters the enforcement path.
- `$envelope.Envelope` is a real member (`HookPayload.psm1:481`).
- All four named pytest node IDs and all cited `Context`/`It` regions exist as stated.

---

## Defects

### D1 — `[P4-T7]` acceptance cannot fail, and read literally it deletes behaviour the spec preserves

`return $candidates[0]` occurs **twice** in the hook: line 290 (single-candidate path, which `spec.md` line 353 requires be retained) and line 307 (the positional tie-break to be removed). A zero-match assertion demands removing both. Separately, `Select-String` treats `$` as an end-of-line anchor, so the pattern matches nothing regardless of file content — the assertion returns zero either way.

**Delta — replace the `[P4-T7]` acceptance sentence with:**

> Acceptance: the `It` named `denies rather than selecting the earliest candidate on an unresolved tie` passes; and `Select-String -SimpleMatch -Pattern 'return $candidates[0]'` over `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` returns exactly one match, down from the two the pre-change parent carried at lines 290 and 307. The surviving match is the single-distinct-candidate return that `spec.md` line 353 requires be retained; the removed match is the positional tie-break at former line 307.

### D2 — Seven assertion tokens are regex-fragile; five are unsatisfiable and two are trivially satisfied

Every `Select-String` acceptance condition in the plan is written as a bare pattern. `$` is a regex anchor and `(` opens a group, so:

| task | token | effect as written |
|---|---|---|
| `[P0-T12]` | `param(` | unbalanced `(`; raises a regex parse error rather than returning zero |
| `[P1-T4]` | `$MyInvocation.InvocationName` | anchor; "exactly one match" unsatisfiable (file carries 1 occurrence) |
| `[P4-T1]` | `Import-Module (Join-Path $PSScriptRoot` | unbalanced `(`; "exactly two matches" unsatisfiable |
| `[P4-T1]` | `$PWD` | anchor; always zero — that leg of the no-re-implementation guard is trivially satisfied |
| `[P4-T2]` | `$PSBoundParameters.ContainsKey` | anchor; "at least one match" unsatisfiable |
| `[P4-T6]` | `$segments[0..3]` | anchor plus `[0..3]` character class; "exactly one match" unsatisfiable |
| `[P4-T14]` | `-MockWith { $true }` | anchor; zero-match always — **the AC-09 false-approval guard cannot fail** |
| `[P4-T15]` | `$PWD`, `$env:TEMP` | anchors; two of seven searches always return zero, contradicting the task's own "real discriminator" claim |

`[P4-T14]` is the most serious of these: it is the guard the delegation asked be verified as genuinely discriminating, and as written it passes on any file content including one carrying a blanket mock.

**Delta — add to the plan preamble, after the "Named test identifiers" block:**

> ### Search-assertion form (mandatory for every acceptance condition in this plan)
>
> Every `Select-String` acceptance condition is executed as `Select-String -SimpleMatch -Pattern '<token>' -Path '<path>'`, with the pattern in single quotes. `-SimpleMatch` is mandatory: without it `$` is a regex end-of-line anchor and `(` opens a group, so tokens such as `$true`, `$PWD`, `$segments[0..3]`, and `param(` either match nothing whatever the file contains or raise a parse error. An acceptance condition run without `-SimpleMatch` is void and must be re-run.
>
> Where a task asserts a zero-match result and claims the search is a discriminator, the task also records a control count: the same `-SimpleMatch` search run against a named file that does contain the token, with its non-zero match count recorded in the same artifact.

**Delta — append to `[P4-T15]`:** after "each of which is present elsewhere in the tracked tree so the search is a real discriminator", add: `For each of the seven tokens, record in the same artifact the control match count from a -SimpleMatch search of one named tracked file that does contain it, so a zero result on the new suite is distinguished from a search that cannot match.`

### D3 — `[P4-T7]` invalidates two existing cases that no task amends

`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` lines 97-103 (`uses the earliest candidate when the checkpoint folder is absent`) and 105-111 (`uses the earliest candidate when the checkpoint folder is not a candidate`) pin the positional tie-break that `[P4-T7]` converts into an ambiguity denial. `[P4-T11]` re-specifies only the sibling case at lines 89-95. `[P4-T17]`'s "Pester failures are 0" is unsatisfiable while these two stand.

**Delta — insert as `[P4-T11a]`, renumbering subsequent Phase 4 tasks:**

> - [ ] [P4-T11a] Re-specify the two positional-fallback cases that sit beside the case `[P4-T11]` renames, in the same `Context` named `deterministic selection among two feature folders`: the `It` named `uses the earliest candidate when the checkpoint folder is absent` and the `It` named `uses the earliest candidate when the checkpoint folder is not a candidate`. Both currently assert that an unresolved multi-candidate tie returns the earliest-occurring candidate, which is the behaviour `[P4-T7]` removes. Rename each to state the denial it now asserts and drive both from the F1-derived target. Acceptance: neither original `It` name remains in the file, `Select-String -SimpleMatch -Pattern 'uses the earliest candidate'` over that file returns zero matches, and both re-specified cases pass.

### D4 — Three fixed `It` identifiers are required to pass but no task authors them

The preamble fixes 15 `It` names. Tasks author twelve. These three are required by an acceptance condition but created by nothing:

- `denies with the ambiguity code when the target cannot be resolved` (required by `[P4-T4]`, carries AC-03)
- `emits an ambiguity code distinct from the missing-document and marker reasons` (required by `[P4-T4]`, carries AC-03's distinctness clause)
- `denies with the missing-document reason when the document is absent under the target root` (required by `[P4-T9]`, carries AC-02)

The first two assert new behaviour and have no fail-before row in Phase 3.

**Delta — insert as `[P3-T5a]`:**

> - [ ] [P3-T5a] [expect-fail] Add the two ambiguity-reason rows as `It` blocks named `denies with the ambiguity code when the target cannot be resolved` and `emits an ambiguity code distinct from the missing-document and marker reasons`. The first asserts a deny whose `permissionDecisionReason` carries the `PRD_FEATURE_BLOCKED:` prefix and embeds the ambiguity reason code read from the `[P0-T8]` binding artifact. The second asserts that code differs from the missing-document reason substring and from the indeterminate-work-mode reason substring, and that it occurs as a single literal. Acceptance: both named `It` blocks exist and fail against the current hook, which has no ambiguity branch, and each failure message is recorded in the `[P3-T6]` fail-before artifact. No F1 identifier literal is quoted in this task; the expected code is read from the binding artifact at implementation time.

**Delta — insert as `[P3-T5b]`:**

> - [ ] [P3-T5b] [expect-fail] Add the missing-document row as an `It` named `denies with the missing-document reason when the document is absent under the target root`: the target root resolved through the injection parameter, the existence mock answering false for the required-document path composed against that root, asserting a deny whose reason leads with the resolved feature folder and then names the missing document list, the work mode, and the existing remedy, and retains the `PRD_FEATURE_BLOCKED:` prefix. Acceptance: the named `It` exists, its outcome against the current hook is recorded in the `[P3-T6]` fail-before artifact, and the asserted reason text matches the pre-change reason apart from the resolved-folder value.

**Delta — `[P3-T6]`:** change "six `It` blocks" to "nine `It` blocks" and "P3-T2 through P3-T5" to "P3-T2 through P3-T5b" in both the task text and the acceptance sentence.

### D5 — The declared batch split is not operationalised; Phase 2 writes will be denied

`.claude/hooks/enforce-powershell-batch-budget.ps1` is registered as a PreToolUse hook on Write/Edit at `.claude/settings.json` line 144, with `prodCap = 3` (line 426). Its own description states the batch is **session-scoped**, counts distinct paths cumulatively, and that "the session must explicitly reset the counter by deleting the state file before starting a new batch" (`.claude/state/powershell-batch-budget.<session_id>.json`). `.psd1` files count as production.

The plan writes six distinct production PowerShell paths: the two `.claude/hooks/` files, their two bundled mirrors, and the two `pester.runsettings.psd1` copies. With no reset, the cumulative count reaches 3 at `[P2-T1]` and the hook denies at `[P2-T2]`. `[P0-T10]` records the route as a batch split but names no boundary mechanism, so the batch table in the preamble describes an intent the runtime does not observe.

**Delta — append to `[P0-T10]`:** after "was not invoked", add: `and stating the reset mechanism by which each batch boundary is realised: the session's batch-budget state file at .claude/state/powershell-batch-budget.<session-id>.json is removed before the first write of each new batch, per the reset procedure documented in .claude/hooks/enforce-powershell-batch-budget.ps1. Acceptance additionally requires the artifact to name that state-file path and to state the resolved session id.`

**Delta — insert one task immediately before `[P2-T1]`, `[P4-T1]`, and `[P5-T1]`, and a second before `[P2-T3]`, each of the form (IDs assigned by the planner, with subsequent tasks renumbered):**

> - [ ] [P#-T#] Open batch `<letter>` by removing the session batch-budget state file `.claude/state/powershell-batch-budget.<session-id>.json`, using the session id recorded in the `[P0-T10]` artifact. Acceptance: the state file is absent immediately before the first write of this batch, and the removal and the resulting absence are recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/batch-boundary-<letter>.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. If the state file cannot be removed from this session, halt and report blocked rather than proceeding into a batch whose writes the budget hook will deny.

### D6 — Three acceptance criteria are not covered by any task

- **`spec.md` line 627** — "Row — own folder named, cwd modelled as the item worktree: `allow`, unchanged. Retained as a regression guard." `[P3-T2]` covers the session-root cwd and `[P3-T3]` covers the absolute form at both cwds. No task covers the **relative** form at item-worktree cwd, which is the row the defect report records as currently allowing.
- **`spec.md` line 639** — requires **both** the truncation `Context` **and** the `preserved gate behavior` `Context` (FolderResolution.Tests.ps1 lines 203-282) pass byte-unmodified. `[P4-T6]` names only the truncation block.
- **`spec.md` line 637** — requires the epic merge gate's "suites pass unmodified". `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` and `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` exist but appear in neither `[P0-T6]`'s baseline list nor `[P5-T4]`'s verification list.

**Delta — insert as `[P3-T2a]`:**

> - [ ] [P3-T2a] Add the item-worktree regression-guard row as an `It` named `allows when the modelled cwd is the item worktree`: the same payload and the same resolved target as the `[P3-T2]` row, with the modelled session root set equal to the item worktree rather than to a different worktree, the existence mock answering true only for the path composed against that root, asserting the decision is `allow`. Acceptance: the named `It` exists and passes against the current hook, establishing it as a retained regression guard rather than a fail-before row, and its passing outcome is recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/fail-before.<ISO-8601>.md` alongside the failing rows. Add `allows when the modelled cwd is the item worktree` to the preamble's fixed `It` list, raising its count from fifteen to twenty.

(The preamble's fixed-`It` list must also gain the three names from D4 and the two renamed cases from D3; `[P4-T17]`'s "fifteen fixed `It` identifiers" changes to the revised count.)

**Delta — `[P4-T6]` acceptance:** after "returns exactly one match", add: `; and the Context block 'preserved gate behavior' at the same file's lines 203-282 passes byte-unmodified, including its five cases covering full-feature spec.md absence, full-bug spec.md absence, full-feature user-story.md absence by name, minor-audit with neither prerequisite present, and the legacy full marker normalisation, as required by spec.md line 639.`

**Delta — `[P0-T6]` and `[P5-T4]`:** change "four PowerShell suites" / "four unmodified PowerShell gates" to "six", add `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` and `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` to both lists, and change "four pass counts and four fail counts" to "six pass counts and six fail counts".

### D7 — The plan makes no ruling on probe composition when the resolved target is unbound, and roughly 25 existing cases depend on it

Three existing cases key their existence mock on a **bare repo-relative** path: FolderResolution.Tests.ps1 lines 124, 156, and 187 compare `$Path -eq 'docs/features/active/.../spec.md'`. A further group across both suites asserts on reason strings that embed the resolved folder in bare repo-relative form. None of these binds a resolved target, and none is amended by any task.

After `[P4-T8]` and `[P4-T9]` compose probe paths against the resolved target root, whether those comparisons still match is decided entirely by what the composition does when the injection parameter is unbound and target derivation yields no target — and the plan never states it. `[P4-T8]`'s acceptance asserts the `indeterminate work-mode marker` `Context` "still passes" and `[P4-T6]`'s asserts the truncation `Context` passes, but neither task specifies the mechanism that makes them pass. This is the single largest unstated dependency in the plan.

**Delta — add to the plan preamble as ruling 8:**

> 8. **Unbound-target composition (binding ruling).** When the injection parameter is unbound and F1's derivation yields no target, the composition sites in `Get-PrdFeatureIssueContent` and `Get-PrdFeatureMissingFile` emit the bare repo-relative spelling they emit today, unchanged. The resolved target root is prefixed only when a target is bound or derived. This is what keeps the existing bare-relative keyed mocks at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` lines 124, 156, and 187 matching, and what keeps every existing reason-string assertion that embeds the folder in repo-relative form matching. The ambiguity deny branch added by `[P4-T4]` is therefore taken only when derivation returns an explicit no-target result **and** the session root is not the derived target, never on the unbound-parameter path alone. Composing an absolute prefix unconditionally is prohibited: it breaks every existing decision-level case at once and the failure presents as a mass suite failure at `[P4-T17]` rather than as a located defect.

**Delta — insert as `[P4-T9a]`:**

> - [ ] [P4-T9a] Verify the unbound-target composition ruling holds across the existing decision-level cases. Run both existing suites and confirm that every case that binds no resolved target still passes: specifically the three cases whose existence mock keys on a bare repo-relative path at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` lines 124, 156, and 187, and every case in the `Context` blocks `decision equivalence and the reproduction differential`, `preserved gate behavior`, `indeterminate work-mode marker`, and `block message`. Acceptance: all cases in those four `Context` blocks pass with their files unmodified apart from the `BeforeAll` edit made by `[P1-T5]`, and the count of passing cases in each block is recorded in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/unbound-target-composition.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. A failure here means the composition prefixes unconditionally; correct the composition rather than the tests.

### D8 — `[P5-T5]` runs a command the pre-implementation gate denies

`git add --dry-run .` matches the staging classifier at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` line 140, which tests the `add` and `commit` subcommands, and the pathspec `.` is not an orchestration-bookkeeping tree. The command is denied. The companion `git status --porcelain` already enumerates untracked files, so the `git add` leg adds nothing.

**Delta — `[P5-T5]`:** replace ``by running `git status --porcelain` and `git add --dry-run .` from the worktree root`` with ``by running `git status --porcelain --untracked-files=all` from the worktree root, which enumerates tracked modifications and untracked files in one command. A `git add --dry-run` companion is not used: the pre-implementation gate classifies `git add` as a staging command at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` line 140 and denies it for a pathspec outside the orchestration-bookkeeping trees.``

### D9 — `[expect-fail]` tagging contradicts two tasks' own acceptance text

- `[P0-T11]` is tagged `[expect-fail]` but its acceptance accepts "either a reproduction or an explicit non-reproduction", so it cannot fail, and `ExpectedExitCode:` has no determinate value.
- `[P3-T3]` is tagged `[expect-fail]` and its acceptance records "its outcome", explicitly permitting a pass, while `[P3-T6]` demands "a failure for each" of the rows including this one.

**Delta — `[P0-T11]`:** remove the `[expect-fail]` tag and the `ExpectedExitCode:` field from the required field list. Replace the acceptance opening with: `Acceptance: the artifact exists, carries Timestamp:, Command:, EXIT_CODE:, and Output Summary:, and records the observed outcome as either REPRODUCED or NOT-REPRODUCED. This task is an investigation, not a fail-before row; neither outcome is a failure and no [expect-fail] evidence obligation attaches to it.`

**Delta — `[P3-T3]`:** remove the `[expect-fail]` tag and replace the acceptance with: `Acceptance: the named It exists and its observed outcome against the current hook — pass or fail — is recorded in the [P3-T6] artifact. This row is stated positively as the fixed gate's required behaviour, so neither outcome is a failure of this task, and it is excluded from the [P3-T6] count of rows required to fail.`

**Delta — `[P3-T6]`:** after the revised count from D4, add: `The It named 'allows an absolute path to the target feature folder' from [P3-T3]'s row and the It from [P3-T2a]'s row are recorded with their observed outcomes but are excluded from the count of rows required to fail, per those tasks' own acceptance text.`

### D10 — Phase 3 fail-before evidence records a parameter-binding error, not a behavioural failure

`[P3-T2]` supplies "the resolved target through the injection parameter", but that parameter is added to `Invoke-PrdFeatureBeforePlannerDecision` by `[P4-T2]`. Every Phase 3 row that binds it fails with a parameter-binding error against the Phase 3 hook. The row does fail, so the `[expect-fail]` tag is satisfied, but the recorded message proves nothing about probe composition.

**Delta — append to `[P3-T6]`:**

> The injection parameter that the Phase 3 rows bind is added by `[P4-T2]`, so a row binding it against the Phase 3 hook fails with a parameter-binding error rather than with a composition-path assertion failure. For each row, record which of the two failure modes was observed. For the rows whose failure is a parameter-binding error, additionally record the same row's observed decision and reason when run with the parameter omitted, so the artifact carries at least one behavioural observation of the pre-change composition path per row rather than only a binding diagnostic.

### D11 — Three citation-drift items

- **`[P4-T5]`** cites "lines 368-370" for the unconditional checkpoint fallback. The block is lines **367-369**: `if (-not $folder) {` at 367, `$folder = Get-PrdFeatureCheckpointFolder` at 368, `}` at 369; line 370 is blank. Removing 368-370 literally leaves a dangling `if`. **Delta:** change ``lines 368-370`` to ``lines 367-369, comprising the guard `if (-not $folder) {`, the assignment `$folder = Get-PrdFeatureCheckpointFolder`, and its closing brace``.
- **Preamble ruling 1** places "the literal `docs`" at line 252. The pattern literal is at line **251**; line 252 is the `[regex]::Matches` call. **Delta:** change `at line 252` to `at line 251, consumed by the [regex]::Matches call at line 252`.
- **`[P4-T10]`** cites Tests.ps1 "lines 107-116" and **`[P4-T11]`** cites FolderResolution.Tests.ps1 "lines 89-95". `[P1-T5]` edits the `BeforeAll` block of both files first, shifting both ranges before Phase 4 runs. **Delta:** in `[P4-T10]`, replace ``at `tests/...Tests.ps1` lines 107-116`` with ``the `It` currently named `falls back to orchestrator-state.json when prompt has no folder reference` (at lines 107-116 before the `[P1-T5]` `BeforeAll` edit shifts them)``, and replace ``that case's blanket existence mock at line 109`` with ``that case's blanket existence mock, the only `Mock -CommandName Get-PrdFeatureFileExistence` inside it``. In `[P4-T11]`, replace ``at `tests/...FolderResolution.Tests.ps1` lines 89-95`` with ``the `It` currently named `prefers the checkpoint folder when it occurs later in the prompt` (at lines 89-95 before the `[P1-T5]` `BeforeAll` edit shifts them)``.

### D12 — The coverage acceptance depends on a settings change the test runner may not read

`[P2-T4]` and `[P2-T5]` add the new sibling to `CodeCoverage.Path` in the repo-side and bundled `pester.runsettings.psd1`. `[P2-T7]`, `[P6-T3]`, and `[P6-T5]` then require a per-file line-coverage percentage for that sibling from `artifacts/pester/powershell-coverage.xml`, and `spec.md` line 667 (AC) requires it be at or above 85 percent.

The MCP tool descriptions state each PoshQC function runs "using bundled extension resources", and `spec.md` lines 732-733 assign the extension rebuild, reinstall, and push-down to the epic's delivery feature rather than to this one. If the runner reads the installed extension's settings rather than the repo-side file, the sibling never enters the denominator and the AC cannot be evidenced by any command the plan names. This is stated as an unverified risk: the runner's settings source was not confirmed in this pass, and no prior `artifacts/pester/` output exists in this worktree to inspect.

**Delta — insert as `[P2-T5a]`:**

> - [ ] [P2-T5a] Confirm the new sibling actually enters the coverage denominator before any later task depends on it. Invoke `mcp__drm-copilot__run_poshqc_test`, then search the emitted `artifacts/pester/powershell-coverage.xml` for the path `enforce-prd-feature-before-planner-helpers.ps1` using `Select-String -SimpleMatch`. Record the match count in `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/coverage-denominator-check.<ISO-8601>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, alongside a control search for `enforce-prd-feature-before-planner.ps1`, which the pre-change settings already list at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 237 and which must return a non-zero count. Acceptance: both searches return non-zero match counts. **If the sibling's count is zero while the control is non-zero,** the MCP runner is not reading the repository-side runsettings edited by `[P2-T4]`; in that case record the finding, then satisfy `[P2-T7]`, `[P6-T3]`, and `[P6-T5]` by invoking the repository-side PoshQC module directly against `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` rather than through the MCP function, and name that command verbatim in each of those three tasks' `Command:` field. Do not record a placeholder coverage value and do not drop the per-file figure: `spec.md` line 667 requires it.

### D13 — `[P0-T3]` acceptance is internally contradictory and cannot fail

It requires the summary to state 448 and then authorises recording a different measured value as citation drift. Measured today is 448, so it passes, but as written no measurement can fail it.

**Delta — replace the `[P0-T3]` acceptance sentence with:**

> Acceptance: the artifact records 6 measured integers, and its `Output Summary:` reports the measured count for `.claude/hooks/enforce-prd-feature-before-planner.ps1` together with an explicit comparison against the research record's figure of 448, stated as MATCHES or DIFFERS-BY-N. A DIFFERS result does not fail this task; it is recorded as citation drift and every later task that cites a line number in that file is re-derived before it runs.

### D14 — Two tasks append to differently named artifacts

`[P1-T6]` and `[P4-T16]` both write `evidence/other/file-size-ledger.<ISO-8601>.md` and both say "append". With distinct run timestamps these are two different files, so `[P4-T16]` appends to a file that does not exist.

**Delta — `[P1-T6]`:** change the path to `.../evidence/other/file-size-ledger.md` (no timestamp element) and add: ``Each appended block carries its own `Timestamp:` line, so the single ledger file records both the Phase 1 and the Phase 4 measurements in order.`` **Delta — `[P4-T16]`:** change the path to the same untimestamped `.../evidence/other/file-size-ledger.md` and add `appending a second timestamped block below the Phase 1 block rather than creating a second file.` **Delta — preamble evidence-location paragraph:** add `The file-size ledger at evidence/other/file-size-ledger.md is the single exception to the timestamped-filename convention, because two tasks append to one ledger; each block inside it carries its own Timestamp: line.`

### D15 — Two `[P4-T3]` acceptance clauses name no observable

"the case ... progresses past target derivation" and "`HookPayload.psm1` shows no modification in the change set" are both unobservable by any command the task names.

**Delta — replace the `[P4-T3]` acceptance sentence with:**

> Acceptance: `Select-String -SimpleMatch -Pattern '$envelope.Envelope'` over `.claude/hooks/enforce-prd-feature-before-planner.ps1` returns at least one match, confirming the hook now reads the envelope root that `Resolve-ClaudeHookToolInput` surfaces on its `Envelope` member at `.claude/lib/hook-payload/HookPayload.psm1` line 481; and `.claude/lib/hook-payload/HookPayload.psm1` is absent from the changed-file set that `[P5-T5]` enumerates.

---

## Summary of required plan deltas

| # | Task(s) | Class |
|---|---|---|
| D1 | `[P4-T7]` | acceptance cannot fail; conflicts with `spec.md` line 353 |
| D2 | preamble, `[P0-T12]`, `[P1-T4]`, `[P4-T1]`, `[P4-T2]`, `[P4-T6]`, `[P4-T14]`, `[P4-T15]` | seven unsatisfiable or trivially-satisfied search tokens |
| D3 | new `[P4-T11a]` | two existing cases invalidated with no amending task |
| D4 | new `[P3-T5a]`, `[P3-T5b]`, `[P3-T6]` | three required `It`s authored by no task |
| D5 | `[P0-T10]`, four new batch-boundary tasks | declared batch split not operationalised; Phase 2 writes denied |
| D6 | new `[P3-T2a]`, `[P4-T6]`, `[P0-T6]`, `[P5-T4]` | three uncovered acceptance criteria |
| D7 | preamble ruling 8, new `[P4-T9a]` | unstated composition ruling that ~25 existing cases depend on |
| D8 | `[P5-T5]` | command denied by the pre-implementation gate |
| D9 | `[P0-T11]`, `[P3-T3]`, `[P3-T6]` | `[expect-fail]` tag contradicts own acceptance text |
| D10 | `[P3-T6]` | fail-before evidence not discriminating |
| D11 | preamble ruling 1, `[P4-T5]`, `[P4-T10]`, `[P4-T11]` | citation drift, one off-by-one that breaks a literal edit |
| D12 | new `[P2-T5a]`, `[P2-T7]`, `[P6-T3]`, `[P6-T5]` | coverage AC may be unevidencable by the named commands |
| D13 | `[P0-T3]` | acceptance cannot fail |
| D14 | preamble, `[P1-T6]`, `[P4-T16]` | append target does not exist |
| D15 | `[P4-T3]` | two unobservable acceptance clauses |

**Acceptance-criteria inventory check.** `spec.md` carries exactly 38 checkbox criteria between the `## Acceptance Criteria` heading at line 600 and `## Risks & Mitigations` at line 671, confirmed by direct count rather than from the planner's declaration. `[P6-T8]`'s total of 38 is correct. Thirty-five map to a task; the three gaps are itemised in D6.
