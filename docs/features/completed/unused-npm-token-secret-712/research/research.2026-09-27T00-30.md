# Research: unused-npm-token-secret (Issue #712)

- Date: 2026-09-27
- Branch: `bug/unused-npm-token-secret-712`
- Base: `origin/main@2dce111e`
- Method: read-only inspection with Grep, Glob, and Read over the worktree. No secret value was read, printed, or handled. No `gh secret` command was run. Two vendor documentation pages were fetched (cited in section 7).
- Tool note: the Grep tool used here searches dot-directories. Verified by searching `VSCE_PAT` over the whole tree, which returned `.github/workflows/publish-extension.yml` alongside `README.md` and `extensions/drm-copilot/PUBLISHING.md`.

## 1. Inventory of `NPM_TOKEN` and `NODE_AUTH_TOKEN` references (outside `docs/features/**`)

Search: `NPM_TOKEN|NODE_AUTH_TOKEN` over the whole worktree with `docs/features/**` excluded, then repeated separately over `.github/`, `.claude/`, `.agents/`, and `extensions/`.

| Location | Line(s) | Classification | Notes |
|---|---|---|---|
| `docs/engineering/npm-token-rotation.runbook.md` | 1, 3, 9, 21, 27, 33 | Historical record (superseded) | Line 3 carries the #528 superseded notice. Steps 9 and 27 tell the reader to find and update the `NPM_TOKEN` row in repository secrets. |
| `docs/research/2026-05-04-publish-mcp-server-to-npm-research.md` | 15, 172, 177 | Historical record | This is the original point-in-time research that recommended a token (line 15). Its example workflow sets `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}` (line 172), which is not the shipped workflow. |

Zero matches in each of these:
- `.github/` (workflows, `dependabot.yml`). There is no `.github/actions/` directory; `Glob .github/**/*.y*ml` returned only `dependabot.yml` and the files under `workflows/`.
- `.claude/`, `.agents/`, `extensions/` (including the extension `resources/` bundle).
- `scripts/`, `README.md`, and any CHANGELOG. None of these appeared in the whole-tree search.

No live consumer exists. Neither entry is a dead reference in executable configuration. Both are prose documents.

`README.md` is already corrected. `README.md:402` reads "Credential: publication uses npm trusted publishing over OIDC (workflow permission `id-token: write`); no npm token secret is used."

## 2. Secrets referenced by each workflow (names only)

Primary search: `secrets\.[A-Za-z_]+` (only-matching) over `.github/workflows/`. Cross-check: case-insensitive `secret` over `.github/**/*.{yml,yaml}`, plus `github\.token|GITHUB_TOKEN|GH_TOKEN`. Both returned one hit and the same member.

| Workflow | Secrets referenced |
|---|---|
| `publish-mcp-npm.yml` | none. Auth is OIDC: `permissions: id-token: write` (line 45), `registry-url` (line 54), `npm install -g npm@11.18.0` (line 57), `npm publish --provenance --access public` (line 95). There is no `env:` block and no `NODE_AUTH_TOKEN`. |
| `publish-extension.yml` | `VSCE_PAT` (line 65, `vsce publish --pat ${{ secrets.VSCE_PAT }}`) |
| `verify-published-releases.yml`, `ci.yml`, `npm-audit-gate.yml`, `_build-check.yml`, `_docs-validation.yml`, `_drm-copilot-extension-tests.yml`, `_npm-audit-gate.yml`, `_poshqc.yml`, `_quality-checks.yml`, `_root-typescript-tests.yml`, `_security-scan.yml`, `_shell-coverage.yml` | none. No `secrets: inherit`, `GITHUB_TOKEN`, or `GH_TOKEN` appears. |

`publish-mcp-npm.yml` sets `registry-url`, so `setup-node` writes an `.npmrc` that expects a `NODE_AUTH_TOKEN` variable. The workflow never supplies one. npm CLI 11.18.0 with Node 24 meets the trusted-publishing minimums of npm 11.5.1 and Node 22.14.0 (npm docs, section 7).

## 3. Disposition of `docs/engineering/npm-token-rotation.runbook.md`

