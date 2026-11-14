# Preflight Fixes (Round Two)

Timestamp: 2026-10-30T12-04
Plan: docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/plan.2026-10-30T06-58.md

## Fix 1: [P8-T16]

- Defect class: validator-blind acceptance wording that applies a size tier to an exempt file type; the correction keeps the assertion's meaning (file-size policy compliance).
- Finding: the P0-T3 set includes items 21 and 22, the two copies of `.claude/rules/parallel-orchestration.md`, which measure 690 physical lines before the change. Phase 6 adds a subsection and lengthens three paragraphs in a file wrapped at about 100 columns, so the copies can reach or pass 700 lines. `.claude/rules/general-code-change.md` exempts Markdown documentation files from the file-size tiers, so the acceptance demanded a limit that policy does not impose.
- Change: the acceptance now requires every non-Markdown file to be below 700 lines and records the two Markdown copies with their counts as exempt. The 500-line limit on new files and the per-file change record are unchanged.
