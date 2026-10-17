# Research: CI green gate evaluates all checks, and Codex CI Green Gate parity (Issue #899, with #891)

- Issue: #899 (bug, minor-audit); also resolves #891
- Branch: `bug/ci-green-gate-all-checks-and-codex-parity-899`
- Research timestamp: 2026-10-11T09-50
- Method: every finding was verified by reading the named file in this worktree with Read, Grep, and Glob. One external source was fetched (the `gh pr checks` manual, see 5.1). No shell commands were run and no file outside this `research/` folder was written.
- Prior art: `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/` (research, evidence). Its section 4.5 already recorded the Codex CI Green Gate gap that #891 now addresses.

## 1. Current State and Drift Surfaces (Q1)

### 1.1 Claude S9 (`.claude/skills/orchestrate/SKILL.md:285-303`, 449 lines)

Verbatim current text of the steps that #899 changes:

- `:292` step 2: "Invoke `gh pr checks --required --json bucket,name,state,link,workflow` (or an equivalent JSON-emitting command) against that head SHA. `gh` is the only sanctioned channel for querying GitHub Actions state."
- `:294` epic-child paragraph: "Epic-child rule: when the PR base branch is an `epic/<slug>-integration` branch (checkpoint `epic_mode` is `true`), run the step 2 query without `--required`, because integration branches carry no required-status-check protection and `--required` then returns an empty set. An empty check list, including an empty `gh pr checks --required` result, is not accepted as green for such a PR: the gate must observe at least one check whose `workflow` is `CI` against the child head SHA, and every observed `CI` check must succeed before `ci_gate.conclusion` is accepted as `success`. Every check returned by the unfiltered query counts: a failing or cancelled non-`CI` check fails the gate, and a pending one keeps it pending. Step 3 enforces this rule by passing `-RequireWorkflow CI` to the parser, which never returns `success` until at least one passing `CI` check is observed. When `gh pr checks` fails with a `no checks reported` error on the child branch, step 3 runs the parser with `-ChecksJson '[]'`; that error is never treated as green, and the parser returns `pending` for it."
- `:296` step 3: "Parse the JSON by running `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <head-sha>`, appending `-RequireWorkflow CI` when `epic_mode` is `true`. The parser emits the `ci_gate` object defined below and derives `ci_gate.conclusion` over the queried checks (the required checks on a non-epic PR; every observed check on an epic child): `success` when every queried check passed or was skipped, `failure` when any queried check failed or was cancelled, and `pending` when any queried check is still in progress. With `-RequireWorkflow CI`, the parser returns `pending` instead of `success` until at least one check whose `workflow` is `CI` has passed."
- `:291` step 1, `:297` step 4 (bounded poll, `awaiting_ci` on timeout), `:298` step 5 (write `ci_gate`, `step9_status: passed` only on `success` with matching head SHA), `:299` step 6 (epic merge), `:301` CI-dependent AC paragraph, `:303` DONE rule: unchanged by #899.
- Same wording family outside S9: `:345` "When S9 records `step9_status: "failed_remediation_required"` (a failed required check; a poll timeout follows the wait branch per S9 step 4):".
- PR Creation Gate condition 6 (`:363`) keys on `ci_gate.conclusion == "success"` only; it needs no change because the conclusion's population is defined in S9.

The defect: the non-epic population is "the required checks", so a failing non-required check (observed: `NPM Audit Gate / npm audit (.)` and `NPM Audit Gate / npm audit (extensions/drm-copilot)`) does not affect `ci_gate.conclusion`. Those check names come from the `CI` workflow itself: `.github/workflows/ci.yml:35-41` declares job `npm-audit-gate` named `NPM Audit Gate` calling `.github/workflows/_npm-audit-gate.yml`, whose job is `npm audit (${{ matrix.manifest }})` (`_npm-audit-gate.yml:25`) over `.`, `extensions/drm-copilot`, `packages/mcp-server` (`:31-33`). They are therefore `workflow == "CI"` checks that branch protection does not mark required.

### 1.2 parallel-orchestrate merge decision (`.claude/skills/parallel-orchestrate/SKILL.md`, 1200 lines)

Verbatim, `## Per-Item Merge to Main (Merge-on-Green)` procedure (`:371-389`):

- `:373-376` step 1: "The item's child orchestration runs unmodified, with `epic_mode` `false` or absent, and finishes at its own DONE. The child's PR Creation Gate condition 6 already requires `ci_gate.conclusion == "success"`, so at child DONE the item's pull request is open against `main` and its checks are green. The child is never instructed to merge its own pull request."
- `:377-385` step 2: "On child completion, durably confirm pull-request state and check conclusion with `gh pr view --json state,mergedAt,headRefOid`, and with `gh pr checks` when the check conclusion must be re-read — never from an in-memory completion notification — then record `merge_status: ci_green`. Before recording `merge_status: ci_green`, confirm that the `headRefOid` value equals the `ci_gate.head_sha` the child reported at DONE and that the child reported no pending CI-dependent acceptance criteria. When either check fails, do not record `merge_status: ci_green` and do not run `gh pr merge`; the item waits until its child pushes the check-off and re-runs S9, and the parent does not commit the check-off itself."
- `:386` step 3: "Execute `gh pr merge --merge <PR>` for that item's pull request, whose base is `main`."

