# Research: ci-merge-queue-for-main (Issue #952)

- Issue: #952
- Branch: bug/ci-merge-queue-for-main-952
- Feature folder: docs/features/active/2026-10-16-ci-merge-queue-for-main-952
- Inputs read: `issue.md`, `spec.md`, `plan.2026-10-16T00-15.md` (feature folder); `docs/features/potential/promoted/2026-10-16-ci-merge-queue-for-main.md`
- Mode: research only; no file outside this research path was modified.

## Summary

1. **Blocking feasibility finding: the merge-queue rule is documented as unavailable for this repository.** GitHub's gated-feature text (`github/docs` `data/reusables/gated-features/merge-queue.md`, fetched 2026-10-16) states that pull request merge queues are available on GitHub.com for **organization-owned** public repositories and for organization-owned private repositories on GitHub Enterprise Cloud. The GitHub REST API (`GET https://api.github.com/repos/drmoisan/drm-copilot`, fetched 2026-10-16) reports `visibility: "public"`, `owner.type: "User"`, `owner.login: "drmoisan"`; `GET /users/drmoisan` reports `type: "User"`, `id: 54180981` (the same id as the ruleset's bypass actor). The repository is therefore user-owned, and the `merge_queue` ruleset rule is expected to be rejected or unavailable. The API's actual response to a PUT carrying a `merge_queue` rule on a user-owned repository was not observed (research has no authenticated `gh` access); it is likely a 422 validation failure. This finding needs a user decision before the ruleset deliverable can be scoped (see Open Questions, OQ-1).
2. Every required check context is produced by exactly one workflow, `.github/workflows/ci.yml`, through reusable workflows called with `uses:`. Only `ci.yml` needs a `merge_group:` trigger. No reusable workflow (including `_poshqc.yml`, owned by #953) needs editing.
3. No workflow in the `ci.yml` call graph reads `github.event.*`, `github.head_ref`, `github.base_ref`, or `github.event_name`, and none has `paths`, `if:` event conditions, concurrency groups, or custom checkout refs. On a `merge_group` event every required job runs unconditionally and reports under the same context string.
4. `gh pr merge` exits 0 when it enqueues a pull request and prints its "will be added to the merge queue" message only on a TTY; it also rejects `-d`/`--delete-branch` when a queue is required. Every repository procedure that records a merge commit after `gh pr merge` must therefore poll until `state == MERGED`. Five Claude surfaces, one Codex surface, and one release script are affected. `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:369` passes `--delete-branch` and would fail once a queue is active.
5. The merge-gate hooks (`.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`) bring a command into scope only when it is a structural `gh pr merge` invocation **and** carries the exact token `--merge`. `gh pr merge <n> --auto`, a bare `gh pr merge <n>`, the short form `-m`, `--squash`/`-s`, `--rebase`/`-r`, `--admin` without `--merge`, and any `gh api` merge or enqueue mutation are not gated today.
6. Recommended approach: add `merge_group: types: [checks_requested]` to `ci.yml` only; add a pure merge-state parser plus queue-aware polling text to every merge procedure; broaden the merge-gate scope to every structural `gh pr merge` invocation except a pure `--disable-auto`, plus `gh api` merge/enqueue mutations; and ship the ruleset payloads and runbook with the availability blocker stated at the top.

## Required-Check-to-Workflow Map

Required contexts are as supplied by the orchestrator from `gh api repos/drmoisan/drm-copilot/rulesets/15241672` (not re-read by research). The composed check-run name is `<caller job id or name> / <called job name>[ (<matrix value>)]`.

| Required context | Caller (`ci.yml`) | Reusable workflow and job | Matrix |
|---|---|---|---|
| `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` | `ci.yml:29-30` | `_drm-copilot-extension-tests.yml:8-13` job `drm-copilot-extension-tests`, name `drm-copilot Extension Tests (${{ matrix.os }})` | `os: ubuntu-latest` |
| `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)` | `ci.yml:29-30` | same | `os: windows-latest` |
| `docs-validation / Documentation Validation` | `ci.yml:17-18` | `_docs-validation.yml:8-9` | none |
| `poshqc / PowerShell QC` | `ci.yml:23-24` | `_poshqc.yml:8-9` (job `poshqc`; the sibling job `poshqc-linux-hooks`, `_poshqc.yml:54-55`, is not required) | none |
| `shell-coverage / Shell Coverage (Bats + kcov)` | `ci.yml:26-27` | `_shell-coverage.yml:8-9` | none |
| `security-scan / Security Scanning` | `ci.yml:14-15` | `_security-scan.yml:8-9` | none |
| `quality-checks7 / Code Quality & Tests (3.10)`, `(3.11)`, `(3.12)`, `(3.13)` | `ci.yml:11-12` | `_quality-checks.yml:8-13`, name `Code Quality & Tests` (GitHub appends the matrix value) | `python-version` |
| `build-check / Build Package` | `ci.yml:20-21` | `_build-check.yml:8-9` | none |

Non-required jobs also produced by `ci.yml`: `root-typescript-tests` (`ci.yml:32-33`, two matrix legs), `NPM Audit Gate / npm audit (...)` (`ci.yml:35-41`, three matrix legs), `poshqc / PowerShell hook suites (Linux)`.

Workflows outside `ci.yml` produce no required context: `publish-extension.yml:18-19` and `publish-mcp-npm.yml:18-19` define jobs named `Extension Tests (${{ matrix.os }})` with no caller prefix, which do not match `drm-copilot-extension-tests / drm-copilot Extension Tests (...)`.

## Findings by Research Question

### Q1. Workflow triggers and required-check producers

Every `on:` block in `.github/workflows/*.yml` (14 files):

| File | Triggers (`file:line`) | Produces required check? |
|---|---|---|
| `ci.yml` | `push` main/development (`:4-5`); `pull_request` main/development/`epic/**` (`:6-7`); `workflow_dispatch` (`:8`) | Yes (all 11) |
| `_quality-checks.yml` | `workflow_call`, `workflow_dispatch` (`:3-5`) | Via `ci.yml` only |
| `_security-scan.yml` | `workflow_call`, `workflow_dispatch` (`:3-5`) | Via `ci.yml` only |
| `_docs-validation.yml` | `workflow_call`, `workflow_dispatch` (`:3-5`) | Via `ci.yml` only |
| `_build-check.yml` | `workflow_call`, `workflow_dispatch` (`:3-5`) | Via `ci.yml` only |
| `_poshqc.yml` | `workflow_call`, `workflow_dispatch` (`:3-5`) | Via `ci.yml` only |
| `_shell-coverage.yml` | `workflow_call`, `workflow_dispatch` (`:3-5`) | Via `ci.yml` only |
| `_drm-copilot-extension-tests.yml` | `workflow_call`, `workflow_dispatch` (`:3-5`) | Via `ci.yml` only |
| `_root-typescript-tests.yml` | `workflow_call`, `workflow_dispatch` (`:3-5`) | No |
| `_npm-audit-gate.yml` | `workflow_call` with input, `workflow_dispatch` with input (`:3-21`) | No |
| `npm-audit-gate.yml` | `schedule`, `pull_request` with `paths` (`:3-15`), `workflow_dispatch` | No |
| `publish-extension.yml` | `push` tags `v*`, `workflow_dispatch`, `pull_request` with `paths` (`:3-15`) | No |
| `publish-mcp-npm.yml` | `push` tags `mcp-server-v*`, `workflow_dispatch`, `pull_request` with `paths` (`:3-15`) | No |
| `verify-published-releases.yml` | `schedule`, `workflow_dispatch`, `pull_request` with `paths` (`:3-19`) | No |

- Reusable workflows do not need their own `merge_group` trigger. GitHub's reusable-workflow reference states that "the `github` context is always associated with the caller workflow" (docs.github.com, *Reusing workflow configurations*, fetched 2026-10-16), and a workflow is reusable when its `on:` includes `workflow_call` (docs.github.com, *Reusing workflows*). A `merge_group` run of `ci.yml` therefore runs every called job with `github.event_name == 'merge_group'`.
- Only `ci.yml` needs the trigger. The issue's suggestion to check `npm-audit-gate.yml` and `publish-extension.yml` is resolved: neither produces a required context, and adding `merge_group` to them would add CI cost without changing queue behavior.
- `_poshqc.yml` (owned by #953) does not need editing.

### Q2. Event-dependent expressions on a `merge_group` event

Search `github\.(event|head_ref|base_ref|ref|sha)|concurrency|merge_group|if:` over `.github/workflows` returned only:

- `_shell-coverage.yml:34` `if: steps.cache-kcov.outputs.cache-hit != 'true'` (step-level, event-independent).
- `_quality-checks.yml:39` cache-hit step condition; `_quality-checks.yml:95` `if: matrix.python-version == '3.13'` (Codecov upload step; `fail_ci_if_error: false` at `:101`).
- `_poshqc.yml:85` `if: always()` (artifact upload step).
- `publish-extension.yml:63`, `publish-mcp-npm.yml:73,93,102`, `verify-published-releases.yml:51,57` (outside the `ci.yml` call graph).

Search `GITHUB_(BASE_REF|HEAD_REF|EVENT_NAME|EVENT_PATH|REF|SHA)` over the repository (excluding `node_modules`) returned one match, in a completed feature's research note; no script invoked by CI reads these variables.

Behavior on `merge_group` for the `ci.yml` call graph:

- No `github.event.pull_request.*`, `head_ref`, `base_ref`, or `event_name` reads exist, so nothing evaluates to empty.
- No `paths`/`paths-ignore` filter on `ci.yml`. The `merge_group` event documentation lists only `branches`/`branches-ignore` filters for that event (docs.github.com, *Events that trigger workflows*, `merge_group`).
- No job-level `if:`; every required job runs. The docs' required-check troubleshooting table states a job skipped by a conditional reports "Success", while a workflow skipped by path, branch, or commit-message filtering leaves the check "Pending" and blocks merging (docs.github.com, *Troubleshooting required status checks*). Neither skip mode applies here.
- No `concurrency:` groups.
- All checkouts use `actions/checkout@v7` with no `ref:`; on `merge_group`, `GITHUB_SHA` is "SHA of the merge group" and `GITHUB_REF` is "Ref of the merge group" (same docs section), so checkout fetches the merge-group commit.
- `_quality-checks.yml:48` runs `git diff --exit-code poetry.lock` against the working tree, not a base ref; it is event-independent. No changed-file detection against a base exists.
- `_poshqc.yml:27` runs `git status --porcelain` after formatting; event-independent.

Conclusion: the only change needed is the trigger itself. Recommended form:

```yaml
  merge_group:
    types: [checks_requested]
```

No `branches:` filter is recommended. Rationale: the queue only dispatches for branches whose ruleset requires a queue, and an unfiltered trigger cannot stall a queue added later to another branch. (A filter of `[main]` matching the docs example is an acceptable alternative.)

### Q3. GitHub documentation and `gh` behavior

Merge queue (docs.github.com, *Managing a merge queue* and *About protected branches*, fetched 2026-10-16):

- Availability: organization-owned repositories only (see Summary item 1).
- "You must use the `merge_group` event to trigger your GitHub Actions workflow"; otherwise "status checks will not be triggered ... The merge will fail as the required status check will not be reported."
- "A merge queue creates temporary branches with a special prefix" (`gh-readonly-queue/{base_branch}`), grouping the PR "with the latest version of the `base_branch`" and "changes from pull requests ahead of it in the queue."
- The queue "provides the same benefits as the Require branches to be up to date before merging branch protection, but does not require a pull request author to update their pull request branch."
- "A merge queue cannot be enabled with branch protection rules that use wildcard characters." The ruleset's `conditions` were not supplied to research; the coordinator should confirm `conditions.ref_name.include` contains no wildcard pattern before applying.
- Settings: merge method; build concurrency ("between `1` and `100`"); only merge non-failing pull requests; status check timeout; minimum/maximum group size; wait time.

Ruleset REST endpoint (docs.github.com, *REST API endpoints for rules*):

- `PUT /repos/{owner}/{repo}/rulesets/{ruleset_id}` with body fields `name`, `target` (`branch|tag|push`), `enforcement` (`disabled|active|evaluate`), `bypass_actors[]` (`actor_id`, `actor_type`, `bypass_mode` `always|pull_request|exempt`), `conditions.ref_name.include/exclude`, `rules[]`. Responses 200, 404, 422, 500.
- The documentation does not state whether a supplied `rules` array replaces or merges with existing rules, nor whether omitted fields keep prior values. Recommendation: build the payload from a fresh `GET` and send every writable field, including the complete `rules` array, so the result is correct under either semantics.
- `merge_queue` rule: `type: "merge_queue"`, `parameters` (all marked required): `check_response_timeout_minutes` (int), `grouping_strategy` (`ALLGREEN` = every PR's merge-group commit must pass; `HEADGREEN` = only the group head), `max_entries_to_build` (int), `max_entries_to_merge` (int), `merge_method` (`MERGE|SQUASH|REBASE`), `min_entries_to_merge` (int), `min_entries_to_merge_wait_minutes` (int). The REST page gives no numeric ranges.

`merge_group` event: activity type `checks_requested` only; "The `merge_group` event is separate from the `pull_request` and `push` events."

`gh pr merge` (cli.github.com manual; `cli/cli` `pkg/cmd/pr/merge/merge.go` and `http.go` on `trunk`, fetched 2026-10-16):

- "When targeting a branch that requires a merge queue, no merge strategy is required." Queue requirement is read from the PR's `isMergeQueueEnabled`; `shouldAddToMergeQueue()` is `mergeQueueRequired && !UseAdmin`.
- With a queue, a supplied method flag only produces the warning "The merge strategy for <base> is set by the merge queue", and the request is forced to `payload.auto = true`, which issues the GraphQL `enablePullRequestAutoMerge` mutation (not `enqueuePullRequest`). If checks have passed the PR is added to the queue; otherwise auto-merge is enabled.
- `--admin` bypasses the queue and merges directly. The repository owner (user 54180981) is a bypass actor with `bypass_mode: pull_request`.
- `--auto` sets `autoMerge` only when the PR is not immediately mergeable; `--auto` is mutually exclusive with `--disable-auto` and `--admin`.
- `-d`/`--delete-branch` with a queue returns the error "Cannot use `-d` or `--delete-branch` when merge queue enabled".
- Output: "Pull request <repo>#<n> will be added to the merge queue for <base> when ready" is printed only when stdout is a TTY. An already-queued PR prints a warning to stderr and exits 0 (`ErrAlreadyInMergeQueue` converted to success). Successful enqueue exits 0.
- Outside a queue and non-interactive with no method flag: "--merge, --rebase, or --squash required when not running interactively" (flag error, non-zero).
- Short flags: `-m/--merge`, `-s/--squash`, `-r/--rebase`, `-d/--delete-branch`; value flags `-b/--body`, `-F/--body-file`, `-t/--subject`, `-A/--author-email`, `--match-head-commit`, inherited `-R/--repo`.

`gh pr view --json` (cli.github.com manual): the 46 fields include `state`, `mergeCommit`, `mergedAt`, `mergeStateStatus`, `autoMergeRequest`, `headRefOid`; there is no `isInMergeQueue` field. Queue membership is readable only through GraphQL (`pullRequest { isInMergeQueue mergeQueueEntry { state position } }`).

Expected observations (documented semantics; not observed live by research):

- While queued: `state` `OPEN`, `mergeCommit` null, `mergedAt` null. `mergeStateStatus` while queued is not documented; do not key on it. `autoMergeRequest` is non-null at least while the PR waits to enter the queue; whether it remains non-null after entry is not documented.
- After merge: `state` `MERGED`, `mergeCommit.oid` set, `mergedAt` set.
- Removal from the queue (failed merge-group checks, timeout, conflict, manual removal) returns the PR to `OPEN` with no merge commit; the CLI cannot remove a PR from a queue (docs, *Merging a pull request with a merge queue*).
- Whether `mergeCommit` equals the merge-group commit that `main` advances to is likely but not documented. The procedures should not depend on it: confirm with `git merge-base --is-ancestor <mergeCommit.oid> origin/main` after `git fetch`.

### Q4. Procedures that merge and then read a merge commit

No procedure in the tree runs `gh pr view --json mergeCommit`; each says "on success, record `merge_commit_sha`" after `gh pr merge`, which assumes a synchronous merge.

| Surface | `file:line` | Current text (exact or abridged where marked) | Merge target |
|---|---|---|---|
| parallel-orchestrate skill | `.claude/skills/parallel-orchestrate/SKILL.md:391` | "3. Execute `gh pr merge --merge <PR>` for that item's pull request, whose base is `main`." | `main` |
| | `:392-393` | "4. On success, record `merge_commit_sha`, `merged_at`, and `merge_status: merged`, then regenerate `docs/features/parallel/<slug>/parallel-status.md`." | |
| | `:436-439` | "Branch protection on `main` affects only the pacing of step 3 ... an automated `gh pr update-branch` plus re-green cycle is inserted between same-cohort merges ..." | |
| | `:450`, `:470` | "On a conflicted `gh pr merge --merge`, the parent ..." (conflict detected only at merge time) | |
| parallel-orchestrator agent | `.claude/agents/parallel-orchestrator.md:288-289` | "Every non-withdrawn item has `merge_status` of `merged` or `worktree_removed`, each durably confirmed by `git` and `gh` ..." | `main` |
| | `:298-299` | "Before `gh pr merge`, confirm that the `headRefOid` value equals that reported `ci_gate.head_sha` ..." | |
| parallel-run skill | `.claude/skills/parallel-run/SKILL.md:54-56` | "each item's pull request targets `main` directly and is merged individually by `parallel-orchestrator` ..." | No change needed (delegates to parallel-orchestrate) |
| orchestrate skill (S9 step 6) | `.claude/skills/orchestrate/SKILL.md:301` | "6. If the checkpoint's `epic_mode` is `true`, execute `gh pr merge --merge <PR>` ... On success, record `epic_merge: { merge_commit_sha, target_branch, merged_at }` ..." | `epic/<slug>-integration` |
| | `:366` | PR Creation Gate condition 7: "... the integration-branch merge (`gh pr merge --merge`) has completed and `epic_merge.merge_commit_sha` is recorded" | |
| epic-orchestrate skill | `.claude/skills/epic-orchestrate/SKILL.md:126-129` | "`epic-orchestrator` runs the same S9 CI-green procedure ... then executes `gh pr merge --merge` once green, gated by `enforce-epic-merge-gate.ps1`." | `main` |
| | `:140-141` | child "merges its own PR into the integration branch, recording `epic_merge: { merge_commit_sha, target_branch, merged_at }`" | integration branch |
| | `:355-356` | "The final integration-to-`main` PR has merged and `epic_merge_pr.merge_commit_sha` is recorded." | `main` |
| epic-orchestrator agent | `.claude/agents/epic-orchestrator.md:163` | "The final integration-to-`main` PR has merged (`epic_merge_pr.merge_commit_sha` recorded)." | `main` |
| parallel-orchestration rule | `.claude/rules/parallel-orchestration.md:154` | "`gh pr view --json state,mergedAt,headRefOid` — pull-request state, merge time, and merge commit (... `merge_commit_sha`)." The listed fields contain no merge commit; `headRefOid` is the PR head. Pre-existing inaccuracy. | |
| | `:689` | merge gate "authorizes a per-item `gh pr merge --merge` ..." | |
| orchestrator-state rule | `.claude/rules/orchestrator-state.md:238` | "The gate consults the array only for a `gh pr merge --merge` command that names an explicit pull request number ..." | |
| cleanup-merged-worktrees skill | `.claude/skills/cleanup-merged-worktrees/SKILL.md:199-212` | human-performed merge; "The ruleset on `main` sets `strict_required_status_checks_policy`, so the branch must be up to date with `main` before the merge becomes available to the operator" | `main` (human) |
| Codex epic-orchestrate skill | `.agents/skills/epic-orchestrate/SKILL.md:169-172` | "... record the current head SHA and successful conclusion, and merge the integration branch to `main` only through the merge gate." | `main` |
| | `:176-177` | "Do not report completion until ... the final PR is merged with its merge SHA recorded ..." | |
| Codex epic-orchestrator agent | `.codex/agents/epic-orchestrator.toml:79-80` | "the final integration-to-main PR is merged with its merge SHA recorded" | `main` |
| Release script | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:369-385` | `Invoke-GhExe -GhArgs @('pr', 'merge', $prNumber, '--merge', '--delete-branch')`, then immediately `git checkout main`, `git pull origin main`, then tag push (`:387-392`) | `main` |

Notes:

- `.github/agents`, `.github/skills`, `.github/prompts`, `.github/instructions`: no `gh pr merge`, `mergeCommit`, or merge-on-green procedure (search `merge-on-green|merge on green|epic_merge|pr merge|mergeCommit` over `.github`; the single hit, `github-actions-ci-cd-best-practices.instructions.md:332`, is unrelated). No `.github` edit is required.
- `.agents/skills/orchestrate/SKILL.md` and `.agents/skills/parallel-*`: no merge command (Codex has no parallel surface; `.agents/skills/orchestrate/SKILL.md` has no S9 step 6 merge).
- `.claude/lib/**`: no merging code (search returned no matches).
- The orchestrate S9 step 6 merge targets an `epic/<slug>-integration` branch. `.claude/skills/orchestrate/SKILL.md:296` states "integration branches carry no required-status-check protection", so a queue on `main` does not change that merge. Making it queue-aware is still recommended for uniformity (one sentence, no behavior change when the merge is synchronous), because the issue lists it and because a future ruleset could cover those branches.
- `Invoke-FullReleaseFlow.ps1` is a correctness risk once a queue exists: `--delete-branch` makes `gh` exit non-zero ("Cannot use `-d` or `--delete-branch` when merge queue enabled"), which the script treats as failure at `:370-373` (fail-safe stop before tagging). Without `--delete-branch`, the immediate `git pull` would read pre-merge `main` and tag the previous version. Tests pin the argument string at `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:75,171,338`. The script calls `gh` through PowerShell (`Invoke-GhExe`), so it is not intercepted by the Bash-matcher merge gate.

Mirror and parity relationships:

| Source | Mirror | Enforcing test |
|---|---|---|
| `.claude/**` (skills, agents, rules, hooks, lib) | `extensions/drm-copilot/resources/claude-customizations/.claude/**` (byte-identical) | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) |
| `.codex/**`, `.agents/**` | `extensions/drm-copilot/resources/codex-and-agents-customizations/{.codex,.agents}/**` (byte-identical) | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-228` |
| Claude/Codex orchestrate, parallel-orchestrate, parallel-orchestrator agent | bundles above | `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` (fragment pins per `##` section and byte-identical mirror assertions; `:244-270` pins the parallel merge section, `:225-241` pins S9) |
| parallel-orchestrate `## Per-Item Merge to Main (Merge-on-Green)` | — | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:219-225` pins "Execute `gh pr merge --merge <PR>`" and "`gh pr view --json state,mergedAt,headRefOid`" |
| New hook or lib files | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (`:30-32` merge-gate files, `:182` ci-gate parser) and `.../codex-and-agents-customizations/pack-manifests/core.json:36` | pack-manifest completeness tests (`test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`); `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` pattern |
| New dot-sourced hook dependency | — | `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (S1-S8: every direct dot-source must be in its own guarded `try` with `Add-HookDependencyFailure`) |

Keep the existing fragment "Execute `gh pr merge --merge <PR>`" verbatim and add the polling text after it, so `parallel_orchestrator_surface_expectations.py` needs no change.

### Q5. Merge-gate hooks: current recognition and bypasses

Claude gate, `.claude/hooks/enforce-epic-merge-gate.ps1` (472 lines):

- Scope filter, `:343-356`: `Test-CommandLineInvocation -CommandWord 'gh' -SubcommandPath @('pr','merge')` AND `Test-CommandLineFlag ... -FlagName '--merge'`; when the flag is absent, a raw-scan fallback searches wrapper segments (`Test-CommandLineSegmentRawScan`) for the substring `--merge` (`:345-353`). Otherwise the command is allowed (`:354-356`).
- `Test-CommandLineFlag` (`.claude/hooks/hook-command-invocation-operands.ps1:125-156`) matches `--merge` or `--merge=...` by exact token on the first Structural match. `-m` is not matched.
- PR number, `Get-EpicMergeGateCommandPrNumber` `:99-143`: first all-digit operand from `Get-CommandLineOperand`, else the value of `--merge` via `Get-CommandLineFlagValue`. Operand collection (`hook-command-invocation.ps1:281-289`) stops at the first dash token that is not in the gh option tables (`:47-51`: only `-R`/`--repo`) or the global standalone list (`:63`: `--force`, `-f`, `--dry-run`, `-n`, `--quiet`, `-q`, `--verbose`, `-v`). `Get-CommandLineFlagValue` returns `$null` when the following token is dash-led (`hook-command-invocation-operands.ps1:111`).
- Header comment `:34`: "Trigger scope: --squash is out of scope for this gate and is allowed on both runtimes." Final deny message `:415` names `gh pr merge --merge`.

Codex gate, `.codex/hooks/enforce-epic-merge-gate.ps1` (385 lines): identical scope filter at `:144-157`; `Get-CodexMergeCommandPrNumber` `:43-76` uses the same operand/flag logic; deny message `:191`. The Codex copy reads only the child and epic checkpoints (no parallel branch).

Current behavior by command (both runtimes; derived from the code above):

| Command | In scope today | PR number read | Effect |
|---|---|---|---|
| `gh pr merge 5 --merge` | Yes | 5 | Gated |
| `gh pr merge --merge 5` | Yes | 5 | Gated |
| `gh pr merge 5 --merge --auto` | Yes | 5 | Gated |
| `gh pr merge --merge --auto 5` | Yes | `$null` (`--merge` value is `--auto`) | Treated as bare: child and epic branches may allow from the session-root checkpoint without a number match; parallel and standalone branches deny |
| `gh pr merge 5 --auto` | No | — | **Bypass** (enables auto-merge or enqueues) |
| `gh pr merge 5` | No | — | **Bypass** under a queue (enqueues); without a queue `gh` errors non-interactively |
| `gh pr merge 5 -m` | No | — | **Bypass** today (merge-commit merge); pre-existing gap |
| `gh pr merge 5 --squash` / `-s` / `--rebase` / `-r` | No | — | Deliberate exemption (`:34`), pinned by tests; under a queue it enqueues like any other spelling |
| `gh pr merge 5 --admin --squash` | No | — | **Bypass**, and `--admin` skips the queue |
| `gh pr merge --subject x 5 --merge` | Yes | `$null` (operand loop stops at unmodeled `--subject`) | Treated as bare (same weakness as row 4) |
| `gh pr merge https://github.com/o/r/pull/5 --merge` | Yes | `$null` (selector not all-digit) | Treated as bare |
| `gh api graphql ... enqueuePullRequest` / `enablePullRequestAutoMerge` / `mergePullRequest` | No | — | **Bypass** (hook matches only `gh pr merge`) |
| `gh api -X PUT repos/o/r/pulls/5/merge` | No | — | **Bypass** |

Hook registration (Q6) limits all of the above to the Bash tool on Claude; a `gh` command issued through the Claude PowerShell tool is not intercepted by any `PreToolUse` hook.

Test suites and conventions:

| File | Lines | Notes |
|---|---|---|
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 465 | `:37-41` pins "allows gh pr merge without --merge (e.g., --squash)" |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 187 | `ConvertTo-MergeGateEnvelope` helper `:37-47`; extractor cases `:54-73`; wrapper cases `:147-186` |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` | 181 | `-ForEach` decision matrix `:90-115`; `:102` pins `gh pr merge 691 --squash` → allow |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1` | 203 | |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1` | 309 | |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` | 255 | |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1` | 43 | entry-point coverage via `[Console]::SetIn` |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 117 | `ConvertTo-CodexMergeTriggerScopingPayload` `:46-58`; Codex returns `$null` for allow |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` | 205 | `:95` pins `gh pr merge 691 --squash` → allow |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1` | 172 | |

Conventions: every decision case mocks `Get-ChildOrchestratorCheckpointContent`, `Get-EpicOrchestratorCheckpointContent`, `Get-ParallelOrchestratorCheckpointContent`, and the `WorktreeItemResolution`/`WorktreeRunResolution` text seams; `Resolve-EpicMergeGateRunTarget` and `Resolve-EpicMergeGateItemTarget` are mocked to a synthetic `SessionRoot`; each `Describe` opens with the `Invoke-EpicStateInterceptionProbe` baseline case (`EpicStateIsolation.Baseline.Helpers.ps1`). No temporary files, processes, or network.

Concurrent item #927: the only #927 record in this tree (`docs/features/potential/promoted/2026-10-15-pr-author-docs-only-exemption-hardening-901.md`) targets `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, not the merge gate. The orchestrator's statement that #927 edits `enforce-epic-merge-gate*.ps1` (docs-only merge allowance) could not be verified from the tree. If #927 adds a docs-only allowance, it would most plausibly add an allow branch inside `Invoke-EpicMergeGateDecision` between the PR-number read and the standalone branch (`:358-413`) or a new helper. This item must touch: the scope filter (`:334-356`), `Get-EpicMergeGateCommandPrNumber` (`:99-143`), the header (`:3`, `:7-8`, `:34`), and the deny message (`:415`). Adjacent regions (`:334-358`) and the shared 500-line budget are the overlap points.

### Q6. Hook registration

- Claude: `.claude/settings.json:92-129`, `PreToolUse` matcher `"Bash"` runs `validate-bash.ps1`, `enforce-promotion-mcp-only.ps1`, `enforce-pr-author-skill.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1` (`:114`), `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`. Other matchers are `Write|Edit` (`:131`), `Agent` (`:180`), and subagent-name matchers (`:215-278`). No matcher covers the PowerShell tool.
- Codex: `.codex/config.toml:119-150`, `[[hooks.PreToolUse]] matcher = "^Bash$"` runs `validate-bash.ps1`, `enforce-promotion-mcp-only.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1` (`:140-144`), `enforce-epic-worktree-removal-gate.ps1`. A second block (`:152-`) with matcher `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` runs other gates, not the merge gate.
- Bundle mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json:114`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml:142-143`.
- `validate-bash.ps1` contains no `gh api`, `rulesets`, or `--method` rule (search returned only `.OUTPUTS` doc lines), so the coordinator's `gh api --method PUT` is not hook-blocked.

### Q7. Existing documentation

- `merge_group`/merge queue: no runtime or workflow reference (search excluding `docs/features/**`, bundles, `node_modules`).
- Strict up-to-date references that become stale when the queue applies: `.claude/skills/parallel-orchestrate/SKILL.md:436-439` (update-branch re-green cycle) and `.claude/skills/cleanup-merged-worktrees/SKILL.md:206-208`.
- `.github/workflows/README.md:8-16` documents `ci.yml` triggers (three triggers) and must list `merge_group`; `:34-75` documents the required-status-check rename procedure using the legacy branch-protection endpoint (`branches/{branch}/protection/required_status_checks`), not the ruleset endpoint actually in use.
- `tests/scripts/workflows/CiWorkflow.Tests.ps1` (175 lines) asserts `ci.yml` trigger invariants with line-oriented parsing (`Get-CiTriggerBranchList` `:42-146`); it is the natural home for a `merge_group` assertion.
- `.claude/rules/ci-workflows.md:37` (`modified-workflow-needs-green-run`): the PR's own `pull_request` run satisfies it; the `merge_group` leg cannot run before the queue exists.

### Q8. See `## Automation Feasibility`.

## Candidate Approaches

**Selected: trigger-plus-procedures-plus-gate, with ruleset payloads shipped behind the availability blocker.**

- `ci.yml` gains `merge_group: types: [checks_requested]`.
- A pure parser (`Invoke-MergeConfirmationParser.ps1`, modeled on `Invoke-CiGateParser.ps1`) converts one GraphQL or `gh pr view` JSON snapshot into `merged | pending | not_queued | closed` plus `merge_commit_sha`/`merged_at`; procedures poll it with a bounded interval and timeout. Pure logic stays testable without `gh` (same separation as `Invoke-CiGateParser.ps1:13-17`).
- The merge gate's scope becomes "every structural `gh pr merge` invocation except one whose only action flag is `--disable-auto`", plus `gh api` invocations carrying `enqueuePullRequest`, `enablePullRequestAutoMerge`, or `mergePullRequest`, or a `pulls/<n>/merge` path. A method-agnostic scope is required because, with a queue, every spelling (`--merge`, `--squash`, `--auto`, bare) performs the same enqueue.
- The ruleset deliverable ships as payload files plus a runbook; it is not applied by this item.

Advantages: the trigger and gate changes are correct with or without a queue; the procedures behave identically when the merge is synchronous (the first poll returns `MERGED`); the gate closes pre-existing bypasses (`-m`, `--auto`).

Rejected alternatives:

- Narrow gate scope (`--merge` or `--auto` or no method flag; keep the `--squash`/`--rebase` exemption): smaller test churn (no pinned row changes) but leaves `gh pr merge <n> --squash` as an ungated enqueue once a queue exists, which does not meet "exactly like plain merges".
- Gate-side `gh` call to detect a queue: rejected; the gate's documented posture is checkpoint-only with no live `gh` call (`enforce-epic-merge-gate.ps1:36-39`).
- Adding `merge_group` to every workflow: rejected; non-required workflows do not affect the queue and would add CI cost.
- Replacing the queue with `strict_required_status_checks_policy: false`: removes the re-sync loop and is available to user-owned repositories, but abandons the issue's expected behavior that "the combined result is still validated before it lands on `main`". Kept only as a user decision under OQ-1.

## Behavior Semantics

Merge confirmation, per merge attempt:

1. Run `gh pr merge <PR> --merge` (positional number; no `--delete-branch`; no `--auto`). A non-zero exit is a merge failure handled by the existing conflict/failure paths.
2. Poll a snapshot (recommended: `gh api graphql` query for `state`, `mergeCommit { oid }`, `mergedAt`, `isInMergeQueue`, `autoMergeRequest { enabledAt }`; `gh pr view --json state,mergeCommit,mergedAt,autoMergeRequest` is the fallback without queue membership).
3. Derive status: `MERGED` with non-empty `mergeCommit.oid` → `merged`; `CLOSED` → `closed` (failure); `OPEN` and (`isInMergeQueue` or `autoMergeRequest` non-null) → `pending`; `OPEN` with neither → `not_queued` (removed from the queue or never enqueued; failure). `MERGED` with an empty commit is a fail-fast error.
4. On `pending`, wait a bounded interval; on total-timeout exhaustion, record `awaiting_merge_queue` and stop without recording `merged`.
5. On `merged`, `git fetch origin <base>` and confirm `git merge-base --is-ancestor <oid> origin/<base>` exits 0 before recording `merge_commit_sha`, `merged_at`, `merge_status: merged`.
6. On `not_queued`, re-check `mergeable`; `CONFLICTING` enters the existing conflict path; otherwise treat as a merge-group CI failure (the PR head's own checks may still be green), and re-delegate the child to merge `origin/main` and re-run S9, consuming a remediation attempt.

Ordering rules: `merge_status: ci_green` before `gh pr merge` (unchanged); `merged` only after step 5.

## Requirements Mapping and Proposed File Changes

### Category A. Workflows

- `.github/workflows/ci.yml` (add trigger).
- `.github/workflows/README.md` (Triggers section; optionally the ruleset-based context-update note).
- `tests/scripts/workflows/CiWorkflow.Tests.ps1` (assert `  merge_group:` exists in the trigger block, `types` contains `checks_requested`, and no `paths` key under it; keep existing assertions).

### Category B. Merge gate (mirror groups noted)

- New `.claude/hooks/enforce-epic-merge-gate-command.ps1` holding `Test-EpicMergeGateCommandInScope` and a gh-aware selector reader (moving the body of `Get-EpicMergeGateCommandPrNumber`), with a value-flag table (`-b`, `--body`, `-F`, `--body-file`, `-t`, `--subject`, `-A`, `--author-email`, `--match-head-commit`, `-R`, `--repo`) and boolean flags skipped; accepts an all-digit selector or a `/pull/<n>` URL. Placing it in a new file keeps `enforce-epic-merge-gate.ps1` (472 lines) under 500 and away from #927's likely region.
  - Mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1`; add the path to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- `.claude/hooks/enforce-epic-merge-gate.ps1` (guarded dot-source; replace `:334-356` with the helper call; update `:3`, `:7-8`, `:34`, `:415`) + bundle mirror.
- `.codex/hooks/enforce-epic-merge-gate.ps1` (same scope change at `:139-157`; PR-number reader `:43-76`; message `:191`) + `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`. Option: a byte-identical `.codex/hooks/enforce-epic-merge-gate-command.ps1` copy (+ bundle + Codex `pack-manifests/core.json`); the helper uses only functions both runtimes already ship.
- Tests (new files; existing `enforce-epic-merge-gate.Tests.ps1` is at 465 lines):
  - `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`
  - `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`
  - Update pinned rows: `enforce-epic-merge-gate.Tests.ps1:37-41`, `enforce-epic-merge-gate.Authorization.Tests.ps1:102`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:95` (the `--squash` cases become gated; with a valid record they still allow, so the Authorization rows' expected value stays `allow` and only the `Tests.ps1:37` case changes to deny-without-checkpoint).
- Rules text: `.claude/rules/orchestrator-state.md:238`, `.claude/rules/parallel-orchestration.md:689` (and `:154` field-list correction) + bundle mirrors.

### Category C. Merge-confirmation logic

- New `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` + bundle mirror + `core.json` entry.
- New `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`; extend `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` (or a sibling manifest test).
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (drop `--delete-branch`; add `Wait-ForPullRequestMerged` using the existing sleep seam at `:127-141`; delete the remote branch after confirmation or rely on the repository setting) + `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:75,171,338` and a new `Invoke-FullReleaseFlow.MergeWait.Tests.ps1`.

### Category D. Procedures (each with its bundle mirror)

- `.claude/skills/parallel-orchestrate/SKILL.md` (`:391-394`, `:436-439`, conflict entry `:450`/`:470` to include the `not_queued` outcome).
- `.claude/agents/parallel-orchestrator.md` (`:288-289`).
- `.claude/skills/orchestrate/SKILL.md` (`:301`, `:366`).
- `.claude/skills/epic-orchestrate/SKILL.md` (`:126-129`, `:140-141`, `:355-356`).
- `.claude/agents/epic-orchestrator.md` (`:163`).
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` (`:206-208`, optional wording update).
- `.agents/skills/epic-orchestrate/SKILL.md` (`:169-172`, `:176-177`) + Codex bundle mirror.
- `.codex/agents/epic-orchestrator.toml` (`:79-80`, optional) + Codex bundle mirror.
- Contract tests to extend, not break: `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` (426 lines), `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (381 lines).

### Category E. Ruleset deliverables (feature folder; not applied)

- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json`
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.rollback.json`
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md`

Proposed `merge_queue` rule (append to the complete existing `rules` array; every other field copied from a fresh GET):

```json
{
  "type": "merge_queue",
  "parameters": {
    "check_response_timeout_minutes": 60,
    "grouping_strategy": "ALLGREEN",
    "max_entries_to_build": 5,
    "max_entries_to_merge": 5,
    "merge_method": "MERGE",
    "min_entries_to_merge": 1,
    "min_entries_to_merge_wait_minutes": 5
  }
}
```

Rationale: `MERGE` matches every repository procedure (`--merge`) and `allowed_merge_methods`; `ALLGREEN` validates every PR's combined state; `min_entries_to_merge: 1` merges a lone PR without waiting; 60 minutes exceeds the observed 19-minute CI (run 38846579572). The other integer values are the commonly used UI defaults and were not verified against documentation. The rollback payload is the pre-change GET body's writable fields (`name`, `target`, `enforcement`, `conditions`, `bypass_actors`, `rules`) without the `merge_queue` rule. The `conditions` block was not supplied to research and must be captured from the GET (OQ-4).

## Automation Feasibility

- **Blocker:** merge queues are documented as available only for organization-owned repositories; `drmoisan/drm-copilot` is user-owned. No unattended CLI step can enable the queue on the current ownership. Transferring the repository to an organization is possible through `POST /repos/{owner}/{repo}/transfer`, but it is a user decision with wide impact (URLs, Marketplace and npm publishing secrets, Codecov, bypass actors, bundled references) and is outside this item.
- If the repository becomes organization-owned, applying the ruleset is unattended: `gh api --method PUT repos/<owner>/drm-copilot/rulesets/15241672 --input <apply.json>`, after a `gh api repos/<owner>/drm-copilot/rulesets/15241672` capture used to regenerate the payload. It requires a token with repository administration write permission. No GitHub UI action is required. The session permission mode may prompt for the Bash `gh api` call (no `gh` entry is pre-approved in `.claude/settings.json`); that is a local permission prompt, not a GitHub UI step. `validate-bash.ps1` does not block it.
- Verifying the trigger before the ruleset exists (a `merge_group` event cannot fire without a queue):
  1. Static: `CiWorkflow.Tests.ps1` asserts the `merge_group` key, `checks_requested`, and the absence of `paths` under it; the existing `push`/`pull_request` assertions stay.
  2. Structural: the PR's own `pull_request` CI run proves `ci.yml` still parses and every required job reports (GitHub rejects an invalid `on:` block at run creation).
  3. Static cross-check: a test or reviewer step confirming no workflow in the `ci.yml` call graph reads `github.event.pull_request`, `head_ref`, `base_ref`, or has `paths` (grep-based assertion over `.github/workflows/_*.yml` and `ci.yml`).
  4. Post-apply (coordinator, only after the ruleset is applied): GET the ruleset and confirm the `merge_queue` rule; enqueue one green PR with `gh pr merge <n> --merge`; poll until `MERGED`; confirm with `gh api repos/<owner>/drm-copilot/commits/<mergeCommit>/check-runs` (or the merge-group head SHA) that all 11 required contexts concluded `success` on a `merge_group` run; then queue two green PRs and confirm both merge without `gh pr update-branch`. Rollback with the rollback payload if any required context does not report within `check_response_timeout_minutes`.

## Testing Implications

- Pester (PowerShell policy): new hook scope cases for `--auto`, bare, `-m`, `--squash`, `-s`, `--rebase`, `--admin`, `--disable-auto` (allow), value-flag-led spellings (`--subject x 5 --merge`), URL selector, `--merge --auto 5`, `gh api graphql` mutations (deny) and a `gh api graphql` query containing `isInMergeQueue` (allow), mention-only text (allow); both runtimes. Use the existing envelope helpers and seam mocks; no temporary files.
- Pester for the parser: every state combination in Behavior Semantics, `MERGED` with empty commit (error), malformed JSON (error), null fields; deterministic, no `gh`.
- Pester for `Invoke-FullReleaseFlow.ps1`: argument list without `--delete-branch`; wait loop with mocked sleep and scripted `gh` responses (pending → merged; pending → timeout; not_queued).
- Pytest: extend the documentation contract tests for new fragments and mirror byte-identity.
- Coverage: PowerShell line coverage only (Pester has no branch metric); new production files are in the denominator.

## Numeric Derivation Evidence

### N1. Workflow files with an `on:` block

- Complete Family: YAML workflow files in `.github/workflows/`.
- Exhaustive Search Scope: `.github/workflows/*.yml` (no `.yaml` files present in the Glob result).
- Inclusion Rules: file under `.github/workflows/` with extension `.yml`.
- Exclusion Rules: `README.md`.
- Primary Search Strategy or Query Expression: `Glob .github/workflows/*.yml`.
- Primary Member Set: `_build-check.yml`, `_docs-validation.yml`, `_drm-copilot-extension-tests.yml`, `_npm-audit-gate.yml`, `_poshqc.yml`, `_quality-checks.yml`, `_root-typescript-tests.yml`, `_security-scan.yml`, `_shell-coverage.yml`, `ci.yml`, `npm-audit-gate.yml`, `publish-extension.yml`, `publish-mcp-npm.yml`, `verify-published-releases.yml`.
- Primary Count: 14.
- Cross-check Search Strategy or Query Expression: `Grep ^on: path=.github/workflows output_mode=count`.
- Cross-check Member Set: `ci.yml`, `npm-audit-gate.yml`, `publish-mcp-npm.yml`, `publish-extension.yml`, `_build-check.yml`, `verify-published-releases.yml`, `_docs-validation.yml`, `_drm-copilot-extension-tests.yml`, `_npm-audit-gate.yml`, `_poshqc.yml`, `_quality-checks.yml`, `_shell-coverage.yml`, `_root-typescript-tests.yml`, `_security-scan.yml`.
- Cross-check Count: 14.
- Member-set Comparison: normalized (sorted) sets are identical; every file has exactly one `on:` line.

### N2. Workflows that need a `merge_group` trigger

- Complete Family: workflow files whose triggers can produce a check run named by a required context.
- Exhaustive Search Scope: the 14 files in N1.
- Inclusion Rules: a non-reusable workflow (not `workflow_call`-only) containing a job whose composed name equals a required context.
- Exclusion Rules: reusable workflows (context inherited from caller); workflows whose job names do not compose to a required context.
- Primary Search Strategy or Query Expression: read each trigger block and job `name:` (Q1 table); compose names against the required list.
- Primary Member Set: `ci.yml`.
- Primary Count: 1.
- Cross-check Search Strategy or Query Expression: `Grep uses: \./` over `ci.yml` and `_*.yml` (call graph) plus `Grep name:` for job names in `publish-extension.yml`, `publish-mcp-npm.yml`, `npm-audit-gate.yml`, `verify-published-releases.yml` (no caller prefix `drm-copilot-extension-tests /`, no required job names).
- Cross-check Member Set: `ci.yml`.
- Cross-check Count: 1.
- Member-set Comparison: identical.

### N3. Required check contexts (assertion withheld for spec use)

- Complete Family: `required_status_checks` contexts of ruleset 15241672.
- Primary Member Set (orchestrator-supplied GET): the 11 contexts in the map table. Primary Count: 11.
- Cross-check: composition from YAML (`ci.yml` job ids × reusable job names × matrix values) produces 17 contexts, of which the same 11 strings appear; this proves each required context is produced, but it does not independently enumerate the ruleset.
- Member-set Comparison: required set ⊂ produced set; no required context is unproduced.
- Status: the count 11 is not proposed for a `spec.md` acceptance criterion until the coordinator re-reads the ruleset; phrase the criterion non-numerically ("every context in `required_status_checks` is produced by a `merge_group` run of `ci.yml`").

## Risks

- **Availability (blocking):** the queue cannot be enabled on a user-owned repository (OQ-1).
- **#953 overlap:** none required; `_poshqc.yml` is not edited.
- **#927 overlap:** unverified scope; if it edits `enforce-epic-merge-gate.ps1`, the adjacent regions are `:334-413`. Moving scope logic to a new helper file reduces the conflict surface. Rebase on `main` before PR creation.
- **500-line limit (current counts):** `.claude/hooks/enforce-epic-merge-gate.ps1` 472; `enforce-epic-merge-gate-authorization.ps1` 443; `enforce-epic-merge-gate-resolution.ps1` 243; `hook-command-invocation.ps1` 482; `hook-command-invocation-operands.ps1` 198; `hook-command-scanner.ps1` 400; `hook-command-payload.ps1` 484; `.codex/hooks/enforce-epic-merge-gate.ps1` 385; `tests/.../enforce-epic-merge-gate.Tests.ps1` 465; `TriggerScoping.Tests.ps1` 187; `Authorization.Tests.ps1` 181; `AuthorizationFields.Tests.ps1` 203; `ItemResolution.Tests.ps1` 309; `WorktreeResolution.Tests.ps1` 255; `Coverage.Tests.ps1` 43; Codex `trigger-scoping` 117, `authorization` 205, `decision-surface` 172; `CiWorkflow.Tests.ps1` 175; `Invoke-FullReleaseFlow.ps1` 401; `Invoke-FullReleaseFlow.Tests.ps1` 426; `Invoke-CiGateParser.ps1` 402. Do not add gh-specific flags to the shared tables in `hook-command-invocation.ps1` (482 lines, shared by every gate).
- **Parity tests:** any `.claude`, `.codex`, or `.agents` edit without the matching bundle edit fails the resource-contract tests; fragment pins fail if pinned sentences are reworded.
- **Behavior change:** broadening the gate denies `gh pr merge --squash`/`-s`/`--rebase` without a checkpoint; ad-hoc agent merges that relied on the exemption will need an authorization record.
- **Merge-group failures invisible to S9:** S9 reads PR-head checks; a merge-group failure leaves the head green. The `not_queued` branch must route to remediation, not to a re-merge loop.
- **Double CI cost:** each PR runs `ci.yml` on `pull_request` and again on `merge_group`, plus `push` on `main` after merge (unchanged).
- **PowerShell-tool route:** gates intercept only the Bash tool; `gh` via the PowerShell tool remains ungoverned (pre-existing).

## Open Questions (with recommended defaults)

- **OQ-1. Queue unavailable on a user-owned repository.** Options: (a) ship the trigger, procedure, and gate changes now and ship the `merge_queue` payload marked "apply only after the repository is organization-owned"; (b) also ship an alternative payload setting `strict_required_status_checks_policy: false` (removes the loop now, loses pre-merge combined validation; `push` CI on `main` detects breakage after the fact); (c) transfer the repository to an organization first. Recommended default: (a), with (b) documented in the runbook as a separate user decision, because the issue's expected behavior requires combined validation before landing.
- **OQ-2. Gate scope.** Recommended default: method-agnostic (every structural `gh pr merge` except a pure `--disable-auto`) plus `gh api` merge/enqueue mutations and `pulls/<n>/merge`. Alternative: narrow scope preserving the `--squash`/`--rebase` exemption.
- **OQ-3. `--admin`.** Recommended default: gate it like any merge (checkpoint required) without an extra unconditional deny; record in the runbook that `--admin` skips the queue for the bypass actor.
- **OQ-4. Ruleset `conditions`.** Not supplied to research. Recommended default: the implementer captures the full GET body into the rollback file and derives the apply file from it; confirm no wildcard ref patterns.
- **OQ-5. `strict_required_status_checks_policy` alongside the queue.** Recommended default: leave `true` (minimal change; the docs state the queue does not require the author to update the branch). Post-apply check: enqueue a `BEHIND` PR; if it is refused, apply a follow-up payload with `false`.
- **OQ-6. `Invoke-FullReleaseFlow.ps1` scope.** Recommended default: in scope (drop `--delete-branch`, add the merge wait), because the release flow otherwise stops at the merge step once a queue exists.
- **OQ-7. Orchestrate S9 step 6 (integration-branch merge).** Recommended default: add the same confirmation sentence for uniformity; it is a no-op for synchronous merges.
- **OQ-8. Parser location.** Recommended default: `.claude/lib/ci-gate/` beside `Invoke-CiGateParser.ps1`, reusing its manifest-test pattern.
- **OQ-9. `merge_group` branch filter.** Recommended default: none (`types: [checks_requested]` only).
