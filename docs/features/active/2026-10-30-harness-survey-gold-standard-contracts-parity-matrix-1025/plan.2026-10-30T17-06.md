# 2026-10-30-harness-survey-gold-standard-contracts-parity-matrix - Plan

- **Issue:** #1025
- **Parent (optional):** epic #1018, child 1
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T17-06
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Requirements sources:** `spec.md` (`## Acceptance Criteria`, authoritative), `user-story.md`, `research/research.2026-10-30T21-08.md`, `docs/features/epics/shared-agent-harness-layer/epic.md` (`## Shared Design`, `## Execution Preconditions`)

## Required References

- Policy order: `policy-compliance-order` skill. PowerShell policies: `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`.
- Tool routes, launchers, the batch budget, PoshQC MCP limits, CI shape and contract tests: the `execution-environment` skill. This plan does not restate them; a task that says "branch-current Pester run" or "PSSA run" uses the route that skill names under `## PowerShell Route and PoshQC MCP Limits`.
- Evidence naming: `evidence-and-timestamp-conventions` skill. Every evidence file is `<name>.<timestamp>.md` stamped with the UTC write time; a consumer selects the lexicographically greatest `<name>.*.md`.

## Definitions

- `<FEATURE>` is `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`.
- `SCRATCH` is `<session scratchpad>/issue-1025/`. Every helper script, staged copy and intermediate report lives under `SCRATCH`, with file names starting `issue-1025-`. Evidence records the literal token `SCRATCH`, never a host path. Scratch helpers are throwaway PowerShell and are never committed.
- `MB` is the merge base of `origin/main` and `HEAD`, derived after fetching `origin/main` at the time the task runs. Every scope comparison uses `MB`.
- Shared set: the 55 names present in both `.claude/skills` and `.agents/skills`, partitioned into batches A to F as in research `### 1.4 Recommended execution of the full survey`. Single-ecosystem set: the 35 names in research `### N2` (11 Claude-only, 24 Codex-only).

## Edit Set (complete; all paths are new files)

- `config/harness-parity-matrix.json`, `config/harness-parity-matrix.schema.json`
- `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1`, `scripts/harness/HarnessSkillContract.psm1` (three production PowerShell files; no fourth)
- `tests/scripts/harness/HarnessInventory.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.Tests.ps1`, `tests/scripts/harness/HarnessSkillContract.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`
- `.agents/skills/<name>/references/standard.md` for every `codex:skill:<name>` entry with disposition `shared`, each paired with `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`
- `<FEATURE>/survey/**`, `<FEATURE>/runbooks/**`, `<FEATURE>/evidence/**`, and this plan
- `artifacts/orchestration/orchestrator-state.json` (gitignored checkpoint; the owner-stop record only)

Configuration confirmation (planning finding F1, no edit): `config/poshqc-scan.json` `test.scanFolders` contains `tests/scripts`, so `tests/scripts/harness/` is scanned and sharded; `config/poshqc-coverage.json` `roots` contains `scripts`, so `scripts/harness/*.psm1` is in the coverage population. Neither file is edited. P0-T4 re-confirms both at execution time.

## Excluded Paths (must never be edited)

