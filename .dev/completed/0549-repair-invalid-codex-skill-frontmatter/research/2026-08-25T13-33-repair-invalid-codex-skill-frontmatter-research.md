<!-- markdownlint-disable-file -->

# Task Research Notes: Codex skill frontmatter repair for Issue #549

## Research Executed

### File Analysis

- `.agents/skills/*/SKILL.md`
  - Enumerated 62 canonical skill files. Each has a matched skill name and a byte-identical counterpart under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/*/SKILL.md`.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/*/SKILL.md`
  - Enumerated 62 bundled skill files. There are no missing counterparts or existing byte-parity differences.
- `docs/features/active/2026-08-25-repair-invalid-codex-skill-frontmatter-549/spec.md`
  - Defines the scope as frontmatter-only repair, preservation of skill bodies and behavior, validation of all 62 pairs, and byte parity.
- `scripts/dev_tools/push_down_codex_and_agents_customizations.py`
  - Identifies the bundled Codex payload root used for distribution.

### Code Search Results

- YAML frontmatter parsing with a duplicate-key traversal over YAML mapping nodes
  - Found two syntax failures: `csharp-change-budget-router` and `powershell-change-budget-router`, both caused by an unquoted colon-space sequence in `description`.
- Codex-native skill frontmatter fields
  - Found 12 `paths` fields. The Issue #549 spec identifies this field as unsupported in Codex skill frontmatter.
- Description-character validation
  - Found nine descriptions containing angle brackets. The Issue #549 spec identifies these description values as unsupported.
- Live evidence-location-hook contract
  - Found five retired `artifacts/research/` guidance occurrences across the canonical and bundled skill pairs. Four skills are additional affected pairs; `translate-claude-to-codex` is already in the angle-bracket category.

### External Research

- No external research was required.
  - The active Issue #549 specification and the repository payload publisher are the authoritative sources for this repository-local metadata repair.

### Project Conventions

- Standards referenced: `AGENTS.md`, `.agents/skills/research-issue/SKILL.md`, and `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Instructions followed: research output is limited to the feature-associated research folder; no source, configuration, skill, or bundled payload file was changed by this research task.

## Key Discoveries

### Project Structure

The canonical tree is `.agents/skills/<skill>/SKILL.md`. Its distributed mirror is `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<skill>/SKILL.md`. The scan found 62 folders in each tree, the same set of skill names, and zero byte differences before repair.

### Invalid Frontmatter Inventory

Each listed canonical skill and its same-named bundled counterpart are affected. The three frontmatter categories are disjoint and yield 23 pairs. Four additional skills retain retired research-location guidance; the already-affected `translate-claude-to-codex` skill also needs a body-path correction. The complete scope is therefore 27 unique invalid pairs.

| Defect | Count | Skills |
| --- | ---: | --- |
| Unsupported `paths` field | 12 | `architecture-boundaries`, `csharp`, `general-code-change`, `general-unit-test`, `powershell`, `python`, `python-suppressions`, `quality-tiers`, `self-explanatory-code-commenting`, `tonality`, `typescript`, `typescript-suppressions` |
| Unquoted `description` containing `: ` | 2 | `csharp-change-budget-router`, `powershell-change-budget-router` |
| Angle brackets in `description` | 9 | `csharp-qa-gate`, `invoke-csharp-engineer`, `invoke-powershell-engineer`, `invoke-python-engineer`, `policy-audit-template-usage`, `powershell-qa-gate`, `python-qa-gate`, `translate-claude-to-codex`, `translate-copilot-to-claude` |
| Retired research-location guidance | 4 additional pairs | `research-issue`, `orchestrate`, `evidence-and-timestamp-conventions`, `epic-plan` |
| Retired research path in the body | already counted above | `translate-claude-to-codex` |

The unquoted descriptions fail YAML parsing with `mapping values are not allowed here`. The scan found no malformed delimiters, missing `name` or `description`, missing pair, existing parity drift, or duplicate YAML key in either tree. In particular, there is no duplicated `description` key at the current revision.

The live `.codex/hooks/enforce-evidence-locations.ps1` contract forbids `artifacts/research/` and states that research output belongs under `docs/features/<feature>/research/` when feature-associated or `docs/research/` when one-off. The bundled hook has the same text. The following body corrections are required in both copies of the affected skill:

- `research-issue`: replace the frontmatter description and the `## Output` path that specify `artifacts/research/` with the two supported research roots.
- `orchestrate`: replace the task-researcher delegation target and the permitted `artifacts/` research-output list item with the supported research roots.
- `evidence-and-timestamp-conventions`: remove `artifacts/research/` from the allowed artifacts list and state that research uses the two supported tracked documentation roots.
- `epic-plan`: replace the acceptance of `artifacts/research/` for `research_path` with the applicable feature-associated research root, while retaining the feature-folder condition.
- `translate-claude-to-codex`: replace both references to `artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md` with the verified tracked path `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`.

### Exact Minimal Repair

