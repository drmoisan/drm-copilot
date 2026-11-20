# blast-radius-false-conflict-edges (Issue #489)

- Date captured: 2026-08-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/blast-radius-false-conflict-edges/ (Issue #489)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #489
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/489
- Last Updated: 2026-08-18
- Work Mode: full-bug

## Summary

Blast-radius computation admits paths into an item's radius that are not sources of genuine write-write or write-read contention, producing false `path_overlap` conflict edges that serialize parallel runs which should execute concurrently. This is the third observed instance of the class (prior instances: issue #472, and a case recorded in operator memory).

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `compute_blast_radius` / `.claude/lib/blast-radius/*.psm1` / `claude-blast-radius-derive*.ts`, consumed by the parallel planner when seeding generation-0 cohorts
- Data source or fixture: `artifacts/orchestration/parallel-orchestrator-state.json` for the `verification-integrity` parallel run (issues 485, 486, 487)

## Steps to Reproduce

1. Prepare the three `verification-integrity` items (issues 485, 486, 487) through the parallel planner so each records a `blast_radius`.
2. Read the recorded `blast_radius.paths` for each item from `artifacts/orchestration/parallel-orchestrator-state.json`.
3. Compute exact pairwise intersections of the recorded radii and derive the conflict graph.
4. Run cohort computation over the derived conflict edges.

## Expected Behavior

Conflict edges reflect genuine write-write or write-read contention on concrete artifacts. The `verification-integrity` true conflict graph is a single edge (486-487), which colors to two cohorts: {485, 486} concurrent, then 487.

## Actual Behavior

The three items form a complete K3 triangle, every edge carrying `reason: path_overlap`, forcing three cohorts and fully serial execution. Measured pairwise intersections:

- 485 intersect 486: 7 x `.claude/rules/*.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, `quality-tiers.yml`, bare `extensions/drm-copilot`, bare `scripts/dev_tools`. Zero concrete source files in common.
- 485 intersect 487: 5 x `.claude/rules/*.md`, `quality-tiers.yml`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `artifacts/` plus eight `artifacts/*` evidence subdirectories, bare `extensions/drm-copilot/`. Zero concrete source files in common.
- 486 intersect 487: 5 x `.claude/rules/*.md`, `quality-tiers.yml`, and `extensions/drm-copilot/src/mcp-tools.ts`. One genuine source-file conflict.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: recorded `conflict_edges[]` for the `verification-integrity` run contains all three pairs (485-486, 485-487, 486-487) with `reason: path_overlap`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Parallel runs that should execute concurrently are serialized. The defect scales with item count: any shared policy-read path forms a complete conflict graph over the entire item set on its own, so a large lane-parallel organization degrades toward fully serial execution.

## Suspected Cause / Notes

Three distinct false-contention sources have been identified:

1. **Phase 0 policy-read paths.** Every atomic plan is required by `CLAUDE.md` to read `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, the applicable language rules, and `.claude/rules/quality-tiers.md`, and to consult `quality-tiers.yml`. These are read-only by mandate. Because every plan reads them, they form a complete conflict graph over any item set. Two plans that both merely READ a file are not in contention.
2. **Bare directory tokens.** Radii contain entries such as `extensions/drm-copilot` and `scripts/dev_tools` with no file beneath them. Under prefix-honouring comparison these match an entire subtree, so two items touching unrelated files in the same large directory conflict.
3. **Evidence output directories.** `artifacts/` and its subdirectories are per-feature evidence WRITE targets. Each item writes to its own `<FEATURE>/evidence/` tree, so a shared `artifacts/` prefix is not real contention.

Files to inspect:

- Python: `scripts/dev_tools/compute_blast_radius.py`, `_blast_radius_conflicts.py` (see `_smallest_path_overlap`), `_blast_radius_extraction.py`, `_blast_radius_glob.py`, `_blast_radius_thresholds.py`, `_blast_radius_validation.py`.
- PowerShell parity: `.claude/lib/blast-radius/BlastRadius*.psm1` with tests under `tests/scripts/claude-lib/blast-radius/`, including `BlastRadius.Parity.Tests.ps1`.
- TypeScript: `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive*.ts` with tests under `extensions/drm-copilot/test/lib/push-down/`.
- Config: `config/blast-radius.json` and its byte-identical mirror at `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`.
- Prose: `.claude/rules/parallel-orchestration.md` and any rule describing radius derivation.

## Proposed Fix / Validation Ideas

Two candidate fix sites exist and they are not equivalent in risk.

- **Extraction side (strongly preferred).** Stop admitting policy-read paths, bare directory tokens, and evidence-output directories into the radius in the first place. Comparison semantics stay untouched.
- **Comparison side (risky).** Change how overlap is judged. Issue #452 / PR #453 deliberately hardened comparison to report MORE contention: separator-free repository-root shared surfaces are reached from plan and specification text, and path comparison honours listed-directory prefixes on both sides. Weakening that comparison would reverse a deliberate fail-closed correction and could reintroduce the defect #452 fixed.

Open design questions for research:

- Whether the durable fix is a read/write distinction in the radius model (a path contributes to contention only when at least one side WRITES it) versus a simpler exclusion list. The read/write distinction is more principled but larger.
- Whether `quality-tiers.yml`, currently an explicitly declared entry in `shared_surfaces` in `config/blast-radius.json`, is correctly classified. A file every plan reads but few plans write may belong in a new read-only category rather than in `shared_surfaces`. It must not be removed without a reasoned basis.

Constraints on any fix:

- The fail-closed default must be preserved: an unknown or unclassifiable path must continue to count as contention.
- Backward compatibility: existing recorded radii and checkpoints must continue to validate. Any new config key is optional with a fail-closed default.
- Python / PowerShell / TypeScript parity must be maintained; the existing parity suite must stay green and should be extended.
- If any part genuinely requires a comparison-side change, that must be stated explicitly with justification for why the extraction-side alternative is insufficient.

- [x] Unit coverage areas: extraction admission rules, conflict-edge derivation, config loading of any new key, cross-runtime parity.
- [x] Integration scenario to retest: recompute the `verification-integrity` radii and recolor; the run must yield two cohorts with 485 and 486 in the same cohort, demonstrated empirically rather than asserted.
- [x] Manual verification notes: before/after cohort count for `verification-integrity` must be captured as evidence.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
