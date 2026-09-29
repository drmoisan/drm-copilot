# skill-referenced-scripts-not-bundled (Spec)

- **Issue:** #762
- **Parent (optional):** none
- **Owner:** Dan Moisan
- **Last Updated:** 2026-09-28T19-20
- **Status:** Approved
- **Version:** 1.0

## Context
Skills distributed by push-down reference scripts that are not included in the skill's bundle, so the skill is non-functional in consumer repositories. Rule: every script a skill references must be bundled with the skill (included in the push-down payload that carries the skill), regardless of the script's folder location.

Research and full audit table: `research/2026-09-28T19-15-skill-bundle-audit-research.md`.

Impact / Severity: High.

## Repro & Evidence
Steps to Reproduce:
1. Push down the Claude customizations into a consumer repository.
2. Invoke the `cleanup-merged-worktrees` skill in the consumer.
3. The skill runs `bash scripts/bash/cleanup-worktrees.sh`, which the bundle does not carry.

Expected: every script a skill invokes ships in the push-down payload together with the skill.

Actual: `cleanup-merged-worktrees` (10 bash scripts), `orchestrate` and `epic-orchestrate` (`Invoke-CiGateParser.ps1`), `parallel-orchestrate` and `parallel-remove` (Python CLIs) invoke scripts outside the bundle.

## Scope & Non-Goals
- In scope:
  - Audit of all skills under `.claude/skills/**` (recorded in the research artifact).
  - Bundling the cleanup-worktrees scripts and the CI gate parser with the skills that invoke them.
  - Shell QC discovery and kcov coverage for bash scripts that live under `.claude/skills/`.
  - An automated guard, run by pytest in CI, that fails when a skill references a script that is not in that skill's bundle, and that also checks every file inside a skill folder is carried by the skill's packs.
