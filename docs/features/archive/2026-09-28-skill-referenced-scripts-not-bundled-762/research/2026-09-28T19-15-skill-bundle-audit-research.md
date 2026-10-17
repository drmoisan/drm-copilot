# Skill bundle audit — research (Issue #762)

- Issue: #762
- Branch: `fix/skill-bundled-scripts`
- Base: `origin/main` @ `5d0b93a0`
- Date: 2026-09-28T19-15

## Rule under enforcement

"No bundled skill should reference a script that is not bundled with it."

Definition adopted (user scope correction, 2026-09-28): a script is **bundled with a skill** when it is part of the payload that ships with that skill wherever the skill is distributed. Folder location is not the criterion; a script may live outside `.claude/skills/<name>/` provided it is carried with the skill.

## How a skill's bundle is defined and distributed

1. **Payload root.** Consumers receive Claude customizations through the `push_down_claude_customizations` MCP tool, which runs the in-process TypeScript port (`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts` -> `claude-customizations.ts`). Its source is the extension bundle directory `extensions/drm-copilot/resources/claude-customizations/`.
2. **Published folders.** `ROOT_FOLDERS = [".claude", "config"]` (`claude-customizations.ts`). Nothing under `scripts/**`, `tests/**`, or any other repository path is published. (The repository CLI `scripts/dev_tools/push_down_claude_customizations.py` publishes `(".claude",)` only; that divergence is tracked in #764.)
3. **Bundle mirror.** The bundle's `.claude/**` is a byte-identical mirror of the repository `.claude/**` (minus `settings.local.json` and agent memory), enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Adding a file under `.claude/` therefore requires the same file in the bundle.
4. **Pack filter.** When packs are selected, only paths listed in the selected `pack-manifests/<pack>.json` files plus `core.json` are published (`compute_published_paths`). A skill ships with a pack when its `SKILL.md` is listed there; a file it needs ships with it only when that file is listed in `core` or in the same pack.
5. **No extension filter.** Neither engine filters by file extension; `.claude/lib/bash/*.sh` already ships this way. Bash scripts are invoked as `bash <path>`, so the executable bit is not required.
6. **Existing gap.** `test_push_down_claude_pack_manifest_completeness.py` checks only each skill's `SKILL.md`, not other files in the skill folder (for example `scripts/`, `references/`). A file added to a skill folder but omitted from the manifest would be dropped from a pack-scoped push-down without any test failing.

Consequence: a script is bundled with skill S if and only if (a) it lies under a published root folder, (b) it is present in the extension bundle, and (c) it is listed in `core.json` or in every pack manifest that lists `S/SKILL.md`.

## Classification rule for references

- **Script dependency** (subject to the rule): a script path the skill instructs the runtime to execute or load — a `Bash(...)` pattern in `allowed-tools`, or an invocation form in the body (`bash`/`sh`/`source <path>`, `pwsh ... -File <path>`, `& <path>`, `. <path>`, `Import-Module <path>` including `Import-Module (Join-Path $root '<path>')`, `python <path>`, `python -m <package.module>`).
- **Not a script dependency**: cross-references to other skills, hooks (`.claude/hooks/*.ps1` are cited as the enforcer of a contract, not run by the skill), rules, MCP tools; citations of the Python validator or reference implementation that backs an MCP tool or hook (`scripts/dev_tools/*.py` described as "authoritative", "canonical reference", "enforced by"); template examples (`helper.py`, `starter.ts`, `module.py`); explicit "do not use" notes; glob patterns.

## Audit table (all 56 skills under `.claude/skills/**`)

Skills with no script path in `SKILL.md` or `allowed-tools`: commit-message, csharp-change-budget-router, csharp-orchestration-state-machine, csharp-qa-gate, discovery-behavior-reconciliation, discovery-coverage-ledger, discovery-parity-matrix, discovery-repo-inventory, discovery-runtime-characterization, discovery-validate-artifacts, discovery-workflow, epic-run, evidence-and-timestamp-conventions, execute-hard-lock, feature-promotion-lifecycle, fill-feature-docs, invoke-csharp-engineer, parallel-run, policy-audit-template-usage, policy-compliance-order, powershell-change-budget-router, powershell-orchestration-state-machine, powershell-qa-gate, pr-base-branch-merge-base, pr-context-artifacts, python-change-budget-router, python-qa-gate (runs `poetry run` tools, no script path), quota-throttling, remediation-handoff-atomic-planner, research-issue, review-epic, review-feature, review-staged, show-my-agent-tree, skill-canonical-location-audit, update-status.

| Skill | Script paths found | Classification | Bundled? | Resolution |
| --- | --- | --- | --- | --- |
| acceptance-criteria-tracking | `.claude/lib/requirements/GeneratedDocumentCounters.psm1`; `scripts/dev_tools/plan_progress_report.py` | Dependency; explicit "do not use" note | Yes (core); n/a | None required |
| atomic-plan-contract | `scripts/dev_tools/module.py` | Example text in a rule description | n/a | None |
| cleanup-merged-worktrees | `scripts/bash/cleanup-worktrees.sh` (allowed-tools + steps 1, 6) and its sourced closure: `cleanup_worktrees_{enumerate,report_records,lib,dirt,actions,detached,preserve,preserve_eol}_lib.sh`, `cleanup_worktrees_scan_helper.sh`; hooks `enforce-*-worktree-removal-gate.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-pr-author-skill.ps1`, `enforce-model-routing-receipt.ps1` | Dependency (10 scripts); hooks are cross-references | **No** | **Violation — relocate** the 10 scripts to `.claude/skills/cleanup-merged-worktrees/scripts/`, mirror into the bundle, list in `core.json` |
| epic-orchestrate | `scripts/orchestration/Invoke-CiGateParser.ps1` ("run the ... procedure"); `.claude/lib/model-routing/ModelRouting.psm1`; `scripts/dev_tools/epic_wave_computation.py`, `validate_epic_orchestrator_state.py`; hooks | Dependency; dependency; citations of reference implementation/validator; cross-references | **No**; yes; n/a | **Violation — relocate** parser to `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (shared with orchestrate) |
| epic-plan | `scripts/dev_tools/epic_wave_computation.py`; hooks | Citation; cross-references | n/a | None |
| feature-review-workflow | `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` | Citation of a validator that does not exist; not invoked | n/a | Out of scope; follow-up **#764** |
| human-exception-runbook | `enforce-evidence-locations.ps1` | Hook cross-reference | n/a | None |
| identify-session-id | `.claude/hooks/persist-session-id.ps1`; inline `pwsh -Command` | Hook cross-reference; inline command, no script | n/a | None |
| invoke-powershell-engineer / invoke-python-engineer | `**/*.ps1`, `**/*.py` globs | Path globs | n/a | None |
| make-skill-template | `helper.py`, `starter.ts` | Template examples | n/a | None |
| mermaid-diagram | `./.claude/lib/mermaid/MermaidValidation.psm1` (Import-Module); `MermaidGrammar.psm1`; hook | Dependency; lib-internal; cross-reference | Yes (core) | None required |
| orchestrate | `scripts/orchestration/Invoke-CiGateParser.ps1` ("Parse the JSON via"); `ModelRouting.psm1`; `scripts/dev_tools/{validate_orchestrator_state,_orchestrator_state_routing,_orchestrator_state_model_routing_gate,compute_complexity_floor,resolve_delegation_model}.py`; hooks | Dependency; dependency; citations of the Python validator authority; cross-references | **No**; yes; n/a | **Violation — relocate** parser to `.claude/lib/ci-gate/` |
| parallel-add | `.claude/lib/blast-radius/BlastRadius.psm1` (Import-Module); `scripts/dev_tools/{compute_blast_radius,_blast_radius_*,_parallel_state_structures,parallel_mutation_protocol}.py` | Dependency; citations | Yes (core); n/a | None required |
| parallel-close | `scripts/dev_tools/parallel_mutation_protocol.py` | Citation | n/a | None |
| parallel-orchestrate | `.claude/lib/bash/{validate-parallel-manifest,compute-concurrency-batches,compute-cohorts}.sh`; `.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1`; `ModelRouting.psm1`; `poetry run python -m scripts.dev_tools.parallel_drift_detection_cli`; other `scripts/dev_tools/*.py`; hooks | Dependencies; dependency; dependency; **dependency**; citations; cross-references | Yes; yes; yes; **No**; n/a | Drift CLI: **violation, not relocatable** (imports the `scripts.dev_tools` package and requires Poetry). Registered as a tracked guard exception; port tracked in **#763** |
| parallel-plan | `.claude/lib/bash/{compute-cohorts,compute-concurrency-batches,report-lane-assertion,validate-parallel-manifest}.sh`; `BlastRadius.psm1`; `scripts/dev_tools/*.py`; hooks | Dependencies; citations; cross-references | Yes (core) | None required |
| parallel-remove | `poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py`; `parallel_mutation_protocol.py`; test file; hook | **Dependency**; citation; citation; cross-reference | **No** | **Violation, not relocatable** (package import, abandon-gate token seam). Tracked guard exception; port tracked in **#763** |
| pr-author | `enforce-pr-author-skill.ps1` | Hook cross-reference | n/a | None |
| translate-copilot-to-claude | `.claude/hooks/*.ps1` and named hooks; inline `pwsh -Command` | Hook cross-references | n/a | None |

## Options considered per violation

### cleanup-merged-worktrees (10 bash scripts)

- **Option A — include `scripts/bash/` in the bundle.** Requires a new `ROOT_FOLDERS` entry in both push-down engines, a new mirrored subtree with its own parity test, and new manifest entries. It would also write upstream-owned files into the consumer-owned `scripts/` tree, where consumer shell QC would lint and cover them without their bats suites, and would overwrite TaskMaster's hand-ported copy on every push-down.
- **Option B — relocate into `.claude/skills/cleanup-merged-worktrees/scripts/` (selected).** Uses the existing mechanism unchanged: `.claude/**` is already published, mirrored, and pack-filtered. Cost: add `.claude/skills` to the shell QC discovery roots and the kcov include pattern (two tokens in `scripts/bash/shell_qc_lib.sh`, one rule-file update), update the bats suites' paths and the shellcheck `source=` directives. The scripts already resolve siblings through `SCRIPT_DIR` / `BASH_SOURCE`, so no sourcing logic changes.
- **Option C — relocate into `.claude/lib/bash/`.** Also bundled and already a QC root, but places single-owner scripts in the shared library, reducing cohesion. Not selected.

### Invoke-CiGateParser.ps1 (shared by orchestrate and epic-orchestrate)

- Relocate to `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (selected). `.claude/lib/` is the established shared runtime location for scripts used by more than one skill; both skills are in `core`, so listing the file in `core.json` bundles it with both. Its Pester suite moves to `tests/scripts/claude-lib/ci-gate/` and the file is added to the coverage path list beside the other `.claude/lib` modules.
- Placing it in the orchestrate skill folder would also be compliant under the bundle definition, but would make epic-orchestrate depend on another skill's private folder. Not selected.

### Python CLIs (parallel-orchestrate, parallel-remove)

- Relocation does not make them functional: each imports sibling modules from the `scripts.dev_tools` package and runs under Poetry, which consumers do not have. Inclusion in the bundle has the same defect. A port to the Python-free destination runtime is required (precedent: `.claude/lib/bash/compute-cohorts.sh`). That is a separate change; tracked in #763. The guard registers both references as explicit, issue-linked exceptions and fails if either exception becomes stale.

## Guard design

- Module `scripts/dev_tools/skill_bundle_contract.py`: pure functions for frontmatter `allowed-tools` parsing, invocation-form reference extraction, and bundle-membership evaluation; a thin loader that reads the real repository, bundle, and manifests; a `main()` CLI.
- Checks per skill: every script dependency resolves to an existing repository file, is present in the extension bundle under a published root folder, and is listed in `core` or every pack that lists the skill; every file inside the skill folder is listed in `core` or every pack that lists the skill.
- The published root folders are held in a Python constant pinned to the TypeScript `ROOT_FOLDERS` by a parity test.
- Tests: unit tests with inline strings (no temporary files) plus a repository-level test that runs the checker against the real tree, which is how CI enforces the rule (`pytest` in the Python CI stage).

## Automation Feasibility

No step requires human interaction. All work is file edits, local toolchain runs (WSL Ubuntu for bash; pwsh for Pester; Poetry for Python), git, and `gh`.
