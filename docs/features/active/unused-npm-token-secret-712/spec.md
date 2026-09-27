# unused-npm-token-secret (Spec)

- **Issue:** #712
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T01-00
- **Status:** Approved (autonomous mode; design decisions adopted per orchestration kickoff)
- **Version:** 1.0
- **Work Mode:** full-bug (this file is the authoritative acceptance-criteria source)
- **Research:** `docs/features/active/unused-npm-token-secret-712/research/research.2026-09-27T00-30.md`
- **Human-exception runbook:** `docs/features/active/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md`

No secret value, token value, abbreviated token string, or token ID is read, printed, requested, or recorded by this change or by any artifact it produces.

## Context

- Summary: the GitHub Actions repository secret `NPM_TOKEN` is stored in `drmoisan/drm-copilot` but is referenced by no workflow. `.github/workflows/publish-mcp-npm.yml` publishes `@danmoisan/drm-copilot-mcp` through npm trusted publishing (OIDC): the `publish` job declares `permissions: id-token: write` (line 45) and runs `npm publish --provenance --access public`. Issue #528 (PR #701) corrected the README and marked `docs/engineering/npm-token-rotation.runbook.md` superseded; its decision D4 deferred deletion of the secret to this issue.
- Observed environment: GitHub repository settings for `drmoisan/drm-copilot`, and the npmjs.com account that owns `@danmoisan/drm-copilot-mcp`.
- Impact and severity: Low. A stored, unused, long-lived publish credential is exposure with no benefit. Its presence can also lead a maintainer to rotate it in response to a publish failure, as the pre-#528 README advised, which does not address the actual cause.
- First observed: 2026-09-26, during the #528 feature audit (`feature-audit.2026-09-26T23-49.md`, note on D4).

## Repro & Evidence

- Steps to reproduce:
  1. A repository admin lists repository secrets (names only) and observes `NPM_TOKEN`.
  2. Search `.github/` for `NPM_TOKEN`: no workflow references it.
- Expected: no unused long-lived publish credential is stored, and no automated check exists that would permit a token-based publish to be reintroduced unnoticed.
- Actual: the secret remains stored, and no test prevents a workflow from reintroducing `secrets.NPM_TOKEN` or a `NODE_AUTH_TOKEN` assignment.
- Evidence (verified 2026-09-27 on this branch, read-only):
  - Grep `NPM_TOKEN|NODE_AUTH_TOKEN` over `.github/` (all files): no matches.
  - Grep `TOKEN|secrets` (case-insensitive) over `.github/**/*.{yml,yaml}`: two lines, `publish-mcp-npm.yml:45 id-token: write` and `publish-extension.yml:65 secrets.VSCE_PAT`. Neither names `NPM_TOKEN` or `NODE_AUTH_TOKEN`.
  - The research record's `## Numeric Derivation Evidence` section provides the primary and cross-check derivations for the zero-reference claim used in AC1.
- Frequency: deterministic (repository state).

## Scope & Non-Goals

- In scope:
  - Verifying that no file under `.github/` references `NPM_TOKEN` (AC1).
  - Adding a Python guard test that fails if a YAML file under `.github/` reintroduces a `secrets.NPM_TOKEN` reference or any `NODE_AUTH_TOKEN` reference (AC2, D1-D3, D6).
  - A one-sentence addition to the superseded notice in `docs/engineering/npm-token-rotation.runbook.md` that points to issue #712 (AC3, D4).
  - Recording the human-exception step (secret deletion and npm token revocation) as pending, with the existing runbook as the procedure (AC4, D5).
  - Evidence files under the feature folder's canonical `evidence/<kind>/` directories.
