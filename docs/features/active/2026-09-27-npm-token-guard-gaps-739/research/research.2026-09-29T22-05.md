# Research: npm-token-guard-gaps (Issue #739)

Timestamp: 2026-09-29T22-05
Branch: bug/npm-token-guard-gaps-739
Work mode: minor-audit (complexity band C3)
Requirements source: `docs/features/active/2026-09-27-npm-token-guard-gaps-739/issue.md` (no issue comments)

## Summary

The #712 guard (`tests/scripts/dev_tools/test_workflow_npm_token_guard.py`, 263 lines) detects two families: `secrets.NPM_TOKEN` / `secrets['NPM_TOKEN']` (line 30-32) and any word-bounded `NODE_AUTH_TOKEN` (line 33). It scans every `*.yml`/`*.yaml` under `.github/` (line 79-98). The #712 code review recorded the same gaps as non-blocking follow-ups (`docs/features/completed/unused-npm-token-secret-712/code-review.2026-09-27T09-35.md:27` and `:122`).

Recommended approach (single change to the test module plus one runbook line):

1. Add one generic `_authToken` pattern in a new helper. It covers routes 1-3 (`.npmrc` writes, `NPM_CONFIG__AUTHTOKEN` / `npm_config__authToken` / registry-scoped `npm_config_//registry.npmjs.org/:_authToken`, and `npm config set ... _authToken`).
2. Extend the existing `NPM_TOKEN` context pattern from `secrets` to `secrets|vars` (route 4).
3. Add a new helper that detects `NPM_TOKEN` in an assignment position: a YAML mapping key or a shell/PowerShell assignment (route 5). The #712 decision D2 rejected a bare-substring match, so this helper does not flag comments or prose that lack an assignment shape.
4. Keep the scan scope at `.github/**/*.{yml,yaml}`. No `.npmrc` file exists in the repository today, so a repository-wide `.npmrc` scan is recorded as an open question, not a requirement.
5. Correct the module docstring, add the two missing bracket-form parametrized cases, and replace runbook step 2 so it points at the pending evidence record under `docs/features/completed/`.

Every proposed pattern was checked against `.github/` with ripgrep. The narrow probes for each route returned zero matches. The broad probes matched only `registry-url` (publish-mcp-npm.yml:54), `id-token: write` (publish-mcp-npm.yml:45), `secrets.VSCE_PAT` (publish-extension.yml:65), and "env vars" prose in an agent Markdown file. None of those lines matches a proposed pattern, so none of the proposed patterns matches the current tree. The Python regexes were not executed in this research. Behavior on the positive and negative example strings below was worked out by hand and must be confirmed by the new parametrized tests.

## Findings

### Q1. Detection patterns for the five uncaught routes

Current patterns (test file line 30-33):

- `_NPM_TOKEN_SECRET_REFERENCE = re.compile(r"secrets\s*(?:\.\s*NPM_TOKEN\b|\[\s*['\"]NPM_TOKEN['\"]\s*\])", re.IGNORECASE)`
- `_NODE_AUTH_TOKEN_REFERENCE = re.compile(r"\bNODE_AUTH_TOKEN\b", re.IGNORECASE)`

Neither matches `_authToken`, `NPM_CONFIG__AUTHTOKEN`, `vars.NPM_TOKEN`, or `NPM_TOKEN: ${{ secrets.OTHER }}`. `NODE_AUTH_TOKEN` has an underscore between `AUTH` and `TOKEN`, so it is a separate token from `_AUTHTOKEN` and neither pattern overlaps the other.

#### Routes 1-3: one generic `_authToken` pattern (subsumes all three)

Proposed constant and helper:

```python
_NPM_AUTH_TOKEN_CONFIG_REFERENCE = re.compile(r"(?<![A-Za-z0-9])_authtoken\b", re.IGNORECASE)

def find_npm_auth_token_config_references(text: str) -> list[int]: ...
```

Rationale:

