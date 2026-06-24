# relocate-research-canonical-location - Refactor Spec

- **Issue:** #227
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24T13-09
- **Status:** Draft
- **Version:** 0.2

## Intent & Outcomes

### Problem Statement

The research step of orchestration writes research files to `artifacts/research/`. The repository `.gitignore` ignores `artifacts` (line 6, a bare entry that matches the `artifacts/` tree at any depth), so research output is never tracked in version control. Research artifacts contain substantive findings (current-state analysis, candidate approaches, requirements mapping, file inventories) that are valuable to retain alongside the feature they support. Because the path is under the ignored `artifacts/` tree, these findings are lost on every clean checkout.

### Motivation

Research output that supports a feature should be durable and versioned alongside that feature. The fix is to relocate the canonical research output to two git-tracked roots under `docs/` and to update every enforcement point, instruction surface, agent write-path allowlist, and test that currently assumes `artifacts/research/`, consistently across the Claude, Codex, and GitHub Copilot ecosystems and their bundled extension copies.

### Outcomes

1. Feature-associated research is written to `<FEATURE>/research/<timestamp>-<short-name>-research.md` (for example `docs/features/active/<feature>/research/<timestamp>-<short-name>-research.md`).
2. One-off research not associated with a feature is written to `docs/research/<timestamp>-<short-name>-research.md`.
3. `artifacts/research/` is no longer the canonical target and is rejected by the enforcement hooks and the Python evidence-location validator.
4. Both tracked research roots resolve to git-tracked paths (not under the ignored `artifacts/` tree).

## Invariants (must not change)

- **Filename convention:** The timestamp-and-name filename convention is preserved. Files continue to use `<timestamp>-<short-name>-research.md`, where `<timestamp>` uses the existing `yyyy-MM-ddTHH-mm` format (for example `2026-06-24T13-02`). The validating regex `^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$` operates on the filename only and does not change.
- **`research-path` reporting token:** The `SubagentStop` inline hook regex in `.claude/settings.json` accepts the `research-path` token regardless of the path value. This token remains the contract; no functional change to the regex is required.
- **`enforce-evidence-locations` exclusion-only model:** The hook continues to use an exclusion-only model (forbidden-prefix list; paths not on the list pass through). The model itself does not change; only the forbidden-prefix membership and docstring change.
- **Evidence-location enforcement for non-research paths:** Enforcement behavior for all non-research evidence paths (baselines, QA gates, coverage, regression results) remains unchanged.
- **Performance characteristics:** No performance-sensitive behavior is involved. Hook and validator execution remain string/regex operations with no measurable latency change expected.
- **Compatibility guarantees:** No CLI flags, config schemas, or versioned external interfaces are altered. The change is a relocation of a path contract within the customization/enforcement layer.

## Scope (structural changes)

Change the canonical research output location across all three customization ecosystems (Claude, Codex, GitHub Copilot), including bundled extension copies, so research is persisted in tracked locations:

- Feature-associated research: `docs/features/active/<feature>/research/<timestamp>-<short-name>-research.md`.
- One-off research: `docs/research/<timestamp>-<short-name>-research.md`.

The validation hooks, agent write-path allowlists, skills, prompts, and tests that currently assume `artifacts/research/` must be updated to the new contract consistently across ecosystems and their bundled copies.

### In-Scope File Inventory (by ecosystem)

**Claude ecosystem (root):**
- `.claude/agents/task-researcher.md` — frontmatter `tools` write allowlist, description metadata, and body output-location prose.
- `.claude/agents/orchestrator.md` — delegation prose referencing the research output path.
- `.claude/skills/research-issue/SKILL.md` — output-path prose and description metadata.
- `.claude/skills/orchestrate/SKILL.md` — delegation prose and the `artifacts/research/` entry in the Evidence Location Authority permitted-sub-path list.
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — `artifacts/research/` entry in the allowed `artifacts/` sub-paths list (to be removed; research is no longer an `artifacts/` path).
- `.claude/hooks/validate-task-researcher-output.ps1` — `Test-IsUnderResearchRoot` root-check logic and three hard-coded `artifacts/research/` error messages.
- `.claude/hooks/enforce-evidence-locations.ps1` — docstring/allowed-path documentation update, plus addition of `artifacts/research/` to the forbidden-prefix set.
- `.claude/settings.json` — no functional change required (`research-path` token and `Write(/artifacts/**)` orchestrator allowlist are unaffected); update any descriptive text if present.

