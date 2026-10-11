---
parallel: "bug-burndown-2026-10-11"
mode: "closed"
max_concurrency: 4
created_at: "2026-10-11T11:55:42Z"
items:
  - issue_num: 899
    feature_folder: "2026-10-11-ci-green-gate-all-checks-and-codex-parity-899"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 890
    feature_folder: "2026-10-11-parallel-skills-python-engine-calls-and-enum-error-members-890"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 885
    feature_folder: "2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 902
    feature_folder: "2026-10-11-epic-integration-branch-not-synced-with-main-902"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 901
    feature_folder: "2026-10-11-pr-author-hook-docs-only-exemption-901"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 900
    feature_folder: "2026-10-11-concurrent-children-share-scratchpad-file-names-900"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 903
    feature_folder: "2026-10-11-round-2-review-nits-and-evidence-timestamps-903"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 886
    feature_folder: "2026-10-11-validator-file-path-invocation-repo-root-first-886"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 894
    feature_folder: "2026-10-11-product-name-examples-remain-in-generic-rules-894"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 898
    feature_folder: "2026-10-11-orchestrator-state-rule-sentence-dropped-850-898"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 895
    feature_folder: "2026-10-11-codex-web-setup-review-follow-ups-895"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 884
    feature_folder: "2026-10-11-compute-concurrency-batches-coverage-884"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 887
    feature_folder: "2026-10-11-host-tools-manifest-and-bootstrap-behavior-887"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 889
    feature_folder: "2026-10-11-argumentless-sort-ordering-and-comparator-coverage-gaps-889"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 543
    feature_folder: "2026-10-11-epic-planner-field-list-remainder-543"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
  - issue_num: 892
    feature_folder: "2026-10-11-push-down-ac22-test-command-omits-memory-tests-892"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-11T11:55:42Z"
---

# Parallel Run: bug-burndown-2026-10-11

Draft manifest written at intake. Items are in state `proposed`; blast radii are placeholders until each item is prepared, and the final manifest replaces them with declared radii.

| group | issue_num | also closes | scope summary |
| --- | --- | --- | --- |
| P1 | 899 | #891 | CI green gate rules require every check, not only required checks (#899): orchestrate S9 and the parallel-orchestrate child-DONE acceptance |
| P2 | 890 |  | Port the parallel-add, parallel-close and parallel-orchestrate skills' remaining Python engine calls (parallel_mutation_protocol decide_admission, recolor_unstarted, build_add_entry, decide_close, build_close_entry, build_requeue_entry) to the bash engine under .claude/lib/bash, with bundled mirrors; review the parallel-orchestrator.md poetry run python -c grant |
| P3 | 885 |  | parallel-add tells issue-number preparation children to record a top-level issue_adoption object, using the same issue-adoption line as parallel-plan; update the bundled mirror. |
| P4 | 902 |  | Operator decision (A): add an epic-orchestrate skill step that, before each wave, runs a main-sync as a dedicated chore child when the integration branch is behind origin/main (the PR #882 pattern) |
| P5 | 901 |  | Operator decision (A): the pr-author hook exempts branches whose diff from the base touches only docs/**, and fails closed on any other path (and on any diff it cannot compute) |
| P6 | 900 |  | Unique per-child scratch file names: the planning and execution contracts (atomic-plan Appendix H helper-script guidance and any orchestrate or executor text that names SCRATCH files) direct each child to a location or name unique to that child, for example SCRATCH/<issue>/ or an issue-number suffix. |
| P7+P8 | 903 |  | P7: evidence-timestamp conventions - evidence filenames carry the time each file is written, and internal Timestamp lines use one stated time zone; update the evidence-and-timestamp-conventions skill and whatever plan or executor guidance produces plan-time filenames |
| P9 | 886 |  | File-path entry scripts put the repository root FIRST in sys.path (insert at index 0) so the scripts package always imports from the invoked worktree, starting with scripts/dev_tools/validate_orchestration_artifacts.py and covering every other file-path entry script with the same append pattern |
| P10 | 894 |  | Remove product-name examples from pushed rule surfaces: src/TaskMaster.Domain in .claude/rules/parallel-orchestration.md, No-COM in .claude/rules/typescript.md and .claude/rules/csharp.md, with bundled mirrors; fix the typescript.md cross-reference to the renamed heading; pin per-file occurrence counts in test_push_down_issue_824_follow_ups.py (CR-5) |
| P11 | 898 |  | The operator APPROVED adding the #850 sentence to .claude/rules/orchestrator-state.md and its bundled mirror: for an explicit pull request number, the per-feature checkpoint the merge gate consults is the live worktree whose checkpoint records that number in pr_gate.pr_number or a standalone_merge_authorizations entry |
| P12 | 895 |  | codex-web-setup review follow-ups CR-1, CR-2, CR-3, CR-10, CR-11, CR-12, CR-14 for .codex/codex-web-setup.sh and its bats suites under tests/shell. |
| P13 | 884 |  | Bash half of #884 only: raise .claude/lib/bash/compute-concurrency-batches.sh kcov line coverage to at least 85% |
| P14+P15 | 887 | #888 | One item for the host-tool scripts (#887 and #888) |
| P16 | 889 |  | Operator decision: convert all 19 argument-less .sort() calls in extensions/drm-copilot/src/lib to compareCodePoint, and add the two test gaps (null-path tie branches; targetRole order assertion in engine-pipeline.test.ts). |
| P17 | 543 |  | #543 remainder |
| P18 | 892 |  | Docs only: amend the #790 spec.md Test Strategy pytest command (spec.md:196) used by AC-22 to include test_push_down_claude_memory_scope.py and test_push_down_claude_pack_memory_modes.py, as a planning-agent amendment with a recorded rationale; do not change the AC text itself. |