- Any `SKILL.md` in `.claude/skills/**`, `.agents/skills/**`, `.github/skills/**` and their bundle copies under `extensions/drm-copilot/resources/**`.
- Every `pack-manifests/core.json` (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`) and every other pack manifest.
- `docs/features/templates/policy_audit/*`.
- `config/poshqc-coverage.json`, `config/poshqc-scan.json`, `config/file-size-baseline.json`.
- `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
- `extensions/drm-copilot/jest.config.cjs`.
- The execution-environment brief in all six copies (`.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md` and their three bundle copies).
- `scripts/dev_tools/generate_codex_agent_variants.py` and every `tests/scripts/dev_tools/test_push_down_*` file (run only).
- Any `.agents/skills/<name>/` folder that has no `SKILL.md` (planning finding F2 below).

## Language Choices

| Choice | Where | Cost | Risk and mitigation |
| --- | --- | --- | --- |
| PowerShell 7 modules + Pester 5 | `scripts/harness/*.psm1`, `tests/scripts/harness/*.Tests.ps1` (inventory, matrix validation, contract check, repository gate) | Three production PowerShell files equal the direct-mode batch budget of three per kind per session and worktree; a fourth file (for a size split) is denied in direct mode. The `preparation`, `large` and `remediation` routes exempt the executing worktree when its checkpoint selects them (execution-environment `## Batch Budget`). | A split beyond three files is planned only when the executing worktree's checkpoint selects an exempt route; otherwise the inventory module stays one file below the 800-line hard limit. Runs in the required `poshqc / PowerShell QC` check with no workflow or configuration edit. |
| JSON + JSON Schema Draft 2020-12 | `config/harness-parity-matrix.json`, `config/harness-parity-matrix.schema.json` | No parser dependency: `ConvertFrom-Json` reads both. | `Test-Json -SchemaFile` supports Draft 2020-12 only on PowerShell 7.4 or later, and the `windows-latest` runner version is unconfirmed. The module's structural validation is the gate; the schema-module agreement test keeps the two from drifting; the `Test-Json` assertion is skipped below 7.4 and no gate depends on it. |
| Throwaway PowerShell under `SCRATCH` | identity pass, survey comparison, matrix bootstrap, bundle copy, Diff-ID reconciliation, shuffled-order runs | None committed; launched with `sh` per the brief. | Never committed: P12-T10 asserts no added file outside the edit set. |
| Existing Python, run only | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_issue_824_follow_ups.py`, `test_codex_full_migration_inventory.py`, the Codex generator `--check` | No new `.py` file (owner directive). | P12-T9 asserts zero added `.py` files against `MB`. |

## Owner Stop Design

Phases 0 to 8 run before owner input and end with a complete, gate-passing pre-stop state: survey, records, classification, approval artifact (`pending`), E5 result, runbooks E1-E4 and E6, schema, modules, tests, a matrix whose entries are `provisional` where a decision or experiment is pending, and contracts plus bundle copies for the 55 default-`shared` names (needed because the repository gate requires a contract for every `codex:skill` entry with disposition `shared`). Phase 9 is the single stop. Phases 10 to 12 run on resume from the recorded owner decisions and runbook results, without re-planning.

### Phase 0 — Policy Reads, Execution Gate and Baselines

- [ ] [P0-T1] Read, in order, `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`, then the skills `execution-environment`, `human-exception-runbook` and the rule `.claude/rules/orchestrator-state.md`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:` and one line per file read, in the order above.
- [ ] [P0-T2] Confirm that the parallel run `bugs-1001-1002-1003-1006` has merged: for each of issues #1001, #1002, #1003, #1006, #1009, #1010, #1011, #1012 and #1013, read the issue state and its closing pull request's merge state with read-only `gh` queries (the orchestrator runs them when the executor's tool set denies `gh`), and confirm each merge commit is an ancestor of `HEAD` with `git merge-base --is-ancestor`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-parallel-run.<timestamp>.md` has one row per issue with `state`, `merged` and `ancestor-of-HEAD`, and the line `ParallelRun: MERGED` only when all nine rows read `CLOSED`, `true`, `true`. Any other row value writes `ParallelRun: NOT-MERGED`.
- [ ] [P0-T3] Re-derive every citation in `## Citations Re-Checked at Phase 0` against `HEAD` after confirming `HEAD` contains `origin/main` (`git merge-base --is-ancestor origin/main HEAD` exits 0; when it exits 1 the orchestrator syncs the branch first). For each path confirm it is tracked (`git ls-files --error-unmatch`); for each symbol, heading or test name confirm one or more fixed-string matches with `git grep -n -F` in that tracked path. Re-enumerate `.claude/skills`, `.agents/skills` and `.github/skills` and compare the folder-name sets with the research `### N2` member sets.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-citations.<timestamp>.md` lists every citation with `PRESENT` or `MOVED`, and the skill-set comparison with `Added:` and `Removed:` lists; it ends `Citations: PASS` only when every row is `PRESENT` and both lists are empty.
- [ ] [P0-T4] Confirm the edit set is still new and its configuration preconditions hold: `git ls-tree -r --name-only origin/main -- config/harness-parity-matrix.json config/harness-parity-matrix.schema.json scripts/harness tests/scripts/harness` prints nothing; no `.agents/skills/*/references/` path is tracked on `origin/main`; `config/poshqc-scan.json` `test.scanFolders` contains `tests/scripts`; `config/poshqc-coverage.json` `roots` contains `scripts`; `git ls-files .claude/settings.local.json` prints the path and `git ls-files .vscode/settings.json` prints nothing.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-edit-set.<timestamp>.md` records each check with its observed output and ends `EditSet: PASS` only when every check matches.
- [ ] [P0-T5] Write the gate summary and stop on failure. The gate passes when the latest `phase0-parallel-run.*.md` reads `ParallelRun: MERGED`, the latest `phase0-citations.*.md` reads `Citations: PASS` and the latest `phase0-edit-set.*.md` reads `EditSet: PASS`. On any other value the executor checks no later task, returns `BLOCKED at [P0-T5]: re-planning required`, and names each failing row.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md` contains `Gate: PASS`, the `MB` derivation command, and the three consumed artifact names.
- [ ] [P0-T6] Capture the PowerShell test baseline: a branch-current single-process Pester run over the `config/poshqc-scan.json` scan folders with coverage, reading pass and fail counts from `artifacts/pester/pester-junit.xml` and total line coverage from `artifacts/pester/powershell-coverage.xml`.
  - Acceptance: `<FEATURE>/evidence/baseline/pester-baseline.<timestamp>.md` has `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric passed, failed and total line-coverage values, and `scripts/harness: absent (0 files)`.
- [ ] [P0-T7] Capture the analyzer baseline: a direct PSSA run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `scripts` and `tests/scripts`.
  - Acceptance: `<FEATURE>/evidence/baseline/pssa-baseline.<timestamp>.md` has the four command-step fields and a numeric finding count in `Output Summary:`.
- [ ] [P0-T8] Capture the Python contract-test baseline: run `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`, `tests/scripts/dev_tools/test_codex_full_migration_inventory.py`, and the Codex generator `scripts/dev_tools/generate_codex_agent_variants.py` with `--check`.
  - Acceptance: `<FEATURE>/evidence/baseline/python-contract-baseline.<timestamp>.md` has the four command-step fields per command and numeric passed and failed counts.
- [ ] [P0-T9] Capture the file-size baseline: run `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` and record the result of the It block `reports zero ratchet violations against config/file-size-baseline.json`; record the host `$PSVersionTable.PSVersion` and whether `Test-Json` accepts `-SchemaFile`.
  - Acceptance: `<FEATURE>/evidence/baseline/file-size-and-host.<timestamp>.md` has the four command-step fields, the It result, and the host PowerShell version.

### Phase 1 — Skill Identity Pass and Survey Index

- [ ] [P1-T1] Write `SCRATCH/issue-1025-skill-identity.ps1` and run it: it enumerates folders containing `SKILL.md` directly under the three skill trees, and for every name present in more than one tree records `git hash-object` of each copy, a normalized comparison (whitespace collapsed, heading markers ignored), and the class `byte-identical` (all hashes equal), `wording-only` (normalized text equal) or `substantive` (otherwise).
  - Acceptance: `<FEATURE>/evidence/baseline/skill-identity.<timestamp>.md` has `Command:` naming `SCRATCH/issue-1025-skill-identity.ps1`, `EXIT_CODE: 0`, one row per name in more than one tree with each copy's hash and a class, and a `Rows:` count equal to the multi-tree name count the script printed.
- [ ] [P1-T2] Create `<FEATURE>/survey/skill-survey.md` with one table row per name in the union of the three trees, columns `Skill`, `Claude`, `Codex`, `Copilot`, `Identity`, `Proposed disposition`, `Batch`, `Record` as in spec `### Survey Records`; identity values come from the latest `skill-identity.*.md`, single-tree names carry `single-ecosystem` and batch `single`, and every `Record` link targets a batch file under `<FEATURE>/survey/`.
  - Acceptance: the table row count equals the union count; every `Identity` value is one of the four enum values; every `Batch` value is `A` to `F` or `single`.
- [ ] [P1-T3] Write `SCRATCH/issue-1025-survey-compare.ps1` and run it: it parses the `Skill` column of `<FEATURE>/survey/skill-survey.md` and compares it with a fresh enumeration of the three trees.
  - Acceptance: `<FEATURE>/evidence/baseline/survey-completeness.<timestamp>.md` has the four command-step fields, `EXIT_CODE: 0`, and the lines `Missing: 0`, `Extra: 0` and `Duplicated: 0`.

### Phase 2 — Content Pass: Batch Records

Each batch task reads every copy of each member name, searches each section missing from one copy across that ecosystem's agent bodies, rules and sibling skills before recording it as missing, and writes one `### <skill-name>` record per member in the spec `### Survey Records` shape. `byte-identical` records have no difference table. Every difference row has a Diff ID `D-<skill-name>-<nn>` (two digits, one-based, gap-free), a class from `positive`, `negative`, `neutral`, `mechanism-only`, a port direction `none` or `<from>-><to>`, and a rationale against the draft objective. Text follows `.claude/rules/tonality.md` and contains no `TaskMaster.sln`.

- [ ] [P2-T1] Create `<FEATURE>/survey/batch-a-discovery.md` with the 16 batch A records.
  - Acceptance: one `### ` record per batch A name and no other; every record has `Presence:`, `Identity:`, `Proposed disposition:` and `Objective (draft):` lines.
- [ ] [P2-T2] Create `<FEATURE>/survey/batch-b-foundation-and-policy.md` with the 8 batch B records.
  - Acceptance: as P2-T1, for batch B names.
- [ ] [P2-T3] Create `<FEATURE>/survey/batch-c-integration.md` with the 5 batch C records, including the `feature-promotion-lifecycle` MCP-only versus fallback conflict as a difference row.
  - Acceptance: as P2-T1, for batch C names; the `feature-promotion-lifecycle` record has one or more rows referencing `## MCP-First Execution Rule`.
- [ ] [P2-T4] Create `<FEATURE>/survey/batch-d-language-routing-and-gates.md` with the 11 batch D records.
  - Acceptance: as P2-T1, for batch D names.
- [ ] [P2-T5] Create `<FEATURE>/survey/batch-e-orchestration.md` with the 6 batch E records.
  - Acceptance: as P2-T1, for batch E names.
- [ ] [P2-T6] Create `<FEATURE>/survey/batch-f-authoring-and-review-wrappers.md` with the 9 batch F records.
  - Acceptance: as P2-T1, for batch F names.
- [ ] [P2-T7] Create `<FEATURE>/survey/single-ecosystem.md` with one record per single-ecosystem name: `Presence:`, `Identity: single-ecosystem`, `Proposed disposition:` (`shared` or `native`) and a one-line rationale; no difference table.
  - Acceptance: one `### ` record per single-ecosystem name and no other; the `Proposed disposition` of each record equals its row in `<FEATURE>/survey/skill-survey.md`.

### Phase 3 — Experiments: E5 Result and Owner Runbooks

Each runbook carries, in order, the sections `## Cue`, `## Prerequisites`, `## Step-by-step Instructions`, `## Verification` and `## Source and Citation` (`.claude/skills/human-exception-runbook/SKILL.md` `## Required Sections`); uses a scratch repository and never this repository; and its Verification section gives a result template with `Timestamp:`, `Command:`, `EXIT_CODE:` (0 when observed as described, 1 otherwise), `Output Summary:` and `Tool versions:`, naming the result path from spec `## Experiments`. Sources are the URLs in research section 6 with capture date 2026-10-30.

- [ ] [P3-T1] Create `<FEATURE>/evidence/other/e5-claude-hooks-subagent-permissions-documentation.<timestamp>.md` from research `### E5. Claude Code hooks, subagent and permissions details`: subagent frontmatter fields, hook configuration levels and handler types, permission evaluation order, each with its source URL and fetch date 2026-10-30.
  - Acceptance: the file has `Timestamp:`, the three finding groups, and three source URLs under `code.claude.com`.
- [ ] [P3-T2] Create `<FEATURE>/runbooks/e1-copilot-duplicate-skill-listing.runbook.md` (probe skill in three locations; VS Code Skills page and `/` menu; Copilot CLI `/skills`).
  - Acceptance: the five headings appear once each in the required order and the Verification template names `e1-copilot-duplicate-skill-listing-result`.
- [ ] [P3-T3] Create `<FEATURE>/runbooks/e2-codex-claude-frontmatter.runbook.md` (probe skill with the six Claude-only fields; Codex listing and invocation; optional VS Code `context: fork` check).
  - Acceptance: as P3-T2, with `e2-codex-claude-frontmatter-result`.
- [ ] [P3-T4] Create `<FEATURE>/runbooks/e3-copilot-cli-cloud-claude-agents.runbook.md` (scratch repository with only a Claude-format agent; CLI `/agent` list; cloud-agent picker).
  - Acceptance: as P3-T2, with `e3-copilot-cli-cloud-claude-agents-result`.
- [ ] [P3-T5] Create `<FEATURE>/runbooks/e4-copilot-workspace-settings.runbook.md` (workspace `.vscode/settings.json` in the scratch repository with the location and file-use settings; Skills page, agent picker and References observations).
  - Acceptance: as P3-T2, with `e4-copilot-workspace-settings-result`.
- [ ] [P3-T6] Create `<FEATURE>/runbooks/e6-copilot-default-double-load.runbook.md` (same scratch repository as E4 with no settings file; References list and CLI `/instructions`).
  - Acceptance: as P3-T2, with `e6-copilot-default-double-load-result`.

### Phase 4 — Schema, PowerShell Modules and Unit Tests

Modules follow `.claude/rules/powershell.md`: `[CmdletBinding()]`, comment-based help, approved verbs, explicit `Export-ModuleMember`. File listing and reading are injected script-block parameters defaulting to the real file system. Tests use in-memory content only, create no files, and remove imported modules in `AfterAll`.

- [ ] [P4-T1] Create `config/harness-parity-matrix.schema.json` per spec `### Parity Matrix: Location and Format`, `### Parity Matrix: Top-Level Object` and `### Parity Matrix: Feature Entry`: dialect Draft 2020-12, `$id` `https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json`, `additionalProperties: false` at both levels, every field, enum, pattern and the four `if`/`then` rules under `allOf`; UTF-8 without BOM, LF, two-space indent.
  - Acceptance: `ConvertFrom-Json` parses the file; the agreement It in P8-T1 verifies content.
- [ ] [P4-T2] Create `scripts/harness/HarnessInventory.psm1` exporting `Get-HarnessInventory` (parameters `-RepositoryRoot`, `-ListFiles`, `-ReadFile`) and `Test-HarnessInventoryPathExcluded`; it applies the 13 inventory rules in spec `### Parity Matrix: Feature Kinds and Inventory Rules` and the exclusion list, reads JSON with `ConvertFrom-Json` and frontmatter keys and TOML table headers with anchored regular expressions, and returns objects with `id`, `ecosystem`, `kind`, `name`, `source_path` and optional `source_pointer`, sorted by `id` (ordinal).
  - Acceptance: the module imports without error; stays at or below 800 logical lines (a size beyond 500 is recorded in P12-T11 as guidance only).
- [ ] [P4-T3] Create `tests/scripts/harness/HarnessInventory.Tests.ps1` with one It per kind (13) proving its rule on injected listings, one It per exclusion-list entry group proving exclusion, and one It proving ordinal `id` ordering.
  - Acceptance: a branch-current Pester run of this file reports 0 failed in `artifacts/pester/pester-junit.xml`.
- [ ] [P4-T4] Create `scripts/harness/HarnessParityMatrix.psm1` exporting `Get-HarnessParityMatrixRuleSet` (enums, required fields, conditional rules, `$id` as data), `Import-HarnessParityMatrix` (`-Path`, `-ReadFile`), `Get-HarnessParityMatrixViolation` (`-Matrix`, `-InventoryFeature`) returning violation objects that each name the offending `id` and rule, and `New-HarnessParityMatrixSkeleton` emitting draft entries for unmatched inventoried features. It enforces spec `## Data & State` invariants 1 to 7.
  - Acceptance: the module imports without error.
- [ ] [P4-T5] Create `tests/scripts/harness/HarnessParityMatrix.Tests.ps1` with one It per failure case in spec AC `Completeness unit tests: failure cases` (inventoried feature with no entry; entry without `disposition`; unknown `disposition`, `kind`, `ecosystem`, `consumers` item and `decision_status`, one It each; `dropped` without `reason`; `dropped` with empty `reason`; `dropped` without `decision_ref`; duplicate `id`; `id` inconsistent with `ecosystem`; `id` inconsistent with `kind`; unsorted `features`; orphan not `dropped`; `shared` without `target_paths`; `generated` without `target_paths`; `generated` without `generated_from`; `provisional` without `decision_ref`; malformed `decision_ref`; unknown property), one pass-case It whose in-memory matrix covers all four dispositions and yields no violation, and one It for `New-HarnessParityMatrixSkeleton`.
  - Acceptance: a branch-current Pester run of this file reports 0 failed; each failure-case It asserts the offending `id` appears in the violation.
- [ ] [P4-T6] Create `scripts/harness/HarnessSkillContract.psm1` exporting `Get-HarnessSkillContractRequiredSet` (`-Matrix`; entries with `kind` `skill`, `ecosystem` `codex`, `disposition` `shared`), `Get-HarnessSkillContractViolation` (`-Name`, `-Content`; rules 1 to 5 and 7 of spec `### Contract Format`) and `Get-HarnessSkillContractSetViolation` (`-Matrix`, `-RepositoryRoot`, `-ReadFile`, `-TestPath`; reports a missing contract by path).
  - Acceptance: the module imports without error.
- [ ] [P4-T7] Create `tests/scripts/harness/HarnessSkillContract.Tests.ps1` with one It each for: missing contract for a required skill; wrong H1; missing H2; extra H2; reordered H2; empty section; gap in `OB-<n>`; repeat in `AC-<n>`; check citing a non-existent behavior; behavior cited by no check; checkbox syntax; `TaskMaster.sln` present; conforming contract with no violation; required set derived from an in-memory matrix.
  - Acceptance: a branch-current Pester run of this file reports 0 failed.
- [ ] [P4-T8] Run the three unit suites together, branch-current, with coverage over `scripts/harness`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/harness-unit-coverage.<timestamp>.md` has the four command-step fields, 0 failed from the JUnit file, and per-file line coverage from `artifacts/pester/powershell-coverage.xml` of 85% or more for each of the three modules; a lower value is fixed by adding tests in the matching test file and re-running before this task is checked.

### Phase 5 — Matrix Bootstrap

- [ ] [P5-T1] Write `SCRATCH/issue-1025-matrix-bootstrap.ps1` and run it: it imports the three modules, calls `Get-HarnessInventory` and `New-HarnessParityMatrixSkeleton`, applies spec `### Default Dispositions`, and writes `config/harness-parity-matrix.json` (`$schema` and `schema_version` `1.0.0`; UTF-8 without BOM, LF, two-space indent; `features` sorted by `id`). Every entry is `decision_status` `provisional` with an issue-keyed `decision_ref`: `#1025:survey/difference-approval.md#bulk-approval-set` by default, the runbook path for entries depending on E1 to E4 or E6, and `#1025:survey/difference-approval.md#disposition-proposals` for `dropped` entries. Single-ecosystem skills are written `native` with the proposed disposition in `notes` (they become `shared` only after owner approval, P11-T2).
  - Acceptance: `<FEATURE>/evidence/other/matrix-bootstrap.<timestamp>.md` has the four command-step fields, the entry count per `kind`, and `EXIT_CODE: 0`.
- [ ] [P5-T2] Run `Get-HarnessParityMatrixViolation` on the committed-to-be matrix against the live inventory from a scratch script.
  - Acceptance: `<FEATURE>/evidence/other/matrix-violations-pre-contract.<timestamp>.md` records `Violations: 0` and the count of `codex:skill` entries with disposition `shared`, which equals the shared-set size.

### Phase 6 — Contracts and Bundle Copies for the Default-Shared Names

Each contract task writes `.agents/skills/<name>/references/standard.md` for every batch member, in the exact spec `### Contract Format` structure, using the draft objective and records from Phase 2, tool-neutral, in the tonality policy, without `TaskMaster.sln`; it then runs `Get-HarnessSkillContractViolation` over the batch from a scratch script and records zero violations in `<FEATURE>/evidence/other/contracts-<letter>.<timestamp>.md`. Each bundle-copy task runs `SCRATCH/issue-1025-copy-contracts.ps1` for the batch (byte copy to the `extensions/drm-copilot/resources/codex-and-agents-customizations/` mirror), then runs `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`, `tests/scripts/dev_tools/test_codex_full_migration_inventory.py::test_all_repo_agent_skills_are_bundled_and_identical` and `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_pushed_roots_carry_no_hard_coded_solution_file`, and records the four command-step fields with 3 passed and 0 failed in `<FEATURE>/evidence/qa-gates/bundle-parity-<letter>.<timestamp>.md`.

- [ ] [P6-T1] Create the 16 batch A contracts.
  - Acceptance: latest `contracts-a.*.md` records 16 files and `Violations: 0`.
- [ ] [P6-T2] Create the batch A bundle copies and run the three contract tests.
  - Acceptance: latest `bundle-parity-a.*.md` records 3 passed, 0 failed.
- [ ] [P6-T3] Create the 8 batch B contracts.
  - Acceptance: latest `contracts-b.*.md` records 8 files and `Violations: 0`.
- [ ] [P6-T4] Create the batch B bundle copies and run the three contract tests.
  - Acceptance: latest `bundle-parity-b.*.md` records 3 passed, 0 failed.
- [ ] [P6-T5] Create the 5 batch C contracts.
  - Acceptance: latest `contracts-c.*.md` records 5 files and `Violations: 0`.
- [ ] [P6-T6] Create the batch C bundle copies and run the three contract tests.
  - Acceptance: latest `bundle-parity-c.*.md` records 3 passed, 0 failed.
- [ ] [P6-T7] Create the 11 batch D contracts.
  - Acceptance: latest `contracts-d.*.md` records 11 files and `Violations: 0`.
- [ ] [P6-T8] Create the batch D bundle copies and run the three contract tests.
  - Acceptance: latest `bundle-parity-d.*.md` records 3 passed, 0 failed.
- [ ] [P6-T9] Create the 6 batch E contracts.
  - Acceptance: latest `contracts-e.*.md` records 6 files and `Violations: 0`.
- [ ] [P6-T10] Create the batch E bundle copies and run the three contract tests.
  - Acceptance: latest `bundle-parity-e.*.md` records 3 passed, 0 failed.
- [ ] [P6-T11] Create the 9 batch F contracts.
  - Acceptance: latest `contracts-f.*.md` records 9 files and `Violations: 0`.
- [ ] [P6-T12] Create the batch F bundle copies and run the three contract tests.
  - Acceptance: latest `bundle-parity-f.*.md` records 3 passed, 0 failed.

### Phase 7 — Owner Approval Artifact

- [ ] [P7-T1] Create `<FEATURE>/survey/difference-approval.md` in the spec `### Owner Approval Artifact` shape with `Approval-Status: pending`, empty `Approved-By` and `Approved-At`; `## Bulk Approval Set` with every non-disputed Diff ID; `## Disposition Proposals` with every single-ecosystem skill and every matrix entry written `dropped` (listed from `config/harness-parity-matrix.json`); `## Owner Questions` with Q1 to Q8 and their defaults, adding to Q3 the F2 constraint; empty `## Owner Overrides`; and `## Disputed Cases` with one `### D-<skill>-<nn>` block (Context, Option A, Option B, Recommendation, empty `Owner-Decision:`) per case meeting a disputed-case rule.
  - Acceptance: the six headings and three metadata fields appear once each.
- [ ] [P7-T2] Write `SCRATCH/issue-1025-diff-reconcile.ps1` and run it: it collects every Diff ID from the six batch files and every Diff ID in the approval artifact's bulk table and disputed headings.
  - Acceptance: `<FEATURE>/evidence/other/diff-id-reconciliation.<timestamp>.md` has the four command-step fields and `Missing: 0`, `Duplicated: 0`, `Unknown: 0`, `InvalidClass: 0`.

### Phase 8 — Repository Gate and Pre-Stop QA Loop

- [ ] [P8-T1] Create `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` reading the real tree and `config/harness-parity-matrix.json`, with the It blocks `schema declares Draft 2020-12 and the 1.0.0 id`, `schema enums required fields and conditional rules agree with the module rule set`, `committed matrix has no violation against the live inventory`, `every hook-registration permission and subagent-frontmatter-field entry has a parity_group`, `every shared codex skill has a conforming contract`, and `committed matrix passes Test-Json on PowerShell 7.4 or later`, the last marked skipped when `$PSVersionTable.PSVersion` is below 7.4. Failure messages list each offending `id` or contract path.
  - Acceptance: a branch-current Pester run of this file reports 0 failed and 5 or 6 passed (6 on 7.4 or later, otherwise 5 with 1 skipped).
- [ ] [P8-T2] Run the pre-stop PowerShell loop over `scripts/harness` and `tests/scripts/harness`: format (each file prints `Already formatted:`, none prints `Formatted:`; on a rewrite restart the loop), PSSA with the repository settings (0 findings), then all four harness suites with coverage.
  - Acceptance: `<FEATURE>/evidence/qa-gates/pre-stop-loop.<timestamp>.md` records each step with the four command-step fields, 0 failed, and per-file line coverage of 85% or more for the three modules.
- [ ] [P8-T3] Confirm the pre-stop state is complete for the stop: the latest artifacts of P1-T3, P2-T7, P3-T1, P5-T2, P6-T12, P7-T2, P8-T2 exist with passing values, and the five runbooks exist.
  - Acceptance: `<FEATURE>/evidence/other/pre-stop-readiness.<timestamp>.md` lists each artifact name and ends `PreStop: READY`.

### Phase 9 — Single Owner Stop

- [ ] [P9-T1] Record the owner stop and halt. After the orchestrator commits the pre-stop work, record in `artifacts/orchestration/orchestrator-state.json` `blocked_reason: "human_decision_required"` and `human_interaction.requirements[]` with six entries: `response: "halt"` for `<FEATURE>/survey/difference-approval.md` (bulk approval, disputed cases, Q1 to Q8), and `response: "exception"` with `runbook_path` set to each of the E1, E2, E3, E4 and E6 runbook paths; validate the checkpoint with the `validate_orchestration_artifacts` MCP tool (`orchestrator-state`); copy the recorded block into `<FEATURE>/evidence/other/owner-stop.<timestamp>.md` with the resume condition from spec `## Owner Stop`; then stop with `BLOCKED: human_decision_required`.
  - Acceptance: the validator returns no error; `owner-stop.*.md` lists six requirements with five non-empty `runbook_path` values; no later task is checked in this run.

### Phase 10 — Resume Check

- [ ] [P10-T1] Verify the resume condition: `<FEATURE>/survey/difference-approval.md` has `Approval-Status` `approved` or `approved-with-overrides`, non-empty `Approved-By` and `Approved-At`, a non-empty `Owner-Decision` in every disputed case; and each of E1, E2, E3, E4 and E6 has either a latest `<FEATURE>/evidence/other/<id>-…-result.*.md` with the template fields or a deferral row in `## Owner Overrides`.
  - Acceptance: `<FEATURE>/evidence/other/resume-check.<timestamp>.md` ends `Resume: READY`; otherwise it lists each unmet item and the run stays blocked under the same stop without a new stop record.
- [ ] [P10-T2] Before the orchestrator syncs `origin/main` into the branch, list the upstream changes since `MB` with `git diff --name-only HEAD...origin/main` and the local uncommitted state with `git status --porcelain`, and confirm the upstream list names no edit-set path and no path this branch changed.
  - Acceptance: `<FEATURE>/evidence/other/resume-drift.<timestamp>.md` records both outputs and `EditSetDrift: 0`; a non-zero value stops for re-planning. Upstream changes to inventory sources (new skills, agents, hooks) are absorbed by P11-T2, whose violation check runs against the live inventory after the sync.

### Phase 11 — Apply Owner Decisions

- [ ] [P11-T1] Apply every owner override and disputed-case decision to the batch records and `<FEATURE>/survey/single-ecosystem.md` (class, port direction, proposed disposition), leaving Diff IDs unchanged.
  - Acceptance: `<FEATURE>/evidence/other/owner-decisions-applied.<timestamp>.md` lists each decision with the record it changed; a re-run of `SCRATCH/issue-1025-diff-reconcile.ps1` reports `Missing: 0`, `Duplicated: 0`, `InvalidClass: 0`.
- [ ] [P11-T2] Update `config/harness-parity-matrix.json`: set each single-ecosystem skill to its approved disposition (a Claude-only name approved `shared` becomes `claude:skill:<name>` `shared` with `target_paths` `.agents/skills/<name>/SKILL.md` and `owner_child` 3, per F2); apply overrides; set `consumers` and the `copilot:agent:*` dispositions from the recorded E1 to E4 and E6 results; set `decision_status` `approved` on every settled entry and remove its `decision_ref` unless `dropped`; leave entries tied to a deferred runbook `provisional` with `decision_ref` pointing to the runbook.
  - Acceptance: `Get-HarnessParityMatrixViolation` against the live inventory, run from a scratch script, records `Violations: 0` in `<FEATURE>/evidence/other/matrix-violations-post-decision.<timestamp>.md`, with counts of `approved` and `provisional` entries.
- [ ] [P11-T3] Create contracts for every Codex-only name the owner approved `shared`, and revise every existing contract whose objective or behaviors an override changes; delete the contract of any name the owner moved off `shared`. An empty set is recorded as `none`.
  - Acceptance: `<FEATURE>/evidence/other/contracts-post-decision.<timestamp>.md` lists created, revised and deleted paths and `Violations: 0` from `Get-HarnessSkillContractViolation` over the created and revised files.
- [ ] [P11-T4] Synchronize the bundle copies for every path listed in P11-T3 (copy, overwrite or delete) with `SCRATCH/issue-1025-copy-contracts.ps1`, then run the three contract tests named in Phase 6.
  - Acceptance: `<FEATURE>/evidence/qa-gates/bundle-parity-post-decision.<timestamp>.md` records 3 passed, 0 failed.
- [ ] [P11-T5] Run `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` branch-current.
  - Acceptance: `<FEATURE>/evidence/qa-gates/repo-gate-post-decision.<timestamp>.md` records 0 failed from the JUnit file.

### Phase 12 — Final QA Loop and Self-Review

- [ ] [P12-T1] Run PowerShell formatting over `scripts/harness` and `tests/scripts/harness`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-format.<timestamp>.md` has the four command-step fields and every file prints `Already formatted:` with none printing `Formatted:`; a rewrite restarts the loop at this task.
- [ ] [P12-T2] Run PSSA with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `scripts/harness` and `tests/scripts/harness`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-pssa.<timestamp>.md` records 0 findings; any finding is fixed and the loop restarts at P12-T1.
- [ ] [P12-T3] Run the four harness suites branch-current with coverage.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-pester-harness.<timestamp>.md` records 0 failed from `artifacts/pester/pester-junit.xml` and per-file line coverage from `artifacts/pester/powershell-coverage.xml` of 85% or more for `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1` and `scripts/harness/HarnessSkillContract.psm1`.
- [ ] [P12-T4] Run a fresh single-process Pester run over `tests/scripts` with coverage (the CI shape).
  - Acceptance: `<FEATURE>/evidence/regression-testing/full-pester.<timestamp>.md` records 0 failed and total line coverage.
- [ ] [P12-T5] Compare coverage: baseline total from the latest `pester-baseline.*.md`, post-change total from P12-T4, and the three per-file values from P12-T3.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` records the three figures, `TotalNotReduced: true`, and `NewFilesAtOrAbove85: true`.
- [ ] [P12-T6] Run seeded shuffled file-order runs of `tests/scripts/harness` in one process with seeds 1025, 2051 and 3077 from `SCRATCH/issue-1025-shuffle.ps1`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/harness-shuffle.<timestamp>.md` records each seed, its file order and 0 failed; an order dependence is fixed on both sides and all seeds re-run.
- [ ] [P12-T7] Run the Python contract set from P0-T8 again.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-python-contracts.<timestamp>.md` records 0 failed and the generator `--check` exit 0.
- [ ] [P12-T8] Run `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` and measure the logical lines of every added `.psm1` and `.Tests.ps1`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/file-size.<timestamp>.md` records 0 failed and every added code file at or below 800 lines, noting any file above 500 as guidance.
- [ ] [P12-T9] List added files with `git diff --name-only --diff-filter=A <merge-base>` and the untracked set with `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/no-new-python.<timestamp>.md` records both outputs and `AddedPy: 0` (no entry ending `.py` in either list).
- [ ] [P12-T10] List changed files with `git diff --name-only <merge-base>` and `git status --porcelain`, and compare each with `## Edit Set` and `## Excluded Paths`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/excluded-paths.<timestamp>.md` records both outputs, `ExcludedTouched: 0` (no `SKILL.md`, pack manifest or other excluded path) and `OutsideEditSet: 0`.
- [ ] [P12-T11] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from `MB`, citing the evidence above for each row.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed, the loop re-run from P12-T1, and the self-review rewritten.

## Acceptance Criteria Traceability

| AC (spec unless noted) | Tasks |
| --- | --- |
| SPEC-AC-01 Phase 0 gate | P0-T2, P0-T3, P0-T4, P0-T5 |
| SPEC-AC-02 Survey completeness | P1-T2, P1-T3 |
| SPEC-AC-03 Identity evidence | P1-T1 |
| SPEC-AC-04 Per-skill records | P2-T1 to P2-T7 |
| SPEC-AC-05 Classification and approval artifact | P7-T1, P7-T2 |
| SPEC-AC-06 Owner decision recorded | P10-T1, P11-T1 |
| SPEC-AC-07 Schema | P4-T1, P8-T1 |
| SPEC-AC-08 Matrix | P5-T1, P5-T2, P11-T2, P11-T5 |
| SPEC-AC-09 Contracts | P6 odd tasks, P11-T3, P8-T1 |
| SPEC-AC-10 Bundle copies | P6 even tasks, P11-T4, P12-T7 |
| SPEC-AC-11 Failure-case unit tests | P4-T5 |
| SPEC-AC-12 Pass case | P4-T5, P8-T1, P11-T5 |
| SPEC-AC-13 Contract unit tests | P4-T7 |
| SPEC-AC-14 Inventory unit tests | P4-T3 |
| SPEC-AC-15 Required CI check | orchestrator S9 on `poshqc / PowerShell QC`; local proxy P12-T4 |
| SPEC-AC-16 Coverage | P4-T8, P12-T3, P12-T5 |
| SPEC-AC-17 Schema validation fallback | P8-T1 |
| SPEC-AC-18 Test isolation | P12-T4, P12-T6 |
| SPEC-AC-19 E5 result | P3-T1 |
| SPEC-AC-20 Runbooks | P3-T2 to P3-T6 |
| SPEC-AC-21 Runbook results | P10-T1, P11-T2 |
| SPEC-AC-22 Owner stop recorded | P9-T1 |
| SPEC-AC-23 No new Python | P12-T9 |
| SPEC-AC-24 File size | P12-T8 |
| SPEC-AC-25 Excluded paths untouched | P12-T10 |
| US-AC-PG parity_group on hook, permission, subagent field entries (user-story) | P8-T1 |
| US-AC-CP Copilot entries approved or provisional with issue-keyed `decision_ref` (user-story) | P11-T2, P11-T5 |

## Citations Re-Checked at Phase 0

- `config/poshqc-scan.json` | `scanFolders`
- `config/poshqc-coverage.json` | `roots`
- `.claude/skills/human-exception-runbook/SKILL.md` | `## Required Sections`
- `.claude/rules/orchestrator-state.md` | `## Invariants (human_interaction block)`
- `.claude/rules/orchestrator-state.md` | `## Blocked-Reason Vocabulary`
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | `Invoke-PoshQCTest`
- `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` | `Invoke-PoshQCFormat`
- `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` | `Invoke-PoshQCAnalyze`
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | `reports zero ratchet violations against config/file-size-baseline.json`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` | `test_bundled_codex_files_are_listed_in_some_pack_manifest`
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | `test_pushed_roots_carry_no_hard_coded_solution_file`
- `tests/scripts/dev_tools/test_codex_full_migration_inventory.py` | `test_all_repo_agent_skills_are_bundled_and_identical`
- `scripts/dev_tools/generate_codex_agent_variants.py` | `--check`
- `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, `feature-audit.yyyy-MM-ddTHH-mm.md` | file presence
- `.github/skills/feature-promotion-lifecycle/SKILL.md` | `## MCP-First Execution Rule`
- `.agents/README.md`, `.agents/skills/README.md`, `.github/skills/README.md` | file presence (exclusion list)

## Pre-Mortem

- Review checklists: the self-review (P12-T11) walks all three templates; the no-new-Python (P12-T9), excluded-path (P12-T10), tonality (Phase 2 and Phase 6 preambles) and coverage (P12-T5) checks are recorded before review, so a reviewer finds an evidence row for each.
- Coverage: the repository gate cannot reach the error branches, so every rule is driven by in-memory unit tests (P4-T3, P4-T5, P4-T7); per-file coverage is read from `artifacts/pester/powershell-coverage.xml`, never from an MCP result, at P4-T8, P8-T2 and P12-T3, with an 85% floor per module.
- Mirror parity: every contract task is followed by its bundle-copy task and the resource-contract test (Phase 6, P11-T4); no `.agents/skills/<name>/` folder without `SKILL.md` is created (F2); no pack manifest or `SKILL.md` is edited. No execution-environment brief fact changes (no CI job, required context, tool route or batch-budget rule is added; a new test file under a scanned folder is already described), so no brief-update task is needed and none of its six copies is edited.
- File size: three modules split by concern; the inventory module is the largest and stays at or below 800 logical lines; a fourth production file is used only under an exempt route (Language Choices); P12-T8 records sizes. JSON and Markdown are exempt.
- Test isolation: injected script blocks, no temporary files, modules removed in `AfterAll`; P12-T6 runs seeded shuffled file-order runs with seeds 1025, 2051 and 3077, each seed and file order recorded; P12-T4 runs the fresh single-process `tests/scripts` run. No Jest or Python test is added or changed, so no Jest shuffle or Python reversed-order run applies.
- CI-only behavior: the gate runs only in the Windows shards on a clean checkout. The exclusion list removes gitignored paths (`.claude/settings.local.json` is tracked but local-scope and excluded; `.vscode/settings.json`, `.claude/worktrees/**`, `artifacts/**` are gitignored) so a developer worktree and CI inventory the same set; paths are compared in forward-slash relative form; the `Test-Json` assertion is skipped below 7.4 and gates nothing.
- Evidence: every artifact is under `<FEATURE>/evidence/<kind>/` with a write-time UTC stamp, carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` where it records a command, and records `SCRATCH` instead of host paths; runbook templates give the owner the same fields.

## Size Justification

The plan has 71 tasks, above the 40-task guideline (its physical length stays below the 400-line guideline), because the feature combines a 90-name content survey (six batch records plus single-ecosystem records), five runbooks, three modules with four test files, 55 contracts delivered as six contract tasks each paired with a bundle-copy task as required, a single owner stop, and post-stop phases that must run on resume without re-planning. Merging tasks would break the one-outcome-per-task rule or the contract and bundle-copy pairing.

## Test Plan

- Unit: `tests/scripts/harness/HarnessInventory.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.Tests.ps1`, `tests/scripts/harness/HarnessSkillContract.Tests.ps1` (in-memory seams).
- Integration: `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` on the committed tree; the existing Python resource-contract tests (run only).
- Manual: owner-run runbooks E1 to E4 and E6 at the single stop.
- Coverage evidence: baseline `<FEATURE>/evidence/baseline/pester-baseline.<timestamp>.md`; post-change `<FEATURE>/evidence/qa-gates/final-pester-harness.<timestamp>.md` and `<FEATURE>/evidence/regression-testing/full-pester.<timestamp>.md`; comparison `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md`.

## Open Questions / Notes

- F1 (configuration): no edit to `config/poshqc-scan.json` or `config/poshqc-coverage.json` is required; both already include the new paths.
- F2 (contract location for Claude-only names): `tests/scripts/dev_tools/test_codex_full_migration_inventory.py` (`test_all_repo_agent_skills_are_bundled_and_identical`) requires every `.agents/skills/<name>/` folder to hold a bundled `SKILL.md`, and `SKILL.md` files are excluded from this child. A Claude-only name approved `shared` therefore gets no contract in this child; its contract is written by child 3 when it creates `.agents/skills/<name>/`. This matches the spec's required set (`codex:skill` entries only) and is stated in the approval artifact under Q3.
- F3 (pre-stop dispositions): single-ecosystem skills are bootstrapped `native` and `provisional`, with the proposal in `notes`, so the pre-stop gate needs contracts only for the 55 default-shared names; approved `shared` Codex-only names receive contracts in P11-T3.
- The runner PowerShell version is unconfirmed; P0-T9 records the host version, and no gate depends on `Test-Json`.
- The required CI check `poshqc / PowerShell QC` on the pull request head is checked by the orchestrator at S9.