- npm reads the auth token only through the `_authToken` configuration key, whether it is set in an `.npmrc` line, through an `npm_config_` environment variable (case-insensitive, `__` for the leading underscore), or through `npm config set`. Every one of the three routes therefore contains the literal `_authToken` in some casing.
- Lookbehind `(?<![A-Za-z0-9])` accepts a preceding `:` (`//registry.npmjs.org/:_authToken`), `_` (`NPM_CONFIG__AUTHTOKEN`, where the match starts at the second underscore), whitespace, quote, or start of line. It rejects an unrelated name that merely ends in `_AUTHTOKEN` after a letter or digit (for example `GH_AUTHTOKEN`), which limits false positives.
- Trailing `\b` rejects longer identifiers such as `_authTokens`.

Expected positives (proposed param ids):

| id | text |
|---|---|
| `npmrc-echo-registry-scoped` | `echo "//registry.npmjs.org/:_authToken=${TOKEN}" >> ~/.npmrc` |
| `npmrc-bare-key` | `_authToken=${TOKEN}` |
| `npm-config-env-upper` | `NPM_CONFIG__AUTHTOKEN: ${{ secrets.PUBLISH }}` |
| `npm-config-env-lower` | `npm_config__authToken: x` |
| `npm-config-env-registry-scoped` | `npm_config_//registry.npmjs.org/:_authToken: x` |
| `npm-config-set-bare` | `npm config set _authToken "$TOKEN"` |
| `npm-config-set-registry-scoped` | `npm config set //registry.npmjs.org/:_authToken "$TOKEN"` |

Expected negatives: `id-token: write` (`oidc-permission`), `registry-url: "https://registry.npmjs.org"` (`setup-node-registry-url`), `always-auth: true` (`always-auth`), `NODE_AUTH_TOKEN: x` (`node-auth-token-is-separate-family`), `GH_AUTHTOKEN: x` (`letter-prefixed-name`), `""` (`empty`).

A separate `npm config set` pattern is not needed. A command that sets `_authToken` is caught by the generic pattern, and a command that sets another key (`npm config set registry ...`) does not configure a token.

#### Route 4: `vars.NPM_TOKEN` (dot and bracket forms)

Extend the existing constant; the helper `find_npm_token_references` (line 36-56) keeps its name and signature, and its docstring (line 37-44) is updated to name both contexts:

```python
_NPM_TOKEN_CONTEXT_REFERENCE = re.compile(
    r"\b(?:secrets|vars)\s*(?:\.\s*NPM_TOKEN\b|\[\s*['\"]NPM_TOKEN['\"]\s*\])", re.IGNORECASE
)
```

The leading `\b` is new. It stops `mysecrets.NPM_TOKEN` from matching and does not change any existing positive case, because in each of them `secrets` follows `{ `, `[`, or the start of the string. Rename the constant from `_NPM_TOKEN_SECRET_REFERENCE` to reflect the wider context; it is module-private (leading underscore) and only line 55 references it. Update the tree-scan assertion message at line 240-241 to "NPM_TOKEN secret or variable references found".

New positives: `vars-dot` (`${{ vars.NPM_TOKEN }}`), `vars-bracket` (`${{ vars['NPM_TOKEN'] }}`). New negatives: `vars-longer-name` (`${{ vars.NPM_TOKEN_V2 }}`), `prefixed-context-name` (`${{ mysecrets.NPM_TOKEN }}`).

#### Route 5: an environment variable named `NPM_TOKEN` fed from another secret

Proposed constant and helper:

```python
_NPM_TOKEN_ASSIGNMENT = re.compile(
    r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=", re.IGNORECASE
)

def find_npm_token_assignments(text: str) -> list[int]: ...
```

- Branch 1 matches a YAML mapping key in block or flow style (`env:` / `NPM_TOKEN: ${{ secrets.PUBLISH }}`, `env: { NPM_TOKEN: x }`, `- NPM_TOKEN: x`, and reusable-workflow `secrets:` blocks that pass `NPM_TOKEN: ${{ secrets.X }}`). The lookbehind excludes `secrets.NPM_TOKEN`, `env.NPM_TOKEN`, `MY_NPM_TOKEN`, and hyphen-joined names.
- Branch 2 matches a shell or PowerShell assignment: `export NPM_TOKEN=...`, `echo "NPM_TOKEN=${{ secrets.X }}" >> "$GITHUB_ENV"`, `$env:NPM_TOKEN = '...'`. `\b` rejects `MY_NPM_TOKEN=` because `_` and `N` are both word characters.
- Neither branch matches `NPM_TOKEN_V2` because the name must be followed by an optional quote and then `:` or `=`.
- Consistent with D2 (`docs/features/completed/unused-npm-token-secret-712/spec.md:68-75`), a comment such as `# NPM_TOKEN is no longer used` is not reported because it has no `:` or `=` after the name. A comment written as `# NPM_TOKEN: removed` would be reported. That is an accepted residual (see Risks).

