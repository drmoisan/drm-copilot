# Preflight Record: Main Plan After the [P6-T10] Revision (Issue #1032)

Timestamp: 2026-10-31T17-59
Plan: docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/plan.2026-10-30T18-39.md
Scope: single-pass preflight of the main plan against the current branch tree (`feature-1032-h3fix`, merged with `origin/epic/shared-agent-harness-layer-integration`). The branch plans `plan-agents-branch-a.md` and `plan-agents-branch-b.md` are out of scope (ALL CLEAR in `preflight-round2.2026-10-31T04-59.md`).

PREFLIGHT: ALL CLEAR
CONVERGENCE: NO FURTHER ROUNDS EXPECTED

No PREFLIGHT-FIX lines: no trivial defect was found, and the plan file was not edited.
No PREFLIGHT-DEFECT lines.

## Validator Results

- `mcp__drm-copilot__validate_orchestration_artifacts` (`artifact_type: plan`): ok, no warnings returned.
- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`: `plan validation passed`, EXIT_CODE 0, no `PLAN GATE WARNING` lines.

## Prior Defect: [P6-T10] Satisfiability

The revised acceptance requires, per file, baseline and final line and branch percentages, a final line percentage of at least 85% and a final branch percentage of at least 75%, and a changed-line result of `no added lines` or zero uncovered added or modified executable lines. The whole-file no-decrease condition is removed, so deleting covered code no longer fails the task.

Current-tree measurements taken during preflight (scratch output under `SCRATCH`; not baseline evidence):

| File | Measurement | Line | Branch | Assessment |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/agentic_sync.py` | pytest with `--cov=scripts.dev_tools.agentic_sync --cov-branch` over the agentic_sync and push-down test modules (53 passed) | 98% statements (101 stmts, 2 missed) | 34 branches, 2 partial | Above both thresholds; P1-T4 changes a tuple and a docstring only. |
| `scripts/dev_tools/push_down_copilot_customizations_rewrites.py` | same run | 98% statements (57 stmts, 1 missed) | 10 branches, 1 partial | Above both thresholds; P5-T4 removes one data entry. |
| `src/lib/push-down/copilot-customizations-engine.ts` | Jest, engine and reference-rewrites suites | 97.99% | 81.39% | Above both thresholds; also gated at 85/75 by its `coverageThreshold` entry. P1-T3 changes array data only. |
| `src/lib/push-down/reference-rewrites.ts` | same Jest run | 99.17% | 93.75% | Above both thresholds; no `coverageThreshold` entry (as P6-T7 states). P5-T3 removes one catalog entry. |
| `src/repo-automation-command-registration-admin.ts` | Jest, its own suite plus the three `extension.*` suites of `H3-JEST` | 86.9% | 75% | Gated at 85/75 by its `coverageThreshold` entry in the full suite, which is a superset of this run. The function P5-T2 removes (`registerSyncAgentsFromInstructionsCommand`) has no branches, so branch coverage is unchanged by its removal; removing its covered statements lowers line coverage by under one point on this subset (estimated about 86.4%), which remains at or above 85%. |

Changed-line result: every added or modified executable line in the five files is module-level data or an import (`ROOT_FOLDERS`, `COPILOT_ROOT_FOLDERS`, catalog arrays, the `./command-runtime` import), each executed at module load by the existing suites; the remaining edits remove lines. The condition is satisfiable without a further task.

## Current-Tree Checks

- The epic merge changed only documentation under other children's feature folders and the epic manifest. Child 3's revised plan lists `scripts/dev-tools/sync-agents-from-instructions.ps1`, `.github/copilot-instructions.md` and the six execution-environment brief copies as not edited, which matches UA-C3c and the Phase 2 and Phase 4 edit sets.
- Child 3's spec (`### Surface: instructions`) makes `CLAUDE.md` begin with `@AGENTS.md`; [P4-T2] already conditions its edit on the post-child-3 state ("no edit when child 3 already made the change") and measures its diff from `MB`.
- Cited headings exist in the current tree: `C1/spec.md` `### Parity Matrix: Feature Entry` (with `provisional`), `### Parity Matrix: Identifier Encoding`, and the E3 and E4 experiment rows; `C3/spec.md` `### Generation model (all surfaces)`, `### Surface: instructions`, `### Surface: skill mirror`, `### Surface: agents`, `## Inputs / Outputs`, `## API / CLI Surface`, `## Language Classification`.
- `scripts/harness-generation/Invoke-HarnessGeneration.ps1` and `config/harness-parity-matrix.json` are not yet in the tree; their presence is an execution-time Phase 0 gate (UA-C1a, UA-C3a) with a Stop outcome, not a plan defect.
- `scripts/dev-tools/sync-agents-from-instructions.ps1`, its bundled template and `RETIRED-PESTER` are tracked, as P0-T5, P0-T11 and P5-T1 require.
