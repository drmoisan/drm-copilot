# Code Review: unused-npm-token-secret (#712)

---

**Review Date:** 2026-09-27
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/unused-npm-token-secret-712`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue #712 in the branch name.
**Base Branch:** `origin/main` (`91cffc3b`, merge base `91cffc3bc1794336069649c39132a6c704416eec`)
**Head Branch:** `bug/unused-npm-token-secret-712` (`bf4dc2b1`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (263 lines), a pytest module that scans every `*.yml`/`*.yaml` file under `.github/` and fails when a line references the `NPM_TOKEN` secret (dot or bracket access, case-insensitive, whitespace-tolerant, word-bounded) or mentions `NODE_AUTH_TOKEN` (word-bounded, case-insensitive). It also appends one sentence to the superseded notice in `docs/engineering/npm-token-rotation.runbook.md` and adds the feature folder (spec, plan, research, human-exception runbook, 36 evidence files). No production code, workflow, or configuration file changed.

Evidence reviewed: the full `origin/main...HEAD` diff via regenerated `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (head `bf4dc2b1`); reviewer check-only runs of Black, Ruff, Pyright, and the guard tests; a reviewer regex probe of 20 reintroduction shapes run from the session scratchpad against the module's own helpers; the #510 failure reproduction; and CI run 36322316826 step conclusions. The implementation matches the spec's function list, test list, and constraints, and the tests are correct and readable. The findings below are non-blocking.

**What changed:**
- New guard module with `find_npm_token_references`, `find_node_auth_token_references`, `enumerate_github_yaml_files`, and 7 test functions (17 nodes).
- One-line documentation edit to the superseded engineering runbook.
- Feature-folder planning and evidence documents.

