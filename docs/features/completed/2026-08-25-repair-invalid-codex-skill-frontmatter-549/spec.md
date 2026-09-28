# 2026-08-25-repair-invalid-codex-skill-frontmatter (Spec)

- **Issue:** #549
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-25T13-14
- **Status:** Draft
- **Version:** 0.1

## Context
The Codex-native skill frontmatter in the canonical `.agents/skills/*/SKILL.md`
tree and its bundled mirror must conform to the repository YAML schema. The
root audit reports 23 invalid frontmatter definitions per tree, and the live
hook identifies five additional narrowly scoped body guidance/reference
corrections. Together, these defects prevent reliable skill discovery and
validation.

Environment:
- OS/version: Windows development worktree
- Python version: Not applicable to the target documents
- Command/flags used: Repository skill-frontmatter validation and canonical/bundled byte-parity comparison
- Data source or fixture: 27 unique canonical skill definitions and 27 matched bundled mirrors (54 `SKILL.md` files)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Enumerate all 27 canonical `.agents/skills/*/SKILL.md` definitions and locate their matched bundled mirrors.
2. Parse the YAML frontmatter for every file with the repository validator.
3. Identify the 23 invalid frontmatter definitions in each tree: 12 unsupported `paths` fields, two descriptions containing `: ` that need YAML quotes, and nine descriptions containing angle brackets.
4. Run the live hook and identify the required body corrections in `research-issue`, `orchestrate`, `evidence-and-timestamp-conventions`, `epic-plan`, and `translate-claude-to-codex`.

Expected:
All 27 canonical/bundled pairs (54 files) parse as valid frontmatter, use supported fields, and remain byte-identical across the two trees. The live hook accepts the four evidence-location guidance corrections and the `translate-claude-to-codex` body-reference correction.

Actual:
The validator rejects invalid frontmatter definitions. Prior reports included duplicate `description` fields; the current audit confirms that no duplicate keys remain and identifies the three frontmatter defect categories above. The live hook also rejects five specific body guidance/reference defects.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: Root audit result: 23 invalid frontmatter definitions per tree; live hook scope: 27 matched pairs (54 files) plus five required body guidance/reference corrections.


## Scope & Non-Goals
- In scope: Correct invalid YAML frontmatter in all 27 canonical `.agents/skills/*/SKILL.md` definitions and their 27 matched bundled mirrors; correct the four evidence-location guidance bodies in `research-issue`, `orchestrate`, `evidence-and-timestamp-conventions`, and `epic-plan`; correct the Codex-runtime body reference in `translate-claude-to-codex`.
- Out of scope / non-goals: Changes to skill Markdown bodies other than those five required guidance/reference corrections; workflow behavior, prompt content, agent definitions, schema design, or unpaired files.
- Explicitly excluded systems, integrations, or datasets: External services, published packages, runtime model routing, and any files outside the canonical skill tree and corresponding bundled mirror.

## Root Cause Analysis
The affected documents contain schema-invalid `paths` keys or YAML description values that require quoting or schema-compatible text. No duplicate frontmatter keys remain in the current root audit; the repair must not introduce any. The live hook also requires four body guidance corrections to use canonical evidence-location content and one body reference correction to point to the intended Codex runtime surface.


## Proposed Fix

### Design summary (what changes where):

For each affected canonical skill, remove unsupported frontmatter `paths`
fields and normalize only invalid `description` scalar syntax or values. Apply
the exact resulting file content to the matched bundled mirror so every pair
has byte parity. Separately, correct evidence-location content in
`research-issue`, `orchestrate`, `evidence-and-timestamp-conventions`, and
`epic-plan`, and correct the Codex-runtime body reference in
`translate-claude-to-codex`; mirror each body correction exactly.

### Boundaries and invariants to preserve:

- Preserve each skill's body, intent, mandatory sequencing, artifacts, validation, remediation, and completion gates, except for the five explicitly required body guidance/reference corrections.
- Preserve supported frontmatter fields and their semantics.
- Do not add duplicate keys or replace schema-invalid fields with unapproved alternatives.
- Keep every canonical skill and its matched bundled mirror byte-identical.

### Dependencies or blocked work:

The existing repository skill-frontmatter parser and mirror-parity checks are the validation source. No external dependency or schema change is required.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- All 27 canonical `.agents/skills/*/SKILL.md` files and their 27 corresponding bundled-mirror files.
- The body guidance content of `research-issue`, `orchestrate`, `evidence-and-timestamp-conventions`, and `epic-plan`, plus the body reference in `translate-claude-to-codex`, with each matched mirror updated identically.

#### Functions/classes/CLI commands impacted:

No production functions, classes, or CLI commands change. Existing skill discovery and validation consume the repaired frontmatter.

#### Data flow and validation changes:

The validator reads each YAML frontmatter block, validates it against the supported skill schema, and compares each canonical file to its mirror. The live hook also validates the designated evidence-location guidance and Codex-runtime body reference. The repair updates the 27 pairs so all frontmatter parses and each canonical file compares byte-for-byte to its mirror.

