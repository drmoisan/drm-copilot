# P6-T10 Citation Search Outside docs/

Timestamp: 2026-10-02T03-18
Command: git grep -n -F "ci.research.md" -- . ":(exclude)docs"
EXIT_CODE: 0
Output Summary: Exactly one line, the fixture string: `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1:249:                    shared_surfaces = @('config/orchestration-routing.json', 'docs/ci.research.md')`. The four citation lines recorded at baseline (P0-T33) no longer match.
