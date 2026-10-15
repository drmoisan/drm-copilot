# Change Scope Against the P0-T3 SHA (P8-T6)

Timestamp: 2026-10-09T04-40
Command: git diff --name-only 3d5a8446d6e39f66dd593a53280e47aedd83ba1c; git status --porcelain
EXIT_CODE: 0
Output Summary: every listed path is either in the Files Written inventory or under the feature folder. All 16 unconditional inventory paths appear in the name-only listing. None of the 5 conditional paths appears, consistent with Phase 4 recording NO-CHANGE for each (P4-T5 through P4-T9). Porcelain is empty because every change is committed. The promoted lifecycle record was not listed by P0-T3 and does not appear here. The diff runs in the shell with the literal SHA recorded in P0-T3 because inline `pwsh` is denied (denial text in evidence/baseline/requirements-source.2026-10-09T02-51.md).

## Non-feature-folder paths in the listing (all in the inventory)

```text
.claude/lib/blast-radius/BlastRadiusExtraction.psm1
.claude/lib/blast-radius/BlastRadiusTokenShape.psm1
.claude/rules/parallel-orchestration.md
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
scripts/dev_tools/_blast_radius_extraction.py
scripts/dev_tools/_blast_radius_token_shapes.py
tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json
tests/fixtures/blast_radius/derivation-file-shaped-tokens.json
tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json
tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
tests/scripts/dev_tools/test_blast_radius_extraction.py
tests/scripts/dev_tools/test_blast_radius_extraction_rules.py
tests/scripts/dev_tools/test_blast_radius_token_shapes.py
```

Feature-folder paths: plan.2026-10-08T17-24.md, spec.md, and the evidence files under evidence/baseline, evidence/regression-testing, and evidence/qa-gates.
