# Orchestrator Fix-Feasibility Demonstration — Issue #489

Timestamp: 2026-08-17T21-20
Purpose: Ratify the research recommendation empirically before committing the plan to it. The research pass had no shell tool and recorded two central claims as unverified. This artifact executes them.

This is a PRE-IMPLEMENTATION feasibility demonstration produced by the orchestrator. It is not the deliverable fail-before/pass-after evidence; that is produced by the committed fixture and regression test the plan delivers.

## Source data

The `verification-integrity` radii were read from `artifacts/orchestration/parallel-orchestrator-state.json`. That path is gitignored (`.gitignore:6` `/artifacts`), so the data is not in git and is invisible to CI and to a fresh checkout. The three recorded `blast_radius` blocks were snapshotted before any change. Promoting them to a committed fixture under `tests/fixtures/` is a deliverable of the plan.

Recorded radius sizes:

| Item | paths | modules | shared_surfaces | contracts | source |
| --- | --- | --- | --- | --- | --- |
| 485 | 184 | 6 | 1 | 40 | declared |
| 486 | 125 | 3 | 2 | 45 | declared |
| 487 | 140 | 4 | 1 | 10 | declared |

## Before state — reproduced by execution

Command: `conflicts(radius_a, radius_b, config)` from `scripts/dev_tools/_blast_radius_conflicts.py`, then `compute_cohorts` from `scripts/dev_tools/parallel_cohort_computation.py`, over the recorded radii and the current committed `config/blast-radius.json`.

EXIT_CODE: 0

```
485 vs 486: conflict=True reasons=path_overlap('.claude/rules/general-code-change.md ~ .claude/rules/general-code-change.md'),
                             module_overlap('claude-runtime'),
                             shared_surface_overlap('quality-tiers.yml'),
                             contract_dependency('->')
485 vs 487: conflict=True reasons=path_overlap('.claude/rules/ ~ .claude/rules/benchmark-baselines.md'),
                             module_overlap('claude-runtime'),
                             shared_surface_overlap('quality-tiers.yml')
486 vs 487: conflict=True reasons=path_overlap('.claude/rules/ ~ .claude/rules/general-code-change.md'),
                             module_overlap('claude-runtime'),
                             shared_surface_overlap('quality-tiers.yml')

BEFORE-STATE derived edges: [(485, 486), (485, 487), (486, 487)]
BEFORE-STATE cohorts:       [[485], [486], [487]]
```

Output Summary: The recomputed before state reproduces the recorded checkpoint exactly — a complete K3 triangle and three single-item cohorts. The recorded `reason: path_overlap` on each edge is only the first-reported disjunct.

## Premise correction (material)

The brief named three false-contention sources, all at the `paths` level. Execution shows the conflict relation is a four-way disjunction and that **three of the four disjuncts fire on all three pairs**:

- `path_overlap` — fires on all three pairs, from `.claude/rules/` policy-read citations.
- `module_overlap` — fires on all three pairs. `claude-runtime` is reported first; `python-dev-tools` and `vscode-extension` also overlap on all three pairs, and those two are reached from **genuine, disjoint writes** (485 writes `scripts/dev_tools/pr_context/*`, 486 writes `scripts/dev_tools/plan_gate_*`, 487 writes `scripts/dev_tools/new_active_feature_folder_*`; all three write under `extensions/drm-copilot/src/`).
- `shared_surface_overlap` — fires on all three pairs via `quality-tiers.yml`.
- `contract_dependency` — fires on 485-486 via the punctuation token `->`.

Consequence: an extraction-only fix confined to the three named path-level sources would leave `module_overlap` firing on every pair, so the K3 and the three-cohort serialization would survive. The brief's change surface was necessary but not sufficient.

## After state — simulated fix, executed

The simulation applies, to the recorded radii, the rules the plan will implement in the extractor, and re-resolves modules and shared surfaces against a config with the umbrella module entries removed:

1. Mandate-read exclusion: `.claude/rules/**`, `quality-tiers.yml`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `artifacts/**`, `.github/instructions/**`.
2. Directory-shaped token rejection (wildcard-free token whose final component carries no extension).
3. Cross-corpus `docs/features/**` glob rejection.
4. Letterless contract-token rejection.
5. Config content: remove the umbrella module entries `python-dev-tools`, `vscode-extension`, `claude-runtime`, `copilot-surface`, `agents-surface`.

EXIT_CODE: 0

```
485: paths=142 modules=[] shared=[]                                                  contracts=34
486: paths=107 modules=[] shared=['scripts/dev_tools/validate_orchestration_artifacts.py'] contracts=41
487: paths=103 modules=[] shared=[]                                                  contracts=10

485 vs 486: conflict=False
485 vs 487: conflict=False
486 vs 487: conflict=True  path_overlap('extensions/drm-copilot/src/mcp-tools.ts ~ extensions/drm-copilot/src/mcp-tools.ts')

AFTER-FIX edges:   [(486, 487)]
AFTER-FIX cohorts: [[485, 486], [487]]
```

Output Summary: The required outcome is achieved. The derived conflict graph reduces to exactly the single true edge, and the recolor yields two cohorts with 485 and 486 concurrent. The surviving edge is the genuine source-file conflict on `extensions/drm-copilot/src/mcp-tools.ts` — the one real conflict the operator identified.

## Conclusions carried into the specification

1. The fix is achievable entirely on the extraction side plus config content. **No comparison-side change is required.** `_blast_radius_conflicts.py` and `_blast_radius_glob.py` are not modified, so the issue #452 / PR #453 hardening is preserved intact.
2. The module-map removal is config-content, not relation semantics — the same fix class as issue #472 Defect A. The conflict relation stays frozen.
3. Both false-negative directions retain a backstop: `detect_escaped_paths` in `scripts/dev_tools/parallel_drift_detection.py` tests every observed diff path against the declared radius, and observed radii are built verbatim from diff paths, so a genuine write to an excluded path is caught at execution time.

## Reproduction

The scripts used are session-scratchpad only and are not committed. The plan delivers the durable equivalent: a committed fixture under `tests/fixtures/` holding the three recorded radii verbatim, plus a regression test that pins the before state and asserts the after state in both the Python and PowerShell runtimes.