Other passages that depend on child CI status:

- `:461-463` merge-conflict sub-step (d): "... and re-enters `## Per-Item Merge to Main (Merge-on-Green)` at the durable `gh pr checks` confirmation step." Consistent once step 2 always re-reads; no edit required.
- `:484-486` merge-conflict step 4: "Each remediated pass ends again at child DONE with the pull request open and CI green, after which the parent retries the merge ..." No edit required.
- `:594-597` transition chain: "`pr_open` to `ci_green` on durable confirmation after child DONE". No edit required.
- `:3` frontmatter description: "per-item merge to main after durably confirming CI green". No edit required.
- The enforcement hook `.claude/hooks/enforce-epic-merge-gate.ps1:289` authorizes a parallel merge on `merge_status == 'ci_green'` only; it never reads checks. The re-read obligation is therefore textual and lives in step 2.

The defect: "when the check conclusion must be re-read" makes the re-read conditional, so the parent can record `ci_green` from the child's DONE report alone.

### 1.3 Codex CI Green Gate (`.agents/skills/orchestrate/SKILL.md:453-464`, 497 lines)

Verbatim:

- `:455-458`: "Before PR/DONE completion, the orchestrator must observe the live PR head SHA and required GitHub checks through `gh`. The checkpoint must record the checked head SHA and CI result. DONE is blocked unless the required checks pass for the current PR head SHA."
- `:460`: "The checkpoint records the CI result in a top-level `ci_gate` object with the required keys `conclusion`, `head_sha`, and `verified_at`. `conclusion` is one of `success`, `failure`, or `pending`; `head_sha` is the PR head SHA the required checks were observed against; `verified_at` is the ISO-8601 time at which this gate (S9) recorded the result. DONE requires `ci_gate.conclusion` equal to `success` and `ci_gate.head_sha` equal to the current PR head SHA. The key set is defined by `CI_GATE_KEYS` in `scripts/dev_tools/validate_orchestrator_state.py`, and the TypeScript MCP validator used by the Codex runtime requires the same keys."
- `:462`: `pr_gate` paragraph (unchanged).
- `:464`: CI-dependent acceptance-criteria paragraph (unchanged).

Same wording family in the same file: `:425` ("a failed required check stays `autonomous` and enters the remediation loop") and `:476` PR Creation Gate condition 5 ("The required CI checks pass for the current PR head SHA."). The Codex skill has no epic-child rule, no parser invocation, and no `epic_mode` concept (Grep `epic_mode|integration branch|epic/` returns nothing). A Codex epic child is identified by its kickoff marker and base branch: `.agents/skills/epic-orchestrate/SKILL.md:76` ("PR base branch MUST be <integration_branch>, not main") with `integration_branch: epic/<epic-slug>-integration` (`:27`).

### 1.4 Drift-surface inventory

