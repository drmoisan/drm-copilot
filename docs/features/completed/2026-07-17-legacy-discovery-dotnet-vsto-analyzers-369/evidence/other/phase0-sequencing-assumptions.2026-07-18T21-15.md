# Phase 0 — Upstream Sequencing Assumption Verification

- Timestamp: 2026-07-18T21-15
- Task: [P0-T6]
- Feature: legacy-discovery-dotnet-vsto-analyzers (#369)
- Depends on: #363 (analyzer framework), #360 (config contract), #359 (schemas)

## Checked Paths

| Path | Result |
| --- | --- |
| `scripts/dev_tools/discovery/analyzer/models.py` | PRESENT |
| `scripts/dev_tools/discovery/analyzer/pipeline.py` | PRESENT |
| `scripts/dev_tools/discovery/analyzer/inventory.py` | PRESENT |
| `scripts/dev_tools/discovery/analyzer/emitter.py` | PRESENT |
| `scripts/dev_tools/discovery/analyzer/cli.py` | PRESENT |
| `scripts/dev_tools/discovery/domain_profile.py` | PRESENT |
| `schemas/discovery/v1/evidence-reference.schema.json` | PRESENT |

## Verdict

All seven upstream paths are PRESENT. The sequencing assumption is satisfied;
#363/#360/#359 have merged into the integration branch and are available in this
worktree. Execution proceeds to Phase 1. No BLOCKED-UPSTREAM condition.

## Supporting contract observations

- `ParseResult` (models.py) is paths-only: `paths: tuple[str, ...]`. The
  `TextParseResult` subtype approach in [P1-T3] is required (see the coordination
  decision record under `coordination/text-parse-result-reconciliation.md`).
- `AnalyzerError` is defined in `inventory.py` (a `ValueError` subclass), distinct
  from `DomainProfileError` in `domain_profile_models.py`.
- The `Analyzer` protocol (pipeline.py) is structural: `name` plus
  `parse/classify/map/emit`. The `AnalyzerFileSystem` seam exposes `exists`,
  `is_dir`, `walk_files`, `read_bytes`, `write_text`.
- The #363 emitter `serialize_record` computes the scheme-less relative `$schema`.
- `DEFAULT_PROFILE_FILENAME` is exported from `domain_profile.py`.