**Claude ecosystem (bundled copy — content verified byte-for-byte identical to root):**
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/research-issue/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`

**Codex ecosystem (bundled):**
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/task-researcher.toml` — embedded write allowlist (`"Write(/artifacts/research/**)"`), embedded body prose (mirrors the Claude agent), and the stop-hook text that confirms the artifact path under `artifacts/research/`.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml` — delegation prose in `developer_instructions`.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1` — docstring update (mirrors the Claude hook).
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/research-issue/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md`

**GitHub Copilot ecosystem (root):**
- `.github/agents/task-researcher.agent.md` — role-definition prose, operational constraint, and collaborative-process references that describe `artifacts/research/` as the (untracked) scratch area.
- `.github/prompts/research-issue.prompt.md` — output-path prose, filename-convention example, and operating-rules reference.
- `.github/prompts/fillout-prd-feature.prompt.md` — research-path reference that instructs callers to include research file paths under `artifacts/research`.

**GitHub Copilot ecosystem (bundled copy — content verified identical to root):**
- `extensions/drm-copilot/resources/customizations/.github/agents/task-researcher.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/prompts/research-issue.prompt.md`
- `extensions/drm-copilot/resources/customizations/.github/prompts/fillout-prd-feature.prompt.md`

**Hooks (called out for testing emphasis):**
- `.claude/hooks/validate-task-researcher-output.ps1` and its bundled mirror.
- `.claude/hooks/enforce-evidence-locations.ps1`, its Claude bundled mirror, and the Codex bundled copy.

**Validators (Python):**
- `scripts/dev_tools/validate_evidence_locations.py` — `_FORBIDDEN_PREFIX_TO_CANONICAL` dict; add `artifacts/research/` with a canonical suggestion pointing to the two new roots.

**Tests:**
- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`
- `tests/scripts/dev_tools/test_validate_evidence_locations.py`

## Non-Goals

- **Migrating existing historical `artifacts/research/` files.** Existing archived research under `artifacts/research/` is historical and is not migrated, moved, or rewritten by this change.
- **Changing `.gitignore`.** No `.gitignore` modification is required. `docs/` is already tracked, so `docs/features/active/` and `docs/research/` are tracked by default. The `artifacts` entry remains unchanged.
- **Updating historical feature documents.** Plan files, feature-audit files, and archive documents that reference `artifacts/research/` as context are historical records, not enforcement or instruction files, and are out of scope.
- **Updating generated files.** `testResults.xml` and similar generated outputs are not authored and are out of scope.
- **Re-architecting the research workflow.** This is a relocation of a path contract, not a new behavioral system. No redirect shim, new routing service, or architectural redesign is introduced.

## Dependencies / Touchpoints

- **Cross-ecosystem mirrors:** Each root Claude and GitHub Copilot file has a bundled mirror under `extensions/drm-copilot/resources/`. The root copy is the source of truth; the bundled copy must remain identical after the change.
- **Codex translation:** The Codex `.toml` agents and `.agents/skills/` files are separate translations with no root-repo counterpart. The `translate-claude-to-codex` skill is the documented propagation mechanism. The Codex `task-researcher.toml` embeds the Claude agent frontmatter and body verbatim inside `developer_instructions` and also contains a stop-hook body that references `artifacts/research/` directly; both the embedded sections and the stop-hook body must be updated as part of this change.
- **Orchestrator routing input:** The orchestrator determines which research root to use before delegating to `task-researcher`, based on whether an active feature folder is in scope (`feature-folder` in `artifacts/orchestration/orchestrator-state.json`). The resolved output path is passed in the delegation prompt; the `task-researcher` agent does not infer the feature folder independently.
- **Documentation:** `docs/engineering/claude-code-architecture.md` references `artifacts/research/` in an architectural description. It should be updated for accuracy but is not a blocking enforcement concern.
- **Required coordination:** None outside this repository. No CI/CD configuration or release tooling depends on the research output path.

