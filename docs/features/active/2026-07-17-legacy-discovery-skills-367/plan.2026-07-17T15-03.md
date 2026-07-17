# legacy-discovery-skills — Plan

- **Issue:** #367
- **Parent (optional):** Epic `legacy-discovery-and-parity` (child feature #9008, Wave 2, complexity C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T15-03
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Spec:** `docs/features/active/2026-07-17-legacy-discovery-skills-367/spec.md`
- **User Story:** `docs/features/active/2026-07-17-legacy-discovery-skills-367/user-story.md`
- **Research:** `docs/features/active/2026-07-17-legacy-discovery-skills-367/research/2026-07-17-legacy-discovery-skills-research.md`

## Required References

- General Coding Standards: `.claude/rules/general-code-change.md`
- General Unit Test Policy: `.claude/rules/general-unit-test.md`
- Python Standards: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
- Tone Policy: `.claude/rules/tonality.md`

**All work must comply with these policies; do not duplicate their content here.**

## Scope Summary

Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad539c45a0675a010`. All paths below are relative to that root. All commands run from that root.

Deliverables (additive only; no existing file is modified):

1. Seven domain-neutral skills at `.claude/skills/discovery-*/SKILL.md` per the spec `## Skill Decomposition` table.
2. Seven byte-identical bundle copies at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/discovery-*/SKILL.md` (mandatory in-feature per spec Scope Clarification 1; broader publishing remains #9012).
3. One pytest structural-contract module at `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`.

Language toolchains in scope: Python only (the pytest module; skills are Markdown with no command-bearing toolchain). Python has mandatory coverage policy (line >= 85%, branch >= 75%), so baseline and final-QC coverage capture is required.

Evidence location (non-overridable): `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/<kind>/` only (`baseline/`, `qa-gates/`, `other/`). No `artifacts/` evidence paths are used anywhere in this plan.

Shared constraints applied to every skill-authoring task in Phase 1:

- Frontmatter: `name` (exactly matching the folder) and single-quoted `description` required; `allowed-tools` only on `discovery-repo-inventory` and `discovery-validate-artifacts`; no `context`/`agent` frontmatter keys.
- Agent routing via a body-level `## Worker Routing` section (agent-stage skills only).
- Domain neutrality: none of the banned substrings (case-insensitive) `taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management` (also the unhyphenated `task management`) may appear; no stack-specific analyzer is named literally; domain specificity is read from the domain profile via `dev.discovery.profile`.
- Upstream contracts referenced by plain string name only (agent slugs, `dev.discovery.*` console-script names, `schemas/discovery/v1/` schema paths); no upstream file-existence assertions; the full registry lives only in `discovery-workflow`.
- File body under 500 lines; no absolute paths, worktree-specific text, or generated timestamps (the bundle mirror must be a verbatim copy).

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Compliance and Baseline Capture

- [ ] [P0-T1] Read the policy files in the order defined by `policy-compliance-order`: (1) `CLAUDE.md`, (2) `.claude/rules/general-code-change.md`, (3) `.claude/rules/general-unit-test.md`, (4) `.claude/rules/python.md`, (5) `.claude/rules/python-suppressions.md`, (6) `.claude/rules/tonality.md`; then write the evidence artifact `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of files read.
  - Acceptance: The artifact exists at the stated path with all three required fields and lists all six files in the stated order.
- [ ] [P0-T2] Run the Python format-check baseline `poetry run black --check .` and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/baseline/baseline-black-check.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields; `Output Summary:` states the pass/fail result and any files flagged.
- [ ] [P0-T3] Run the Python lint baseline `poetry run ruff check .` and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/baseline/baseline-ruff.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields; `Output Summary:` states the diagnostic count (expected 0 on a clean baseline).
- [ ] [P0-T4] Run the Python type-check baseline `poetry run pyright` and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/baseline/baseline-pyright.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields; `Output Summary:` states the error count (expected 0 on a clean baseline).
- [ ] [P0-T5] Run the Python test-and-coverage baseline `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/baseline/baseline-pytest-cov.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with the numeric baseline line-coverage and branch-coverage percentages and the passed/failed test counts. Placeholders such as `UNVERIFIED` are not permitted.
  - Acceptance: The artifact exists with all four fields and records numeric baseline coverage values (line % and branch %) in `Output Summary:`.
- [ ] [P0-T6] Run the push-down parity gate baseline `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/baseline/baseline-push-down-parity.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: The artifact exists with all four fields; `Output Summary:` records the pre-change pass state of the parity gate (expected passing before new skills are added).

### Phase 1 — Author the Seven Discovery Skills

All tasks in this phase apply the Shared constraints listed in `## Scope Summary`. Content requirements per skill come from the spec `## Skill Decomposition` table and `## Referenced Contracts`.

- [ ] [P1-T1] Create `.claude/skills/discovery-workflow/SKILL.md`: the umbrella sequencing skill with frontmatter `name: discovery-workflow` and a single-quoted `description`; body documents the end-to-end stage order (profile -> inventory -> coverage -> runtime -> parity -> reconciliation -> validation gate) and contains the canonical `## Referenced Contracts` registry enumerating: `dev.discovery.profile` and `discovery-profile.yaml` (#9001); the seven schema paths under `schemas/discovery/v1/` (`feature-contract`, `coverage-ledger`, `runtime-characterization-scenario`, `parity-matrix`, `unspecified-behavior-record`, `product-decision-record`, `evidence-reference`) (#9002); the nine `dev.discovery.validate-*` console scripts (`profile`, `feature-contract`, `coverage-ledger`, `runtime-scenario`, `parity-matrix`, `unspecified-behavior`, `product-decision`, `evidence-reference`, `all`) (#9003); the assumed #9006 inventory command `dev.discovery.inventory`; and the four assumed #9007 agent slugs (`legacy-parity-analyst`, `runtime-characterization-analyst`, `requirements-reconciler`, `migration-coverage-reviewer`) in a routing table. The registry text explicitly flags the #9006 inventory command name and the four #9007 agent slugs as fan-in reconciliation assumptions. (AC-1, AC-2, AC-5)
  - Acceptance: The file exists, frontmatter has `name` matching the folder and a single-quoted `description` with no `allowed-tools`/`context`/`agent` keys, the `## Referenced Contracts` registry contains all names above with both fan-in assumption flags, and the file is under 500 lines.
- [ ] [P1-T2] Create `.claude/skills/discovery-repo-inventory/SKILL.md`: frontmatter `name: discovery-repo-inventory`, single-quoted `description`, and `allowed-tools`; body instructs loading the domain profile via `dev.discovery.profile`, driving the language-neutral inventory analyzer (assumed command `dev.discovery.inventory`, noted as a fan-in assumption whose canonical registry entry lives in `discovery-workflow`) against the profile's `legacy_source.root` and `target.root`, recording outputs under the profile's `artifacts.root`, then running any stack-specific analyzer commands applicable to the profile's `technology_stack` as documented by the analyzer framework (no stack-specific analyzer named literally); names validators `dev.discovery.validate-profile` and `dev.discovery.validate-evidence-reference` and references `discovery-workflow` and `discovery-validate-artifacts` by name. (AC-1, AC-2, AC-4, AC-5)
  - Acceptance: The file exists with the stated frontmatter (including `allowed-tools`), contains the fragments `dev.discovery.profile`, `dev.discovery.inventory`, `legacy_source.root`, `target.root`, `artifacts.root`, `technology_stack`, `dev.discovery.validate-profile`, `dev.discovery.validate-evidence-reference`, contains no `## Worker Routing` section, and is under 500 lines.
- [ ] [P1-T3] Create `.claude/skills/discovery-coverage-ledger/SKILL.md`: frontmatter `name: discovery-coverage-ledger` and single-quoted `description` only; body covers producing feature contracts and the coverage ledger from inventory output per schemas `feature-contract` and `coverage-ledger`, with a `## Worker Routing` section naming agent slug `migration-coverage-reviewer`, and names validators `dev.discovery.validate-feature-contract` and `dev.discovery.validate-coverage-ledger`; references `discovery-workflow` and `discovery-validate-artifacts` by name. (AC-1, AC-2)
  - Acceptance: The file exists with `name`/`description`-only frontmatter, contains a `## Worker Routing` section naming `migration-coverage-reviewer`, contains the schema and validator names above, and is under 500 lines.
- [ ] [P1-T4] Create `.claude/skills/discovery-runtime-characterization/SKILL.md`: frontmatter `name: discovery-runtime-characterization` and single-quoted `description` only; body covers producing runtime characterization scenarios and evidence references per schemas `runtime-characterization-scenario` and `evidence-reference`, with a `## Worker Routing` section naming agent slug `runtime-characterization-analyst`, and names validators `dev.discovery.validate-runtime-scenario` and `dev.discovery.validate-evidence-reference`; references `discovery-workflow` and `discovery-validate-artifacts` by name. (AC-1, AC-2)
  - Acceptance: The file exists with `name`/`description`-only frontmatter, contains a `## Worker Routing` section naming `runtime-characterization-analyst`, contains the schema and validator names above, and is under 500 lines.
- [ ] [P1-T5] Create `.claude/skills/discovery-parity-matrix/SKILL.md`: frontmatter `name: discovery-parity-matrix` and single-quoted `description` only; body covers producing/refreshing the parity matrix (schema `parity-matrix`, consuming `feature-contract` and `runtime-characterization-scenario`), with a `## Worker Routing` section naming agent slug `legacy-parity-analyst`, and names validator `dev.discovery.validate-parity-matrix`; references `discovery-workflow` and `discovery-validate-artifacts` by name. (AC-1, AC-2)
  - Acceptance: The file exists with `name`/`description`-only frontmatter, contains a `## Worker Routing` section naming `legacy-parity-analyst`, contains the schema and validator names above, and is under 500 lines.
- [ ] [P1-T6] Create `.claude/skills/discovery-behavior-reconciliation/SKILL.md`: frontmatter `name: discovery-behavior-reconciliation` and single-quoted `description` only; body covers capturing unspecified/contradictory behavior and reconciling into product decisions per schemas `unspecified-behavior-record` and `product-decision-record`, with a `## Worker Routing` section naming agent slug `requirements-reconciler`, and names validators `dev.discovery.validate-unspecified-behavior` and `dev.discovery.validate-product-decision`; references `discovery-workflow` and `discovery-validate-artifacts` by name. (AC-1, AC-2)
  - Acceptance: The file exists with `name`/`description`-only frontmatter, contains a `## Worker Routing` section naming `requirements-reconciler`, contains the schema and validator names above, and is under 500 lines.
- [ ] [P1-T7] Create `.claude/skills/discovery-validate-artifacts/SKILL.md`: frontmatter `name: discovery-validate-artifacts`, single-quoted `description`, and `allowed-tools`; body is the canonical validation-gate mechanics: running each of the nine `dev.discovery.validate-*` console scripts after its owning stage, `dev.discovery.validate-all` as the workflow completion gate, pass/fail semantics (each validator yields a `list[str]` of errors; empty list is a pass), and direction back to the owning stage skill on failure; lists all seven `schemas/discovery/v1/` schemas as validation targets. (AC-1, AC-2)
  - Acceptance: The file exists with the stated frontmatter (including `allowed-tools`), names all nine `dev.discovery.validate-*` scripts and all seven schema names, documents the empty-error-list pass semantics, contains no `## Worker Routing` section, and is under 500 lines.
- [ ] [P1-T8] Verify domain neutrality of the seven new skill files by running a case-insensitive search for the banned substrings (`taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`, `task management`) across `.claude/skills/discovery-*/SKILL.md` and correcting any hit before proceeding. (AC-4)
  - Acceptance: The case-insensitive search over the seven files at `.claude/skills/discovery-workflow/SKILL.md`, `.claude/skills/discovery-repo-inventory/SKILL.md`, `.claude/skills/discovery-coverage-ledger/SKILL.md`, `.claude/skills/discovery-runtime-characterization/SKILL.md`, `.claude/skills/discovery-parity-matrix/SKILL.md`, `.claude/skills/discovery-behavior-reconciliation/SKILL.md`, `.claude/skills/discovery-validate-artifacts/SKILL.md` returns zero matches.
- [ ] [P1-T9] Verify name non-collision and line caps for the seven new skills: confirm no new skill folder name equals any of the 40 pre-existing `.claude/skills/` directory names, any `code-modernization` `/modernize-*` command name (modernize-assess, modernize-brief, modernize-extract-rules, modernize-harden, modernize-map, modernize-preflight, modernize-reimagine, modernize-status, modernize-transform, modernize-uplift), or any `code-modernization` agent name (legacy-analyst, business-rules-extractor, architecture-critic, scaffolder, security-auditor, test-engineer, version-delta-analyst); confirm each of the seven `SKILL.md` files is under 500 lines. (AC-3, AC-9)
  - Acceptance: All seven names are absent from all three collision sets and every file's line count is < 500.

### Phase 2 — Bundle Byte-Copies

- [ ] [P2-T1] Copy `.claude/skills/discovery-workflow/SKILL.md` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/discovery-workflow/SKILL.md`. (AC-7)
  - Acceptance: The destination file exists and its bytes are identical to the source file.
- [ ] [P2-T2] Copy `.claude/skills/discovery-repo-inventory/SKILL.md` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/discovery-repo-inventory/SKILL.md`. (AC-7)
  - Acceptance: The destination file exists and its bytes are identical to the source file.
- [ ] [P2-T3] Copy `.claude/skills/discovery-coverage-ledger/SKILL.md` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/discovery-coverage-ledger/SKILL.md`. (AC-7)
  - Acceptance: The destination file exists and its bytes are identical to the source file.
- [ ] [P2-T4] Copy `.claude/skills/discovery-runtime-characterization/SKILL.md` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/discovery-runtime-characterization/SKILL.md`. (AC-7)
  - Acceptance: The destination file exists and its bytes are identical to the source file.
- [ ] [P2-T5] Copy `.claude/skills/discovery-parity-matrix/SKILL.md` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/discovery-parity-matrix/SKILL.md`. (AC-7)
  - Acceptance: The destination file exists and its bytes are identical to the source file.
- [ ] [P2-T6] Copy `.claude/skills/discovery-behavior-reconciliation/SKILL.md` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/discovery-behavior-reconciliation/SKILL.md`. (AC-7)
  - Acceptance: The destination file exists and its bytes are identical to the source file.
- [ ] [P2-T7] Copy `.claude/skills/discovery-validate-artifacts/SKILL.md` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/discovery-validate-artifacts/SKILL.md`. (AC-7)
  - Acceptance: The destination file exists and its bytes are identical to the source file.
- [ ] [P2-T8] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` to verify the parity gate passes with the new skills and copies in place, and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/other/push-down-parity-postcopy.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. (AC-7)
  - Acceptance: `EXIT_CODE: 0` and the artifact exists at the stated path with all four fields.

### Phase 3 — Structural Contract Test Module

The module follows the text-fragment contract precedent in `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py` (module-level `REPO_ROOT`, `read_repo_text` helper, tuples of literal required fragments, byte-parity assertion against `extensions/drm-copilot/resources/claude-customizations/`). It asserts only on this feature's own files — never on #9006/#9007 artifact existence. The completed file stays under 500 lines.

- [ ] [P3-T1] Create `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` with the module docstring, `REPO_ROOT`/bundle-root constants, a `read_repo_text` helper, the frozen tuple of the seven skill relative paths, the frozen banned-substring set, and the frozen `code-modernization` command/agent name set; add the existence-and-frontmatter tests asserting for each of the seven skills that `SKILL.md` exists at `.claude/skills/<name>/SKILL.md`, that `name: <name>` matches the folder, and that a non-empty `description:` line is present. (AC-6)
  - Acceptance: The file exists, is importable, and `poetry run pytest tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` collects and passes the existence/frontmatter tests.
- [ ] [P3-T2] Add to `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` the required-fragment tests asserting per skill the literal body fragments from the decomposition table: the four `## Worker Routing` agent-slug pairings (`discovery-coverage-ledger` -> `migration-coverage-reviewer`, `discovery-runtime-characterization` -> `runtime-characterization-analyst`, `discovery-parity-matrix` -> `legacy-parity-analyst`, `discovery-behavior-reconciliation` -> `requirements-reconciler`); the `dev.discovery.*` command names per skill (including `dev.discovery.profile`, `dev.discovery.inventory`, the per-stage `dev.discovery.validate-*` names, and `dev.discovery.validate-all` in the umbrella and gate skills); the `schemas/discovery/v1/` schema references per skill; and the `## Referenced Contracts` registry plus both fan-in assumption flags in `discovery-workflow`. (AC-5, AC-6)
  - Acceptance: The added tests pass in `poetry run pytest tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`.
- [ ] [P3-T3] Add to `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` the domain-neutrality test asserting the case-insensitive absence of every banned substring (`taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`, `task management`) from each of the seven skill texts, and the non-collision test asserting no new skill name appears in the frozen `code-modernization` command/agent name set. (AC-3, AC-4, AC-6)
  - Acceptance: The added tests pass in `poetry run pytest tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`.
- [ ] [P3-T4] Add to `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` the bundle byte-parity test asserting each of the seven skill files is byte-identical to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/<name>/SKILL.md`, following the mirroring-assertion pattern of `test_discovery_fix_is_mirrored_into_bundled_payload` in `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py`; verify the completed module is under 500 lines. (AC-6, AC-7, AC-9)
  - Acceptance: The added test passes in `poetry run pytest tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` and the module line count is < 500.

### Phase 4 — Final QA Loop

Run the full Python toolchain in order (format -> lint -> type-check -> test with coverage). If any step fails or changes files, fix the cause and restart the loop from P4-T1; the recorded artifacts must come from the final clean pass. `EXIT_CODE: SKIPPED` is not a valid outcome for any task in this phase.

- [ ] [P4-T1] Run `poetry run black .` and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-black.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If any file is reformatted, restart the loop from P4-T1 after the change. (AC-9)
  - Acceptance: `EXIT_CODE: 0` on the final pass with zero files changed, recorded in the artifact.
- [ ] [P4-T2] Run `poetry run ruff check .` and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-ruff.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. On failure, remediate and restart from P4-T1. (AC-9)
  - Acceptance: `EXIT_CODE: 0` with zero diagnostics, recorded in the artifact.
- [ ] [P4-T3] Run `poetry run pyright` and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-pyright.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. On failure, remediate and restart from P4-T1. (AC-9)
  - Acceptance: `EXIT_CODE: 0` with zero errors, recorded in the artifact.
- [ ] [P4-T4] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` (full suite, coverage mode) and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-pytest-cov.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with the numeric post-change line-coverage and branch-coverage percentages and the passed/failed test counts. Placeholders are not permitted. On failure, remediate and restart from P4-T1. (AC-9)
  - Acceptance: `EXIT_CODE: 0`, all tests pass, and the artifact records numeric post-change coverage values (line % and branch %).
- [ ] [P4-T5] Run the two gate suites explicitly — `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` — and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-contract-gates.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with the per-module passed test counts. (AC-6, AC-7)
  - Acceptance: `EXIT_CODE: 0` and the artifact records both modules passing.
- [ ] [P4-T6] Verify coverage no-regression: compare the P0-T5 baseline coverage values against the P4-T4 post-change values and write `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-coverage-delta.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:`, the numeric baseline line/branch percentages, the numeric post-change line/branch percentages, the delta, and the statement that this feature adds no production Python code (only a test module), so the coverage denominator is unchanged and new-code coverage is not applicable. Post-change line coverage must remain >= 85% and branch coverage >= 75% with no regression from baseline; if either condition fails, the outcome is remediation-required, not PASS. (AC-9)
  - Acceptance: The artifact exists with all numeric values (no placeholders) and confirms thresholds and no-regression, or records a remediation-required outcome.
- [ ] [P4-T7] Verify acceptance-criteria traceability: for each of AC-1 through AC-9 in `docs/features/active/2026-07-17-legacy-discovery-skills-367/spec.md`, record the satisfying task IDs and evidence artifact paths in `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/qa-gates/final-qc-ac-traceability.<yyyy-MM-ddTHH-mm>.md` containing `Timestamp:` and one row per AC.
  - Acceptance: The artifact exists and every AC row cites at least one completed task ID and, where applicable, an evidence artifact path; any unsatisfied AC is recorded as remediation-required.

## Acceptance-Criteria Traceability

| Spec AC | Satisfying tasks |
|---|---|
| AC-1 (seven skills sequence the workflow) | P1-T1 .. P1-T7 |
| AC-2 (frontmatter contract; plain-string references; `## Worker Routing`) | P1-T1 .. P1-T7 |
| AC-3 (name non-collision, frozen-set test) | P1-T9, P3-T3 |
| AC-4 (domain neutrality, banned substrings, profile-driven) | P1-T2, P1-T8, P3-T3 |
| AC-5 (upstream reference isolation; fan-in assumption flags) | P1-T1, P1-T2, P3-T2 |
| AC-6 (contract test module exists and passes) | P3-T1 .. P3-T4, P4-T5 |
| AC-7 (bundle byte-parity; push-down gate passes) | P2-T1 .. P2-T8, P3-T4, P4-T5 |
| AC-8 (scope clarification recorded in spec) | Already recorded in `spec.md` Scope Clarification 1; confirmed via P4-T7 traceability check |
| AC-9 (500-line caps; Python toolchain passes; no coverage reduction) | P1-T9, P3-T4, P4-T1 .. P4-T6 |

## Test Plan

- Unit/contract: `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` (existence, frontmatter, required fragments, banned-substring absence, plugin-name non-collision, bundle byte-parity), asserting only on this feature's own files.
- Regression gate: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (always-on `.claude/**` bundle parity).
- Full suite: `poetry run pytest --cov --cov-branch --cov-report=term-missing` at baseline (P0-T5) and final QC (P4-T4).
- Coverage evidence: baseline artifact `evidence/baseline/baseline-pytest-cov.<yyyy-MM-ddTHH-mm>.md`; post-change artifact `evidence/qa-gates/final-qc-pytest-cov.<yyyy-MM-ddTHH-mm>.md`; comparison artifact `evidence/qa-gates/final-qc-coverage-delta.<yyyy-MM-ddTHH-mm>.md` (all under `docs/features/active/2026-07-17-legacy-discovery-skills-367/`). No production Python code is added, so the coverage denominator is unchanged; numeric values are still required at both capture points.

## Open Questions / Notes

- The #9006 inventory command name (`dev.discovery.inventory`) and the four #9007 agent slugs are fan-in reconciliation assumptions (spec `## Referenced Contracts`); they are isolated to the `discovery-workflow` registry plus one fragment in `discovery-repo-inventory`, and the contract tests never assert upstream artifact existence.
- Per spec Scope Clarification 1, the bundle byte-copy (Phase 2) is in-feature; broader `resources/` publishing (pack manifests, converter registration, `.github`/`.agents` mirrors) remains #9012.
- Skills are Markdown; no formatter/linter/type-checker stage applies to them. The Python toolchain loop applies because of the new test module.