| Surface (source; bundle mirror) | Current text | Change for #899/#891 | Reason |
|---|---|---|---|
| `.claude/skills/orchestrate/SKILL.md:292,294,296,345`; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` (same lines) | `--required` query; "required checks on a non-epic PR"; "a failed required check" | Yes | Primary #899 defect |
| `.claude/skills/parallel-orchestrate/SKILL.md:373-385`; Claude bundle mirror (same lines) | conditional `gh pr checks` re-read | Yes | #899 parent re-read |
| `.agents/skills/orchestrate/SKILL.md:425,453-460,476`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` (same lines) | required-checks gate; no epic-child guard; no parser | Yes | #891 parity plus #899 rule |
| `.claude/agents/orchestrator.md:133`; Claude bundle mirror | "monitors the required CI checks ... A failed required check" | Yes | Restates the population; would contradict S9 |
| `.claude/agents/parallel-orchestrator.md:51`; Claude bundle mirror | "after durably confirming that its checks are green" | Optional | Not wrong after the fix; tightening to "every check on its head" is consistent |
| `.codex/agents/orchestrator.toml:191,193` and five generated variants `orchestrator-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` `.toml`, each mirrored in the Codex bundle (12 files) | "8. Required GitHub checks are green ..."; "The MCP validator and required CI checks are the hard completion boundary." | Yes | Codex completion boundary restates the population |
| `.agents/skills/orchestrator-workflow/SKILL.md:439`; Codex bundle mirror | "required GitHub checks pass for the current PR head SHA before PR/DONE completion" | Yes | Same |
| `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:17,55`; Claude bundle mirror | "A required CI check fails after the pull request is open." | Recommended | After #899 any failing check enters the loop |
| `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` help `:8,20-24,41,46,75`; Claude bundle mirror | help cites `gh pr checks --required` and "required check" | Recommended (comment-only) | Help would describe a query S9 no longer runs |
| `.claude/skills/epic-orchestrate/SKILL.md:108-109`; `.claude/agents/epic-orchestrator.md` | "runs the same S9 CI-green procedure" | No | Inherits S9 by reference; both files are SHA-256 pinned in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:160-169` |
| `.claude/skills/acceptance-criteria-tracking`, `.agents/...`, `.github/...` `SKILL.md` | "after the CI green gate (S9) records `ci_gate.conclusion` as `success`" | No | Keys on the conclusion, not the population |
| `.claude/skills/feature-review-workflow/SKILL.md:72-73`, `.agents/...` | refer to "S9 CI green gate" / "CI Green Gate (S9)" | No | Reference only |
| `.github/agents/*orchestrator*.agent.md` | only list `step9_status` as a checkpoint field | No | No CI-green rule text exists on the Copilot surface |
| `.codex/hooks/enforce-completion-consistency.ps1:24,226-238`, `.claude/hooks/enforce-completion-consistency.ps1` | check `ci_gate.conclusion == "success"` | No | Conclusion-based |
| `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:167,220` | release flow polls `gh pr checks --required --json bucket` | No (out of scope; observation) | Release automation, not the orchestrator S9; pinned by `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:71,170,304,335`. Candidate follow-up |

## 2. Mirror Mechanics (Q2)

| Pair | Enforcing test | Regenerate or check |
|---|---|---|
| Every `.claude/**` file and `extensions/drm-copilot/resources/claude-customizations/.claude/**` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` (text equality, all distributable files) | Hand-copy the source bytes to the mirror |
| `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/parallel-orchestrator.md`, `.agents/skills/orchestrate/SKILL.md` | `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:72-87,409-423` (byte equality) | Hand-copy |
| Every `.agents/**` and `.codex/**` file and the Codex bundle | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-228` (text equality) | Hand-copy |
| `.codex/agents/orchestrator.toml` and its five variants, root and bundle | `scripts/dev_tools/generate_codex_agent_variants.py` (`_synchronize`, `:221-268`): writes the C3 base alias to both roots and every variant to both roots; `--check` reports drift. CI runs `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` (`.github/workflows/_quality-checks.yml:71`); unit tests in `tests/scripts/dev_tools/test_generate_codex_agent_variants.py` | Edit `.codex/agents/orchestrator.toml` only, then run `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` and `... --check` |
| Parser and pack membership | `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1`; `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:177` lists the parser | No manifest change needed |
| Skill script references | `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py:29-66` via `scripts/dev_tools/skill_bundle_contract.py` (scans `.claude/skills` only, `skill_bundle_contract_cli.py:43`) | A new `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1` invocation in `parallel-orchestrate` passes because the parser is in `core.json`; `.agents` skills are not scanned |

Issue #510: the local-only failure on gitignored `.claude/state/**` is resolved in the current tree. `tests/scripts/dev_tools/claude_payload_scope_test_support.py:27-44` excludes `agent-memory`, `state`, and `worktrees` under `.claude/` and `.claude/settings.local.json`, and `test_push_down_claude_resource_contracts.py:101` applies that filter. Residual risk: the Codex parity test (`:219`) enumerates the filesystem under `.agents` and `.codex`; it excludes `.codex/state` (`:231`) but any other untracked local file under those roots would fail locally. When a local parity failure appears, confirm with `git hash-object` on the source and mirror before treating it as a defect.

## 3. Text-Pinning Tests (Q3)

| Test | Pinned text that the #899 edit must keep (or change deliberately) |
|---|---|
| `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py:57-66,156-166` (S9 section, both Claude orchestrate copies) | `-RequireWorkflow CI`; "Every check returned by the unfiltered query counts"; "a failing or cancelled non-`CI` check fails the gate"; "at least one passing `CI` check"; "`no checks reported`"; "`-ChecksJson '[]'`"; "is never treated as green"; "derives `ci_gate.conclusion` over the queried checks". Keep all eight. |
| same file `:67,169-179` | schema bullet "the PR head SHA that the queried checks were observed against". Keep. |
| same file `:68-71,182-192` | must NOT contain "derives `ci_gate.conclusion` as `success` when all required checks pass" or "that the required checks were observed against" (whole file). New Codex text must not introduce these into the Claude copies; the Codex `:460` phrase "the required checks were observed against" is in a different file and is not checked here, but it should change anyway. |
| same file `:52-55,195-209` | exactly one S9 line contains both "`pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson" and "-HeadSha <head-sha>`". The step 3 command must stay on one line and must not be duplicated in another S9 line with the same span. |
| `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:139-165` (Codex `## CI Green Gate`) | "top-level `ci_gate` object with the required keys `conclusion`, `head_sha`, and `verified_at`"; "`verified_at` is the ISO-8601 time at which this gate (S9) recorded the result"; "DONE requires `ci_gate.conclusion` equal to `success` and `ci_gate.head_sha` equal to the current PR head SHA"; "`CI_GATE_KEYS` in `scripts/dev_tools/validate_orchestrator_state.py`"; "top-level `pr_gate` object with the keys `pr_number`, `pr_url`, `head_branch`, and `head_sha`"; "`PR_GATE_KEYS` in `scripts/dev_tools/_orchestrator_state_routing.py`". Note "with the required keys" refers to keys, not checks; keep it. |
| same file `:168-189` | Codex `## Hard Enforcement Boundary` lines starting "- `ci_gate`:" and "- `pr_gate`:" (`.agents/skills/orchestrate/SKILL.md:302-303`). Untouched. |
| same file `:192-204` | Codex CI-dependent paragraph fragments (`:464`). Keep. |
| same file `:222-238` | Claude S9 CI-dependent paragraph (`:301`). Untouched. |
| same file `:241-267` | parallel Merge-on-Green: "Issue #744 later amended two parts of that child contract"; "The parent never commits acceptance-criteria check-offs from the coordinator root"; "confirm that the `headRefOid` value equals the `ci_gate.head_sha` the child reported at DONE"; "the child reported no pending CI-dependent acceptance criteria"; "do not record `merge_status: ci_green` and do not run `gh pr merge`". Keep all. |
| same file `:270-283` | parallel-orchestrator agent `## Completion Requirements` fragments (`:294-299`). Untouched. |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:214-220` | Merge-on-Green: "durably confirm pull-request state and check conclusion with `gh pr view --json state,mergedAt,headRefOid`"; "merge_status: ci_green"; "Execute `gh pr merge --merge <PR>`"; "`.claude/skills/orchestrate/SKILL.md` is **not modified by this feature**". The new step 2 sentence must begin with the first fragment verbatim. |
| same file `:160-169` | SHA-256 pins of `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md`. Do not edit either file. |
| `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py:46-66` | both `orchestrate` and `epic-orchestrate` invoke `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`. Keep. |
| `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1:91-98` | default-path vacuous success on `[]`. Unchanged behavior. |

Searches for "checks are green", "check conclusion must be re-read", "Required GitHub checks", "monitors the required", "failed required check", and "durably confirming" across `tests/**`, `scripts/**`, `extensions/drm-copilot/src/**`, `extensions/drm-copilot/test/**`, and `packages/**` returned no other assertions. Those passages can change without breaking a pin.

## 4. Invoke-CiGateParser.ps1 and the Coverage Gap (Q4)

### 4.1 Contract (`.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, 402 lines including a trailing blank line)

- Script parameters (`:88-111`): `-ChecksJson` (mandatory, pipeline), `-HeadSha` (mandatory, not empty), `-PrPipelineRunId` (default `''`), `-PrPipelineRunUrl` (default `''`), `-NowProvider` (ScriptBlock, `[ValidateNotNull()]`), `-RequireWorkflow` (default `''`), `-AsJson` (switch).
- `begin` defines `Get-CiGateConclusion` (`:118-241`), `ConvertTo-CiGateObject` (`:243-284`), `Invoke-CiGateParser` (`:286-382`). `process` (`:390-401`) calls `Invoke-CiGateParser` only when `$MyInvocation.InvocationName -ne '.'`, forwarding every parameter including the script-level `$NowProvider` (`:397`).
- Conclusion (`Get-CiGateConclusion`): whitespace-only `-RequireWorkflow` throws (`:168-170`); null or empty set returns `success`, or `pending` with the guard (`:177-182`); a missing `bucket` throws (`:196-198`); `fail` and `cancel` return `failure` immediately (`:206-207`); `pending` is recorded (`:208`); `pass` from the named workflow (case-sensitive `-ceq`, absent `workflow` property never matches) sets the guard flag (`:209-218`); `skipping` is ignored (`:219`); any other bucket throws (`:220-224`); pending wins over success (`:230-232`); with the guard, no matching pass yields `pending` (`:236-238`).
- `-RequireWorkflow` therefore adds a presence condition over all observed checks; it never filters them.
- Exact current default delegates:
  - `:104` (script param block): `    [ScriptBlock]$NowProvider = { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') },`
  - `:338` (`Invoke-CiGateParser` param block): `            [ScriptBlock]$NowProvider = { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') },`
- Consequence: running the script without `-NowProvider` uses the `:104` delegate and forwards it, so the `:338` default is reached only when the function `Invoke-CiGateParser` is called directly without `-NowProvider`.

### 4.2 How tests invoke it (`tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`, 410 lines)

- `:11-12` dot-sources the script with `-ChecksJson '[]' -HeadSha 'bootstrap-sha'`, so the functions load and the `process` body is skipped.
- `:16` `$script:fixedClock = { '2026-06-24T17:00:00Z' }`; every direct call passes `-NowProvider $script:fixedClock` (`:37` through `:266`).
- `:404` is the only script-file invocation (`& $script:scriptPath ... -NowProvider $script:fixedClock`), so it also injects a clock.
- No test calls either default delegate. #841 evidence (`docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-pester-coverage.2026-10-08T22-17.md:11,32-33`) recorded LINE 45/46 = 97.83%, missed line 338 only, and listed 104 as HIT. The mechanism for the 104 hit was not determined: no test executes the script-level default body, and the issue reports 104 as unrecorded. The tests below execute both bodies explicitly, so both lines are covered without depending on that mechanism.

### 4.3 Deterministic tests for the default delegates (recommended)

Add one `Context "default NowProvider delegates"` with two `It` blocks. Use Pester `Mock -CommandName Get-Date` returning a fixed UTC `[datetime]`. Repository precedent: `tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1:26-34,61` mocks `Get-Date` and the mock reaches a script invoked with `&`.

1. Function default (`:338`):
   - Arrange: `Mock -CommandName Get-Date -MockWith { [datetime]::new(2026, 6, 24, 17, 0, 0, [System.DateTimeKind]::Utc) }`.
   - Act: `$result = Invoke-CiGateParser -ChecksJson '[]' -HeadSha 'sha1'` (no `-NowProvider`).
   - Assert: `$result.verified_at | Should -Be '2026-06-24T17:00:00Z'`; `Should -Invoke -CommandName Get-Date -Times 1 -Exactly`.
2. Script default (`:104`):
   - Same mock.
   - Act: `$result = & $script:scriptPath -ChecksJson '[]' -HeadSha 'x'` (no `-NowProvider`).
   - Assert: the same exact `verified_at`, and `Should -Invoke -CommandName Get-Date -Times 1 -Exactly`.

Properties: no wall-clock read (the mock replaces `Get-Date`), no sleeps, no temporary files, no `gh`. `[DateTimeKind]::Utc` makes `.ToUniversalTime()` an identity operation, so the result does not depend on the host time zone. Caveat (not verified): in .NET custom format strings `:` is the culture time separator. The `CI` PoshQC job runs on `windows-latest` (`.github/workflows/_poshqc.yml:10`), which most likely uses a `:` culture. A regex fallback (`'^\d{4}-\d{2}-\d{2}T\d{2}.\d{2}.\d{2}Z$'`) would avoid that dependency but would assert less; prefer the exact assertion. Expected test-file size is about 440 lines, under the 500 limit. No production change is needed for coverage.

### 4.4 Coverage configuration

- Coverage population: `config/poshqc-coverage.json:3-9` roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`; `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` is in scope.
- The bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1` is under none of those roots and is not in the coverage population (`scripts/powershell/PoshQC/README.md:71-73`).
- Settings: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27` (CoverageGutters format, output `artifacts/pester/powershell-coverage.xml`, `CoveragePercentTarget = 0`, so the Pester run does not enforce a threshold).
- Tier: `.claude/lib/ci-gate` is T3 (`quality-tiers.yml`, per #841 research 1.2); line threshold 85% applies; PowerShell has no branch threshold.

## 5. All-Checks Mode Evaluation (Q5)

### 5.1 `gh pr checks` JSON fields (external)

Fetched from https://cli.github.com/manual/gh_pr_checks on 2026-10-11: JSON fields are `bucket`, `completedAt`, `description`, `event`, `link`, `name`, `startedAt`, `state`, `workflow`. No field marks a check as required; only the `--required` filter does. Exit code 8 means checks pending. The locally installed `gh` version was not checked. #841 research 1.3 records that a zero-check set reaches the caller as a `no checks reported` error, not as `[]`.

### 5.2 Options

- (a) Selected: drop `--required` from S9 step 2 for every PR. The parser already evaluates every check it receives (`Get-CiGateConclusion` reads every element), so `ci_gate.conclusion` becomes `failure` when any check fails or is cancelled. A failing non-required check then follows the existing CI-failure path (`.claude/skills/orchestrate/SKILL.md:343-351`): a synthetic Blocking finding naming the check and job URL, through R1-R5, sharing the attempt count. The epic-child guard (`-RequireWorkflow CI`) is unchanged. No parser behavior change, no new parameter, no schema change.
- (b) Rejected: a required-versus-non-required report ("required checks green; N non-required checks failing"). Required identity is not in the JSON (5.1), so it needs a second `gh pr checks --required` query and either a new parser input (a list of required names) or a new `ci_gate` field. That adds parser surface and a schema or validator change. It also leaves a "green with failures" state that the parent must remember not to merge on, which is the ambiguity #899 removes. Option (a) satisfies the first alternative the issue names.

### 5.3 Behavior semantics after (a)

- Population: every check on the PR head SHA, for every PR (non-epic, epic child, epic final PR via `epic-orchestrate`'s reference to S9).
- `success`: every check passed or was skipped (and, on an epic child, at least one `CI` check passed). `failure`: any check failed or was cancelled. `pending`: any check is in progress (or, on an epic child, no passing `CI` check yet).
- Zero-check case: today a non-epic `gh` error ("no required checks reported") is not described by S9. Recommended text: a `no checks reported` error is never treated as green for any PR. On a non-epic PR the gate stays `pending` within the bounded poll. On an epic child, step 3 passes `-ChecksJson '[]'` with `-RequireWorkflow CI`, which returns `pending` (existing text). Do not call the parser with `'[]'` without the guard, because its default path returns `success` (`:177-182`). In a repository that runs no workflows at all, the result is a poll timeout recorded as `awaiting_ci`. That is a fail-closed outcome and does not change the parser.
- Do not apply `-RequireWorkflow CI` to non-epic PRs. The skill is pushed down to consumer repositories that may have no workflow named `CI`; there the gate would never reach `success`.
- Known consequence: a pre-existing failing check that the change did not cause (for example a newly disclosed npm advisory) now blocks DONE and the parallel merge, and enters remediation. That is the semantics #899 requests. The reviewer's existing remediability classes (`external_dependency` halt) apply if the failure cannot be fixed in scope.

### 5.4 Schema and validators

`ci_gate` keeps the same keys and enum: `scripts/dev_tools/validate_orchestrator_state.py:105` `CI_GATE_KEYS = ("conclusion", "head_sha", "verified_at")`; `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1:72` (and bundle mirror) `$script:CI_GATE_KEYS = @('conclusion', 'head_sha', 'verified_at')`; `extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts:29`. The completion hooks (`.claude/hooks/enforce-completion-consistency.ps1:226-231`, `.codex/hooks/enforce-completion-consistency.ps1:233-238`) and the merge gate (`.claude/hooks/enforce-epic-merge-gate.ps1:289`) key on `conclusion` or `merge_status` only. No schema, validator, hook, or TypeScript change is needed.

### 5.5 Codex parity design (#891)

- Mirror the Claude S9 rules into `## CI Green Gate`: an all-checks query (`gh pr checks --json bucket,name,state,link,workflow` against the head SHA); parse with `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <head-sha>`, appending `-RequireWorkflow CI` when the PR base branch is an `epic/<slug>-integration` branch; the epic-child sentences ("Every check returned by the unfiltered query counts", "a failing or cancelled non-`CI` check fails the gate", "at least one passing `CI` check", "`no checks reported`", "`-ChecksJson '[]'`", "is never treated as green"); and the outcome definitions.
- Key the epic-child condition on the PR base branch (observable via `gh pr view --json baseRefName`), because the Codex checkpoint has no `epic_mode` field (1.3).
- Portability gap (record as a follow-up; not resolved here): the Codex push-down (`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:123-148`) copies only `resources/codex-and-agents-customizations`, whose packs carry no `.claude/lib/` file (Grep of `codex-and-agents-customizations/pack-manifests` for `.claude/` and `ci-gate` returns no match). In a consumer repository with only the Codex payload installed, the parser path would not exist. Codex skills otherwise invoke scripts under `.codex/scripts/` (for example `.agents/skills/epic-orchestrate/SKILL.md:98`). Copying the parser into `.codex/scripts/` would create a second implementation that can drift. Recommended interim text: the Codex gate states the derivation rules in prose and invokes the parser at `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`. When that file is absent, the orchestrator records blocked state rather than deriving `success` by hand. Bundling the parser into the Codex payload is a separate follow-up decision.

## 6. Overlap Constraints (Q6)

- #890 (Python engine-call text in `.claude/skills/parallel-orchestrate/SKILL.md`): verified text at `:665-666` ("The decision logic for all three commands is the pure engine `scripts/dev_tools/parallel_mutation_protocol.py`"), `:821` (`build_requeue_entry` / `recolor_unstarted`), `:829` (six-argument `recolor_unstarted(...)` call shape). #899 touches only `:373-385` in that file, which is disjoint. Both items edit the same file and its bundle mirror, so whichever lands second re-copies the merged source to the mirror.
- #900 (scratch-file guidance): Grep for "scratch" in `.claude/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/agents/atomic-executor.md`, and `.codex/agents/orchestrator.toml` returns no match, and no #900 feature folder exists on this branch. Its target lines could not be verified. #899 line ranges to keep the conflict surface small: `.claude/skills/orchestrate/SKILL.md:292-296` and `:345`; `.agents/skills/orchestrate/SKILL.md:425`, `:453-460`, `:476`; `.claude/agents/orchestrator.md:133`; `.codex/agents/orchestrator.toml:191,193`; `.agents/skills/orchestrator-workflow/SKILL.md:439`; `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:17,55`.

## 7. File Sizes (Q7)

Line counts from Grep `^` (count mode; includes a trailing empty line where present):

| File | Lines | Limit |
|---|---|---|
| `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` | 402 | 500 (help-only edit keeps it roughly unchanged) |
| `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` | 410 | 500 (about +30 expected) |
| `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` | 312 | 500 |
| `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` | 423 | 500 (do not grow it; put new pins in a new file) |
| `.codex/agents/orchestrator.toml` | 211 | config |
| `.claude/skills/orchestrate/SKILL.md` | 449 | Markdown, exempt |
| `.claude/skills/parallel-orchestrate/SKILL.md` | 1200 | Markdown, exempt |
| `.agents/skills/orchestrate/SKILL.md` | 497 | Markdown, exempt |
| `.agents/skills/orchestrator-workflow/SKILL.md` | 464 | Markdown, exempt |
| `.claude/agents/orchestrator.md` | 194 | Markdown, exempt |
| `.claude/agents/parallel-orchestrator.md` | 306 | Markdown, exempt |
| `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | 133 | Markdown, exempt |

## 8. Verification Route (Q8)

- Local PowerShell: PoshQC MCP tools only (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test` with scan folder `tests/scripts/claude-lib/ci-gate`). Their results carry a summary only. A plan task must not assert a count, percentage, or per-file figure from them.
- Python text contracts: pytest through the repository toolchain.
- Per-file Pester coverage source: workflow `CI` (`.github/workflows/ci.yml:23-24`) job `poshqc`, which calls `.github/workflows/_poshqc.yml` job `PowerShell QC` on `windows-latest` (`:8-10`). Step "Test PowerShell" (`:38-42`) runs `Invoke-PoshQCTest -Root`. The log shows the Pester summary and the aggregate coverage lines; the replay stops at "Missed commands" (`scripts/powershell/PoshQC/PoshQC.Testing.psm1:429-458`), so no per-file figure is guaranteed in the log. The per-file figure is in the uploaded artifact `poshqc-test-results` (`_poshqc.yml:44-52`), file `artifacts/pester/powershell-coverage.xml`: the `<sourcefile name="Invoke-CiGateParser.ps1">` element under the package ending `.claude/lib/ci-gate`, with its `<counter type="LINE" missed=... covered=...>` and per-`<line>` hit counts (as read in #841 evidence `final-pester-coverage...md:28-33`). Retrieve it with `gh run download <run-id> -n poshqc-test-results`.

## Numeric Derivation Evidence

### Claim N1: Codex orchestrator agent files carrying the required-checks completion line = 12

- Complete Family: every `.codex/agents/orchestrator*.toml` file in the repository (base alias and generated profiles, root and Codex bundle).
- Exhaustive Search Scope: entire worktree.
- Inclusion Rules: TOML files whose base name starts with `orchestrator` under a `.codex/agents/` directory.
- Exclusion Rules: other agent families (for example `atomic-planner*.toml`); documentation under `docs/`.
- Primary Search Strategy or Query Expression: Grep `Required GitHub checks are green` (files_with_matches), glob `!{docs/**,artifacts/**}`.
- Primary Member Set: `.codex/agents/orchestrator.toml`, `.codex/agents/orchestrator-c1.toml`, `.codex/agents/orchestrator-c2.toml`, `.codex/agents/orchestrator-c3.toml`, `.codex/agents/orchestrator-c3-elevated.toml`, `.codex/agents/orchestrator-c4.toml`, and the same six names under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/` (raw result 13 files; the 13th, `pack-manifests/core.json`, matched the other alternation term `orchestrator-c1\.toml` in the combined query and is excluded as not a TOML agent file).
- Primary Count: 12.
- Cross-check Search Strategy or Query Expression: Glob `**/.codex/agents/orchestrator*.toml`.
- Cross-check Member Set: the same twelve paths.
- Cross-check Count: 12.
- Member-set Comparison: identical normalized sets. The generator (`scripts/dev_tools/generate_codex_agent_variants.py:182-192,221-257`) writes exactly these: one base alias and five profiles (`PROFILES`, `:62-88`) for the `orchestrator` family, in two roots.

No other numeric acceptance criterion is proposed; the remaining criteria are presence or absence token checks.

## Automation Feasibility

No step requires human interaction. Every change is a Markdown or TOML text edit, a comment-only PowerShell help edit, a Pester addition, and a pytest addition. Codex variants are regenerated by a repository script. Verification uses PoshQC MCP tools, pytest, and the PR's CI run, whose `poshqc-test-results` artifact is downloadable with `gh`. No `.github/workflows/**`, `.github/actions/**`, or `scripts/benchmarks/**` path is changed, so `modified-workflow-needs-green-run` does not trigger. Two decisions are made in this research rather than deferred to a human: option (a) over (b), and recording the Codex parser portability gap as a follow-up.

## Recommendations

### File edits (source plus bundle mirror, byte-identical)

1. `.claude/skills/orchestrate/SKILL.md` and the Claude bundle mirror:
   - `:292` step 2 becomes `gh pr checks --json bucket,name,state,link,workflow`, with one sentence stating that every check on the head SHA is queried for every PR, required or not.
   - `:294` epic-child paragraph: replace "run the step 2 query without `--required`, because ... returns an empty set" and "including an empty `gh pr checks --required` result" with wording that does not mention `--required`. Keep all eight pinned fragments (section 3).
   - Add the zero-check rule: a `no checks reported` error is never green; it is `pending` within the poll on a non-epic PR, and `'[]'` with `-RequireWorkflow CI` on an epic child.
   - `:296` replace "(the required checks on a non-epic PR; every observed check on an epic child)" with "(every check on the PR head)". Keep the command on one line.
   - `:345` "a failed required check" becomes "a failed check".
2. `.claude/skills/parallel-orchestrate/SKILL.md:373-385` and mirror:
   - Step 1: "its checks are green" becomes "every check on its head SHA passed or was skipped".
   - Step 2 starts with the pinned fragment "durably confirm pull-request state and check conclusion with `gh pr view --json state,mergedAt,headRefOid`". Then it always re-reads every check: `gh pr checks <PR> --json bucket,name,state,link,workflow` parsed by `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <headRefOid>`. Record `merge_status: ci_green` only when that conclusion is `success`. On `failure` or `pending`, do not record `ci_green` and do not merge.
   - Remove "when the check conclusion must be re-read". Keep the other pinned fragments.
3. `.agents/skills/orchestrate/SKILL.md` and Codex mirror: rewrite `## CI Green Gate` `:455-460` per 5.5, keeping every pinned fragment in section 3. Change `:425` "a failed required check" to "a failed check" and `:476` condition 5 to "Every check on the current PR head SHA passed or was skipped (`ci_gate.conclusion == "success"`)". State the parser-absent fail-closed rule.
4. `.claude/agents/orchestrator.md:133` and mirror: "monitors the required CI checks" becomes "monitors every CI check"; "A failed required check" becomes "A failed check".
5. `.codex/agents/orchestrator.toml:191,193`: "Required GitHub checks are green" becomes "Every GitHub check is green (passed or skipped)"; "required CI checks" becomes "CI checks". Then run `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` and `--check` (12 files).
6. `.agents/skills/orchestrator-workflow/SKILL.md:439` and Codex mirror: "every GitHub check passes or is skipped for the current PR head SHA before PR/DONE completion".
7. `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:17,55` and mirror: "A required CI check fails" becomes "A CI check fails".
8. `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` help (`:8,20-24,41,46,75`) and mirror, comment-only: drop `--required` from the cited query and say "check" for "required check". Behavior unchanged.
9. Optional: `.claude/agents/parallel-orchestrator.md:51` and mirror: "that every check on its head passed or was skipped".
10. Do not edit: `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md` (hash-pinned; they inherit S9), `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (out of scope), any schema, validator, or hook.

### Test additions

- `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`: the two `It` blocks in 4.3.
- New `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` (reads files only; whitespace-normalized; section extraction like `test_ci_gate_epic_child_contracts.py:101-125`), parametrized over source and mirror:
  - The Claude S9 section has no `--required` and states the all-checks population.
  - The Codex `## CI Green Gate` contains the parser invocation, `-RequireWorkflow CI`, and the epic-child fragments, and has no `--required`.
  - The parallel Merge-on-Green section contains the parser re-read and not "when the check conclusion must be re-read".
  - `.claude/agents/orchestrator.md` has no "required CI checks".
  - All twelve `orchestrator*.toml` files have no "Required GitHub checks are green".
  - `.agents/skills/orchestrator-workflow/SKILL.md` has no "required GitHub checks pass".
  - Do not add to `test_completion_gate_documentation_contracts.py` (423 lines).

### Acceptance criteria for issue.md

- [ ] AC-1: S9 step 2 queries every check for every PR: `rg -n -F -e "--required" .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` returns no match (verified by `test_ci_gate_all_checks_contracts.py`).
- [ ] AC-2: S9 epic-child guard and wording are preserved: `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` passes.
- [ ] AC-3: S9 states that a `no checks reported` error is never green for any PR (verified by `test_ci_gate_all_checks_contracts.py`).
- [ ] AC-4: The parallel parent always re-reads every check before recording `ci_green`: `rg -n -F "when the check conclusion must be re-read" .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` returns no match, and the Merge-on-Green section invokes `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (verified by `test_ci_gate_all_checks_contracts.py`).
- [ ] AC-5: The Codex CI Green Gate (source and mirror) invokes `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1`, passes `-RequireWorkflow CI` for an `epic/<slug>-integration` base, and evaluates every check (verified by `test_ci_gate_all_checks_contracts.py`). `test_completion_gate_documentation_contracts.py` still passes.
- [ ] AC-6: No orchestrator surface restates a required-only population: `rg -n -i -e "required CI checks" -e "required GitHub checks" -e "failed required check" .claude/agents/orchestrator.md .agents/skills/orchestrate/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md .codex/agents .claude/skills/orchestrate/SKILL.md .claude/skills/remediation-handoff-atomic-planner/SKILL.md` returns no match.
- [ ] AC-7: Codex agent variants are in sync: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` exits 0.
- [ ] AC-8: Both default clock delegates execute under test: the Pester tests "uses the Invoke-CiGateParser default NowProvider when none is injected" and "uses the script-level default NowProvider when the script runs without -NowProvider" pass.
- [ ] AC-9 (CI-dependent): the PR's `CI` run artifact `poshqc-test-results` reports `Invoke-CiGateParser.ps1` LINE `missed="0"` in `artifacts/pester/powershell-coverage.xml`.
- [ ] AC-10: Every edited surface matches its bundle mirror: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror`, and `test_skill_bundle_contract_repo.py` pass.
- [ ] AC-11: Epic surfaces are unchanged: `test_parallel_orchestrator_surface_contracts.py` passes (SHA-256 pins on `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md`).
- [ ] AC-12: `ci_gate` schema is unchanged: `rg -n -F "CI_GATE_KEYS = (\"conclusion\", \"head_sha\", \"verified_at\")" scripts/dev_tools/validate_orchestrator_state.py` returns one match.
- [ ] AC-13: The Pester test file stays within the size limit (500 lines or fewer).

Token-search note: write hyphen-leading patterns with `-e` (as above). A bare `rg "--required"` is parsed as an option.

### Follow-up candidates (not in this item)

- Bundle the CI gate parser for Codex-only consumers, or define the Codex fallback (5.5).
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` `Wait-ForPullRequestChecks` uses `--required` and would merge a release PR with a failing non-required check.