- Out of scope / non-goals:
  - Porting the two Python CLIs used by `parallel-orchestrate` and `parallel-remove` (tracked in #763; registered as explicit guard exceptions).
  - The nonexistent `Test-ModifiedWorkflowNeedsGreenRun.ps1` citation and the Python/TypeScript `ROOT_FOLDERS` divergence (tracked in #764).
  - Agents, hooks, and rules (the rule governs skills).
- Explicitly excluded systems: consumer repositories (fixed by the next push-down).

## Root Cause Analysis
The bundle publishes `.claude/**` and `config/**` from `extensions/drm-copilot/resources/claude-customizations/`, filtered by pack manifests. The affected scripts live under `scripts/**`, which is never published, and no automated check ties a skill's script references to the bundle. The existing pack completeness test checks only `SKILL.md`, not other files in a skill folder.

## Proposed Fix

### Design summary (what changes where):
- `git mv scripts/bash/cleanup-worktrees.sh` and its nine sourced libraries to `.claude/skills/cleanup-merged-worktrees/scripts/`; update `SKILL.md` prose and `allowed-tools`; update shellcheck `source=` directives and path comments; update the 16 bats suites and fixture stubs that name the old path; add the files to the bundle mirror and `core.json`.
- `git mv scripts/orchestration/Invoke-CiGateParser.ps1` to `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`; move its Pester suite to `tests/scripts/claude-lib/ci-gate/`; add a core-manifest membership test; add the file to the Pester coverage path list; update `orchestrate` and `epic-orchestrate`; add to the bundle mirror and `core.json`.
- `scripts/bash/shell_qc_lib.sh`: add `.claude/skills` to the discovery roots and the kcov include pattern; add a discovery bats case and fixture; update `.claude/rules/shell.md`.
- New `scripts/dev_tools/skill_bundle_contract.py` with tests `tests/scripts/dev_tools/test_skill_bundle_contract.py` (units) and `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` (repository guard).

### Boundaries and invariants to preserve:
- Script behavior is unchanged; only locations and path strings change.
- Bundle mirror stays byte-identical to `.claude/**`.
- No new dependencies; no temporary files in tests.

### Dependencies or blocked work:
- None. #763 and #764 are independent follow-ups.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
See design summary; historical docs under `docs/features/**` that name the old paths are records and are not rewritten.

#### Functions/classes/CLI commands impacted:
- `discover_shell_scripts`, `run_bats_coverage` include pattern in `shell_qc_lib.sh`.
- New: `parse_allowed_tools`, `extract_script_references`, `evaluate_skill_bundle`, `load_repository_inputs`, `find_violations`, `main` in `skill_bundle_contract.py`.

#### Data flow and validation changes:
The guard reads `.claude/skills/*/SKILL.md`, the bundle file list, and `pack-manifests/*.json`, and reports one violation per (skill, path, reason).

#### Error handling and logging updates:
The CLI prints one line per violation to stderr and exits 1; exits 0 when clean.

#### Rollback/feature-flag considerations (if applicable):
Revert the PR; consumers keep whatever payload they last received.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
`SkillBundleViolation(skill, path, reason)`; reasons: `missing-file`, `not-in-bundle`, `not-in-skill-pack`.

#### Required configuration keys and defaults:
`PUBLISHED_ROOT_FOLDERS = (".claude", "config")`, pinned to the TypeScript `ROOT_FOLDERS` by test. `KNOWN_UNBUNDLED_REFERENCES` holds the two #763 exceptions.

#### Backward-compatibility expectations:
`bash scripts/bash/cleanup-worktrees.sh` no longer exists; the invocation is `bash .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh`. This is called out in the PR.

#### Performance constraints (latency/throughput/memory):
Guard runs in well under one second.

## Assumptions, Constraints, Dependencies
- Assumptions: WSL Ubuntu provides shfmt/shellcheck/bats/kcov locally; CI versions are canonical.
- Constraints: files <= 500 lines.
- External dependencies: none added.

## Data / API / Config Impact
- User-facing changes: the cleanup-worktrees command path changes (skill text updated accordingly).
- Compatibility notes: consumers pick up the relocated scripts on the next push-down.

## Test Strategy
- Regression test: `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled` fails before the fix and passes after.
- Unit tests for extraction (each invocation form, placeholders, globs, citations ignored), bundle evaluation (each reason, pack-specific skills, core), exception staleness, CLI exit codes.
- Existing bats suites for cleanup-worktrees pass from the new path; new bats discovery case for `.claude/skills`.
- Pester: moved CI gate parser suite passes; new manifest membership test.
- Toolchain: shell (shfmt -> shellcheck -> bats+kcov), PowerShell (PoshQC format -> analyze -> test), Python (black -> ruff -> pyright -> pytest with coverage).

## Acceptance Criteria
- [x] AC1: The audit table covering every skill is recorded in the research artifact.
- [x] AC2: `cleanup-merged-worktrees` invokes only scripts that are in its bundle (relocated under `.claude/skills/cleanup-merged-worktrees/scripts/`, mirrored, listed in `core.json`), and the skill text and `allowed-tools` name the bundled paths.
- [x] AC3: `orchestrate` and `epic-orchestrate` reference `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, which is mirrored and listed in `core.json`.
- [x] AC4: No remaining caller in the repository (skills, hooks, tests, CI, config, rules) points at the old script paths, excluding historical feature records.
- [x] AC5: Shell QC discovers, lints, tests, and measures coverage for bash scripts under `.claude/skills/`.
- [x] AC6: A CI-run guard fails when a skill references a script not in its bundle, does not fail because a script lives outside the skill folder, and checks every file in a skill folder is carried by the skill's packs.
- [x] AC7: The two unfixable Python CLI references are registered as issue-linked exceptions (#763) and the guard fails if an exception becomes stale.
- [x] AC8: Full toolchain passes for bash, PowerShell, and Python with coverage thresholds met.

## Risks & Mitigations
- Consumer muscle memory for the old path: the skill text is the only documented entry point and is updated.
- Heuristic reference extraction could miss an unusual invocation form: forms are enumerated from the audit, each has a unit test, and the extractor is extensible.

## Rollout & Follow-up
- Release: normal merge; next push-down delivers the relocated scripts.
- Follow-ups: #763, #764.
- Links: issue #762.