Every mention of the filename `npm-token-rotation`, found by a whole-tree Grep, is listed below. All are plain-text path mentions. None is a Markdown hyperlink, and none sits outside `docs/features/**`:
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/runbooks/burned-version-disposition.runbook.md:257`. This active runbook cites it as "Runbook structure and register precedent".
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/research/research.2026-08-24T12-45.md:1088`.
- Issue #528 artifacts under `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/`: `issue.md:89,98-99`, plan, research, audits, and evidence. These are recorded commands that name the path, for example `git ls-files --error-unmatch -- docs/engineering/npm-token-rotation.runbook.md`.
- Completed features: `2026-07-17-legacy-discovery-documentation-371` (research line 20, baseline evidence line 19) and `2026-07-03-npm-publish-404-and-vsce-bundling-warning-283`. The #283 artifacts refer to that feature's own `runbooks/` copy, not the `docs/engineering/` copy.

Options:
1. **Keep as superseded, and add one sentence to the line-3 notice that references #712.** Suggested sentence: "The unused `NPM_TOKEN` repository secret is being removed under issue #712." This leaves every path mention valid and keeps the structural precedent that #526 cites. The runbook will stop implying the secret still exists.
2. **Keep unchanged.** #528 AC4 already satisfies the "marked superseded" branch of #712 AC3. This is the smallest change, but the runbook would still describe a secret that no longer exists after the human step.
3. **Delete.** This leaves an active runbook (#526 line 257) and the #528 evidence commands pointing at a missing file. If #528 evidence were re-run, `git ls-files --error-unmatch` would exit 1.
4. **Rewrite as a trusted-publishing troubleshooting runbook.** This is outside the scope of #712 and would overwrite the historical record.

**Recommendation: option 1.** It records the D4 follow-up in the document a maintainer is most likely to find, and it breaks no reference. Option 2 is an acceptable fallback if `spec.md` wants zero documentation edits. Leave `docs/research/2026-05-04-...` unedited, because dated research artifacts are point-in-time records. The guard in section 4 does not scan `docs/`.

## 4. Guard test design

### Precedent

- **Python:** `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`.
  - It computes `REPO_ROOT = Path(__file__).resolve().parents[3]` (line 17) and reads `.github/workflows/_quality-checks.yml` as UTF-8 text (lines 29-31).
  - It uses `yaml.safe_load` for structure (line 40). PyYAML is approved at `pyproject.toml:19`.
  - It also runs a plain substring assertion on the lowercased text (lines 83-91), which is the same shape as this guard.
- **Pester:** `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` and `VerifyPublishedReleasesWorkflow.Tests.ps1` read workflow text with `Get-Content` and match it with regular expressions.

### Language decision

- **Python (pytest)** runs in `_quality-checks.yml` on `ubuntu-latest` (line 10) across Python 3.10 to 3.13 (line 13). The job uses a default `actions/checkout@v7`, which is a depth-1 checkout.
- **Pester** runs in `_poshqc.yml` on `windows-latest` (line 10). It would not satisfy the requirement to run in Linux CI.
- **Recommendation: Python.**

### Path

Recommended path: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`.
- No production module exists to mirror. The only existing Python workflow-contract test lives in `tests/scripts/dev_tools/`, so this path follows precedent.
- `tests/scripts/dev_tools/` has no `__init__.py`, so pytest uses rootdir-based import. The basename must be unique across the test tree. Glob found no other `test_*secret*.py` file, and the only `test_*workflow*.py` is the precedent file.

### Assertion shape options

- **(a) Narrow denylist on `NPM_TOKEN`.** This maps one-to-one to AC2 and has no maintenance cost when unrelated secrets are added.
- **(b) Allowlist of every `secrets.X` reference.** This is broader, but every new secret requires a test edit. It still cannot detect an unused secret stored in GitHub Settings, because that state is not in the tree, so it does not address the root condition of #712.
- **(c) Literal `NPM_TOKEN` anywhere in workflow text.** This is simpler, but it also fails on explanatory comments.

**Recommendation: (a).** It has three parts.

**Pure helper.** Place it inside the test module:

```python
_FORBIDDEN_SECRET_REFERENCE = re.compile(
    r"secrets\s*(?:\.\s*NPM_TOKEN\b|\[\s*['\"]NPM_TOKEN['\"]\s*\])",
    re.IGNORECASE,
)
def find_npm_token_references(text: str) -> list[int]: ...  # returns 1-based line numbers
```

Match case-insensitively as a conservative choice. The GitHub docs page fetched for this research does not state whether secret-name lookup is case-sensitive, so this is unverified.

**Tree scan.**
- Enumerate `REPO_ROOT / ".github"` recursively for `*.yml` and `*.yaml`. This covers `workflows/` and any future `.github/actions/**`.
- Assert the enumerated set is non-empty and contains `publish-mcp-npm.yml`. This is a non-vacuity guard: a wrong root path would otherwise pass silently.
- Assert that `find_npm_token_references` returns `[]` for every file.
- Report failures as `path:line` in the assertion message.

**In-memory fixture cases (fail-before proof).** Use `pytest.mark.parametrize` over literal strings. No temporary files and no checked-in fixture are needed.
- Positive detection, where the helper must return the offending line numbers:
  - `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}`
  - `${{ secrets['NPM_TOKEN'] }}`
  - `${{ secrets . npm_token }}`
  - A multi-line YAML snippet in which the reference sits on line 3.
- Negative detection, where the helper must return `[]`:
  - `${{ secrets.VSCE_PAT }}`
  - `${{ secrets.NPM_TOKEN_V2 }}`, where the word boundary prevents a match
  - A comment mentioning NPM_TOKEN without the `secrets` context
  - An empty string

The positive cases show the guard fails when a reintroduction exists. The tree scan shows it passes on the current tree. Together they satisfy AC2 without editing any workflow.

**Optional extension, to be decided in `spec.md`.** A second helper could flag any `NODE_AUTH_TOKEN` assignment under `.github/`. That would also catch a token-based publish reintroduced under a different secret name. It is not required by AC2, so treat it as a spec decision and do not assume it.

### Constraints check

The design uses no `origin/main` access, no git subprocess, no gitignored input, no Windows path (`pathlib` only), no temporary files, and no network access. `.github/` is tracked, so it is present in a depth-1 checkout.

## 5. Runner, coverage, and exact commands

- **Discovery.** `pyproject.toml:113-116` sets `testpaths = ["tests"]`, and `addopts` writes lcov to `artifacts/python/lcov.info`, so the new file is collected by default.
- **Coverage.** `[tool.coverage.run] source = ["src", "scripts/dev_tools"]` and `omit` includes `tests/*` (`pyproject.toml:118-125`). The test module is outside the denominator. Because the change touches no production file, coverage cannot regress.
- **CI.** `ci.yml:12` calls `_quality-checks.yml`. That workflow runs `poetry run pytest --cov --cov-branch --cov-report=xml --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing` (lines 76-79) and then the threshold checker at 85/75 (lines 84-86).
- **Local loop:**
  1. `poetry run black tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  2. `poetry run ruff check tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  3. `poetry run pyright tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  4. `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`
  5. Run the full suite with `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
- Do not use `--cov=<file>.py` as evidence. It measures nothing, and in any case the target is a test file.
- **AC1 repository check.** Use `git grep -n -i -E "secrets *(\. *NPM_TOKEN|\[ *.NPM_TOKEN)" -- .github` with expected exit code 1 (no match). A simpler form, `git grep -n NPM_TOKEN -- .github`, also expects exit code 1. Both run on tracked files only.

## 6. Shared-file risk with sibling items (issues 706 to 716)

- The sibling item list for `parallel_slug: followups-2026-09-27` (recorded in `artifacts/orchestration/orchestrator-state.json`) is not available in this worktree. No `parallel-orchestrator-state.json` is present, and no sibling feature folders or potential records numbered 706 to 716 exist in the tree. Sibling scopes are therefore unknown.
- The only sibling identity observable here is the checked-out branch name `bug/preimplementation-gate-blocks-attribution-trailers-713`, which suggests #713 concerns the preimplementation-gate hook. That is unlikely to overlap.
- Files this item may touch, and their risk:
  - `docs/engineering/npm-token-rotation.runbook.md` (option 1 only): low. It is a single-line edit.
  - `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`: none. It is a new file.
  - `docs/features/active/unused-npm-token-secret-712/**`: none.
- This item should not touch `README.md` or any file under `.github/workflows/`. A sibling that edits `.github/workflows/*.yml` cannot conflict textually, but the new guard would run against its content. A sibling that adds `secrets.NPM_TOKEN` would fail this guard by design.
- The orchestrator should confirm sibling scopes against the parallel checkpoint before execution.

## 7. Human step (human-exception runbook content, no secret value handled)

1. **Delete the repository secret `NPM_TOKEN`.** Use either route:
   - github.com, then `drmoisan/drm-copilot`, then **Settings**, **Secrets and variables**, **Actions**, **Repository secrets**, then `NPM_TOKEN`, then **Remove**.
   - `gh secret delete NPM_TOKEN --repo drmoisan/drm-copilot`, run by a human with admin rights.
   - Verify with `gh secret list --repo drmoisan/drm-copilot`, which lists names only, and confirm that `NPM_TOKEN` is absent.
2. **Revoke the npm access token that backed the secret.** On npmjs.com, go to the profile menu, then **Access Tokens**. Identify the token by its name or creation date, which is at or before the first token-based release, and delete it. The token value is not needed and must not be copied.
3. **Confirm trusted publishing is intact.**
   - Go to npmjs.com, then the package `@danmoisan/drm-copilot-mcp`, then **Settings**, then **Trusted Publisher**.
   - Confirm the GitHub Actions entry names user `drmoisan`, repository `drm-copilot`, and workflow filename `publish-mcp-npm.yml`, with no environment unless one is intentionally configured.
   - Confirm the allowed actions permit a direct `npm publish`.
   - Source: npm Docs, "Trusted publishers for npm packages", https://docs.npmjs.com/trusted-publishers, fetched 2026-09-27. The page lists owner, repository, and workflow filename as required, and environment and allowed actions as optional.
4. **Optional hardening, recommended by the same npm page.** Under package **Settings**, **Publishing access**, select "Require two-factor authentication and disallow tokens". This also prevents a future token-based publish of the package.
5. **Confirm publishing still works without the secret.** The next `mcp-server-v*` tag publish must succeed. Its registry poll step (`publish-mcp-npm.yml:101-128`) serves as the check. No re-dispatch is needed solely for this change.
6. **Record the outcome.** Mark the human action as pending, and later complete, in the orchestrator checkpoint `human_interaction.requirements[]`, with `response: exception` and `runbook_path` set to the feature `runbooks/` file.

## Numeric Derivation Evidence

Numeric claim: the count of `NPM_TOKEN` secret references under `.github/` is 0 (supports AC1).

- **Complete Family:** every YAML file under `.github/`. That is the 14 files in `.github/workflows/` plus `.github/dependabot.yml`. No `.github/actions/` directory exists.
- **Exhaustive Search Scope:** `.github/` recursively, with no glob filter on the primary search.
- **Inclusion Rules:** any occurrence of `NPM_TOKEN`, or of `NODE_AUTH_TOKEN` (the variable a token-based npm publish sets), in any form.
- **Exclusion Rules:** none within `.github/`. `docs/**` is out of family.
- **Primary Search Strategy or Query Expression:** Grep `NPM_TOKEN|NODE_AUTH_TOKEN` over `.github/`, case-sensitive, content mode.
- **Primary Member Set:** {} (empty).
- **Primary Count:** 0.
- **Cross-check Search Strategy or Query Expression:** Grep `secret`, case-insensitive, over `.github/` with glob `*.{yml,yaml}`. This enumerates every secret reference of any name. A second pass used Grep `secrets\.[A-Za-z_]+` in only-matching mode over `.github/workflows/`.
- **Cross-check Member Set:** {`publish-extension.yml:65 secrets.VSCE_PAT`}. No member names `NPM_TOKEN`, so the `NPM_TOKEN` subset is {}.
- **Cross-check Count:** 0 `NPM_TOKEN` members (1 secret reference in total, `VSCE_PAT`).
- **Member-set Comparison:** the primary set {} equals the cross-check `NPM_TOKEN` subset {}. The two strategies are independent: one matches the literal name, the other enumerates the whole secrets context. The claim may be asserted.

No other numeric count is proposed for `spec.md`. The workflow-file count is given for context only and is not proposed as an acceptance criterion.

## Recommendations summary

1. No workflow code change is required. AC1 already holds; verify it with `git grep`.
2. Add the Python guard `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`. It uses shape (a): a pure regex helper, a non-vacuous scan of `.github/**/*.y*ml`, and parametrized in-memory positive and negative fixtures.
3. Keep `docs/engineering/npm-token-rotation.runbook.md` as superseded and add one sentence referencing #712. Do not delete it (five references in active and completed feature documents) and do not rewrite it. Leave `docs/research/2026-05-04-...` untouched.
4. Route secret deletion, npm token revocation, and the trusted-publisher check through a human-exception runbook under `docs/features/active/unused-npm-token-secret-712/runbooks/`. Record it as pending.

### Rejected alternatives

- Pester guard: CI runs Pester on `windows-latest` only.
- Allowlist guard (b): adds maintenance and cannot detect unused stored secrets.
- Deleting the runbook: breaks the active #526 citation and the #528 evidence commands.
