# 2026-10-30-harness-survey-gold-standard-contracts-parity-matrix - Plan A (Pre-Stop)

- **Issue:** #1025
- **Parent (optional):** epic #1018, child 1
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T17-06
- **Status:** Draft
- **Version:** 2.0 (preflight revision: split into plan A and plan B)
- **Work Mode:** full-feature
- **Requirements sources:** `spec.md` (`## Acceptance Criteria`, authoritative), `user-story.md`, `research/research.2026-10-30T21-08.md`, `docs/features/epics/shared-agent-harness-layer/epic.md` (`## Shared Design`, `## Execution Preconditions`)
- **Companion plan:** `owner-decision-plan.md` in this folder (plan B), delegated by the orchestrator after the owner stop described in `## Owner Stop (Orchestrator-Owned, After Plan A)`. This file (plan A) is the canonical plan path.

## Required References

- Policy order: `policy-compliance-order` skill. PowerShell policies: `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`.
- Tool routes, launchers, the batch budget, PoshQC MCP limits, CI shape and contract tests: the `execution-environment` skill. This plan does not restate them; "branch-current Pester run" and "PSSA run" use the routes that skill names under `## PowerShell Route and PoshQC MCP Limits`.
- Evidence naming: `evidence-and-timestamp-conventions` skill. Every evidence file is `<name>.<timestamp>.md` stamped with the UTC write time; a consumer selects the lexicographically greatest `<name>.*.md`.

## Definitions

- `<FEATURE>` is `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`.
- `SCRATCH` is `<session scratchpad>/issue-1025/`. Every helper script, staged copy and intermediate report lives under `SCRATCH`, with file names starting `issue-1025-`. Evidence records the literal token `SCRATCH`, never a host path. Scratch helpers are throwaway PowerShell and are never committed.
- `MB` is the merge base of `origin/main` and `HEAD`, derived after fetching `origin/main` at the time the task runs. Every scope comparison uses `MB`.
- Shared set: the names present in both `.claude/skills` and `.agents/skills` (55 at planning), partitioned into batches A to F as in research `### 1.4 Recommended execution of the full survey`. Single-ecosystem set: the names in research `### N2` present in one tree (35 at planning).
- `BranchBaseline`: the set of paths in the latest `<FEATURE>/evidence/baseline/phase0-branch-snapshot.*.md`, written by entry check X4 before any task is checked.

## Edit Set (complete)

