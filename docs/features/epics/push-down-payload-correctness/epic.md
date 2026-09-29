---
epic: push-down-payload-correctness
integration_branch: epic/push-down-payload-correctness-integration
created_at: 2026-09-29T14:10
intent:
  epic_type: enabler
  business_outcome_hypothesis: A consumer repository receives the same self-sufficient Claude payload whichever push-down entry point runs, and a push-down no longer destroys destination-local configuration or reintroduces content the destination deliberately excluded.
  leading_indicators:
    - A Python/TypeScript parity test fails on any divergence of published roots or merge paths.
    - The skill-bundle contract guard carries zero KnownUnbundledReference exceptions for the parallel skills.
    - A destination blast-radius file with local additions survives a push-down unchanged in those additions.
    - A destination-declared exclusion is honored by both push-down implementations.
  nfrs:
    - Pushed-down enforcement hooks gain no Python legs.
    - No production file exceeds the 500-line cap.
    - Line coverage >= 85% and branch coverage >= 75% where the tooling measures it.
features:
  - issue_num: 507
    feature_folder: 2026-08-22-push-down-root-folders-divergence-507
    depends_on: []
  - issue_num: 763
    feature_folder: 2026-09-28-parallel-skills-invoke-unbundled-python-clis-763
    depends_on: []
  - issue_num: 508
    feature_folder: 2026-08-22-blast-radius-config-has-no-merge-decorator-508
    depends_on: [507]
  - issue_num: 621
    feature_folder: 2026-09-29-push-down-destination-exclusion-manifest-621
    depends_on: [507, 508]
---

# Epic: Push-Down Payload Correctness

Epic issue: #770.

> **Manifest status.** The child issue numbers are the existing GitHub issues. The
> `feature_folder` values are the target basenames given to each preparation child and are
> back-filled from each child's `new_active_feature_folder` receipt as preparation completes.

## Goal

Make the Claude push-down deliver a consistent, self-sufficient payload that respects the state
the destination repository already holds. The push-down has two implementations: Python in
`scripts/dev_tools/push_down_claude_customizations.py` and TypeScript in
`extensions/drm-copilot/src/lib/push-down/*`. Both implementations must publish the same payload.

## Scope

- **#507: Python/TypeScript root-folder parity.** Python `ROOT_FOLDERS` is `(Path(".claude"),)`.
  TypeScript `ROOT_FOLDERS` is `[".claude", "config"]`. Add `config` to the Python side, along
  with the `config/orchestration-routing.json` merge behavior that the TypeScript side applies
  (`claude-routing-merge.ts`), so the Python path does not overwrite a destination routing file.
  Add a parity test that fails if the two lists diverge. This also covers #764 part 2
  (2026-09-29 consolidation comment on #507).
- **#763: Unbundled parallel-skill CLIs.** `parallel-orchestrate` invokes
  `scripts.dev_tools.parallel_drift_detection_cli`, and `parallel-remove` invokes
  `scripts/dev_tools/parallel_mutation_abandon_cli.py`. Neither script ships in the bundle. Port
  both to destination-runtime scripts under `.claude/lib/`, following the precedent of
  `compute-cohorts.sh` and `validate-parallel-manifest.sh`, or bundle them. Then remove the
  `KnownUnbundledReference` exceptions in `scripts/dev_tools/skill_bundle_contract.py`.
- **#508: Merge the destination blast-radius file.** Stop overwriting
  `config/blast-radius.json` wholesale. Merge the destination's existing file the way the routing
  file is merged, or provide a documented destination-local extension point that survives a
  push. Implement the change in both implementations.
- **#621: Destination-side exclusion manifest.** Design a destination-side record of paths
  excluded from push-down, then implement it in both implementations. The push-down consults the
  record before writing and either skips each excluded path or reports a conflict. It never
  overwrites an excluded path silently.

## Non-Goals

- Issue #769 (`enforce-powershell-batch-budget.ps1` orchestration awareness). Another session is
  orchestrating it, and no child of this epic modifies its files.
- The Copilot and Codex push-down surfaces are out of scope, except where a shared helper must
  change to keep the Claude surfaces consistent.
- New Python legs in any pushed-down enforcement hook. The hooks stay bash or PowerShell.

## Shared Design

- **Parity is structural.** Both implementations must agree on published roots, merged paths,
  and, after #621, exclusion semantics. Each child that changes one implementation changes the
  other in the same PR and extends the parity test that #507 introduces.
- **Merge registry.** #507 extends the Python push-down with the routing-file merge. #508
  generalizes this from one merged path to a set of merged paths, and it adds a blast-radius
  merge. #621 adds an exclusion filter ahead of the write and merge step. Each downstream child
  builds on the upstream child's contract and does not replace it.
- **Destination runtime.** Anything a pushed-down skill invokes must run in a consumer without
  Poetry or `scripts/dev_tools/`. Bash is preferred and PowerShell is acceptable.

## Decomposition and Waves

Dependency edges reflect real contracts only:

- #508 depends on #507. The Python path must publish `config/` before a blast-radius merge can
  apply to it, and #508 generalizes the merge mechanism that #507 introduces in Python.
- #621 depends on #507 and #508. The exclusion filter sits in front of the full write and merge
  pipeline, including both merged paths, so its design consumes the final shape of that pipeline.
- #763 has no edge. It changes skill text, `.claude/lib/` scripts, and the bundle contract. It
  does not change the push-down write pipeline.

Wave assignment by longest-path layering (`scripts/dev_tools/epic_wave_computation.py`):

| Wave | issue_num | Feature | Complexity |
| --- | --- | --- | --- |
| 0 | 507 | push-down-root-folders-divergence | C3 |
| 0 | 763 | parallel-skills-invoke-unbundled-python-clis | C3 |
| 1 | 508 | blast-radius-config-has-no-merge-decorator | C3 |
| 2 | 621 | push-down-destination-exclusion-manifest | C4 |

## Complexity Rationale

- **#507, C3.** This is a cross-module contract change (`cross_module_contract_change`). The
  published payload of the Python entry point changes, and a routing-merge port plus a parity
  test span both languages.
- **#763, C3.** Two Python CLIs are ported to destination-runtime scripts with behavioral
  parity. The change also touches skill text and the bundle contract guard across module
  boundaries.
- **#508, C3.** The change alters destination-write semantics in both implementations, and it
  generalizes the single-path merge into a merge set.
- **#621, C4.** No design exists yet. The destination manifest format, its location, the conflict
  reporting, and the interaction with merged paths all require research. The band is reached by
  judgment.

## Epic-Worthiness

The epic has four independently mergeable children. #621 requires a new design, and #763 ports two
CLIs with tests. The combined scope spans two languages and both push-down implementations,
which is more than a single large-path feature can carry. The verdict is **epic**.