1. Remove the complete `paths:` mapping, including its list entries, from each of the 12 affected frontmatter blocks. Do not replace it with another metadata key.
2. Single-quote the existing `description` scalar in the two change-budget-router skills. Their text does not contain a single quote, so this is a syntax-only repair.
3. Replace only the unsupported angle-bracket notation in the nine descriptions while retaining their existing intent. Replace toolchain arrows with ordinary prose, replace `policy-audit.<timestamp>.md` with a timestamped-artifact phrase, and replace `<name>` skill-path placeholders with prose that names the relevant skill package. Do not alter the Markdown body, headings, workflow obligations, or supported `name` field.
4. Apply each canonical file's complete post-repair content unchanged to its same-named bundled counterpart, preserving byte parity.
5. Correct the retired research-location references in the five affected skill bodies. This is a path-only correction: preserve the existing mandatory workflow, validation, remediation, and completion requirements. Use `docs/features/<feature>/research/` for feature-associated work and `docs/research/` for one-off work.

### Proposed Description Normalization

Use the following intent-preserving descriptions for the angle-bracket cases. They avoid both `<` and `>` without weakening the documented workflow.

| Skill | Replacement `description` value |
| --- | --- |
| `csharp-qa-gate` | `Final QA gate for C# changes. Runs CSharpier, .NET analyzers, nullable analysis, and MSTest; compares a captured baseline, enforces zero-regression deltas, and produces the required reporting block before completion.` |
| `invoke-csharp-engineer` | `Invoke the csharp-typed-engineer worker to design, implement, and verify C# changes within typed repository boundaries. Applies CSharpier, .NET analyzers, nullable analysis, and MSTest with the one-to-three production-file small-path budget and zero-regression quality gates.` |
| `invoke-powershell-engineer` | `Invoke the powershell-typed-engineer worker to design, implement, and verify PowerShell changes within typed repository boundaries. Applies PoshQC formatting, analysis, and testing with a one-to-two production-file direct-mode budget, a three-production plus three-test batch cap, and zero-regression quality gates.` |
| `invoke-python-engineer` | `Invoke the python-typed-engineer worker to design, implement, and verify Python changes within typed repository boundaries. Applies Black, Ruff, Pyright, and Pytest with a three-production plus three-test per-batch budget and zero-regression quality gates.` |
| `policy-audit-template-usage` | `Policy audit template usage and output requirements. Use when creating timestamped policy-audit artifacts from the repository templates.` |
| `powershell-qa-gate` | `Final QA gate for PowerShell changes. Runs PoshQC formatting, analysis, and testing with coverage where enforced; compares a captured baseline, enforces zero-regression deltas, and produces the required reporting block before completion.` |
| `python-qa-gate` | `Final QA gate for Python changes. Runs Black, Ruff, Pyright, and Pytest; compares a captured baseline, enforces zero-regression deltas, and produces the required reporting block before completion.` |
| `translate-claude-to-codex` | `Translate the native Claude Code runtime, including Claude rules, skills, agents, hooks, and settings, into the native Codex ecosystem. Preserve mechanical enforceability, diff against existing Codex state, produce an approval plan with an enforceability ledger, then apply it.` |
| `translate-copilot-to-claude` | `Translate GitHub Copilot native files, including instructions, agents, prompts, and skills, into the native Claude runtime. Classify each section, diff against existing Claude state, produce a translation plan for approval, then apply it.` |

### Technical Requirements

- Every frontmatter block must parse as a YAML mapping with `name` and `description` string fields.
- `name` must equal the skill folder name.
- The only permitted metadata fields for this repair are `name` and `description`; `paths` must be absent.
- Description scalars must contain neither `<` nor `>`.
- YAML mapping keys must be unique at every mapping depth. This specifically detects a repeated `description` key instead of accepting parser-dependent last-key behavior.
- Research instructions must not name `artifacts/research/`. They must select `docs/features/<feature>/research/` for feature-associated research or `docs/research/` for one-off research, matching the live hook contract.
- The canonical and bundled byte streams must be equal for each of the 62 same-named paths.

## Recommended Approach

Apply targeted frontmatter edits and the five retired-path body corrections directly to the 27 canonical skills, then copy each resulting complete file to its paired bundled path. This preserves the documented behavior and creates deterministic parity.

Rejected alternatives: regenerating the entire bundle through a broader publication workflow would change the scope from 46 targeted metadata files to a payload-wide operation. Parsing only the canonical tree would not prove the distributed payload is valid or synchronized.

## Implementation Guidance

- **Objectives**: Remove the 12 unsupported fields, quote the two YAML-invalid descriptions, normalize the nine angle-bracket descriptions, correct the five retired research-location references across 27 unique skills, and retain byte equality across all 62 pairs.
- **Key Tasks**: Edit the identified frontmatter and path references only; then validate all 124 files with a YAML parser and explicit duplicate-key traversal; enforce the supported-key, description-character, and research-root checks; compare canonical and bundled bytes by skill name.
- **Dependencies**: Local Python environment provides PyYAML 6.0.3. No new dependency is necessary.
- **Success Criteria**: All 62 canonical and 62 bundled frontmatter blocks parse; all descriptions meet the character rule; no `paths` or duplicate key remains; no retired `artifacts/research/` guidance remains; no missing pair or byte difference remains; bodies differ only at the five verified research-path corrections.