**Top 3 risks:**
1. The guard covers the two approved reintroduction families (D2, D3). A token-based publish that uses neither the `NPM_TOKEN` secret name nor `NODE_AUTH_TOKEN` (for example writing `_authToken=` into `.npmrc` from another secret, or setting `NPM_CONFIG__AUTHTOKEN`) passes the guard.
2. The enumeration reads the filesystem (`rglob`) rather than the git index, so an untracked YAML file under `.github/` would be scanned locally. This can only add false positives, not false negatives; none exists today.
3. Plan tasks P5-T5, P5-T7, P5-T8, P6-T3, P6-T8 remain unchecked under the plan's strict baseline-membership rule even though the CI full-suite evidence now satisfies the substantive condition; a completion gate that counts plan checkboxes could stall on this bookkeeping.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; the guard, documentation edit, and evidence meet spec AC1-AC4, and the Linux CI full suite is green at the branch head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (non-blocking) | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 30-33 (regexes) | Token-based publish shapes outside the two approved families are not detected: `run: echo '//registry.npmjs.org/:_authToken=${NPM_AUTH}' > ~/.npmrc` fed by `NPM_AUTH: ${{ secrets.NPM_PUBLISH_TOKEN }}`; `NPM_CONFIG__AUTHTOKEN: ${{ secrets.X }}`; `npm config set //registry.npmjs.org/:_authToken ...`; an env var named `NPM_TOKEN` fed by another secret (`NPM_TOKEN: ${{ secrets.PUBLISH }}`); `${{ vars.NPM_TOKEN }}`. | Open a follow-up to add a third case-insensitive pattern for `_authToken` / `npm_config_.*authtoken` with matching parametrized positive and negative cases. | D3's stated goal is to catch a token-based publish "under any secret name"; `NODE_AUTH_TOKEN` is the `actions/setup-node` convention but not the only way to hand npm a token. The narrower scope was approved (D2, D3), so this is a hardening item, not a defect against the spec. | Reviewer probe (scratchpad script importing the module): all listed shapes returned `npm=[] node=[]`. |
| Info | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 30-33 | Requested shapes verified as detected: `secrets[ 'NPM_TOKEN' ]`, `secrets[ "NPM_TOKEN" ]`, `secrets['npm_token']`, `SECRETS.NPM_TOKEN`, env-var indirection where the `NPM_TOKEN` secret feeds any env name (`TOKEN: ${{ secrets.NPM_TOKEN }}`), and a `setup-node` `token:` input fed by `secrets.NPM_TOKEN`. A UTF-8 BOM before `NODE_AUTH_TOKEN` is still matched. | None. | Confirms the regex handles whitespace, quote style, and case as specified in D2/D3. | Reviewer probe: each case returned `npm=[1]` (or `node=[1]` for the BOM case). |
| Info | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 52-56, 72-76 | Textual line-wise matching cannot see dynamic or split access: `secrets[format('{0}_TOKEN', 'NPM')]`, `toJSON(secrets)`, and an expression split across lines (`secrets` / `.NPM_TOKEN`) are not reported. | Accept; document as a known limit if the follow-up above is opened. | These forms are uncommon in workflows and are not reliably detectable without evaluating expressions. | Reviewer probe: `format-indexed`, `tojson-secrets`, `multiline-split` returned `[]`. |
| Nit (non-blocking) | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 101-120 | The spaced bracket form `secrets[ 'NPM_TOKEN' ]` and lowercase bracket form `secrets['npm_token']` are handled by the regex but have no dedicated parametrized case, so a later regex edit could drop them without a test failure. | Add two `pytest.param` entries (`spaced-bracket`, `lowercase-bracket`) to the positive matrix in a follow-up. | Locks the documented behavior (docstring lines 39-41) into the test matrix. | Test list in module; reviewer probe results. |
| Nit (non-blocking) | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 15-17, 92-97 | The module docstring says "tracked files are read through `pathlib` only", but `enumerate_github_yaml_files` uses filesystem `rglob`, which also returns untracked or gitignored YAML files. This is the same class of behavior as issue #510, although here it can only produce false positives. `rglob` patterns are also case-sensitive on Linux (`*.YML` would be skipped there). | Reword the docstring to "files under `.github/`" or filter against `git ls-files` output in a follow-up; not required for this change. | Keeps the docstring accurate; today `git status --ignored --porcelain -- .github` is empty and all 15 tracked YAML files use lowercase extensions. | `git status --ignored --porcelain -- .github` (no output); `git ls-files .github`. |
| Info | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 94-95 | Only `*.yml`/`*.yaml` files are scanned; `.github/codex/codex-web-maintenance.sh` and `.github/codex/codex-web-setup.sh` are not. | None required. | Shell scripts cannot read the `secrets` context directly; a token would have to be passed in from a YAML file, which is scanned. | `git ls-files .github`. |
| Minor (non-blocking) | `docs/features/active/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md` | line 136 ("Recording completion" step 2) | The step directs marking AC4 in `issue.md` after the human action. For `full-bug`, `spec.md` is the AC source and AC4 is already checked at the pending stage (D5). | In a follow-up, change the step to "update `evidence/other/human-action-pending.<ts>.md` to complete and reference the issue #712 comment"; leave AC4 unchanged. | Avoids an operator editing the wrong file or reopening AC4. `spec.md` Risks & Mitigations already records this observation. | Runbook line 136; `spec.md` line 280. |
| Info | `docs/features/active/unused-npm-token-secret-712/plan.2026-09-27T00-23.md` | tasks P5-T5, P5-T7, P5-T8, P6-T3, P6-T8 | These tasks are unchecked because the local full suite failed on the #510 node, which the plan's rule does not exempt. CI run 36322316826 now shows the full suite and threshold gate green on Linux at `bf4dc2b1`. | Orchestrator to reconcile the plan checkboxes using `evidence/qa-gates/ci-python-full-suite.2026-09-27T09-35.md`. | Bookkeeping only; the substantive condition is met. | `evidence/qa-gates/ac2-verification.2026-09-27T09-22.md`; CI job step conclusions. |
| Info | `docs/engineering/npm-token-rotation.runbook.md` | line 3 | The appended sentence is present once, on the notice line, and is the only change (`git diff --numstat` `1 1`). Tone is factual. | None. | Satisfies D4 and AC3. | `git diff origin/main...HEAD -- docs/engineering/npm-token-rotation.runbook.md`. |
| Info | `.github/` | n/a | No workflow or other `.github/` file changed; `publish-mcp-npm.yml` remains OIDC-only. No workflow security regression. | None. | The change only adds a guard against regression. | `git diff --name-only origin/main...HEAD -- .github` (no output). |

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Detection is split into pure `str -> list[int]` helpers, so the fail-before proof uses the exact code path the tree scan uses, without temporary files or workflow edits.
- The non-vacuity test asserts both a non-empty enumeration and membership of `.github/workflows/publish-mcp-npm.yml`, which guards against a wrong `parents[3]` root silently passing.
- Diagnostics name every offender as `<relative-posix-path>:<line>` and state why tokens are not allowed.
- Word boundaries prevent false positives on `NPM_TOKEN_V2` and `MY_NODE_AUTH_TOKENS`; the `secrets` prefix requirement keeps explanatory comments such as `# NPM_TOKEN is no longer used` from failing the first guard (D2).

