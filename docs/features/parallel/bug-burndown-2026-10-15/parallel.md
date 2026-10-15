---
parallel: "bug-burndown-2026-10-15"
mode: "closed"
max_concurrency: 6
created_at: "2026-10-15T11:39:07Z"
items:
  - issue_num: 927
    feature_folder: "2026-10-15-pr-author-docs-only-exemption-hardening-927"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 928
    feature_folder: "2026-10-15-subagentstop-hook-uncaught-error-exits-1-928"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 929
    feature_folder: "2026-10-15-subagentstop-artifact-gates-review-notes-929"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 930
    feature_folder: "2026-10-15-host-bootstrap-does-not-install-poetry-930"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 931
    feature_folder: "2026-10-15-release-flow-waits-on-required-checks-only-931"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 932
    feature_folder: "2026-10-15-plan-validator-accepts-bare-scratch-paths-932"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 933
    feature_folder: "2026-10-15-npm-token-guard-misses-append-assignment-933"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 934
    feature_folder: "2026-10-15-workspace-encoding-test-host-specific-paths-934"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 935
    feature_folder: "2026-10-15-hook-test-isolation-737-remainder-935"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 936
    feature_folder: "2026-10-15-hook-coverage-attribution-gaps-936"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 937
    feature_folder: "2026-10-15-exempt-operand-unc-path-leg-937"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 938
    feature_folder: "2026-10-15-test-support-hygiene-793-skipif-938"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 543
    feature_folder: "2026-10-15-epic-planner-receipt-checks-key-gate-543"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 884
    feature_folder: "2026-10-15-untouched-files-coverage-verification-884"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
  - issue_num: 940
    feature_folder: "2026-10-15-dependabot-bumps-types-vscode-past-engines-940"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "2026-10-15T11:39:07Z"
---

# Parallel Run: bug-burndown-2026-10-15

Draft manifest written at intake. Items are in state `proposed`; blast radii are placeholders until each item is prepared, and the final manifest replaces them with declared radii.

| group | issue_num | scope summary |
| --- | --- | --- |
| I01 | 927 | pr-author docs-only exemption hardening |
| I02 | 928 | High severity |
| I03 | 929 | E3 review notes NB-1..NB-5 and NB-7..NB-11 |
| I04 | 930 | The host bootstrap installs poetry when it is missing, with tests. |
| I05 | 931 | Invoke-FullReleaseFlow.ps1 waits on ALL checks: drop --required and use a positive assertion that every check completed successfully, with tests and mirrors. |
| I06 | 932 | The plan validator rejects bare SCRATCH definitions, with tests |
| I07 | 933 | The npm-token guard catches NPM_TOKEN+= (operator decision: catch it) |
| I08 | 934 | Replace the host-specific paths in workspace-encoding.test.ts with host-neutral fixtures. |
| I09 | 935 | #737 remainder |
| I10 | 936 | Cover modes.ps1 line 41, and fix or document the epic-scope lines 206-207 coverage attribution. |
| I11 | 937 | UNC and extended-length path legs in the targets resolver (all 4 copies): fail closed or resolve correctly, with tests. |
| I12 | 938 | Move the #793 test builders into a test-support module and fix the stale skipif. |
| I13 | 543 | Key-gate the per-feature model_routing_receipt and topology_receipt checks in scripts/dev_tools/validate_epic_planner_state.py (lines 222-276, called at line 342) and the TypeScript twin epic-planner-state-core.ts, so the checks apply only when the key is present, with tests on both sides |
| I14 | 884 | Verify the Codex half (.codex/hooks/validate-feature-review-coverage.ps1 coverage, measured at 100% by epic #904 E4) and the bash half (PR #917) |
| I15 | 940 | Dependabot npm PRs fail CI because grouped updates bump @types/vscode above engines.vscode and vsce package then fails Publish to Marketplace (PR #833, run 38311531357) |
