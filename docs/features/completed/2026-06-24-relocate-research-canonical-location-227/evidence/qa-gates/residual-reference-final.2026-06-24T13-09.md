# Final Residual-Reference Grep (P9-T7)

Timestamp: 2026-06-24T13-09
Command: grep -rnE 'artifacts[/\\]research' across the repository, classified against the P0-T6 baseline.
EXIT_CODE: 0

## Result: zero operational routing/permitted matches remain.

Every remaining `artifacts/research` match falls into an allowed class (forbidden-prefix rejection logic, deliberate test assertions, historical out-of-scope reference, this feature's own docs, or generated files). No operational/enforcement/instruction file still treats `artifacts/research/` as a permitted or canonical research-output routing target.

### Class A — Required forbidden-prefix entries (rejection logic; intended)
- .claude/hooks/enforce-evidence-locations.ps1 (lines 20, 68)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1 (lines 20, 68)
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1 (lines 23, 71)
- scripts/dev_tools/validate_evidence_locations.py (line 38, _FORBIDDEN_PREFIX_TO_CANONICAL key)
These implement the rejection of the retired path and are required by the feature contract.

### Class B — Deliberate test assertions (verify rejection; intended)
- tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 (block-decision test for artifacts/research/notes.md)
- tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 (rejects-retired-path test)
- tests/scripts/dev_tools/test_validate_evidence_locations.py (test_artifacts_research_is_forbidden + docstring)

### Class C — Historical reference, explicitly out of scope (plan Open Questions)
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md (lines 24, 175): research-basis reference to a specific historical artifact artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md, not a routing rule. Out of scope per plan Open Questions / research.

### Class D — This feature's own documents (historical/feature-doc; allowed)
- docs/features/active/2026-06-24-relocate-research-canonical-location-227/ : plan, spec, issue, research artifact (relocated), and evidence artifacts that reference the retired path as context or record the migration. These are feature records, not enforcement/instruction files (spec Non-Goals).

### Class E — Generated files (allowed)
- testResults.xml (generated)
- *.pyc bytecode under __pycache__ (generated)
- artifacts/pester/*, artifacts/orchestration/* generated outputs

## Comparison to P0-T6 baseline
The P0-T6 baseline enumerated the operational set (Claude/Codex/GitHub Copilot hooks, validators, agent frontmatter/body, skill prose, prompts — root and bundled) that referenced the old path as a routing/permitted target. After implementation, that operational routing/permitted set is now zero: a targeted grep of .claude and .github excluding the enforce-evidence-locations.ps1 forbidden-prefix entries returns no matches, and the Codex equivalence check (P9-T6) confirms the Codex files carry no routing/permitted artifacts/research reference. The only residual matches in operational files are the intended forbidden-prefix entries (Class A) that implement the rejection.

Acceptance: zero operational routing/permitted matches remain; all remaining matches are classified Class A (required rejection logic), B (test assertions), C (historical out-of-scope), D (feature docs), or E (generated).