Proposed positives: `yaml-env-key-other-secret` (`env:\n  NPM_TOKEN: ${{ secrets.PUBLISH }}`, expected `[2]`), `yaml-flow-mapping` (`env: { NPM_TOKEN: x }`), `quoted-key` (`"NPM_TOKEN": x`), `shell-export` (`export NPM_TOKEN=x`), `github-env-append` (`echo "NPM_TOKEN=x" >> "$GITHUB_ENV"`), `powershell-env` (`$env:NPM_TOKEN = 'x'`), `lowercase-key` (`npm_token: x`).

Proposed negatives: `secrets-dot-context` (`${{ secrets.NPM_TOKEN }}`, which the route-4 helper reports instead), `env-context-read` (`${{ env.NPM_TOKEN }}`), `longer-name-key` (`NPM_TOKEN_V2: x`), `prefixed-name-key` (`MY_NPM_TOKEN: x`), `prose-comment` (`# NPM_TOKEN is no longer used`), `empty`.

#### False-positive scan of the current `.github/` tree

ripgrep (the Grep tool) does not support look-around, so I scanned with superset patterns. If a superset has zero matches in a file, the stricter proposed pattern also has zero matches there.

| Probe (case-insensitive) | Scope | Matches |
|---|---|---|
| `_authtoken` | all files under `.github/` | 0 |
| `NPM_TOKEN` | all files under `.github/` | 0 |
| `\b(?:secrets\|vars)\s*(?:\.\s*NPM_TOKEN\b\|\[\s*['"]NPM_TOKEN['"]\s*\])` (route-4 pattern, no look-around) | all files under `.github/` | 0 |
| `authtoken\|auth_token\|npm_config\|npm\s+(config\s+)?set\|\bvars\b` | all files under `.github/` | 1, `.github/agents/prd-feature.agent.md:36` ("env vars" in prose; not YAML, and not a `vars.NPM_TOKEN` shape) |
| `npm_token\|_authtoken\|node_auth_token\|always-auth\|registry-url\|npm config\|npm set\|\bvars\s*[.\[]\|_auth\b\|_password` | all files under `.github/` | 1, `.github/workflows/publish-mcp-npm.yml:54` (`registry-url: "https://registry.npmjs.org"`; no proposed pattern matches it) |
| `secrets\s*[.\[]\|token\|\$\{\{\s*vars\|env\.[A-Z]` | `.github/**/*.{yml,yaml}` | 2: `.github/workflows/publish-extension.yml:65` (`--pat ${{ secrets.VSCE_PAT }}`), `.github/workflows/publish-mcp-npm.yml:45` (`id-token: write`) |

Legitimate constructs confirmed not to match any proposed pattern: `id-token: write` (publish-mcp-npm.yml:45), `setup-node` `registry-url` (publish-mcp-npm.yml:54), `secrets.VSCE_PAT` (publish-extension.yml:65). `always-auth` and `GITHUB_TOKEN` do not appear in any `.github/` file. They are covered by the negative cases above so they stay unflagged if they are added later.

The OIDC workflow `.github/workflows/publish-mcp-npm.yml` publishes with `npm publish --provenance --access public` (line 95) under `id-token: write` (line 45) and sets no token. #739 must not edit this file; #723 edits it in the same parallel run. None of the proposed patterns matches any of its current lines. If #723 introduces a line matching a new pattern, the guard would fail on #723's branch or after both merge (see Risks).

### Q2. Scan scope beyond YAML

