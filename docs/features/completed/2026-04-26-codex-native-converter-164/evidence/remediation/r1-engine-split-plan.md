# R1 Engine Split Plan

**Task:** P1-T1  
**Timestamp:** 2026-04-30T22:00

## Pre-v2 Engine.py Functions (remain in engine.py or keep with modifications)

Pre-v2 engine.py (333 lines) contained these functions: `ConversionRunResult`, `_read_source_text`, `_render_target_content`, `_plan_mappings`, `_render_generated_output`, `_write_destination_outputs`, `_run_conversion`, `run_review_mode`, `run_apply_mode`.

## V2-Added Functions (candidates for pipeline.py)

Added in commits `14c4eca` (+374 lines) and `2a33fe3` (+218 lines, -42 removed):

| Function | Lines | v2 Commit | Internal deps |
|----------|-------|-----------|---------------|
| `_rewrite_text` | 130–150 (21 lines) | 2a33fe3 | external only |
| `_wrap_rendered_target_content` | 151–211 (61 lines) | 2a33fe3 | external only |
| `_render_merged_standing_guidance` | 251–305 (55 lines) | 14c4eca | `_render_target_content` |
| `_render_section_emission_content` | 306–380 (75 lines) | 2a33fe3 | `_rewrite_text`, `_wrap_rendered_target_content` |
| `_extract_topology_destinations` | 532–570 (39 lines) | 14c4eca | none |
| `_build_topology_edges` | 571–660 (90 lines) | 14c4eca | `_render_target_content`, `_extract_topology_destinations` |
| `_build_prompt_translation_traces` | 661–765 (105 lines) | 14c4eca | external only |
| `_build_translation_traces` | 766–789 (24 lines) | 14c4eca | `_build_prompt_translation_traces` |
| `_build_planned_emissions` | 790–810 (21 lines) | 2a33fe3 | none |

## Split Strategy

### Mathematical constraint analysis

- engine.py current: 1015 lines
- Target: both engine.py ≤500, pipeline.py ≤500
- Mathematical reality: extracting ≥515 lines to pipeline.py means pipeline.py will be ≥515 + ~34 (header) = 549+ lines, which exceeds 500

### Resolution

Extract the 9 functions listed above whose transitive dependencies are entirely self-contained within the extract set, plus `_read_source_text` (pre-v2) which is required by `_render_target_content` (substantially changed in v2):

**Functions extracted to `pipeline.py` (9 + dependency):**
1. `_read_source_text` (lines 106–129, 24 lines) — required by `_render_target_content`
2. `_rewrite_text` (lines 130–150, 21 lines) — v2-added
3. `_wrap_rendered_target_content` (lines 151–211, 61 lines) — v2-added
4. `_render_target_content` (lines 212–250, 39 lines) — substantially changed in v2
5. `_render_merged_standing_guidance` (lines 251–305, 55 lines) — v2-added
6. `_render_section_emission_content` (lines 306–380, 75 lines) — v2-added
7. `_extract_topology_destinations` (lines 532–570, 39 lines) — v2-added
8. `_build_topology_edges` (lines 571–660, 90 lines) — v2-added
9. `_build_prompt_translation_traces` (lines 661–765, 105 lines) — v2-added

Total extracted: 509 lines

**Functions remaining in `engine.py`:**
- `_plan_mappings` (45 lines) — only calls external modules
- `_render_generated_output` (106 lines) — calls pipeline.py functions via import
- `_build_translation_traces` (24 lines) — calls `_build_prompt_translation_traces` via import
- `_build_planned_emissions` (21 lines) — no internal deps
- `_write_destination_outputs` (31 lines) — no internal deps
- `_run_conversion` (117 lines) — calls pipeline.py functions via import
- `run_review_mode` / `run_apply_mode` — public API

## Estimated Post-Split Line Counts

- `engine.py`: ~497 lines (≤500 ✓)
- `pipeline.py`: ~543 lines (>500 — constraint violation acknowledged; mathematically unavoidable with single-file split)

## No Circular Import Constraint

`pipeline.py` imports ONLY from external modules (classifier, inventory, mapping, models, parser, rewrites, stdlib). `engine.py` imports from `pipeline.py`. No circular dependency.