#### Error handling and logging updates:

No application error handling or logging changes are required. Validation output must identify any remaining invalid file or parity mismatch.

#### Rollback/feature-flag considerations (if applicable):

The change is metadata-only and version-controlled. A targeted revert restores a prior skill document if a specific frontmatter correction proves incompatible.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Input: YAML frontmatter delimited by `---` in each `SKILL.md`. Output: frontmatter accepted by the repository schema and canonical/bundled files with byte parity.

#### Required configuration keys and defaults:

Use only the repository-supported skill-frontmatter keys. Do not add `paths`; descriptions requiring special YAML handling must be quoted.

#### Backward-compatibility expectations:

Skill names and supported metadata remain unchanged. Markdown body instructions remain unchanged except for the four evidence-location guidance corrections and one Codex-runtime reference correction required by live validation. Existing callers continue to resolve the same skills after validation succeeds.

#### Performance constraints (latency/throughput/memory):

The repository-wide parse and comparison must complete using the existing validator without introducing additional runtime work.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): Both trees are present locally and contain exactly 27 matched skill pairs (54 files).
- Constraints (budget, performance, compatibility): Restrict edits to invalid YAML frontmatter; retain byte parity and existing skill behavior.
- External dependencies (services, libraries, releases): None.

## Data / API / Config Impact
- User-facing or API changes: None; the repair makes existing skill definitions valid.
- Data or migration considerations: None.
- Logging/telemetry updates (if any): None; use existing validator diagnostics.
- Compatibility notes (CLI flags, config schemas, versioning): Do not change the schema; remove unsupported `paths` keys and use valid YAML description syntax.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: Existing frontmatter parser coverage, plus only targeted coverage if a repository test needs adjustment.
- [ ] Integration scenario to retest: Repository-wide validation of the complete canonical and bundled skill trees.
- [ ] Manual verification notes: Enumerate all 27 matched pairs (54 files), confirm parsing succeeds, compare exact bytes, and confirm live validation accepts all five body corrections.

- Regression tests to add or update: Update only existing validation tests if required to cover the repaired document forms.
- Unit tests (pytest) for the fixed behavior and boundaries: Verify the repository parser accepts every repaired frontmatter block and continues to reject unsupported fields or invalid YAML where covered by existing tests.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): Confirm no duplicate keys, unsupported `paths` fields, unquoted descriptions containing `: `, or unsupported angle-bracket description values remain; confirm each of the five specified body corrections uses the required content or reference.
- Error handling and logging verification: Confirm validation emits no errors for the 27 repaired pairs and five body corrections, and reports a precise file when a deliberate local-only invalid-input check is supported.
- Coverage impact and targets for changed lines/modules: No production code changes; preserve existing validation coverage.
- Toolchain commands to run (format → lint → type-check → test): Run the repository-prescribed validation loop applicable to Markdown and skill-frontmatter changes, ending with repository-wide parse and byte-parity checks.
- Manual validation steps (if required): Inspect the changed frontmatter and five body corrections, then verify canonical/mirror byte parity for all 27 pairs.


## Acceptance Criteria
- [x] Every one of the 27 canonical `.agents/skills/*/SKILL.md` files and its matched bundled mirror (54 files total) has frontmatter that parses successfully under the repository validator.
- [x] The repair removes all 12 unsupported `paths` fields identified by the root audit from both members of each affected pair.
- [x] The repair correctly quotes both descriptions containing `: ` and resolves all nine invalid angle-bracket descriptions in both members of each affected pair.
- [x] No duplicate YAML keys, including `description`, are present in any repaired frontmatter block.
- [x] Each canonical skill and its matched bundled mirror is byte-identical after the repair.
- [x] The evidence-location body guidance in `research-issue`, `orchestrate`, `evidence-and-timestamp-conventions`, and `epic-plan`, and the Codex-runtime body reference in `translate-claude-to-codex`, match live-validator requirements in both mirrors.
- [x] Other than those five explicit body corrections, skill Markdown bodies and their mandatory workflow, evidence, validation, remediation, and completion requirements are unchanged.
- [x] Repository-wide frontmatter parsing and canonical/bundled parity validation complete without errors.

## Risks & Mitigations
- Technical or operational risks: Metadata-only edits could unintentionally alter supported skill metadata, create a new duplicate key, or leave a bundled mirror out of sync.
- Mitigations and rollbacks: Limit changes to frontmatter, parse every file, perform full byte-parity comparison, and revert individual version-controlled document changes if needed.

## Rollout & Follow-up
- Release/rollout steps: Submit the validated metadata repair through the normal repository review process.
- Post-fix monitoring or clean-up tasks: Retain the repository-wide validation result as delivery evidence and investigate any subsequent schema validation reports.
- Links: Issue #549; active feature folder `docs/features/active/2026-08-25-repair-invalid-codex-skill-frontmatter-549/`.