- Out of scope / non-goals:
  - Deleting the repository secret or revoking the npm token by any agent. These are human actions (D5).
  - Any modification to a file under `.github/workflows/` or any other file under `.github/`.
  - Editing `README.md` (already corrected by #528; `README.md:402`).
  - Editing `docs/research/2026-05-04-publish-mcp-server-to-npm-research.md`, which is a dated point-in-time research record (D4).
  - Rewriting `docs/engineering/npm-token-rotation.runbook.md` into a trusted-publishing troubleshooting guide.
  - An allowlist of all secret names used by workflows (D2).
- Explicitly excluded systems: GitHub repository settings and npmjs.com are touched only by a human following the runbook. No `gh secret` command is run by an agent.

## Root Cause Analysis

- Confirmed root cause: the migration of `publish-mcp-npm.yml` to npm trusted publishing removed the workflow's use of `NPM_TOKEN` but did not remove the stored secret or the npm token that backs it. #528 D4 recorded this as a follow-up.
- Contributing condition: no automated check asserts that workflows remain token-free for npm publishing, so a later edit could restore `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}` (the shape shown in `docs/research/2026-05-04-publish-mcp-server-to-npm-research.md:172`) without any test failing.
- Affected components: GitHub repository secret `NPM_TOKEN`; the npm access token that backs it; `.github/workflows/publish-mcp-npm.yml` (unchanged, used as the non-vacuity anchor); `docs/engineering/npm-token-rotation.runbook.md` (superseded notice).

## Design Decisions

### D1 — Guard test language and location

- Options:
  - (a) Python pytest at `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`.
  - (b) Pester at `tests/scripts/workflows/`, following `PublishMcpNpmWorkflow.Tests.ps1`.
- Adopted: (a).
- Rationale: pytest runs in `_quality-checks.yml` on `ubuntu-latest` across Python 3.10 to 3.13; Pester runs only in `_poshqc.yml` on `windows-latest`. The precedent `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` already reads workflow YAML as text from this directory using `Path(__file__).resolve().parents[3]`. `tests/scripts/dev_tools/` has no `__init__.py`, so the basename must be unique across the test tree; no other `test_workflow_npm_token_guard.py` exists.

### D2 — Guard shape

- Options:
  - (a) Narrow guard that detects only `NPM_TOKEN` secret references (`secrets.NPM_TOKEN`, `secrets['NPM_TOKEN']`, with optional whitespace, case-insensitive, word-bounded).
  - (b) Allowlist of every `secrets.<NAME>` reference across workflows.
  - (c) Literal `NPM_TOKEN` substring anywhere in workflow text.
- Adopted: (a).
- Rationale: (a) maps one-to-one to AC2 and has no maintenance cost when an unrelated secret is added. (b) requires a test edit for every new secret and still cannot detect an unused secret stored in GitHub Settings, because that state is not in the tree. (c) also fails on explanatory comments that do not consume the secret.

### D3 — `NODE_AUTH_TOKEN` detection

- Options:
  - (a) Also flag any `NODE_AUTH_TOKEN` reference (word-bounded, case-insensitive) in any YAML file under `.github/`.
  - (b) Guard `NPM_TOKEN` only.
- Adopted: (a).
- Rationale: OIDC trusted publishing needs no token. A token-based publish reintroduced under a different secret name (for example `NODE_AUTH_TOKEN: ${{ secrets.NPM_PUBLISH_TOKEN }}`) would restore the same exposure and would pass a guard limited to `NPM_TOKEN`. Research item 1 and the 2026-09-27 re-check found no `NODE_AUTH_TOKEN` occurrence under `.github/`, so the guard passes on the current tree. A comment that mentions `NODE_AUTH_TOKEN` in a `.github` YAML file will also fail the guard; this is accepted as conservative, and the assertion message names the file and line so the author can reword the comment.

### D4 — Disposition of `docs/engineering/npm-token-rotation.runbook.md`

- Options:
  - (1) Keep with its superseded notice and append one sentence pointing to issue #712.
  - (2) Keep unchanged (#528 AC4 already marked it superseded).
  - (3) Delete.
  - (4) Rewrite as a trusted-publishing troubleshooting runbook.
- Adopted: (1).
- Rationale: deletion would leave plain-text path mentions dangling in other feature folders, including the active #526 runbook (`burned-version-disposition.runbook.md:257`, cited as structural precedent) and the #528 evidence commands (`git ls-files --error-unmatch -- docs/engineering/npm-token-rotation.runbook.md`). Option 2 was acceptable, but the runbook would continue to describe a secret that no longer exists after the human step; the pointer closes the loop at the location a maintainer is most likely to consult. Option 4 is outside the scope of #712 and overwrites a historical record. `docs/research/2026-05-04-publish-mcp-server-to-npm-research.md` stays unchanged.

### D5 — Human step

- Options:
  - (a) Human performs secret deletion and npm token revocation via the runbook; AC4 is satisfied when the runbook exists and the human action is recorded as pending; the run does not block.
  - (b) Block the run until the human confirms completion.
- Adopted: (a).
- Rationale: no repository automation holds credentials for GitHub repository settings or the npmjs.com account, and no agent may handle a secret value. Publishing does not depend on the secret, so the deletion is not a prerequisite for any repository change in this spec. Blocking would hold a completed, independently verifiable repository change on an out-of-band action.

### D6 — Scan scope and non-vacuity

- Options:
  - (a) Enumerate every `.yml` and `.yaml` file under `.github/` recursively, with the repository root derived from the test file location; assert the enumeration is non-empty and contains `.github/workflows/publish-mcp-npm.yml`; prove detection with parametrized in-memory positive and negative strings.
  - (b) Scan only `.github/workflows/*.yml`.
  - (c) Prove detection by editing a workflow or writing a temporary fixture file.
- Adopted: (a).
- Rationale: recursive enumeration also covers `.github/dependabot.yml` and any future `.github/actions/**` composite action. Deriving the root from `Path(__file__).resolve().parents[3]` removes any dependence on the current working directory. The non-empty and membership assertions prevent a wrong root from passing silently. In-memory strings prove the helper fails on a reintroduced reference without temporary files (prohibited by repository test policy), without workflow edits, and without dependence on `origin/main`, git subprocesses, gitignored state, network access, or Windows-specific paths. The scan does not assert a total file count, so sibling items that add or remove workflow files do not affect it.

## Proposed Fix

### Design summary (what changes where):

1. New test module `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` containing two pure detection helpers, one pure-ish enumeration helper, parametrized in-memory detection tests, and tree-scan tests over `.github/**/*.{yml,yaml}`.
2. One sentence appended to the superseded notice (line 3) of `docs/engineering/npm-token-rotation.runbook.md`.
3. Evidence files under `docs/features/active/unused-npm-token-secret-712/evidence/`.
4. The human-exception step is recorded as pending; no repository file is changed by the human step.

No file under `.github/workflows/` (or anywhere else under `.github/`) is modified.

### Boundaries and invariants to preserve:

- No secret or token value is read, printed, requested, or stored.
- No workflow file is modified; `publish-mcp-npm.yml` remains OIDC-only.
- The guard reads tracked files only through `pathlib` and has no git, network, or subprocess dependency.
- Existing plain-text references to `docs/engineering/npm-token-rotation.runbook.md` remain valid (the file is not moved or deleted).
- Merge-order independence: every edit is located by a text anchor, not a line number, and the guard holds whether or not sibling items (issues 706 to 716) merge first. A sibling that adds `secrets.NPM_TOKEN` or `NODE_AUTH_TOKEN` to a `.github` YAML file fails this guard by design.

### Dependencies or blocked work:

- None for the repository change.
- The human step (D5) is not a dependency of any acceptance criterion's check-off beyond being recorded as pending.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

| Path (repository-relative) | Change |
|---|---|
| `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | New file. Guard test module (D1-D3, D6). |
| `docs/engineering/npm-token-rotation.runbook.md` | One-sentence edit to the superseded notice (D4). |
| `docs/features/active/unused-npm-token-secret-712/evidence/baseline/ac1-github-npm-token-grep.<ts>.md` | New evidence file. Pre-change AC1 repository check output and exit code. |
| `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/toolchain.<ts>.md` | New evidence file. Black, Ruff, Pyright, and pytest results for the new module, plus the full-suite pytest coverage summary. |
| `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/guard-detection.<ts>.md` | New evidence file. Pytest output showing the parametrized positive cases (fail-before proof through in-memory reintroductions) and the tree-scan pass on the current tree. |
| `docs/features/active/unused-npm-token-secret-712/evidence/other/human-action-pending.<ts>.md` | New evidence file. Records the human-exception requirement as pending, with the runbook path and no credential data. |

`<ts>` is the ISO-8601 timestamp `yyyy-MM-ddTHH-mm` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No evidence is written under `artifacts/`. The orchestrator separately records the pending human action in `artifacts/orchestration/orchestrator-state.json` under `human_interaction.requirements[]` with `response: exception` and `runbook_path` set to the feature runbook; that checkpoint is orchestration state, not a deliverable of this spec.

Files that must not change: every file under `.github/`; `README.md`; `docs/research/2026-05-04-publish-mcp-server-to-npm-research.md`; `docs/features/active/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md` (already authored).

#### Functions/classes/CLI commands impacted:

New, module-private to the test file:

- `REPO_ROOT: Path = Path(__file__).resolve().parents[3]`
- `GITHUB_DIR: Path = REPO_ROOT / ".github"`
- `_NPM_TOKEN_SECRET_REFERENCE = re.compile(r"secrets\s*(?:\.\s*NPM_TOKEN\b|\[\s*['\"]NPM_TOKEN['\"]\s*\])", re.IGNORECASE)`
- `_NODE_AUTH_TOKEN_REFERENCE = re.compile(r"\bNODE_AUTH_TOKEN\b", re.IGNORECASE)`
- `find_npm_token_references(text: str) -> list[int]` — returns 1-based line numbers of lines matching `_NPM_TOKEN_SECRET_REFERENCE`; `[]` when none.
- `find_node_auth_token_references(text: str) -> list[int]` — returns 1-based line numbers of lines matching `_NODE_AUTH_TOKEN_REFERENCE`; `[]` when none.
- `enumerate_github_yaml_files(github_dir: Path) -> list[Path]` — sorted list of `*.yml` and `*.yaml` files under `github_dir`, recursive.

Test functions (pytest node IDs rooted at `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`):

- `test_find_npm_token_references_detects_reintroduced_reference` — parametrized positive cases; asserts the exact returned line numbers:
  - `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}` -> `[1]`
  - `${{ secrets['NPM_TOKEN'] }}` -> `[1]`
  - `${{ secrets["NPM_TOKEN"] }}` -> `[1]`
  - `${{ secrets . npm_token }}` -> `[1]`
  - a three-line YAML snippet with the reference on line 3 -> `[3]`
- `test_find_npm_token_references_ignores_non_matching_text` — parametrized negative cases returning `[]`:
  - `${{ secrets.VSCE_PAT }}`
  - `${{ secrets.NPM_TOKEN_V2 }}` (word boundary)
  - `# NPM_TOKEN is no longer used` (no `secrets` context)
  - empty string
- `test_find_node_auth_token_references_detects_reference` — parametrized positive cases: `NODE_AUTH_TOKEN: ${{ secrets.NPM_PUBLISH_TOKEN }}` -> `[1]`; `env:\n  node_auth_token: x` -> `[2]`.
- `test_find_node_auth_token_references_ignores_non_matching_text` — parametrized negative cases returning `[]`: `id-token: write`, `MY_NODE_AUTH_TOKENS: x` (word boundary), empty string.
- `test_github_yaml_enumeration_is_non_vacuous` — asserts the enumeration is non-empty and that `.github/workflows/publish-mcp-npm.yml` (compared as a POSIX relative path) is a member.
- `test_github_yaml_files_reference_no_npm_token_secret` — for every enumerated file, reads UTF-8 text and asserts `find_npm_token_references` returns `[]`; the failure message lists every offender as `<relative-posix-path>:<line>`.
- `test_github_yaml_files_reference_no_node_auth_token` — same shape for `find_node_auth_token_references`.

No CLI command, production module, or public API changes.

#### Data flow and validation changes:

- Input: tracked YAML text under `.github/`, read with `Path.read_text(encoding="utf-8")`.
- Processing: line-wise regular-expression matching in the pure helpers.
- Output: pytest pass/fail with `path:line` diagnostics.
- No YAML parsing is required; matching is textual so that references in any key, block scalar, or expression are detected.

#### Error handling and logging updates:

- A decode error or unreadable file propagates as a test error (fail fast); it is not caught or skipped.
- A missing `.github/` directory, or one without `publish-mcp-npm.yml`, fails `test_github_yaml_enumeration_is_non_vacuous` with a message that states the resolved `GITHUB_DIR` relative to `REPO_ROOT`.
- No logging changes.

#### Rollback/feature-flag considerations (if applicable):

- Rollback of the repository change is a revert of the new test file and the one-sentence runbook edit. No feature flag is needed.
- The human step has no rollback; the runbook states that the secret and token must not be recreated as a remedy for a later publish failure.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Helpers accept `str` and return `list[int]` (1-based line numbers, ascending, one entry per matching line).
- The enumeration helper accepts a `Path` and returns `list[Path]` sorted by POSIX relative path for deterministic diagnostics.

#### Required configuration keys and defaults:

- None. Discovery relies on existing `pyproject.toml` settings (`testpaths = ["tests"]`). Coverage configuration (`source = ["src", "scripts/dev_tools"]`, `omit` includes `tests/*`) is unchanged.

#### Backward-compatibility expectations:

- No existing test, workflow, or document behavior changes other than the appended sentence.

#### Performance constraints (latency/throughput/memory):

- The module reads the YAML files under `.github/` once per scan test; expected runtime is well under one second. No explicit constraint beyond the general fast-test requirement.

### Documentation edit (D4) — exact change

- File: `docs/engineering/npm-token-rotation.runbook.md`.
- Anchor: the blockquote line that begins `> **Note:** This runbook is superseded;` and ends `Retained for historical reference only.`
- Change: append, on the same line after `Retained for historical reference only.`, a single space followed by: `The unused \`NPM_TOKEN\` repository secret is being removed under issue #712.`
- Idempotence: if the sentence is already present (for example after a rebase), do not add it again.
- If the anchor text is not found, stop and report; do not insert the sentence elsewhere.

## Assumptions, Constraints, Dependencies

- Assumptions:
  - GitHub secret-name matching case sensitivity is not documented in the source fetched for research; the guard matches case-insensitively as the conservative choice (unverified).
  - The CI pytest job uses a depth-1 checkout; `.github/` is tracked and present in that checkout.
- Constraints:
  - Temporary files in tests are prohibited; detection is proven with in-memory strings.
  - Test file must not exceed 500 lines.
  - No new dependencies (`re`, `pathlib`, and `pytest` only).
  - No absolute paths in artifacts.
- External dependencies: npm trusted publishing configuration for `@danmoisan/drm-copilot-mcp` (verified by the human in the runbook's Pre-check B, not by this change).

## Data / API / Config Impact

- User-facing or API changes: none.
- Data or migration considerations: none in the repository. The out-of-band human action removes one repository secret and one npm access token.
- Logging/telemetry updates: none.
- Compatibility notes: none. CI gains one test module in the existing pytest job.

## Test Strategy

- Regression tests to add: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (all seven test functions listed above).
- Unit tests for boundaries: word-boundary negatives (`NPM_TOKEN_V2`, `MY_NODE_AUTH_TOKENS`), bracket and dot access forms, whitespace inside the expression, mixed case, multi-line line-number accuracy, and empty input.
- Negative scenarios: comments mentioning `NPM_TOKEN` without `secrets` context pass the `NPM_TOKEN` helper; any `NODE_AUTH_TOKEN` token fails the second helper by design (D3).
- Fail-before proof: the current tree already satisfies AC1, so a failing tree-scan run cannot be produced without editing a workflow, which is out of scope. The parametrized positive cases are the fail-before evidence: they show the helpers used by the tree scan return non-empty results for each reintroduced reference shape. This is recorded in `evidence/regression-testing/guard-detection.<ts>.md`.
- Error handling verification: covered by the non-vacuity test and by letting read errors propagate.
- Coverage impact: the test module is outside the coverage denominator (`omit` includes `tests/*`) and no production file changes, so repository line and branch coverage cannot decrease. The full-suite run must still meet the existing 85% line and 75% branch thresholds.
- Toolchain commands (run in order, restart from step 1 on any failure or auto-fix):
  1. `poetry run black tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  2. `poetry run ruff check tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  3. `poetry run pyright tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  4. `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`
  5. `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Do not use `--cov=<file>.py` as coverage evidence.
- Manual validation: the human-exception runbook's Verification section (performed by a human, outside the acceptance gate per D5).

## Acceptance Criteria

- [ ] AC1. No file under `.github/` (which includes every file under `.github/workflows/`) references the `NPM_TOKEN` secret, verified by the repository check `git grep -n NPM_TOKEN -- .github` exiting with code `1` and printing no output, run on this branch after all changes; the command, output, and exit code are recorded in `docs/features/active/unused-npm-token-secret-712/evidence/baseline/ac1-github-npm-token-grep.<ts>.md`. No file under `.github/` is modified by this change (verified by `git diff --name-only origin/main...HEAD -- .github` producing no output). (Maps issue AC1.)
- [ ] AC2. The guard test `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` exists, and `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` passes on the current tree, including the nodes `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_reference_no_npm_token_secret`, `::test_github_yaml_files_reference_no_node_auth_token`, and `::test_github_yaml_enumeration_is_non_vacuous`. The parametrized node `::test_find_npm_token_references_detects_reintroduced_reference` passes for every positive case, demonstrating that the helper used by the tree scan reports a reintroduced `secrets.NPM_TOKEN` or `secrets['NPM_TOKEN']` reference; `::test_find_node_auth_token_references_detects_reference` demonstrates the same for `NODE_AUTH_TOKEN` (D3). The test uses no temporary files, git subprocess, network, `origin/main`, gitignored input, or Windows-specific path, and resolves the repository root from its own file location. Black, Ruff, and Pyright report no findings for the file, and the full pytest suite meets the existing coverage thresholds; results are recorded under `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/` and `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/`. (Maps issue AC2.)
- [ ] AC3. `docs/engineering/npm-token-rotation.runbook.md` is retained with its superseded notice, and that notice line contains exactly one occurrence of the sentence "The unused `NPM_TOKEN` repository secret is being removed under issue #712." The file is otherwise unchanged (verified by `git diff origin/main...HEAD -- docs/engineering/npm-token-rotation.runbook.md` showing a single changed line). `docs/research/2026-05-04-publish-mcp-server-to-npm-research.md` and `README.md` are unchanged. (Maps issue AC3; decision D4.)
- [ ] AC4. The human-exception runbook `docs/features/active/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md` exists and covers deletion of the `NPM_TOKEN` repository secret and revocation of the corresponding npm access token, and the human action is recorded as pending in `docs/features/active/unused-npm-token-secret-712/evidence/other/human-action-pending.<ts>.md` (status `pending`, runbook path, no credential data). Completion of the human action is not required to check off this criterion (D5). (Maps issue AC4.)

## Risks & Mitigations

- Risk: a sibling item (issues 706 to 716) adds `secrets.NPM_TOKEN` or `NODE_AUTH_TOKEN` to a `.github` YAML file. Mitigation: the guard fails by design and names the file and line; resolve by removing the token-based configuration.
- Risk: a future `.github` YAML comment that mentions `NODE_AUTH_TOKEN` fails the guard (D3). Mitigation: the diagnostic identifies the line; reword the comment. This is accepted as the cost of catching a token-based publish under any secret name.
- Risk: the AC1 command `git grep -n NPM_TOKEN -- .github` also matches non-secret mentions (for example a comment or a Markdown file under `.github/instructions/`). This makes the point-in-time AC1 check stricter than the ongoing guard. Mitigation: none required today (zero matches, verified 2026-09-27); if a later non-secret mention is intended, AC1 evidence records it separately from the guard result.
- Risk: the human revokes a token that another system uses. Mitigation: the runbook's Part 2 decision rule requires a unique metadata match and stops on ambiguity or recent use.
- Observation: the runbook's "Recording completion" step 2 refers to marking AC4 in `issue.md`. For `full-bug`, `spec.md` is the acceptance-criteria source and AC4 is satisfied at the pending stage (D5). Post-human completion should be recorded as a follow-up note (issue #712 comment and an update to the pending evidence record), not as a change to AC4 status. The runbook file is not modified by this spec.

## Rollout & Follow-up

- Release/rollout: merge the test and documentation edit through the normal PR flow; CI runs the guard in `_quality-checks.yml`.
- Post-fix follow-up (human, non-blocking): execute `docs/features/active/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md`, comment on issue #712 with completion date and verification results (no credential data), and update the pending evidence record to complete. Optional hardening per the runbook's source: enable "Require two-factor authentication and disallow tokens" under the package's publishing access settings.
- Links: issue #712; #528 / PR #701 (D4 origin); research `docs/features/active/unused-npm-token-secret-712/research/research.2026-09-27T00-30.md`.