## Risks & Mitigations

- **Risk: cross-ecosystem divergence.** The change is contract-wide and must remain consistent across the three ecosystems and their bundled copies; divergence is a regression. **Mitigation:** apply identical edits to each root file and its bundled mirror, and verify content equality after editing; propagate Claude-side changes to the Codex translations.
- **Risk: weakened enforcement.** Hook regexes and agent write-path allowlists must accept two distinct roots without weakening evidence-location enforcement. **Mitigation:** the dual-root acceptance check in `Test-IsUnderResearchRoot` is explicit (feature-folder path with a `/research/` segment, or `docs/research/`), and `artifacts/research/` is added to the forbidden-prefix set in both the PowerShell hook and the Python validator. Negative tests confirm rejection of the old path and of malformed paths.
- **Risk: backward compatibility with archived research.** Existing archived research under `artifacts/research/` is historical and is not migrated. **Mitigation:** this is an explicit non-goal; historical references in feature documents are left unchanged.
- **Risk: filename-convention regression.** The filename convention must remain valid under the new roots. **Mitigation:** the filename regex is unchanged and operates on the filename only; tests assert filename-convention enforcement under both new roots.

## Technical Specifications

### Two-root research contract

**Feature-associated research (orchestration context):**
```
docs/features/active/<feature>/research/<timestamp>-<short-name>-research.md
```
Example: `docs/features/active/2026-06-24-relocate-research-canonical-location-227/research/2026-06-24T13-02-relocate-research-canonical-location-227-research.md`

**One-off research (no associated feature):**
```
docs/research/<timestamp>-<short-name>-research.md
```
Example: `docs/research/2026-06-24T14-00-codex-native-ecosystem-research.md`

No `docs/research/` directory currently exists; it is created by the first research file written there (or a `.gitkeep`).

### Filename convention (preserved)

```
<timestamp>-<short-name>-research.md
```
`<timestamp>` uses `yyyy-MM-ddTHH-mm`. The validating regex `^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$` is unchanged.

### Hook acceptance/rejection logic

`Test-IsUnderResearchRoot` in `validate-task-researcher-output.ps1` is rewritten to accept either root. Implementation approach: normalize the path to forward slashes, then accept when the path `StartsWith('docs/features/')` and contains a `/research/` segment after the feature folder, OR when the path `StartsWith('docs/research/')`. Both checks are case-insensitive. Acceptance/rejection matrix:

```
Accepted: docs/features/**/research/<timestamp>-<short-name>-research.md
Accepted: docs/research/<timestamp>-<short-name>-research.md
Rejected: artifacts/research/...
Rejected: docs/features/**/<file>  (no /research/ segment)
Rejected: any other path
```

The three error messages in the hook that currently hard-code `artifacts/research/` (the root-mismatch message, the missing `research-path` guidance, and the filename-convention message) are updated to reference the two new roots.

`enforce-evidence-locations.ps1` requires no logic change to its exclusion-only model. `artifacts/research/` is added to the forbidden-prefix set so that:
- Block: `artifacts/research/...`
- Allow: `docs/features/**/research/...`
- Allow: `docs/research/...`

The docstring/allowed-path documentation in the hook is updated to remove `artifacts/research/` from the permitted set.

`scripts/dev_tools/validate_evidence_locations.py` adds `artifacts/research/` to the `_FORBIDDEN_PREFIX_TO_CANONICAL` dict with a canonical suggestion pointing to the two new roots. Previously `artifacts/research/` was allowed by omission.

### Agent write-path allowlist forms

