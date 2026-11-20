# Research: CI gate vacuous on empty check list (Issue #841, with #795)

- Issue: #841 (Medium, full-bug); folded-in item: #795 (Low)
- Branch: `bug/ci-gate-vacuous-on-empty-check-list-841` (based on `origin/main` `e7d3779b`)
- Research timestamp: 2026-10-09T02-25
- Method: every finding below was verified by reading the named file in this worktree (Read/Grep/Glob) unless it is marked as external. No shell commands were run. No source files were modified.

## 1. Current State Analysis

### 1.1 Parser contract (`.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, 330 lines)

- Script parameters (`Invoke-CiGateParser.ps1:69-89`): `-ChecksJson` (string, mandatory, pipeline), `-HeadSha` (string, mandatory, not empty), `-PrPipelineRunId` (string, default `''`), `-PrPipelineRunUrl` (string, default `''`), `-NowProvider` (ScriptBlock, default UTC `Get-Date`), `-AsJson` (switch).
- Structure: `begin` block defines three functions; `process` block (`:319-329`) calls `Invoke-CiGateParser` only when not dot-sourced (`$MyInvocation.InvocationName -ne '.'`).
- `Get-CiGateConclusion -Checks <object[]>` (`:96-175`) is the pure derivation:
  - `:132-134` null or empty set returns `success` (the CR-1 defect for epic children).
  - `:145-147` an element without a `bucket` property throws.
  - `:154-165` bucket switch: `fail`/`cancel` return `failure` immediately; `pending` sets `$anyPending`; `pass`/`skipping` no-op; any other value throws.
  - `:170-174` `pending` if any pending, else `success`.
  - The `workflow` property is never read.
- `ConvertTo-CiGateObject` (`:177-218`) emits `head_sha`, `pr_pipeline_run_id`, `pr_pipeline_run_url`, `conclusion`, `verified_at`.
- `Invoke-CiGateParser` (`:220-311`) parses JSON (`:279-284`, throws `malformed checks JSON`), normalizes with `@($parsed)` (`:289`), derives the conclusion (`:291`), resolves `verified_at` through `NowProvider`, optionally emits JSON (`:306-308`).
- Help text stating the vacuous rule: `:19-26` (notably `:22-23`) and `:107-114`.

### 1.2 Callers and copies (repository-wide grep for `Invoke-CiGateParser|ci-gate/`, `docs/features/**` excluded)