- New: `config/harness-parity-matrix.json`, `config/harness-parity-matrix.schema.json`.
- New: `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1`, `scripts/harness/HarnessSkillContract.psm1` (three production PowerShell files; no fourth).
- New: `tests/scripts/harness/HarnessInventory.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.Tests.ps1`, `tests/scripts/harness/HarnessSkillContract.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`.
- New: `.agents/skills/<name>/references/standard.md` for every shared-set name, each paired with `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`.
- New: `<FEATURE>/survey/**`, `<FEATURE>/runbooks/**`, `<FEATURE>/evidence/**`.
- Check-off edits only: this plan file, `<FEATURE>/spec.md` and `<FEATURE>/user-story.md` (acceptance-criteria checkboxes, P9-T11).
- Not edited but already changed on the branch: every path in `BranchBaseline` (the feature's `issue.md`, `spec.md`, `user-story.md`, research, both plans, the epic manifest and the promoted records). P9-T12 treats them as in scope only through `BranchBaseline`.

Configuration confirmation (planning finding F1, no edit): `config/poshqc-scan.json` `test.scanFolders` contains `tests/scripts`, so `tests/scripts/harness/` is scanned and sharded; `config/poshqc-coverage.json` `roots` contains `scripts`, so `scripts/harness/*.psm1` is in the coverage population. Entry check X3 re-confirms both.

## Excluded Paths (must never be edited)

- Any `SKILL.md` in `.claude/skills/**`, `.agents/skills/**`, `.github/skills/**` and their bundle copies under `extensions/drm-copilot/resources/**`.
- Every pack manifest, including `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- `docs/features/templates/policy_audit/*`.
- `config/poshqc-coverage.json`, `config/poshqc-scan.json`, `config/file-size-baseline.json`.
- `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
- `extensions/drm-copilot/jest.config.cjs`.
- The execution-environment brief in all six copies (`.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md` and their three bundle copies).
- `scripts/dev_tools/generate_codex_agent_variants.py` and every `tests/scripts/dev_tools/test_push_down_*` file (run only).
- Any `.agents/skills/<name>/` folder that has no `SKILL.md` (planning finding F2).
- `artifacts/orchestration/orchestrator-state.json`: no executor task writes it; the owner stop is orchestrator-owned.

## Language Choices

| Choice | Where | Cost | Risk and mitigation |
| --- | --- | --- | --- |
| PowerShell 7 modules + Pester 5 | `scripts/harness/*.psm1`, `tests/scripts/harness/*.Tests.ps1` | Three production PowerShell files equal the direct-mode batch budget of three per kind per session and worktree (execution-environment `## Batch Budget`). | The inventory module stays one file at or below 800 logical lines; no fourth production file. Runs in the required `poshqc / PowerShell QC` check with no workflow or configuration edit. |
| JSON + JSON Schema Draft 2020-12 | `config/harness-parity-matrix.json`, `config/harness-parity-matrix.schema.json` | No parser dependency: `ConvertFrom-Json` reads both. | `Test-Json -SchemaFile` supports Draft 2020-12 only on PowerShell 7.4 or later and the runner version is unconfirmed; the module's structural validation is the gate, the schema-module agreement test prevents drift, and the `Test-Json` assertion is skipped below 7.4. |
| Throwaway PowerShell under `SCRATCH` | identity pass, survey comparison, matrix bootstrap, bundle copy, reconciliation, shuffled-order runs | None committed; launched per the brief. | P9-T12 asserts no added path outside the edit set and `BranchBaseline`. |
| Existing Python, run only | `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_issue_824_follow_ups.py`, `test_codex_full_migration_inventory.py` (all under `tests/scripts/dev_tools/`), the Codex generator `--check` | No new `.py` file (owner directive). | P9-T9 asserts zero added `.py` files against `MB`. |

## Execution Preconditions (Orchestrator-Checked)

The orchestrator checks these before delegating plan A execution; the executor does not run them.

- O1 parallel run merged: for each of issues #1001, #1002, #1003, #1006, #1009, #1010, #1011, #1012 and #1013, the issue is closed and its closing pull request is merged, and each merge commit is an ancestor of `HEAD`. The orchestrator writes `<FEATURE>/evidence/baseline/phase0-parallel-run.<timestamp>.md` (one row per issue with `state`, `merged`, `ancestor-of-HEAD`, then `ParallelRun: MERGED` only when all nine rows read `CLOSED`, `true`, `true`) and commits it to the branch. Any other result is a re-planning stop; plan A is not delegated.
- O2 branch current: the branch is synchronized with `origin/main` so that `git merge-base --is-ancestor origin/main HEAD` exits 0.

## Executor Entry Checks (Before [P0-T1])

The executor runs X1 to X4 before checking any task. Each writes its artifact. If any check fails, the executor checks no task and returns `BLOCKED at preflight (before [P0-T1])` with a plan delta naming each failing row; this is the canonical preflight block form.

- X1: the latest `<FEATURE>/evidence/baseline/phase0-parallel-run.*.md` exists and reads `ParallelRun: MERGED`, and `git merge-base --is-ancestor origin/main HEAD` exits 0. Artifact: `<FEATURE>/evidence/baseline/phase0-preconditions.<timestamp>.md` ending `Preconditions: PASS`.
- X2: re-derive every entry in `## Citations Re-Checked at Phase 0` against `HEAD`: each path is tracked (`git ls-files --error-unmatch`); each symbol, heading or test name has one or more fixed-string matches with `git grep -n -F` in that path, passing a hyphen-leading pattern (for example `--check`) through `-e`; a `file presence` citation is checked by `git ls-files --error-unmatch` alone. Re-enumerate the folders holding `SKILL.md` directly under `.claude/skills`, `.agents/skills` and `.github/skills` and compare the name sets with research `### N2`. Artifact: `<FEATURE>/evidence/baseline/phase0-citations.<timestamp>.md` with each citation `PRESENT` or `MOVED`, `Added:` and `Removed:` lists, ending `Citations: PASS` only when every row is `PRESENT` and both lists are empty.
- X3: `git ls-tree -r --name-only origin/main -- config/harness-parity-matrix.json config/harness-parity-matrix.schema.json scripts/harness tests/scripts/harness` prints nothing; no `.agents/skills/*/references/` path is tracked on `origin/main`; `config/poshqc-scan.json` `test.scanFolders` contains `tests/scripts`; `config/poshqc-coverage.json` `roots` contains `scripts`; `git ls-files .claude/settings.local.json` prints the path; `git ls-files .vscode/settings.json` prints nothing. Artifact: `<FEATURE>/evidence/baseline/phase0-edit-set.<timestamp>.md` with each observed output, ending `EditSet: PASS` only when every check matches.
- X4: record the branch snapshot: the output of `git diff --name-only MB...HEAD` and the paths of `git status --porcelain`, as one sorted, de-duplicated path list. Artifact: `<FEATURE>/evidence/baseline/phase0-branch-snapshot.<timestamp>.md` with `Timestamp:`, both commands, and the list under `BranchBaseline:`.

## Matrix Bootstrap Rules

Every value below is derived mechanically; P5-T1 applies the rules in table order and the first matching row wins. All entries are written `decision_status` `provisional`. `<src>` is the entry's `source_path`.

| Entries | `disposition` | `generated_from` / `target_paths` | `owner_child` | `decision_ref` |
| --- | --- | --- | --- | --- |
| `copilot:skill:<name>` | `dropped`, `reason` from spec `### Default Dispositions` | none | 6 | `#1025:survey/difference-approval.md#disposition-proposals` |
| `claude:skill:<name>` or `codex:skill:<name>` for a single-ecosystem name | `native`; `notes` `proposed: <shared or native>` from `<FEATURE>/survey/skill-survey.md` | none | 3 | `#1025:survey/difference-approval.md#disposition-proposals` |
| `codex:skill:<name>` for a shared-set name | `shared` | targets `[.claude/skills/<name>/SKILL.md]` | 3 | `#1025:runbooks/e1-copilot-duplicate-skill-listing.runbook.md` |
| `claude:skill:<name>` for a shared-set name | `generated` | from `.agents/skills/<name>/SKILL.md`; targets `[<src>]` | 3 | `#1025:runbooks/e1-copilot-duplicate-skill-listing.runbook.md` |
| `codex:agent:<name>` whose stem ends `-c1`, `-c2`, `-c3`, `-c4` or `-c3-elevated` and whose base `.codex/agents/<base>.toml` exists | `generated` | from `.codex/agents/<base>.toml`; targets `[<src>]` | `null` | `#1025:survey/difference-approval.md` |
| `copilot:agent:*` | `generated`; `reason` `E3 pending: documentation indicates the Copilot CLI and cloud agent do not read .claude/agents, so this file is kept and generated from one logical definition; dropped if the E3 result shows both read .claude/agents` | from `pending-source:agent`; targets `[<src>]` | 6 | `#1025:runbooks/e3-copilot-cli-cloud-claude-agents.runbook.md` |
| other `claude:agent:*`, `codex:agent:*` | `generated` | from `pending-source:agent`; targets `[<src>]` | 3 | `#1025:runbooks/e4-copilot-workspace-settings.runbook.md` |
| `path-scoped-rule` (both ecosystems) | `generated` | from `pending-source:path-scoped-rule`; targets `[<src>]` | 3 | `#1025:runbooks/e6-copilot-default-double-load.runbook.md` |
| `cross-tool:instructions:AGENTS.md` | `shared` | targets `[AGENTS.md]` | 3 | `#1025:runbooks/e6-copilot-default-double-load.runbook.md` |
| `claude:instructions:CLAUDE.md` / `copilot:instructions:copilot-instructions.md` | `native` | none | 3 / 6 | `#1025:runbooks/e6-copilot-default-double-load.runbook.md` |
| `mcp-server` (both ecosystems) | `generated` | from `pending-source:mcp-server`; targets `[<src>]` | 3 | `#1025:survey/difference-approval.md` |
| `skill-frontmatter-field` | `native` | none | 3 | `#1025:runbooks/e2-codex-claude-frontmatter.runbook.md` |
| `copilot:hook-registration:*`, `prompt`, `handoff` | `native` | none | 6 | `#1025:survey/difference-approval.md` |
| other `hook-registration`, `permission`, `subagent-frontmatter-field` | `native` | none | 5 | `#1025:survey/difference-approval.md` |
| `skill-metadata-file`, `setting` | `native` | none | `null` | `#1025:survey/difference-approval.md` |

- `pending-source:<kind>` is the placeholder permitted by the amended spec `### Parity Matrix: Feature Entry` while the single source does not exist; children 3 to 6 replace it with the source path. The schema and module reject it unless `decision_status` is `provisional`.
- `parity_group` is emitted by `New-HarnessParityMatrixSkeleton`: `skill:<name>`, `skill-field:<key>`, `skill-metadata:<name>`, `agent:<base name>` (variant suffix removed), `subagent-field:<key>`, `handoff:<stem>`, `prompt:<stem>`, `hook:<command-stem>`, `permission:<name>`, `setting:<name>`, `mcp:<name>`, `rule:<stem>` (`.instructions` suffix removed), `instructions:<file name>`.
- `consumers` (documented defaults, research `## 6. Unverified-Behavior Experiments`): `claude:skill` `[claude-code, copilot-vscode, copilot-cli]`; `codex:skill` `[codex, copilot-vscode, copilot-cli]`; `copilot:skill` `[copilot-vscode, copilot-cli]`; `claude:agent` `[claude-code, copilot-vscode]`; `copilot:agent` `[copilot-vscode, copilot-cli, copilot-cloud]`; `claude:path-scoped-rule` `[claude-code, copilot-vscode]`; `claude:instructions:CLAUDE.md` `[claude-code, copilot-vscode, copilot-cli]`; `cross-tool:instructions:AGENTS.md` `[codex, copilot-cli]`; every other entry the owning ecosystem only (`claude` `[claude-code]`, `codex` `[codex]`, `copilot` `[copilot-vscode]`).

### Phase 0 — Policy Reads, Gate Record and Baselines

- [ ] [P0-T1] Read, in order, `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`, then the skills `execution-environment` and `human-exception-runbook`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:` and one line per file read, in the order above.
- [ ] [P0-T2] Write the Phase 0 gate record from the entry-check artifacts: the latest `phase0-parallel-run.*.md`, `phase0-preconditions.*.md`, `phase0-citations.*.md`, `phase0-edit-set.*.md` and `phase0-branch-snapshot.*.md`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md` names the five consumed artifacts, quotes `ParallelRun: MERGED`, `Preconditions: PASS`, `Citations: PASS` and `EditSet: PASS` from them, records the `MB` derivation command, and ends `Gate: PASS`.
- [ ] [P0-T3] Capture the PowerShell test baseline: a branch-current single-process Pester run over the `config/poshqc-scan.json` scan folders with coverage, reading pass and fail counts from `artifacts/pester/pester-junit.xml` and total line coverage from `artifacts/pester/powershell-coverage.xml`.
  - Acceptance: `<FEATURE>/evidence/baseline/pester-baseline.<timestamp>.md` has `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:` with numeric passed, failed and total line-coverage values, and `scripts/harness: absent (0 files)`.
- [ ] [P0-T4] Capture the analyzer baseline: a direct PSSA run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `scripts` and `tests/scripts`.
  - Acceptance: `<FEATURE>/evidence/baseline/pssa-baseline.<timestamp>.md` has the four command-step fields and a numeric finding count in `Output Summary:`.
- [ ] [P0-T5] Capture the Python contract-test baseline: run the four test modules named in `## Language Choices` and the Codex generator `scripts/dev_tools/generate_codex_agent_variants.py` with `--check`.
  - Acceptance: `<FEATURE>/evidence/baseline/python-contract-baseline.<timestamp>.md` has the four command-step fields per command and numeric passed and failed counts.
- [ ] [P0-T6] Capture the file-size and host baseline: run `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` and record the It block `reports zero ratchet violations against config/file-size-baseline.json`; record the host `$PSVersionTable.PSVersion` and whether `Test-Json` accepts `-SchemaFile`.
  - Acceptance: `<FEATURE>/evidence/baseline/file-size-and-host.<timestamp>.md` has the four command-step fields, the It result and the host PowerShell version.

### Phase 1 — Skill Identity Pass and Survey Index

- [ ] [P1-T1] Write `SCRATCH/issue-1025-skill-identity.ps1` and run it: it enumerates folders containing `SKILL.md` directly under the three skill trees and, for every name in more than one tree, records `git hash-object` of each copy, a normalized comparison (whitespace collapsed, heading markers ignored) and the class `byte-identical` (all hashes equal), `wording-only` (normalized text equal) or `substantive` (otherwise).
  - Acceptance: `<FEATURE>/evidence/baseline/skill-identity.<timestamp>.md` has `Command:` naming `SCRATCH/issue-1025-skill-identity.ps1`, `EXIT_CODE: 0`, one row per multi-tree name with each copy's hash and a class, and a `Rows:` count equal to the multi-tree name count the script printed.
- [ ] [P1-T2] Create `<FEATURE>/survey/skill-survey.md` with one table row per name in the union of the three trees, columns `Skill`, `Claude`, `Codex`, `Copilot`, `Identity`, `Proposed disposition`, `Batch`, `Record` as in spec `### Survey Records`; identity values come from the latest `skill-identity.*.md`, single-tree names carry `single-ecosystem` and batch `single`, and each `Record` link is `<batch file>#<skill-name>` under `<FEATURE>/survey/`.
  - Acceptance: the row count equals the union count; every `Identity` value is one of the four enum values; every `Batch` value is `A` to `F` or `single`.
- [ ] [P1-T3] Write `SCRATCH/issue-1025-survey-compare.ps1` and run it: it parses the `Skill` column of `<FEATURE>/survey/skill-survey.md` and compares it with a fresh enumeration of the three trees.
  - Acceptance: `<FEATURE>/evidence/baseline/survey-completeness.<timestamp>.md` has the four command-step fields, `EXIT_CODE: 0`, and the lines `Missing: 0`, `Extra: 0` and `Duplicated: 0`.

### Phase 2 — Content Pass: Batch Records

Each batch task reads every copy of each member name, searches each section missing from one copy across that ecosystem's agent bodies, rules and sibling skills before recording it as missing, and writes one `### <skill-name>` record per member in the spec `### Survey Records` shape. `byte-identical` records have no difference table; every `wording-only` or `substantive` record has a difference table with one or more rows. Every difference row has a Diff ID `D-<skill-name>-<nn>` (two digits, one-based, gap-free), a class from `positive`, `negative`, `neutral`, `mechanism-only`, a port direction `none` or `<from>-><to>`, and a rationale against the draft objective. Text follows `.claude/rules/tonality.md` and contains no `TaskMaster.sln`. P7-T2 verifies tables, links and Diff IDs across all batch files.

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
  - Acceptance: one `### ` record per single-ecosystem name and no other; each record's `Proposed disposition` equals its row in `<FEATURE>/survey/skill-survey.md`.

### Phase 3 — Experiments: E5 Result and Owner Runbooks

Each runbook carries, in order, `## Cue`, `## Prerequisites`, `## Step-by-step Instructions`, `## Verification` and `## Source and Citation` (`.claude/skills/human-exception-runbook/SKILL.md` `## Required Sections`); uses a scratch repository and never this repository; and its Verification section gives a result template with `Timestamp:`, `Command:`, `EXIT_CODE:` (0 when observed as described, 1 otherwise), `Output Summary:`, `Tool versions:` and the named observation lines below, each answered `yes`, `no` or a count, naming the result path from spec `## Experiments`. Plan B maps these observation lines to matrix values. Sources are the URLs in research section 6 with capture date 2026-10-30.

- [ ] [P3-T1] Create `<FEATURE>/evidence/other/e5-claude-hooks-subagent-permissions-documentation.<timestamp>.md` from research `### E5. Claude Code hooks, subagent and permissions details`: subagent frontmatter fields, hook configuration levels and handler types, permission evaluation order, each with its source URL and fetch date 2026-10-30.
  - Acceptance: the file has `Timestamp:`, the three finding groups and three source URLs under `code.claude.com`.
- [ ] [P3-T2] Create `<FEATURE>/runbooks/e1-copilot-duplicate-skill-listing.runbook.md` (probe skill in three locations; VS Code Skills page and `/` menu; Copilot CLI `/skills`), with observation lines `VSCode-Entries:` and `CLI-Entries:` (counts).
  - Acceptance: the five headings appear once each in the required order; the template names `e1-copilot-duplicate-skill-listing-result` and both observation lines.
- [ ] [P3-T3] Create `<FEATURE>/runbooks/e2-codex-claude-frontmatter.runbook.md` (probe skill with the six Claude-only fields; Codex listing and invocation; optional VS Code `context: fork` check), with observation lines `Codex-Lists-Skill:` and `Codex-Warning-Fields:`.
  - Acceptance: as P3-T2, with `e2-codex-claude-frontmatter-result` and both observation lines.
- [ ] [P3-T4] Create `<FEATURE>/runbooks/e3-copilot-cli-cloud-claude-agents.runbook.md` (scratch repository with only a Claude-format agent; CLI `/agent` list; cloud-agent picker), with observation lines `CLI-Lists-Claude-Agent:` and `Cloud-Lists-Claude-Agent:`.
  - Acceptance: as P3-T2, with `e3-copilot-cli-cloud-claude-agents-result` and both observation lines.
- [ ] [P3-T5] Create `<FEATURE>/runbooks/e4-copilot-workspace-settings.runbook.md` (workspace `.vscode/settings.json` in the scratch repository with the location and file-use settings; Skills page, agent picker and References observations), with observation line `Workspace-Settings-Honored:`.
  - Acceptance: as P3-T2, with `e4-copilot-workspace-settings-result` and the observation line.
- [ ] [P3-T6] Create `<FEATURE>/runbooks/e6-copilot-default-double-load.runbook.md` (same scratch repository as E4, no settings file; References list and CLI `/instructions`), with observation lines `VSCode-References-Both-Rules:` and `CLI-Lists-CLAUDE-md:`.
  - Acceptance: as P3-T2, with `e6-copilot-default-double-load-result` and both observation lines.

### Phase 4 — Schema, PowerShell Modules and Unit Tests

Modules follow `.claude/rules/powershell.md`: `[CmdletBinding()]`, comment-based help, approved verbs, explicit `Export-ModuleMember`. File listing and reading are injected script-block parameters defaulting to the real file system. Tests use in-memory content only, create no files, and remove imported modules in `AfterAll`.

- [ ] [P4-T1] Create `config/harness-parity-matrix.schema.json` per spec `### Parity Matrix: Location and Format`, `### Parity Matrix: Top-Level Object` and `### Parity Matrix: Feature Entry` (as amended): dialect Draft 2020-12, `$id` `https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json`, `additionalProperties: false` at both levels, every field, enum and pattern, and the five `if`/`then` rules under `allOf` (including `generated_from` matching `^pending-source:[a-z-]+$` requiring `decision_status` `provisional`); UTF-8 without BOM, LF, two-space indent.
  - Acceptance: `ConvertFrom-Json` parses the file; the agreement It in P8-T1 verifies content.
- [ ] [P4-T2] Create `scripts/harness/HarnessInventory.psm1` exporting `Get-HarnessInventory` (`-RepositoryRoot`, `-ListFiles`, `-ReadFile`) and `Test-HarnessInventoryPathExcluded`; it applies the 13 inventory rules in spec `### Parity Matrix: Feature Kinds and Inventory Rules` and the exclusion list, reads JSON with `ConvertFrom-Json` and frontmatter keys and TOML table headers with anchored regular expressions, and returns objects with `id`, `ecosystem`, `kind`, `name`, `source_path` and optional `source_pointer`, sorted by `id` (ordinal).
  - Acceptance: the module imports without error and stays at or below 800 logical lines.
- [ ] [P4-T3] Create `tests/scripts/harness/HarnessInventory.Tests.ps1` with one It per kind (13) proving its rule on injected listings, one It per exclusion-list entry group proving exclusion, and one It proving ordinal `id` ordering.
  - Acceptance: a branch-current Pester run of this file reports 0 failed in `artifacts/pester/pester-junit.xml`.
- [ ] [P4-T4] Create `scripts/harness/HarnessParityMatrix.psm1` exporting `Get-HarnessParityMatrixRuleSet` (enums, required fields, conditional rules, `$id` as data), `Import-HarnessParityMatrix` (`-Path`, `-ReadFile`), `Get-HarnessParityMatrixViolation` (`-Matrix`, `-InventoryFeature`) returning violation objects that each name the offending `id` and rule, and `New-HarnessParityMatrixSkeleton` emitting draft entries (identity fields, `parity_group` per `## Matrix Bootstrap Rules`, empty `consumers`, `owner_child` `null`) for unmatched inventoried features. It enforces spec `## Data & State` invariants 1 to 7 and the `pending-source:` rule.
  - Acceptance: the module imports without error.
- [ ] [P4-T5] Create `tests/scripts/harness/HarnessParityMatrix.Tests.ps1` with one It per failure case in spec AC `Completeness unit tests: failure cases` (inventoried feature with no entry; entry without `disposition`; unknown `disposition`, `kind`, `ecosystem`, `consumers` item and `decision_status`, one It each; `dropped` without `reason`; `dropped` with empty `reason`; `dropped` without `decision_ref`; duplicate `id`; `id` inconsistent with `ecosystem`; `id` inconsistent with `kind`; unsorted `features`; orphan not `dropped`; `shared` without `target_paths`; `generated` without `target_paths`; `generated` without `generated_from`; `provisional` without `decision_ref`; malformed `decision_ref`; unknown property), one It for a `pending-source:` value with `decision_status` `approved`, one pass-case It whose in-memory matrix covers all four dispositions and a `pending-source:` provisional entry and yields no violation, and one It per `parity_group` derivation family of `New-HarnessParityMatrixSkeleton`.
  - Acceptance: a branch-current Pester run of this file reports 0 failed; each failure-case It asserts the offending `id` appears in the violation.
- [ ] [P4-T6] Create `scripts/harness/HarnessSkillContract.psm1` exporting `Get-HarnessSkillContractRequiredSet` (`-Matrix`; entries with `kind` `skill`, `ecosystem` `codex`, `disposition` `shared`), `Get-HarnessSkillContractViolation` (`-Name`, `-Content`; rules 1 to 5 and 7 of spec `### Contract Format`) and `Get-HarnessSkillContractSetViolation` (`-Matrix`, `-RepositoryRoot`, `-ReadFile`, `-TestPath`; reports a missing contract by path).
  - Acceptance: the module imports without error.
- [ ] [P4-T7] Create `tests/scripts/harness/HarnessSkillContract.Tests.ps1` with one It each for: missing contract for a required skill; wrong H1; missing H2; extra H2; reordered H2; empty section; gap in `OB-<n>`; repeat in `AC-<n>`; check citing a non-existent behavior; behavior cited by no check; checkbox syntax; `TaskMaster.sln` present; conforming contract with no violation; required set derived from an in-memory matrix.
  - Acceptance: a branch-current Pester run of this file reports 0 failed.
- [ ] [P4-T8] Run the three unit suites together, branch-current, with coverage over `scripts/harness`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/harness-unit-coverage.<timestamp>.md` has the four command-step fields, 0 failed from the JUnit file, and per-file line coverage from `artifacts/pester/powershell-coverage.xml` of 85% or more for each module; a lower value is fixed by adding tests in the matching test file and re-running before this task is checked.

### Phase 5 — Matrix Bootstrap

- [ ] [P5-T1] Write `SCRATCH/issue-1025-matrix-bootstrap.ps1` and run it: it imports the three modules, calls `Get-HarnessInventory` and `New-HarnessParityMatrixSkeleton`, applies `## Matrix Bootstrap Rules` row by row (first match wins) plus the `consumers` rule, and writes `config/harness-parity-matrix.json` (`$schema` and `schema_version` `1.0.0`; UTF-8 without BOM, LF, two-space indent; `features` sorted by `id`). The script exits 1 if an entry matches no row.
  - Acceptance: `<FEATURE>/evidence/other/matrix-bootstrap.<timestamp>.md` has the four command-step fields, `EXIT_CODE: 0`, the entry count per `kind`, the count per `disposition`, the count of `pending-source:` entries, and `Unmatched: 0`.
- [ ] [P5-T2] Run `Get-HarnessParityMatrixViolation` on `config/harness-parity-matrix.json` against the live inventory from a scratch script.
  - Acceptance: `<FEATURE>/evidence/other/matrix-violations-pre-contract.<timestamp>.md` records `Violations: 0`, `Approved: 0`, and a count of `codex:skill` entries with disposition `shared` equal to the number of `<FEATURE>/survey/skill-survey.md` rows with `Claude` and `Codex` both `yes`.

### Phase 6 — Contracts and Bundle Copies for the Shared Set

Each contract task writes `.agents/skills/<name>/references/standard.md` for every batch member in the exact spec `### Contract Format` structure, from the draft objective and records of Phase 2, tool-neutral, in the tonality policy, without `TaskMaster.sln`; it then runs `Get-HarnessSkillContractViolation` over the batch from a scratch script and records the file count and `Violations: 0` in `<FEATURE>/evidence/other/contracts-<letter>.<timestamp>.md`. Each bundle-copy task runs `SCRATCH/issue-1025-copy-contracts.ps1` for the batch (byte copy to the `extensions/drm-copilot/resources/codex-and-agents-customizations/` mirror), then runs `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`, `tests/scripts/dev_tools/test_codex_full_migration_inventory.py::test_all_repo_agent_skills_are_bundled_and_identical` and `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_pushed_roots_carry_no_hard_coded_solution_file`, and records the four command-step fields with 3 passed and 0 failed in `<FEATURE>/evidence/qa-gates/bundle-parity-<letter>.<timestamp>.md`.

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

### Phase 7 — Owner Approval Artifact and Survey Reconciliation

- [ ] [P7-T1] Create `<FEATURE>/survey/difference-approval.md` in the spec `### Owner Approval Artifact` shape with `Approval-Status: pending`, empty `Approved-By` and `Approved-At`; `## Bulk Approval Set` with every non-disputed Diff ID; `## Disposition Proposals` with every single-ecosystem skill and every matrix entry written `dropped` (listed from `config/harness-parity-matrix.json`); `## Owner Questions` with Q1 to Q8 and their defaults, adding the F2 constraint to Q3; empty `## Owner Overrides`; and `## Disputed Cases` with one `### D-<skill>-<nn>` block (Context, Option A, Option B, Recommendation, empty `Owner-Decision:`) per case meeting a disputed-case rule.
  - Acceptance: the six headings and three metadata fields appear once each.
- [ ] [P7-T2] Write `SCRATCH/issue-1025-diff-reconcile.ps1` and run it: it reads `<FEATURE>/survey/skill-survey.md`, the six batch files, `<FEATURE>/survey/single-ecosystem.md` and the approval artifact, and counts: Diff IDs in batch files absent from the approval artifact (`Missing`); Diff IDs listed more than once across the bulk table and disputed headings (`Duplicated`); approval Diff IDs absent from batch files (`Unknown`); rows with a class or port direction outside the enums (`InvalidClass`); per-skill sequences that do not start at `01` or have a gap (`SequenceGaps`); `wording-only` or `substantive` records with no difference row (`RecordsWithoutTable`); and index `Record` links whose target file is missing or holds no `### <skill-name>` heading for that row (`BrokenRecordLinks`).
  - Acceptance: `<FEATURE>/evidence/other/diff-id-reconciliation.<timestamp>.md` has the four command-step fields and `Missing: 0`, `Duplicated: 0`, `Unknown: 0`, `InvalidClass: 0`, `SequenceGaps: 0`, `RecordsWithoutTable: 0` and `BrokenRecordLinks: 0`; the script exits 1 when any count is non-zero.

### Phase 8 — Repository Gate

- [ ] [P8-T1] Create `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` reading the real tree and `config/harness-parity-matrix.json`, with the It blocks `schema declares Draft 2020-12 and the 1.0.0 id`, `schema enums required fields and conditional rules agree with the module rule set`, `committed matrix has no violation against the live inventory`, `every hook-registration permission and subagent-frontmatter-field entry has a parity_group`, `every shared codex skill has a conforming contract`, and `committed matrix passes Test-Json on PowerShell 7.4 or later`, the last marked skipped when `$PSVersionTable.PSVersion` is below 7.4. Failure messages list each offending `id` or contract path.
  - Acceptance: a branch-current Pester run of this file reports 0 failed and 5 or 6 passed (6 on 7.4 or later, otherwise 5 with 1 skipped).

### Phase 9 — Final QA Loop, Stop Readiness and Self-Review

- [ ] [P9-T1] Run PowerShell formatting over `scripts/harness` and `tests/scripts/harness`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-format.<timestamp>.md` has the four command-step fields and every file prints `Already formatted:` with none printing `Formatted:`; a rewrite restarts the loop at this task.
- [ ] [P9-T2] Run PSSA with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `scripts/harness` and `tests/scripts/harness`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-pssa.<timestamp>.md` records 0 findings; any finding is fixed and the loop restarts at P9-T1.
- [ ] [P9-T3] Run the four harness suites branch-current with coverage.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-pester-harness.<timestamp>.md` records 0 failed from `artifacts/pester/pester-junit.xml` and per-file line coverage from `artifacts/pester/powershell-coverage.xml` of 85% or more for `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1` and `scripts/harness/HarnessSkillContract.psm1`.
- [ ] [P9-T4] Run a fresh single-process Pester run over `tests/scripts` with coverage (the CI shape).
  - Acceptance: `<FEATURE>/evidence/regression-testing/full-pester.<timestamp>.md` records 0 failed and total line coverage.
- [ ] [P9-T5] Compare coverage: baseline total from the latest `pester-baseline.*.md`, post-change total from P9-T4 and the three per-file values from P9-T3.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` records the figures, `TotalNotReduced: true` and `NewFilesAtOrAbove85: true`.
- [ ] [P9-T6] Run seeded shuffled file-order runs of `tests/scripts/harness` in one process with seeds 1025, 2051 and 3077 from `SCRATCH/issue-1025-shuffle.ps1`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/harness-shuffle.<timestamp>.md` records each seed, its file order and 0 failed; an order dependence is fixed on both sides and all seeds re-run.
- [ ] [P9-T7] Run the Python contract set from P0-T5 again.
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-python-contracts.<timestamp>.md` records 0 failed and the generator `--check` exit 0.
- [ ] [P9-T8] Run `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` and measure the logical lines of every added `.psm1` and `.Tests.ps1`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/file-size.<timestamp>.md` records 0 failed and every added code file at or below 800 lines, noting any file above 500 as guidance.
- [ ] [P9-T9] List added files with `git diff --name-only --diff-filter=A MB` and the untracked set with `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/no-new-python.<timestamp>.md` records both outputs and `AddedPy: 0` (no entry ending `.py` in either list).
- [ ] [P9-T10] Confirm the plan A end state is complete for the owner stop: the latest artifacts of P0-T2, P1-T3, P3-T1, P5-T2, P6-T12, P7-T2 and P9-T3 (whose run includes the repository gate suite) exist with passing values, the five runbooks exist, `Approval-Status: pending` holds, and every matrix entry is `provisional`.
  - Acceptance: `<FEATURE>/evidence/other/pre-stop-readiness.<timestamp>.md` lists each artifact name and ends `PreStop: READY`.
- [ ] [P9-T11] Check off in `<FEATURE>/spec.md` each acceptance criterion listed under "Plan-A-only rows" in `## Acceptance Criteria Traceability`, and in `<FEATURE>/user-story.md` only the criterion beginning `Every hook registration, permission and subagent frontmatter field` (US-AC-PG); every other criterion in both files stays unchecked for plan B or the orchestrator.
  - Acceptance: `spec.md` has exactly 11 checked criteria and `user-story.md` exactly 1, each matching the named rows.
- [ ] [P9-T12] List changed files with `git diff --name-only MB` and `git status --porcelain`, and compare each path with `## Edit Set`, `BranchBaseline` and `## Excluded Paths`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/excluded-paths.<timestamp>.md` records both outputs, `ExcludedTouched: 0` and `OutsideEditSet: 0`, where `OutsideEditSet` counts paths in neither `## Edit Set` nor `BranchBaseline`.
- [ ] [P9-T13] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from `MB`, citing the evidence above for each row.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed, the loop re-run from P9-T1, and the self-review rewritten.

## Owner Stop (Orchestrator-Owned, After Plan A)

After plan A completes with every task checked and the orchestrator commits its work, the orchestrator (not an executor) records the single owner stop:

- In `artifacts/orchestration/orchestrator-state.json`: `blocked_reason: "human_decision_required"` and `human_interaction.requirements[]` with six entries: one `response: "halt"` for `<FEATURE>/survey/difference-approval.md` (bulk approval, disputed cases, Q1 to Q8), and one `response: "exception"` per runbook with `runbook_path` set to `<FEATURE>/runbooks/e1-copilot-duplicate-skill-listing.runbook.md`, `<FEATURE>/runbooks/e2-codex-claude-frontmatter.runbook.md`, `<FEATURE>/runbooks/e3-copilot-cli-cloud-claude-agents.runbook.md`, `<FEATURE>/runbooks/e4-copilot-workspace-settings.runbook.md` and `<FEATURE>/runbooks/e6-copilot-default-double-load.runbook.md` (`.claude/rules/orchestrator-state.md` `## Invariants (human_interaction block)`).
- Validate the checkpoint with `validate_orchestration_artifacts` (`orchestrator-state`) with no error, copy the recorded block and the resume conditions below into `<FEATURE>/evidence/other/owner-stop.<timestamp>.md`, and commit that file.

Resume conditions the orchestrator checks before delegating plan B (all must hold; it writes `<FEATURE>/evidence/other/resume-check.<timestamp>.md` with one row per condition, ending `Resume: READY` only when all hold, and commits it):

- R1: `<FEATURE>/survey/difference-approval.md` has `Approval-Status` `approved` or `approved-with-overrides`, non-empty `Approved-By` and `Approved-At`, and a non-empty `Owner-Decision` in every disputed case.
- R2: each of E1, E2, E3, E4 and E6 has a latest `<FEATURE>/evidence/other/<runbook id>-result.*.md` with the template fields and observation lines, or a deferral row in `## Owner Overrides`.
- R3: the branch is re-synchronized with `origin/main`; before the sync, `git diff --name-only HEAD...origin/main` names no `## Edit Set` path and no path this branch changed (`EditSetDrift: 0`).
- R4: after the sync, a branch-current run of `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` reports 0 failed, and `SCRATCH/issue-1025-survey-compare.ps1` (re-written if absent) reports `Missing: 0` and `Extra: 0`. A failure means a feature or skill name was added or removed upstream since plan A; that is a re-planning stop, and plan B is not delegated.
- On R1 or R2 failure the run stays blocked under the same stop and no new stop record is written.

## Acceptance Criteria Traceability

| AC (spec unless noted) | Plan A tasks | Plan B tasks (`owner-decision-plan.md`) or orchestrator |
| --- | --- | --- |
| SPEC-AC-01 Phase 0 gate | O1, X1 to X4, P0-T2 | — |
| SPEC-AC-02 Survey completeness | P1-T2, P1-T3 | — |
| SPEC-AC-03 Identity evidence | P1-T1 | — |
| SPEC-AC-04 Per-skill records | P2-T1 to P2-T7, P7-T2 | B P1-T1 (re-run) |
| SPEC-AC-05 Classification and approval artifact | P7-T1, P7-T2 | B P1-T1 |
| SPEC-AC-06 Owner decision recorded | — | orchestrator R1; B P0-T2, B P1-T1 |
| SPEC-AC-07 Schema | P4-T1, P8-T1 | — |
| SPEC-AC-08 Matrix | P5-T1, P5-T2, P8-T1 | B P1-T2, B P1-T3, B P1-T6 |
| SPEC-AC-09 Contracts | P6 odd tasks, P8-T1 | B P1-T4, B P1-T6 |
| SPEC-AC-10 Bundle copies | P6 even tasks, P9-T7 | B P1-T5, B P2-T4 |
| SPEC-AC-11 Failure-case unit tests | P4-T5 | — |
| SPEC-AC-12 Pass case | P4-T5, P8-T1 | B P1-T6 |
| SPEC-AC-13 Contract unit tests | P4-T7 | — |
| SPEC-AC-14 Inventory unit tests | P4-T3 | — |
| SPEC-AC-15 Required CI check | local proxy P9-T4 | orchestrator S9 on `poshqc / PowerShell QC` after plan B |
| SPEC-AC-16 Coverage | P4-T8, P9-T3, P9-T5 | B P2-T3 |
| SPEC-AC-17 Schema validation fallback | P8-T1 | — |
| SPEC-AC-18 Test isolation | P9-T4, P9-T6 | — |
| SPEC-AC-19 E5 result | P3-T1 | — |
| SPEC-AC-20 Runbooks | P3-T2 to P3-T6 | — |
| SPEC-AC-21 Runbook results | — | orchestrator R2; B P1-T3 |
| SPEC-AC-22 Owner stop recorded | — | orchestrator `## Owner Stop`; B P0-T2 |
| SPEC-AC-23 No new Python | P9-T9 | B P2-T6 |
| SPEC-AC-24 File size | P9-T8 | B P2-T5 |
| SPEC-AC-25 Excluded paths untouched | P9-T12 | B P2-T8 |
| US-AC-PG parity_group on hook, permission, subagent field entries (user-story) | P4-T5, P8-T1 | — |
| US-AC-CP Copilot entries approved or provisional with issue-keyed `decision_ref` (user-story) | — | B P1-T3, B P1-T6 |

Plan-A-only rows (checked off at P9-T11): SPEC-AC-01, 02, 03, 07, 11, 13, 14, 17, 18, 19, 20 and US-AC-PG. Every other row is checked off by plan B, except SPEC-AC-15, which the orchestrator checks off at S9.

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
- `.codex/agents/orchestrator.toml`, `.codex/agents/orchestrator-c1.toml`, `.codex/agents/orchestrator-c3-elevated.toml` | file presence (variant-suffix rule)
- `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, `feature-audit.yyyy-MM-ddTHH-mm.md` | file presence
- `.github/skills/feature-promotion-lifecycle/SKILL.md` | `## MCP-First Execution Rule`
- `.agents/README.md`, `.agents/skills/README.md`, `.github/skills/README.md` | file presence (exclusion list)
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, `config/file-size-baseline.json`, `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, `extensions/drm-copilot/jest.config.cjs` | file presence (excluded paths, spec AC Phase 0 gate)
- `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | file presence (excluded paths: the six brief copies)

## Pre-Mortem

- Review checklists: the self-review (P9-T13) walks all three templates; the no-new-Python (P9-T9), edit-set and excluded-path (P9-T12), tonality (Phase 2 and Phase 6 preambles) and coverage (P9-T5) checks are recorded before review, so a reviewer finds an evidence row for each.
- Coverage: the repository gate cannot reach the error branches, so every rule is driven by in-memory unit tests (P4-T3, P4-T5, P4-T7); per-file coverage is read from `artifacts/pester/powershell-coverage.xml`, never from an MCP result, at P4-T8 and P9-T3, with an 85% floor per module and a no-reduction check at P9-T5.
- Mirror parity: every contract task is followed by its bundle-copy task and the resource-contract test (Phase 6); the pack-manifest completeness test enumerates bundled `SKILL.md` files only, so contract copies need no manifest entry and none is added; no `.agents/skills/<name>/` folder without `SKILL.md` is created (F2). No execution-environment brief fact changes (no CI job, required context, tool route or batch-budget rule is added; a new test file under a scanned folder is already described), so no brief-update task is needed and none of its six copies is edited.
- File size: three modules split by concern; the inventory module is the largest and stays at or below 800 logical lines; P9-T8 records sizes. JSON and Markdown are exempt.
- Test isolation: injected script blocks, no temporary files, modules removed in `AfterAll`; P9-T6 runs seeded shuffled file-order runs of the touched Pester suites with seeds 1025, 2051 and 3077, each seed and file order recorded; P9-T4 runs the fresh single-process `tests/scripts` run. No Jest or Python test is added or changed, so no Jest shuffle or Python reversed-order run applies.
- CI-only behavior: the gate runs only in the Windows shards on a clean checkout. The exclusion list removes gitignored and local-scope paths (`.claude/settings.local.json`, `.vscode/settings.json`, `.claude/worktrees/**`, `artifacts/**`) so a developer worktree and CI inventory the same set; paths are compared in forward-slash relative form; the `Test-Json` assertion is skipped below 7.4 and gates nothing.
- Evidence: every artifact is under `<FEATURE>/evidence/<kind>/` with a write-time UTC stamp, carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:` where it records a command, and records `SCRATCH` instead of host paths; entry-check artifacts are written before any task is checked; orchestrator-written artifacts (`phase0-parallel-run`, `owner-stop`, `resume-check`) are committed before the delegation that consumes them.

## Size Justification

Plan A has 60 tasks, above the 40-task guideline, because the feature combines a 90-name content survey (six batch records plus single-ecosystem records), five runbooks, three modules with four test files, 55 contracts delivered as six contract tasks each paired with a bundle-copy task, and a full final QA loop with stop readiness. Merging tasks would break the one-outcome-per-task rule or the contract and bundle-copy pairing. The post-decision work is in plan B.

## Test Plan

- Unit: `tests/scripts/harness/HarnessInventory.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.Tests.ps1`, `tests/scripts/harness/HarnessSkillContract.Tests.ps1` (in-memory seams).
- Integration: `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` on the committed tree; the existing Python resource-contract tests (run only).
- Manual: owner-run runbooks E1 to E4 and E6 at the orchestrator-owned stop.
- Coverage evidence: baseline `<FEATURE>/evidence/baseline/pester-baseline.<timestamp>.md`; post-change `<FEATURE>/evidence/qa-gates/final-pester-harness.<timestamp>.md` and `<FEATURE>/evidence/regression-testing/full-pester.<timestamp>.md`; comparison `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md`.

## Open Questions / Notes

- F1 (configuration): no edit to `config/poshqc-scan.json` or `config/poshqc-coverage.json` is required; both already include the new paths.
- F2 (contract location for Claude-only names): `tests/scripts/dev_tools/test_codex_full_migration_inventory.py` (`test_all_repo_agent_skills_are_bundled_and_identical`) requires every `.agents/skills/<name>/` folder to hold a bundled `SKILL.md`, and `SKILL.md` files are excluded from this child. A Claude-only name approved `shared` therefore gets no contract in this child; its contract is written by child 3 when it creates `.agents/skills/<name>/`. This matches the spec's required set (`codex:skill` entries only) and is stated in the approval artifact under Q3.
- F3 (pre-stop dispositions): single-ecosystem skills are bootstrapped `native` and `provisional`, with the proposal in `notes`, so plan A needs contracts only for the shared set; Codex-only names approved `shared` receive contracts in plan B.
- F4 (`pending-source:<kind>`): spec `### Parity Matrix: Feature Entry` was amended in this revision to permit the placeholder for `generated` entries whose single source does not yet exist, only with `decision_status` `provisional`. Such entries stay `provisional` after plan B until children 3 to 6 create the source.
- The runner PowerShell version is unconfirmed; P0-T6 records the host version, and no gate depends on `Test-Json`.