#### Typing and API notes

- All helpers and tests are fully annotated; no `Any`, `# noqa`, or `# type: ignore`. No new public Python API surface was added outside the test module.

#### Error handling and logging

- No exception handling; decode or read errors propagate as test errors, matching the spec's fail-fast requirement. `read_text(encoding="utf-8")` is explicit, so behavior does not depend on the platform default encoding.

---

## Test Quality Audit

The guard's own tests pass (17/17) and cover positive, negative, boundary, multi-line, and non-vacuity cases. The fail-before requirement is met by in-memory reintroductions that return exact line numbers from the helpers the tree scan uses; a real failing tree run is not possible without editing `.github/`, which is out of scope.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` — 7 test functions, 17 nodes; reviewer run `17 passed in 0.05s`.
- `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/guard-detection.2026-09-27T09-17.md` — per-node PASSED list for all 17 nodes.
- `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/fail-before-exception.2026-09-27T09-18.md` — rationale and alternative proof for fail-before.
- `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/guard-constraint-scan.2026-09-27T09-17.md` — no `tempfile`, `tmp_path`, `subprocess`, `origin/main`, `urllib`, or `socket` token in the module.
- `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-coverage.2026-09-27T09-20.md` — local full suite 5148 passed, 1 failed (#510), coverage unchanged at 91%.
- `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/ci-python-full-suite.2026-09-27T09-35.md` — CI Linux full suite and threshold gate success on 3.10-3.13 at `bf4dc2b1`.

### Quality assessment prompts

- **Determinism:** no clock, randomness, network, subprocess, or git; enumeration is sorted.
- **Isolation:** each function targets one helper or one tree-scan property.
- **Speed:** 0.05s for the module.
- **Diagnostics:** assertion messages include input, observed, and expected values, or the offending `path:line` list.

Linux portability: root derivation uses `Path(__file__).resolve().parents[3]`; comparisons use `relative_to(...).as_posix()`; no drive letters or backslashes. The four `ubuntu-latest` CI jobs passed.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | `git grep -n -E "npm_[A-Za-z0-9]{30,}\|ghp_[A-Za-z0-9]{20,}"` over the feature folder and the module exits 1; `evidence/other/human-action-pending.2026-09-27T09-19.md` records `CredentialData: none recorded`. |
| No unsafe subprocess or command construction | PASS | The module has no subprocess use. The runbook's `gh secret delete` and `npm token revoke` commands are for a human operator and carry no credential values. |
| Input validation at boundaries | N/A | Test module; inputs are repository files and literals. |
| Error handling remains explicit | PASS | Errors propagate; no broad `except`. |
| Configuration / path handling is safe | PASS | Root from `__file__`; no CWD dependency; no absolute paths in the module or evidence. |
| Workflow security regression | PASS | No `.github/` change; `permissions: id-token: write` publish path is unchanged; guard adds a regression check. |

---

## Research Log

No external research was required for this review. The regex probe and CI queries were run directly. The spec's assumption that GitHub secret-name matching case sensitivity is undocumented was not re-researched; the guard's case-insensitive match is the conservative choice either way.

---

## Verdict

The change is ready for the normal PR flow. The guard implements D1-D3 and D6 as specified, detects the requested realistic shapes (spaced bracket access, lowercase names, env-var indirection from the `NPM_TOKEN` secret), is Linux-portable, and uses no temporary files, subprocesses, network, or `origin/main`. The documentation edit is a single line, and no workflow file changed.

Non-blocking follow-ups: widen detection to `_authToken`/`npm_config_*authtoken` shapes, add parametrized cases for spaced and lowercase bracket access, correct the "tracked files" docstring wording, fix the feature runbook's AC4 recording step, and reconcile the unchecked plan tasks with the CI evidence.