| File | Role |
|---|---|
| `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` | Source |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1` | Bundle mirror; must be byte-identical (see 3.2) |
| `.claude/skills/orchestrate/SKILL.md:293` (+ bundle mirror) | S9 step 3 invocation (non-epic and epic-child PRs) |
| `.claude/skills/epic-orchestrate/SKILL.md:109` (+ bundle mirror) | Epic final PR (`epic/<slug>-integration` into `main`) runs the same S9 procedure |
| `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` (205 lines) | Unit tests (dot-sources the script, `:11-12`) |
| `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` | Asserts the path is in `pack-manifests/core.json` once |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:165` | Pack membership |
| `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py:23,46-66` | Asserts both orchestration skills invoke the bundled parser path |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:138-163` | SHA-256 pin of `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` |
| `tests/scripts/dev_tools/test_quality_tiers_contract.py:334`, `quality-tiers.yml:40-42` | `.claude/lib/ci-gate` is tier T3 |

No `.agents`, `.codex`, `.github`, TypeScript, or `scripts/` caller exists. There is no Codex copy of the parser (Glob `**/ci-gate/**` returns only the four files above).

### 1.3 `gh pr checks` behavior relevant to the empty case (external, verified against cli/cli `trunk` source on 2026-10-08; the locally installed `gh` version was not checked)

- JSON fields include `bucket` and `workflow`; buckets are `pass`, `fail`, `pending`, `skipping`, `cancel` (https://cli.github.com/manual/gh_pr_checks).
- In `pkg/cmd/pr/checks/checks.go`, `populateStatusChecks` runs before the JSON exporter and returns an error for zero checks: `no checks reported on the '<branch>' branch`, and with `--required`, `no required checks reported on the '<branch>' branch`. The JSON exporter returns before the pending exit-code path, so a pending set with `--json` exits 0.
- Consequence: an empty check set normally reaches the orchestrator as a `gh` error, not as `[]`. The S9 text should state that a "no checks reported" error is treated as an empty check list (pass `'[]'` to the parser), never as green.

### 1.4 S9 text (`.claude/skills/orchestrate/SKILL.md`)

- `:289` step 2 query with `--required`.
- `:291` epic-child rule: drop `--required` when `epic_mode` is true; require at least one check whose `workflow` is `CI`; every observed `CI` check must succeed. Silent on non-`CI` checks (CR-4).
- `:293` step 3: invocation plus "required checks" wording (CR-4).
- `:307` schema bullet: "the PR head SHA that the required checks were observed against" (CR-4).
- `:342` remediation loop: "(a failed required check; ...)" (same wording family; optional alignment).
- `:294` poll while `pending`; timeout routes to `awaiting_ci` wait branch, not the remediation loop.
- The CI workflow's display name is `CI` (`.github/workflows/ci.yml:1`), and it triggers on `pull_request` into `"epic/**"` (`ci.yml:6-7`).

### 1.5 PA-N9 rule text (`.claude/skills/feature-review-workflow/SKILL.md:68-75`)

- `:70` trigger paths: `.github/workflows/**`, `scripts/benchmarks/**`, `.github/actions/**`.
- `:73` SHA-exact definition: "a workflow run whose head SHA matches the current branch head and whose conclusion is success for the affected workflow."
- `:74` `workflow_dispatch` runs qualify.
- `:75` `awaiting_ci` routing.
- Issue #764 fix has landed: `Test-ModifiedWorkflowNeedsGreenRun` has no match outside `docs/` (Grep), and the rule no longer cites a validator script. The rule text is therefore safe to copy once PA-N9 is applied.

### 1.6 #658 orchestrator ruling (`docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/policy-audit.2026-10-08T03-15.md`; folder present on this branch)

Ruling text (`:374`): an in-repo evidence artifact cannot name the SHA of the commit that contains it; the authority for green on the final PR head is S9. AC-7 passes when:

1. the recorded run covers the latest head containing any non-feature-folder change;
2. every later commit touches only feature-folder paths;
3. the S9 gate obligation is stated.

Verification commands used (`:377-380`): `gh run view <run-id>` (workflow, event, head SHA, conclusion); `git log <last-non-feature-commit>..HEAD -- . ":!<feature-folder>"` returns no commits; `git merge-base --is-ancestor <commit> <run-head>`; `git diff --name-only <run-head> HEAD` lists only feature-folder paths. PA-N9 recommendation (`:395`): codify the three conditions in the rule text.

## 2. Candidate Approaches (CR-1)

### 2.1 Option A (selected): opt-in `-RequireWorkflow <name>` parameter

- Add `[string]$RequireWorkflow = ''` to the script, `Invoke-CiGateParser`, and `Get-CiGateConclusion`. Empty means the current behavior, byte-for-byte.
- S9 passes `-RequireWorkflow CI` only when `epic_mode` is true.
- Advantages: non-epic S9 and the epic final PR (which targets `main` and uses `--required`) keep the documented vacuous rule; all existing tests stay valid; the parser stays free of epic concepts (it checks a workflow name, not a branch pattern); matches the remedy recommended by #658 code review CR-1 (`code-review.2026-10-08T03-15.md:41`) and issue.md "Suspected Cause".
- Limitations: enforcement still depends on S9 passing the flag; that dependency is one literal token in the step 3 command and can be pinned by a text test.

### 2.2 Rejected alternatives

- Option B, change the default so an empty set returns `pending`/`failure`: breaks non-epic S9 for repositories or PRs where `--required` legitimately yields no required checks (the push-down ships this parser to consumer repositories that may have no branch protection), and inverts the deliberate design recorded at `:22-23`. Rejected.
- `-EpicChild` switch: encodes orchestration vocabulary in the parser and hard-codes `CI`; a string parameter is equally simple and more reusable. Rejected.
- Filtering to `CI` checks only inside the parser: see 3.2; rejected for fail-closed reasons.

## 3. Behavior Semantics

### 3.1 Derivation with `-RequireWorkflow` set (ordered rules)

1. Validate every element as today (missing `bucket` throws; unknown bucket throws).
2. Any `fail` or `cancel` on any observed check: `failure` (precedence unchanged).
3. Else any `pending`: `pending`.
4. Else, if no observed check has `workflow` equal (case-sensitive, `-ceq`) to the required name with bucket `pass`: `pending`.
5. Else: `success`.

Edge cases:

- Empty or null set: `pending` (rule 4). Default path (no `-RequireWorkflow`) still `success`.
- Only non-`CI` checks, all passing: `pending`.
- `CI` checks present but all `skipping`: `pending` (a skipped CI run is not an observed success; the epic-child rule requires CI checks to succeed).
- Element without a `workflow` property (for example a commit status context): treated as non-matching; it must not throw, because `gh` can return status contexts with an empty workflow. Use `$check.PSObject.Properties.Name -contains 'workflow'` under `Set-StrictMode`.
- `-RequireWorkflow` given as whitespace: reject with `ValidateNotNull` plus an explicit check, or treat only `''` as off; recommend `[ValidateNotNull()]` and treating `[string]::IsNullOrWhiteSpace` as off, documented in help.

Why `pending` rather than `failure` when CI is absent: right after PR creation, checks may not be registered yet, and `gh` reports "no checks reported" during that window (1.3). `pending` keeps S9 in its bounded poll (`orchestrate/SKILL.md:294`); a timeout records an `awaiting_ci` finding instead of a vacuous success. `failure` would route a check-less PR into the R1-R5 loop with a synthetic finding that has no failing check name or job URL (`orchestrate/SKILL.md:344-345`). `.claude/skills/quota-throttling/SKILL.md:177-181` records the same principle: require a positive assertion that an empty set cannot satisfy.

### 3.2 CR-4 rule for non-`CI` checks on an epic child (recommended: must pass)

All checks returned by the unfiltered query participate in rules 2-3 (a failing or cancelled non-`CI` check yields `failure`; a pending one yields `pending`), and at least one passing `CI` check is additionally required. Rationale: it is the fail-closed reading of the gate #658 strengthened; it needs no filtering in the parser (the full set is evaluated as today, with one presence condition added); and on this repository the only other workflows that can run on an epic-child PR are path-filtered workflow PR runs (`publish-extension.yml:12`, `publish-mcp-npm.yml:12`, `verify-published-releases.yml:16`), whose failure indicates a defect in the change. `npm-audit-gate.yml:8-9` does not trigger on `epic/**`. The rejected alternative (ignore non-`CI` checks) would require a filter step and would let a failing workflow on the child head pass S9.

### 3.3 PA-N9 satisfiable condition (proposed replacement for `feature-review-workflow/SKILL.md:73`)

"Green workflow run against the branch head" means a run of the affected workflow whose conclusion is success and which satisfies either:

- (a) its head SHA equals the current branch head; or
- (b) all three conditions of the predecessor-head rule hold: (1) the run's head SHA is an ancestor of, or equal to, the current branch head and contains the latest commit that changes any path outside the active feature folder (`git merge-base --is-ancestor <commit> <run-sha>`); (2) every commit after the run's head SHA changes only paths inside the active feature folder (`git log <run-sha>..HEAD -- . ":!<feature-folder>"` returns no commits); (3) the policy audit states that the orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.

Add one sentence of rationale: an in-repo evidence artifact cannot name the SHA of the commit that contains it. Keep `:74` (`workflow_dispatch` qualifies) and `:75` (`awaiting_ci` routing) unchanged. The phrase "green workflow run against the branch head" used in `.claude/rules/ci-workflows.md:37`, `.claude/rules/benchmark-baselines.md:37`, `.claude/agents/orchestrator.md:135`, and the two `.agents` citers stays valid as a defined term, so those files need no change.

## 4. Requirements Mapping and Proposed Changes

### 4.1 Parser (CR-1)

- `Invoke-CiGateParser.ps1`: add `-RequireWorkflow` at script level (`:69-89`), forward it in the `process` block (`:321-327`), add it to `Invoke-CiGateParser` (`:254-274`, forward at `:291`) and to `Get-CiGateConclusion` (`:124-128`), implement rule 4 after the loop (`:168-174`), and update help (`:7-26`, `:59-61` example, `:107-114`, add `.PARAMETER RequireWorkflow`). Expected size about 365-375 lines (limit 500).
- Output object shape is unchanged; no checkpoint schema, validator (`CI_GATE_KEYS`), or hook change is required.

### 4.2 Orchestrate skill (CR-1 wiring and CR-4)

- `:291` epic-child paragraph: add that S9 passes `-RequireWorkflow CI` in step 3; that a `gh` "no checks reported" error is treated as an empty list and passed as `'[]'`; and that failing or pending non-`CI` checks are evaluated like any other check (3.2).
- `:293` step 3: describe the conclusion over "the queried checks" (required checks on a non-epic PR; all checks on an epic child), keep the command on one line starting with `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1` so `extract_script_references` (`scripts/dev_tools/skill_bundle_contract.py:54`) still finds the path, and state the `-RequireWorkflow CI` variant.
- `:307`: "the PR head SHA that the queried checks were observed against".
- `:342` (optional, same wording family): "a failed check".
- Do not edit `:298` or the PR Creation Gate text; `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:207-238` pins fragments there.
- Do not edit `.claude/skills/epic-orchestrate/SKILL.md`: its final PR targets `main` with `--required`, so the default path applies, and the file is SHA-256 pinned (`parallel_orchestrator_surface_expectations.py:154-163`); an edit requires re-baselining that pin.

### 4.3 Feature-review-workflow skill (PA-N9 and #795)

- `.claude/skills/feature-review-workflow/SKILL.md:73`: replace with 3.3 text.
- `.agents/skills/feature-review-workflow/SKILL.md`: add a `## Policy Rules` section with `### modified-workflow-needs-green-run` between `### Work-mode acceptance-criteria contract` (ends `:64`) and `## Ordered Procedure` (`:66`), carrying the same trigger, definition (3.3), `workflow_dispatch`, and `awaiting_ci` bullets. Refer to the Codex gate as "the orchestrator CI Green Gate (S9)" to match `.agents/skills/orchestrate/SKILL.md:453-460`.
- Bundle mirrors of both receive identical bytes.

### 4.4 #795 analysis

- Difference: the `.agents` copy has no `## Policy Rules` section; the `.claude` copy defines the rule at `:66-75`. Other unrelated divergences exist (C# coverage command `:99` vs `.claude:110`; 80/90 thresholds `:100-103` vs `.claude:111-114`; final report fields `:149-156`), so the `.agents` copy is a hand-maintained Codex variant, not a generated copy.
- Generator check: `scripts/dev_tools/codex_native_converter/` maps source skills to `.agents/skills/<name>/SKILL.md` (`mapping.py:143`), but the `.agents` copy contains `awaiting_ci` wording absent from `.github/skills/feature-review-workflow/SKILL.md` (`:120-130`), so it is not the current converter output. No re-run of the converter is needed or appropriate.
- Parity coverage: `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-229` requires `.agents/**` to equal the Codex bundle; no test compares `.agents` with `.claude` content for this skill. `test_push_down_codex_and_agents_pack_manifest_completeness.py:105` lists the skill as a pre-existing manifest exception only.
- Existing enforcement of "cited rule is defined in referenced skill": none found. The closest is `test_push_down_tier_rule_adoption_gate.py:353-366` (cited path exists), which is path-level, not rule-level.
- Recommendation: in scope, add a narrow regression test that, for each of the four citing copies (`.agents/skills/{ci-workflows,benchmark-baselines}/SKILL.md` and their Codex bundle mirrors), the referenced skill file contains the heading `### modified-workflow-needs-green-run`. Defer a general "every cited rule name resolves" scanner to a follow-up: rule citations are free-form prose (backticked kebab names followed by `(see <path>)`), and a general parser would need a citation grammar and an exception list, which exceeds a Low item.

### 4.5 Out-of-scope observations (record only)

- `.agents/skills/orchestrate/SKILL.md:453-460` (CI Green Gate) has no epic-child rule and does not reference the parser; Codex parity for CR-1 is a separate follow-up candidate.
- `.claude/agents/orchestrator.md:133` says "required CI checks"; leaving it is consistent because the agent text summarizes, and #798 may touch orchestration surfaces.
- `.github/workflows/*.yml` comments and `.github/workflows/README.md:45` use "branch-head run" wording. Editing any `.github/workflows/**` path would itself trigger `modified-workflow-needs-green-run`; do not edit them in this item.

## 5. Copies and Parity Obligations

| Surface | Path | Current state | Parity mechanism |
|---|---|---|---|
| Claude orchestrate | `.claude/skills/orchestrate/SKILL.md` | source | `test_push_down_claude_resource_contracts.py:89-110` (text equality for every `.claude/**` file), `:126-141` (byte equality + `core.json`) |
| Claude orchestrate bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` | same text at `:289-307` (Grep) | as above |
| Codex orchestrate | `.agents/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md` | different variant; no S9 parser text | `test_push_down_codex_and_agents_resource_contracts.py:215-229`; `test_completion_gate_documentation_contracts.py:139-204` pins its CI Green Gate fragments. Not edited. |
| Claude feature-review-workflow | `.claude/skills/feature-review-workflow/SKILL.md` + Claude bundle mirror | rule defined at `:68-75` in both | Claude text equality test; `test_push_down_tier_rule_adoption_gate.py:369-382` (fragments `root \`CLAUDE.md\``, `record tier classification as not applicable`, `tier-classification check` must stay); `test_orchestrator_state_remediation_docs.py:296-305` (MCP contract-lag wording must stay) |
| Codex feature-review-workflow | `.agents/skills/feature-review-workflow/SKILL.md` + Codex bundle mirror | no rule | Codex equality test |
| Copilot feature-review-workflow | `.github/skills/feature-review-workflow/SKILL.md` + `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md` | no rule, no citer | Not in scope for #841 or #795 |
| Parser | `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` + Claude bundle mirror | identical (Grep of `:23`, `:130-132` in mirror) | Claude text equality test; `CiGate.Manifest.Tests.ps1` |

Bundle parity is verified by tests rather than by a diff in this research (no shell was used); a change must write each source and its mirror with identical bytes.

## 6. Testing Implications

### 6.1 Pester (parser)

- Location: `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` (mirrors the source tree under `tests/scripts/claude-lib/`). Scan roots `config/poshqc-scan.json:4` include `tests/scripts`; coverage roots `config/poshqc-coverage.json:5` include `.claude/lib`.
- Keep the existing vacuous-success test (`:91-98`) as the default-path regression guard; rename its description to state "without -RequireWorkflow".
- Add, under a new `Context "-RequireWorkflow (epic-child guard)"`:
  - empty array returns `pending` (expect-fail before the fix: parameter does not exist);
  - null via `Get-CiGateConclusion -Checks $null -RequireWorkflow 'CI'` returns `pending`;
  - only non-`CI` checks passing returns `pending`;
  - `CI` pass plus non-`CI` pass returns `success`;
  - `CI` pass plus non-`CI` fail returns `failure`;
  - `CI` fail returns `failure`; `CI` pending returns `pending`;
  - `CI` only `skipping` returns `pending`;
  - element without `workflow` property is non-matching and does not throw;
  - case sensitivity: `workflow = 'ci'` does not satisfy `CI`;
  - script-level forwarding: invoke the script file with `& $script:scriptPath -ChecksJson '[]' -HeadSha x -RequireWorkflow CI -NowProvider $fixedClock` and assert `pending` (covers the `process` block forwarding; no temp files, no `gh`).
- Expected size about 300-320 lines (limit 500).
- Invocation: the MCP `mcp__drm-copilot__run_poshqc_test` returns summaries without output, so record evidence from a direct `Invoke-Pester` run (PowerShell tool) with code coverage on `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`. Line threshold 85% applies; no branch threshold for PowerShell. Run `Invoke-Formatter`/PSScriptAnalyzer through the PoshQC MCP tools or directly.

### 6.2 Python text-contract tests

- New file (proposed) `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`, reading files only, whitespace-normalized like `test_push_down_tier_rule_adoption_gate.py:146-163`:
  - both orchestrate copies (`.claude` + Claude bundle) contain `-RequireWorkflow CI` in the S9 section and do not contain "derives `ci_gate.conclusion` as `success` when all required checks pass" or "that the required checks were observed against";
  - the four feature-review-workflow copies (`.claude`, Claude bundle, `.agents`, Codex bundle) contain the predecessor-head fragments and no longer contain "whose head SHA matches the current branch head and whose conclusion is success" as the sole definition;
  - #795: each of the four `.agents` citing copies names `.agents/skills/feature-review-workflow/SKILL.md`, and that file contains `### modified-workflow-needs-green-run`; include one synthetic negative case proving the check fails when the heading is absent.
- Existing suites to re-run: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_skill_bundle_contract_repo.py`, `test_completion_gate_documentation_contracts.py`, `test_push_down_tier_rule_adoption_gate.py`, `test_orchestrator_state_remediation_docs.py`, `test_parallel_*` surface pin tests (to confirm `epic-orchestrate` is untouched), and the Pester `CiGate.Manifest.Tests.ps1`.
- Grep of `tests/`, `extensions/drm-copilot/test/`, and `scripts/` for "required checks", "Epic-child rule", "vacuous", "head SHA matches", "observed against", "is not accepted as green" found no assertion on the S9 step 2/3 or rule `:73` text other than the parser test at `Invoke-CiGateParser.Tests.ps1:91`.

## 7. Concurrency Overlap (note only)

- #798 edits `.claude/skills/orchestrate/SKILL.md` (and therefore its Claude bundle mirror). This item edits S9 lines 291, 293, 307 (and optionally 342).
- #824 edits `.claude/skills/feature-review-workflow/SKILL.md` (and its mirror). This item edits line 73 only in that file.
- Neither feature folder is present on this branch; their exact line ranges were not verified. Expect textual merge conflicts in the mirrors if both land; resolve by re-copying the source to the mirror after merge.

## Numeric Derivation Evidence

These counts support the proposed text-contract test parametrization; no numeric acceptance criterion depends on any other figure.

### Claim N1: copies of `feature-review-workflow/SKILL.md` in the repository = 6

- Complete Family: every `SKILL.md` whose skill name is `feature-review-workflow`.
- Exhaustive Search Scope: entire worktree.
- Inclusion Rules: files named `SKILL.md` for the skill.
- Exclusion Rules: README files that mention the name.
- Primary Search Strategy or Query Expression: Glob `**/feature-review-workflow/**`.
- Primary Member Set: `.agents/skills/feature-review-workflow/SKILL.md`; `.claude/skills/feature-review-workflow/SKILL.md`; `.github/skills/feature-review-workflow/SKILL.md`; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`; `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`.
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: Grep `^name: feature-review-workflow$` (files_with_matches), then exclude the two `README.md` hits.
- Cross-check Member Set: the same six paths (raw result 8 files including `.github/skills/README.md` and `extensions/drm-copilot/resources/customizations/.github/skills/README.md`, excluded by rule).
- Cross-check Count: 6.
- Member-set Comparison: identical normalized sets.

### Claim N2: files that currently define the rule = 2; after the fix = 4 (in-scope surfaces)

- Complete Family: files containing a definition of `modified-workflow-needs-green-run`.
- Exhaustive Search Scope: entire worktree excluding `docs/`.
- Inclusion Rules: a heading or definitional sentence for the rule.
- Exclusion Rules: citations in other skills, rules, agents, workflow comments.
- Primary Search Strategy or Query Expression: Grep `^### modified-workflow-needs-green-run`.
- Primary Member Set: `.claude/skills/feature-review-workflow/SKILL.md`; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`.
- Primary Count: 2.
- Cross-check Search Strategy or Query Expression: Grep `"Green workflow run against the branch head" means` with glob `!docs/**`.
- Cross-check Member Set: the same two paths.
- Cross-check Count: 2.
- Member-set Comparison: identical. After the fix the set adds `.agents/skills/feature-review-workflow/SKILL.md` and its Codex bundle mirror (4).

### Claim N3: `.agents`-side citing copies = 4

- Complete Family: files under `.agents/`, `.codex/`, or `extensions/` that cite the rule and point at `.agents/skills/feature-review-workflow/SKILL.md`.
- Exhaustive Search Scope: `.agents/**`, `.codex/**`, `extensions/**`.
- Inclusion Rules: citation lines naming the rule.
- Exclusion Rules: `.claude`-side citers (they point at the `.claude` definer, which exists).
- Primary Search Strategy or Query Expression: Grep `modified-workflow-needs-green-run` across the repo excluding `docs/features/**`, filtered to `.agents`/Codex-bundle paths.
- Primary Member Set: `.agents/skills/ci-workflows/SKILL.md:40`; `.agents/skills/benchmark-baselines/SKILL.md:39`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/ci-workflows/SKILL.md:40`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/benchmark-baselines/SKILL.md:39`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: Grep `\.agents/skills/feature-review-workflow/SKILL\.md` over `{.agents/**,extensions/**,.codex/**}`.
- Cross-check Member Set: the same four lines.
- Cross-check Count: 4.
- Member-set Comparison: identical.

## Automation Feasibility

Fully automatable with no human interaction. All changes are text edits to Markdown skills, one PowerShell script, one Pester file, and one new pytest file. Verification uses local Pester and pytest runs and the repository's CI on the PR. No `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` path is changed, so `modified-workflow-needs-green-run` does not fire for this item. Execution notes: run Pester through the PowerShell tool (agent-worktree text guards deny `pwsh`/`bash` in Bash tool text); write each mirror with the same content as its source.

## Recommendation Summary

- CR-1: add opt-in `-RequireWorkflow <name>` to `Invoke-CiGateParser.ps1`; when set, absence of a passing check from that workflow yields `pending` (never `success`); failure/pending precedence is unchanged; default path unchanged.
- CR-4: on an epic child, all observed checks are evaluated (non-`CI` failures fail the gate) and at least one passing `CI` check is required; S9 passes `-RequireWorkflow CI` when `epic_mode` is true; a `gh` "no checks reported" error is treated as `'[]'`; replace "required checks" wording at `orchestrate/SKILL.md:293` and `:307`.
- PA-N9: replace `feature-review-workflow/SKILL.md:73` with the either/or definition carrying the three #658 ruling conditions and their `git` verification commands.
- #795: add the rule (with the PA-N9 text) to the `.agents` copy and its Codex bundle mirror; add a narrow rule-resolution regression test; defer a general cited-rule scanner.

## Consolidated List of Files a Fix Would Write

1. `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1`
3. `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`
4. `.claude/skills/orchestrate/SKILL.md`
5. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
6. `.claude/skills/feature-review-workflow/SKILL.md`
7. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`
8. `.agents/skills/feature-review-workflow/SKILL.md`
9. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`
10. `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (new)
11. Feature-folder documents and evidence under `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/` (spec, plan, evidence).

Files explicitly not to write: `.claude/skills/epic-orchestrate/SKILL.md` (hash-pinned; default path applies), `.agents/skills/orchestrate/SKILL.md`, `.github/workflows/**`, `.claude/rules/*.md`, `.claude/agents/orchestrator.md`, `pack-manifests/core.json` (parser path already listed).