**Claude `.md` frontmatter — current:**
```yaml
tools:
  - "Write(/artifacts/research/**)"
```
**Claude `.md` frontmatter — required new form:**
```yaml
tools:
  - "Write(/docs/features/**/research/**)"
  - "Write(/docs/research/**)"
```

**Codex `.toml` embedded frontmatter — current:**
```
"Write(/artifacts/research/**)"
```
**Codex `.toml` embedded frontmatter — required new form:**
```
"Write(/docs/features/**/research/**)"
"Write(/docs/research/**)"
```

The Claude `Write(...)` allowlist uses glob syntax with a `/` prefix anchored at repo root; the double-star `**` matches intermediate segments including the `<feature>` folder segment.

### Orchestrator routing decision rule

- If an active feature folder is in scope (`feature-folder` set in `orchestrator-state.json`), write research to `<feature-folder>/research/<timestamp>-<short-name>-research.md`.
- If no active feature folder is in scope (standalone or ad-hoc investigation), write research to `docs/research/<timestamp>-<short-name>-research.md`.

The orchestrator includes the resolved output path in the delegation prompt to `task-researcher`. The `research-issue` skill and the GitHub Copilot `research-issue` prompt are updated to document both paths and the routing rule, replacing the single `artifacts/research/` instruction.

### Cross-ecosystem consistency requirement

The root copy is the source of truth for each Claude and GitHub Copilot file; its bundled mirror under `extensions/drm-copilot/resources/` must remain identical after the change. The Codex `.toml` agents and `.agents/skills/` files are translations with no root counterpart and must receive the equivalent text changes (the Codex `evidence-and-timestamp-conventions/SKILL.md`, `orchestrate/SKILL.md`, and `research-issue/SKILL.md` mirror their Claude counterparts exactly). Root-versus-bundled divergence, or Claude-versus-Codex divergence, is a regression.

### Data flow or validation adjustments

- `task-researcher` writes only to one of the two new roots; its write-path allowlist enforces this.
- `validate-task-researcher-output.ps1` validates the reported `research-path` against the dual-root contract and the filename convention.
- `enforce-evidence-locations.ps1` and `validate_evidence_locations.py` block writes under `artifacts/research/`.

### Logging/telemetry updates

None.

### Migration or backfill needs

None. Historical `artifacts/research/` content is not migrated (see Non-Goals).

## Test Strategy

### `validate-task-researcher-output.Tests.ps1`

- Update existing tests that assert the `artifacts/research/` root and error-message text, and that use `artifacts/research/...` example paths (root-check test, valid-path termination test, missing-file block test, quoted-path extraction test, and the Automation Feasibility section tests) to use valid paths under the new roots.
- The `Test-IsValidResearchFileName` tests operate on the filename only and require no change unless they pass an `artifacts`-rooted path argument.
- Add: feature-folder path accepted (`docs/features/active/some-feature-227/research/2026-06-24T13-02-some-feature-research.md`).
- Add: one-off path accepted (`docs/research/2026-06-24T13-02-some-topic-research.md`).
- Add: old path rejected (`artifacts/research/2026-06-24T13-02-some-topic-research.md`) with a message referencing the new roots.
- Add: feature path without a `/research/` segment rejected (`docs/features/active/some-feature/2026-06-24T13-02-some-feature-research.md`).
- Add: feature path with a correct `/research/` segment but a non-conforming filename rejected (`docs/features/active/some-feature/research/bad-name.md`) with the filename-convention message.

### `enforce-evidence-locations.Tests.ps1`

- Change the existing `'allows writes to artifacts/research/ (permitted research path)'` test into a rejection test: `artifacts/research/notes.md` must produce `decision: block` with `EVIDENCE_LOCATION_BLOCKED`.
- Add: `docs/features/active/my-feature/research/2026-06-24T13-02-foo-research.md` produces `decision: allow`.
- Add: `docs/research/2026-06-24T13-02-foo-research.md` produces `decision: allow`.

### `test_validate_evidence_locations.py`