- `.npmrc` enumeration: Glob `**/.npmrc` returned no files, and Glob `**/*npmrc*` returned no files. A repository-wide case-insensitive Grep for `_authtoken` matched only Markdown documentation (`docs/features/active/2026-09-27-npm-token-guard-gaps-739/issue.md`, `docs/features/potential/promoted/2026-09-27-npm-token-guard-gaps.md`, and three #712 review artifacts under `docs/features/completed/unused-npm-token-secret-712/`). No configuration file contains `_authToken`.
- Non-YAML files under `.github/` that are not Markdown: `.github/codex/codex-web-setup.sh` and `.github/codex/codex-web-maintenance.sh` (Glob `.github/**/*.{sh,ps1,py,js,mjs,cjs,ts,json}`). Workflows do not invoke them (they are Codex web-environment scripts), and neither matches any probe above.
- Widening the scan to every file type under `.github/` would include agent and instruction Markdown. That Markdown already contains prose such as "env vars" (`.github/agents/prd-feature.agent.md:36`), and future documentation could quote `_authToken` or `NPM_TOKEN:` for explanatory reasons, which is the false-positive class D2 rejected.
- `package.json` files exist at the repository root, `extensions/drm-copilot/`, and `packages/mcp-server/`. A checked-in `.npmrc` at any of these roots containing `//registry.npmjs.org/:_authToken=${SOME_VAR}` would be a token route outside `.github/`. The workflow half of that route (`NPM_TOKEN:` or `NODE_AUTH_TOKEN:` assignment) is caught by the route-5 helper and the existing `NODE_AUTH_TOKEN` helper. An arbitrary-name variable (`SOME_VAR`) fed from a secret would not be caught unless `.npmrc` files are scanned.

Recommendation (minimum scope consistent with "Any route that configures a long-lived npm auth token in a workflow fails the guard"): keep the scan at `.github/**/*.{yml,yaml}` (spec D6, `docs/features/completed/unused-npm-token-secret-712/spec.md:103-109`). The issue scopes the expectation to workflows, and every route listed in Steps to Reproduce is expressed in workflow YAML. Record the `.npmrc` gap as an open question. If it is adopted, the smallest safe form checks the fixed candidate paths `REPO_ROOT/.npmrc`, `REPO_ROOT/extensions/*/.npmrc`, and `REPO_ROOT/packages/*/.npmrc` with the `_authToken` helper. It should not use `REPO_ROOT.rglob(".npmrc")`, which traverses `node_modules` and `.git` and would slow the test.

### Q3. Module docstring defect

Line 15-17 currently reads: "The repository root is derived from this file's own resolved location, and tracked files are read through ``pathlib`` only." The scan uses `Path.rglob` and `Path.is_file` (line 92-97) and `Path.read_text` (line 233, 254). It reads every matching file on disk, tracked or not, and has no version-control dependency.

Proposed replacement for line 15-17:

> The repository root is derived from this file's own resolved location, and files are enumerated and read from disk through ``pathlib`` only, whether or not version control tracks them. The module has no dependency on the current working directory, version-control state, or network access.

Line 5-7 (purpose) and line 9-13 (scope) should also be updated so the purpose names all detected families: the `NPM_TOKEN` secret or variable, `NODE_AUTH_TOKEN`, an `_authToken` configuration key in any form, and an `NPM_TOKEN` assignment.

### Q4. Bracket-form test gaps

Existing positive params for `find_npm_token_references` (line 104-118): `dot-access`, `single-quoted-bracket`, `double-quoted-bracket`, `spaced-lowercase-dot`, `third-line-of-three`. Spacing and lowercase are exercised only for the dot form. The bracket branch `\[\s*['\"]NPM_TOKEN['\"]\s*\]` with `re.IGNORECASE` handles both variants, but no case exercises either one.

New param ids to add to the positive list of `test_find_npm_token_references_detects_reintroduced_reference`:

- `spaced-bracket`: `"${{ secrets[ 'NPM_TOKEN' ] }}"`, expected `[1]`
- `lowercase-bracket`: `"${{ secrets['npm_token'] }}"`, expected `[1]`

Optional third case (also handled by `secrets\s*` and also untested): `space-before-bracket`: `"${{ secrets ['NPM_TOKEN'] }}"`, expected `[1]`.

### Q5. Runbook "Recording completion" step 2

Current text, `docs/features/completed/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md:136`:

> 2. Update the pending human-action status in `docs/features/active/unused-npm-token-secret-712/` from pending to complete: mark acceptance criterion AC4 in `issue.md` as satisfied and reference the issue #712 comment. This update may be made by the human or requested from an agent with a link to the comment.

Defects, verified:

- The path is stale. The feature folder is `docs/features/completed/unused-npm-token-secret-712/`. Line 136 is the only `features/active` or `features/completed` reference in the runbook (Grep).
- It changes AC4 status. `spec.md:98` (D5 option (a), adopted at `:100`) says AC4 is satisfied when the human action is recorded as pending. `spec.md:290` says post-human completion is recorded as an issue #712 comment plus an update to the pending evidence record, not as an AC4 status change. `spec.md:295` repeats this.
- The pending evidence record exists at `docs/features/completed/unused-npm-token-secret-712/evidence/other/human-action-pending.2026-09-27T09-19.md`. It has `Status: pending` (line 4), and line 11 says completion "will be recorded by a later update to this file and by a comment on issue #712".

Proposed replacement for line 136:

> 2. Update the pending evidence record `docs/features/completed/unused-npm-token-secret-712/evidence/other/human-action-pending.2026-09-27T09-19.md`: change `Status: pending` to `Status: complete`, and add the completion date and a link to the issue #712 comment from step 1. Do not change acceptance criterion AC4 in `spec.md`; AC4 was satisfied when the human action was recorded as pending (spec decision D5), and completion is recorded only by this follow-up note and the issue comment. Do not record any secret value, token value, abbreviated token string, or token ID in the record. This update may be made by the human or requested from an agent with a link to the comment.

### Q6. Tooling and coverage

- Targeted command, as used for #712 (`docs/features/completed/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-guard.2026-09-27T09-19.md:4`; recorded result "17 passed"): `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`.
- Full toolchain order from `spec.md:268-274`: `poetry run black <file>`, `poetry run ruff check <file>`, `poetry run pyright <file>`, the targeted pytest command, then `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Do not use `--cov=<file>.py` as coverage evidence (`spec.md:274`).
- Coverage: `pyproject.toml:119-127` sets `source = ["src", "scripts/dev_tools"]` and `omit = ["tests/*", "*/tests/*", ...]`. The test module is outside the coverage denominator, and no production file changes, so repository coverage cannot change and there are no changed production lines for the no-regression rule to apply to. The uniform thresholds still apply to the full-suite run: CI enforces `--min-line 85 --min-branch 75` via `scripts.dev_tools.check_python_coverage_thresholds` (`.github/workflows/_quality-checks.yml:82-86`). This change can neither satisfy nor break those thresholds.
- `pyproject.toml:116` `addopts` includes `--cov-report=lcov:artifacts/python/lcov.info`. The targeted run without `--cov` does not activate coverage collection. The full-suite run writes coverage artifacts under `artifacts/`.
- The Markdown runbook edit has no toolchain gate beyond whatever docs validation CI runs (`.github/workflows/_docs-validation.yml` is present; I did not check its contents here).

### Q7. File-size estimate

Current length: 263 lines. Estimated additions after Black formatting:

| Item | Lines (approx.) |
|---|---|
| Two new regex constants, route-4 constant edit | +6 |
| Two new helpers with docstrings (same shape as line 36-56) | +44 |
| Docstring updates (module, `find_npm_token_references`) | +6 |
| Route-4 and bracket params (4 positive, 2 negative) | +8 |
| `_authToken` helper: positive and negative parametrized tests | +55 |
| `NPM_TOKEN` assignment helper: positive and negative parametrized tests | +55 |
| Two additional tree-scan tests in the existing style (line 224-263) | +40 |
| Total | about 477 |

This is close to the 500-line limit. Recommended mitigation, which also removes duplication: replace the per-family tree-scan tests (line 224-263) with one test parametrized over `(finder, family_label)`. Optionally, have each `find_*` helper delegate to a private `_matching_line_numbers(pattern, text)`. With the parametrized tree scan, the estimate is about 425-440 lines. With the private delegate as well, it is about 400-415 lines.

## Numeric Derivation Evidence

No numeric acceptance criterion is proposed. The counts below support findings only.

### Claim: `.github/` YAML scan population is 15 files

- Complete Family: files under `.github/` with extension `.yml` or `.yaml`, recursively (the population enumerated by `enumerate_github_yaml_files`).
- Exhaustive Search Scope: `.github/` recursively, all subdirectories.
- Inclusion Rules: regular files ending in `.yml` or `.yaml`.
- Exclusion Rules: files outside `.github/`; other extensions.
- Primary Search Strategy or Query Expression: Glob `.github/**/*.{yml,yaml}`.
- Primary Member Set: `.github/dependabot.yml`, `.github/workflows/_build-check.yml`, `_docs-validation.yml`, `_drm-copilot-extension-tests.yml`, `_npm-audit-gate.yml`, `_poshqc.yml`, `_quality-checks.yml`, `_root-typescript-tests.yml`, `_security-scan.yml`, `_shell-coverage.yml`, `ci.yml`, `npm-audit-gate.yml`, `publish-extension.yml`, `publish-mcp-npm.yml`, `verify-published-releases.yml` (workflow files under `.github/workflows/`).
- Primary Count: 15.
- Cross-check Search Strategy or Query Expression: Grep pattern `^` with glob `**/*.y*ml`, `output_mode: count`, path `.github`.
- Cross-check Member Set: `.github/dependabot.yml` plus the same 14 files under `.github/workflows/` (`_shell-coverage.yml`, `_security-scan.yml`, `_root-typescript-tests.yml`, `_quality-checks.yml`, `_poshqc.yml`, `_npm-audit-gate.yml`, `_drm-copilot-extension-tests.yml`, `_docs-validation.yml`, `publish-extension.yml`, `_build-check.yml`, `ci.yml`, `publish-mcp-npm.yml`, `verify-published-releases.yml`, `npm-audit-gate.yml`).
- Cross-check Count: 15.
- Member-set Comparison: the normalized sets are identical (15 of 15). No `.yaml`-extension file exists.

### Claim: repository `.npmrc` population is 0 files

- Complete Family: files named `.npmrc` anywhere in the repository working tree.
- Exhaustive Search Scope: repository root recursively (Glob; gitignored paths such as `node_modules` may not be traversed by the tool, which is consistent with the intended exclusion).
- Inclusion Rules: basename `.npmrc`, or basename containing `npmrc`.
- Exclusion Rules: `node_modules`.
- Primary Search Strategy or Query Expression: Glob `**/.npmrc`.
- Primary Member Set: empty.
- Primary Count: 0.
- Cross-check Search Strategy or Query Expression: Glob `**/*npmrc*`, and repository-wide Grep `(?i)_authtoken` (`files_with_matches`) to find any configuration file carrying the key regardless of name.
- Cross-check Member Set: Glob empty. Grep matched only five Markdown documentation files (listed in Q2), none of which is an npm configuration file.
- Cross-check Count: 0 configuration files.
- Member-set Comparison: both strategies return the empty set of `.npmrc` / npm configuration files.

## Proposed Acceptance Criteria

- [ ] `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` defines a helper that reports every line containing an `_authToken` configuration key in any casing: a registry-scoped `.npmrc` line, a bare `_authToken=` line, `NPM_CONFIG__AUTHTOKEN`, `npm_config__authToken`, `npm_config_//registry.npmjs.org/:_authToken`, and `npm config set [//registry.npmjs.org/:]_authToken`. Each form has its own parametrized positive case.
- [ ] The `_authToken` helper does not report `id-token: write`, `registry-url: "https://registry.npmjs.org"`, `always-auth: true`, `NODE_AUTH_TOKEN: x`, or a letter-prefixed name such as `GH_AUTHTOKEN: x`. Each has a parametrized negative case.
- [ ] `find_npm_token_references` reports `vars.NPM_TOKEN` and `vars['NPM_TOKEN']` in addition to the existing `secrets` forms, with a parametrized positive case for each; `vars.NPM_TOKEN_V2` is a parametrized negative case.
- [ ] The module defines a helper that reports an `NPM_TOKEN` assignment: a YAML mapping key (block, flow, or quoted), a shell `NPM_TOKEN=` assignment including a `$GITHUB_ENV` append, and a PowerShell `$env:NPM_TOKEN =` assignment. Each has a parametrized positive case, and one case feeds the key from a differently named secret.
- [ ] The `NPM_TOKEN` assignment helper does not report `${{ secrets.NPM_TOKEN }}`, `${{ env.NPM_TOKEN }}`, `NPM_TOKEN_V2: x`, `MY_NPM_TOKEN: x`, or `# NPM_TOKEN is no longer used`. Each has a parametrized negative case.
- [ ] A tree-scan test asserts that no `*.yml`/`*.yaml` file under `.github/` has a line reported by any of the four helpers, and names each offender as `<relative-posix-path>:<line>`. The test passes on the current tree.
- [ ] Parametrized cases `spaced-bracket` (`${{ secrets[ 'NPM_TOKEN' ] }}`) and `lowercase-bracket` (`${{ secrets['npm_token'] }}`) exist for `find_npm_token_references` and pass.
- [ ] The module docstring no longer says "tracked files"; it states that files are enumerated and read from disk through `pathlib` whether or not version control tracks them, and it names every detected family.
- [ ] Runbook `docs/features/completed/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md` "Recording completion" step 2 names `docs/features/completed/unused-npm-token-secret-712/evidence/other/human-action-pending.2026-09-27T09-19.md` as the record to update, says not to change AC4 status (citing D5), and no longer references `docs/features/active/unused-npm-token-secret-712/` or `issue.md`.
- [ ] `.github/workflows/publish-mcp-npm.yml` is not modified by this change (`git diff --name-only origin/main...HEAD -- .github` produces no output).
- [ ] The test module is under 500 lines.
- [ ] `poetry run black`, `poetry run ruff check`, and `poetry run pyright` on the test module report no errors, `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` passes, and the full suite `poetry run pytest --cov --cov-branch --cov-report=term-missing` meets the 85% line and 75% branch thresholds.

## Risks

- Parallel-run interaction with #723. #723 edits `.github/workflows/publish-mcp-npm.yml` in the same run. If #723 adds a line containing `_authToken`, an `NPM_TOKEN:` key or assignment, or `vars.NPM_TOKEN`, the widened guard fails once both changes are on the same base. This is intended behavior, but it could surface as an unexpected failure on whichever PR merges second. Mitigation: rerun the guard after rebasing onto the other branch.
- Residual false positives from route 5. A YAML comment written as `# NPM_TOKEN: removed` or prose `NPM_TOKEN=` inside a `run:` echo string would be reported. This matches the D3 precedent (`spec.md:287`): the diagnostic names the line, and the fix is to reword it.
- Residual false negatives. A token passed through an arbitrarily named variable into a checked-in `.npmrc` outside `.github/` is not caught (Q2). Legacy basic-auth keys (`_auth`, `_password`, `username`) and `npm login` with piped credentials are not covered. Obfuscated construction (for example string concatenation that assembles `_authToken`) is not detectable by a textual guard.
- File size. Without consolidating the tree-scan tests, the estimate (about 477 lines) leaves little margin under the 500-line limit.
- Stale paths elsewhere in #712 documents. `human-action-pending.2026-09-27T09-19.md:6` and `spec.md:295-296` still reference `docs/features/active/unused-npm-token-secret-712/`. The issue asks only for the runbook step 2 fix, so these are left unchanged unless scope is widened (see Open Questions).
- Unexecuted regexes. The Python look-behind patterns were validated only through superset ripgrep scans and by hand. The parametrized tests are the verification of record.

## Open Questions

1. Should the guard also scan `.npmrc` files at the fixed package roots (`.npmrc`, `extensions/*/.npmrc`, `packages/*/.npmrc`) with the `_authToken` helper? None exist today. Adding the scan closes the arbitrary-variable-name route at small cost, but it goes beyond the issue's "in a workflow" wording.
2. Should the legacy npm credential keys `_auth` and `_password` be added to the `_authToken` pattern? They also configure long-lived registry credentials, but the issue does not list them.
3. Should `${{ env.NPM_TOKEN }}` be added to the route-4 context alternation (`secrets|vars|env`)? The route-5 helper already catches the definition when it is in YAML or `$GITHUB_ENV`, so this would duplicate detection.
4. Should the stale `docs/features/active/...` runbook path on line 6 of the pending evidence record be corrected in the same change? The issue does not name it. Correcting it would help whoever updates the record per the new step 2.
