# Fail-Before Exception Dossier (P2-T2)

Timestamp: 2026-09-27T09-18

WhyFailingRunImpossible: The current tree already satisfies AC1: `git grep -n NPM_TOKEN -- .github` exits 1 with no output (`docs/features/active/unused-npm-token-secret-712/evidence/baseline/ac1-github-npm-token-grep.2026-09-27T09-14.md`). A failing tree-scan run would therefore require editing a file under `.github/`, which spec.md places out of scope, and writing a temporary fixture file instead is prohibited by `.claude/rules/general-unit-test.md`.

## Alternative Proof

Artifact: `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/guard-detection.2026-09-27T09-17.md` (17 passed, EXIT_CODE 0).

The following seven parametrized positive cases are in-memory reintroductions. Each passes by asserting a non-empty, exact line-number result from the same helper the tree scan uses, which shows the tree scan would fail if the shape were reintroduced under `.github/`:

From P1-T2, `find_npm_token_references`:

1. `test_find_npm_token_references_detects_reintroduced_reference[dot-access]` - `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}` -> `[1]`
2. `test_find_npm_token_references_detects_reintroduced_reference[single-quoted-bracket]` - `${{ secrets['NPM_TOKEN'] }}` -> `[1]`
3. `test_find_npm_token_references_detects_reintroduced_reference[double-quoted-bracket]` - `${{ secrets["NPM_TOKEN"] }}` -> `[1]`
4. `test_find_npm_token_references_detects_reintroduced_reference[spaced-lowercase-dot]` - `${{ secrets . npm_token }}` -> `[1]`
5. `test_find_npm_token_references_detects_reintroduced_reference[third-line-of-three]` - three-line snippet, reference on line 3 -> `[3]`

From P1-T4, `find_node_auth_token_references`:

6. `test_find_node_auth_token_references_detects_reference[other-secret-name]` - `NODE_AUTH_TOKEN: ${{ secrets.NPM_PUBLISH_TOKEN }}` -> `[1]`
7. `test_find_node_auth_token_references_detects_reference[lowercase-second-line]` - `env:` / `  node_auth_token: x` -> `[2]`

## Search Record

SearchScope: docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/
SearchPatterns: fail-before-*.md, *fail*.md
SearchResult: none (search run before this file was written; this file is excluded)