- In `test_clean_tree_exits_zero`, replace the allowed path `Path("/fake/repo/artifacts/research/notes.md")` with a new-root path such as `Path("/fake/repo/docs/features/active/my-feature/research/note.md")`.
- Add `test_artifacts_research_is_forbidden`: seed a file at `artifacts/research/seeded.md` and verify `find_forbidden_paths` yields exactly one violation with a canonical suggestion referencing the new paths.

### Invariant validation tests

- Filename-convention enforcement asserted under both new roots.
- Evidence-location enforcement for non-research paths (baselines, QA gates, coverage) confirmed unchanged.

### Coverage impact and targets for changed lines/modules

Coverage thresholds are uniform: line coverage >= 85%, branch coverage >= 75%. Changed lines in the PowerShell hooks and the Python validator must retain coverage at or above these thresholds, with no regression on changed lines.

### Toolchain commands to run (format → lint → type-check → test)

Run the full seven-stage toolchain loop in order until all stages pass in a single pass. For PowerShell: Invoke-Formatter, PSScriptAnalyzer, then Pester for the two hook test files. For Python: Black, Ruff, Pyright, then Pytest for `test_validate_evidence_locations.py`. Architecture-boundary, contract/schema, and integration stages apply where relevant.

### Manual validation steps

- Verify each root file and its bundled mirror are content-identical after edits.
- Verify the Codex translations contain the equivalent text changes.

## Definition of Done

- [x] Structure matches this spec; legacy `artifacts/research/` path retired and rejected by enforcement
- [x] Invariants validated with tests (filename convention preserved; non-research evidence enforcement unchanged)
- [x] Agent write-path allowlists, hooks, validator, skills, and prompts updated across all three ecosystems and bundled copies
- [x] Edge cases and negative scenarios verified (old path rejected; missing `/research/` segment rejected; non-conforming filename rejected)
- [x] Tests, linting, and type checks clean
- [x] Docs updated where accuracy requires (`docs/engineering/claude-code-architecture.md`)
- [x] Toolchain pass completed (format → lint → type-check → test)

## Acceptance Criteria

Mapped to the issue acceptance criteria; each item is concrete and verifiable.

- [x] Feature-associated research is written to `<FEATURE>/research/<timestamp>-<short-name>-research.md` and one-off research to `docs/research/<timestamp>-<short-name>-research.md`; `artifacts/research/` is no longer the canonical target.
- [x] The Claude ecosystem (root `.claude/` and bundled `claude-customizations`) reflects the new contract in `task-researcher.md` (frontmatter `tools`, description, body), `orchestrator.md`, `research-issue/SKILL.md`, `orchestrate/SKILL.md`, `evidence-and-timestamp-conventions/SKILL.md`, and both hooks.
- [x] The Codex ecosystem (bundled `codex-and-agents-customizations`) reflects the new contract in `task-researcher.toml` (embedded frontmatter, body, stop hook), `orchestrator.toml`, the three mirrored skills, and the `enforce-evidence-locations.ps1` docstring.
- [x] The GitHub Copilot ecosystem (root `.github/` and bundled `customizations`) reflects the new contract in `task-researcher.agent.md`, `research-issue.prompt.md`, and `fillout-prd-feature.prompt.md`.
- [x] `validate-task-researcher-output.ps1` accepts both new tracked roots and rejects `artifacts/research/`, with three error messages updated; `enforce-evidence-locations.ps1` and `validate_evidence_locations.py` reject `artifacts/research/`; tests updated accordingly in all three test files.
- [x] Both tracked research locations resolve to git-tracked paths (under `docs/`, not under the ignored `artifacts/` tree); no `.gitignore` change is made.
- [x] Root copies and their bundled mirrors are content-identical after the change; Codex translations contain the equivalent text changes.

## Seeded Test Conditions (from potential)
- [x] Hook unit tests for accepted (feature and one-off) and rejected research paths.
- [x] Filename-convention validation preserved under the new roots.
- [x] Evidence-location enforcement unaffected for non-research paths.
