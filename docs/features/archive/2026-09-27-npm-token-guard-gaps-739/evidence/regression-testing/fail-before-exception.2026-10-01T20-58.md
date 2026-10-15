# Fail-before Exception Dossier (P1-T22)

Timestamp: 2026-10-01T20-58

WhyFailingRunImpossible: The current `.github/` tree contains no instance of any of the five routes listed in `issue.md` "Steps to Reproduce", so a failing run of the tree-scan test would require editing a `.github/` file, and this change must not edit `.github/` (plan constraint and AC10; `.github/workflows/publish-mcp-npm.yml` was most recently changed by #723, merged as PR #813). Writing a temporary fixture file to stage a failing tree is prohibited by `.claude/rules/general-unit-test.md`.

## Alternative Proof

The P1-T17 artifact `docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/regression-testing/guard-detection.2026-10-01T20-54.md` records 52 passed nodes. The following in-memory positive cases prove that each helper the tree scan (`test_github_yaml_files_contain_no_npm_token_route`) uses returns a non-empty result for a reintroduced route, without editing any workflow file:

- P1-T5 (`find_npm_token_references`): `spaced-bracket`, `lowercase-bracket`.
- P1-T6 (`find_npm_token_references`, `vars` context): `vars-dot`, `vars-bracket`.
- P1-T9 (`find_npm_auth_token_config_references`): `npmrc-echo-registry-scoped`, `npmrc-bare-key`, `npm-config-env-upper`, `npm-config-env-lower`, `npm-config-env-registry-scoped`, `npm-config-set-bare`, `npm-config-set-registry-scoped`.
- P1-T12 (`find_npm_token_assignments`): `yaml-env-key-other-secret`, `yaml-flow-mapping`, `quoted-key`, `shell-export`, `github-env-append`, `powershell-env`, `lowercase-key`.
- P1-T15 (`collect_offenders`, the diagnostic formatter the tree scan calls): `test_collect_offenders_names_each_matching_line` returns two `<path>:<line>` offenders for a reintroduced assignment.
- The pre-existing `test_find_node_auth_token_references_detects_reference` cases (`other-secret-name`, `lowercase-second-line`) cover the fourth helper, `find_node_auth_token_references`.

## Search Record

SearchScope: docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/regression-testing/
SearchPatterns: fail-before-*.md, *fail*.md
SearchResult: none (the directory held only `guard-constraint-scan.2026-10-01T20-56.md`, `guard-detection.2026-10-01T20-54.md`, and `guard-line-count.2026-10-01T20-56.md` when searched; this file was excluded because it was written after the search)
