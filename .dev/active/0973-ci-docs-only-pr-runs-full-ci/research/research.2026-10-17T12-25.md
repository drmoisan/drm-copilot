# Research: docs-only pull request runs full CI (Issue #973)

- Issue: #973 (bug)
- Branch: `bug/ci-docs-only-pr-runs-full-ci-973`
- Timestamp: 2026-10-17T12-25 (UTC; restamped by the orchestrator from the host clock, replacing the researcher's estimated value)
- Orchestrator confirmation (section 1.4 caveat): `git diff --name-only --no-renames` was run locally against an archive-move commit and listed both the `docs/features/active/` source path and the `docs/features/archive/` destination path of the same rename. Both sides of a rename are therefore classified.
- Sources read: `.claude/skills/execution-environment/SKILL.md`, `scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`, `.github/workflows/ci.yml` (job `changes`), `config/ci-docs-only-paths.json`, `config/poshqc-coverage.json`, `config/poshqc-scan.json`, `tests/scripts/ci/*.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`, `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, `.github/workflows/README.md` (`## Change-Scope Decision (Issue #962)`), the feature `issue.md` and `spec.md`, the actions/checkout README, and the git-diff manual.
- Marker: facts that need `git`, `gh`, or a CI log are marked **NEEDS-ORCHESTRATOR-CONFIRMATION**.

## 1. Current State

### 1.1 Pure module `scripts/ci/CiChangeScope.psm1` (346 lines)

The module runs no git or gh command and does no I/O. That property is pinned by the `module structure` row of `tests/scripts/ci/CiChangeScope.Tests.ps1`. It exports eight functions and has no private functions.

| Function | Inputs | Output and behavior |
|---|---|---|
| `Test-CiChangeScopeEventEligible` | `EventName`, `HeadRepository`, `Repository` | `EVENT_NOT_PULL_REQUEST` for any event other than `pull_request` (`-cne`). `FORK_PULL_REQUEST` for a blank or different head repository. `$null` when the event is eligible. |
| `ConvertFrom-CiDocsOnlyPathConfig` | `Json` | Validates `version` (=1), a non-empty `include_prefixes`, `exclude_prefixes` (may be empty), and `extensions` (each must start with `.`). Throws `CI_DOCS_ONLY_CONFIG_INVALID: ...` and returns an object with `IncludePrefixes`, `ExcludePrefixes`, and lower-case `Extensions`. |
| `Test-CiDocsOnlyPath` | `Path`, `Config` | Rejects a blank path, a backslash, a leading `/`, or a `..` segment. Then requires an ordinal include-prefix match, no exclude-prefix match, and a case-insensitive extension match taken from the last dot of the leaf (a dot file has no extension). |
| `ConvertFrom-CiNulPathList` | `Text` | Splits `git diff -z` output. Empty text gives a valid empty list. Text without a trailing NUL, or with an empty entry, gives `Valid=$false`. |
| `Get-CiChangeScopePathDecision` | `Paths`, `Config` | Returns `EMPTY_DIFF` for no paths, `NON_ALLOWLISTED_PATH: <first path>` for the first rejected path, and `$null` when every path is allowlisted. |
| `Select-CiGreenBaseCandidates` | `RunsJson`, `CurrentRunId`, `Repository` | Keeps runs that are not the current run, whose conclusion is `success`, whose head repository is this repository, and that have a head SHA. Sorts them by `run_number` descending. Throws `CI_RUN_LIST_INVALID: ...`. |
| `Test-CiFullRunMarker` | `JobsJson`, `MarkerName='CI full run'` | `$true` when a job with that name concluded `success`. Throws `CI_JOB_LIST_INVALID: ...`. |
| `New-CiChangeScopeDecision` | `Code`, `Reason`, `BaseSha` | Builds `Code`, `Reason`, `BaseSha`, `OutputLine` (`code=<x>`), `LogLine` (`code=<x> reason=<r>`), and `SummaryText` (`Change scope: code=<x>; reason=<r>; base=<sha or none>`). Throws `CI_CHANGE_SCOPE_DECISION_INVALID` when `code=false` is requested without a reason that starts with `DOCS_ONLY_SINCE_`. |

### 1.2 Entry script `scripts/ci/Invoke-CiChangeScope.ps1` (271 lines)

- `Invoke-CiChangeScopeNative`: the only process boundary. It runs `& $FileName @ArgumentList 2>$null` and returns `{ ExitCode; Output }`, with output lines joined by LF.
- `Write-CiChangeScopeTarget`: `Output` appends to the file named by `GITHUB_OUTPUT` and `Summary` to the file named by `GITHUB_STEP_SUMMARY`. When the variable is blank, the text goes to `Write-Information` instead. `Log` writes to the information stream, and `Warning` writes `::warning::<text>`.
- `Get-CiChangeScopeContext`: reads `EVENT_NAME`, `HEAD_SHA`, `HEAD_REF`, `HEAD_REPO`, `REPOSITORY`, and `RUN_ID` through the injectable `-ReadVariable` seam. It reads no base SHA or base ref today.
- `Read-CiChangeScopeConfigText`: reads `config/ci-docs-only-paths.json` relative to `$PSScriptRoot`.
- `Find-CiChangeScopeBase`: calls `gh api repos/<repo>/actions/workflows/ci.yml/runs?branch=<HEAD_REF>&event=pull_request&status=success&per_page=50`. A non-zero exit or `CI_RUN_LIST_INVALID` gives `RUN_LIST_FAILED`. For each candidate, newest first, it calls `.../actions/runs/<id>/jobs?filter=latest&per_page=100`. A failure there gives `JOB_LIST_FAILED`. The first candidate whose marker succeeded becomes `BaseSha`. When no candidate qualifies, the function returns **`NO_FULL_GREEN_RUN`** (the final `return` of the function). This is the branch that issue #973 targets.
- `Resolve-CiChangeScopeDecision` runs these steps in order:
  1. Event eligibility.
  2. A throw (`CI_CHANGE_SCOPE_CONTEXT_INVALID`) when `HeadSha`, `HeadRef`, `Repository`, or `RunId` is blank.
  3. Parse the allowlist config.
  4. `Find-CiChangeScopeBase`. Any reason ends the decision with `code=true`.
  5. `git cat-file -e <base>^{commit}`. A non-zero exit gives `BASE_NOT_PRESENT`.
  6. `git merge-base --is-ancestor <base> <head>`. Exit 1 gives `BASE_NOT_ANCESTOR`; any other non-zero exit gives `ANCESTRY_CHECK_FAILED`.
  7. `git diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <base> <head>`. A non-zero exit or invalid NUL output gives `DIFF_FAILED`.
  8. `Get-CiChangeScopePathDecision`.
  9. Otherwise `code=false` with reason `DOCS_ONLY_SINCE_<base>`.
- `Invoke-CiChangeScope`: the seams are `-GhInvoker`, `-GitInvoker`, `-OutputWriter`, and `-ConfigJson`. The function adds a fail-closed envelope: any throw becomes `UNEXPECTED_ERROR` plus a `Warning`. It then writes `Output`, `Log`, and `Summary`, in that order.
- Dot-source guard: `if ($MyInvocation.InvocationName -ne '.')` runs the entry point and `exit 0`.

Current reason codes: `EVENT_NOT_PULL_REQUEST`, `FORK_PULL_REQUEST`, `RUN_LIST_FAILED`, `JOB_LIST_FAILED`, `NO_FULL_GREEN_RUN`, `BASE_NOT_PRESENT`, `BASE_NOT_ANCESTOR`, `ANCESTRY_CHECK_FAILED`, `DIFF_FAILED`, `EMPTY_DIFF`, `NON_ALLOWLISTED_PATH: <path>`, `DOCS_ONLY_SINCE_<sha>`, and `UNEXPECTED_ERROR`.

### 1.3 `ci.yml` job `changes`

- Checkout: `actions/checkout@v7` with `ref: ${{ github.event.pull_request.head.sha || github.sha }}`, `fetch-depth: 0`, `filter: blob:none`, and `persist-credentials: false`.
- Step `scope` (`shell: pwsh`, `continue-on-error: true`) receives `GH_TOKEN`, `EVENT_NAME`, `HEAD_SHA`, `HEAD_REF`, `HEAD_REPO`, `REPOSITORY`, and `RUN_ID`. Neither the base SHA (`github.event.pull_request.base.sha`) nor the base ref (`github.base_ref`) is passed today. **`ci.yml` must change** to add them.
- actions/checkout README (verified with WebFetch): "Set `fetch-depth: 0` to fetch all history for all branches and tags." With a full fetch, every main commit, including the PR's `base.sha`, is in the object store, and `refs/remotes/origin/main` is expected to exist. That the ref exists in this specific job, under `ref:` set to a SHA, is **NEEDS-ORCHESTRATOR-CONFIRMATION** (for example from the checkout step's fetch line in a `Change scope` log). The recommended design does not depend on the remote-tracking ref (section 2).
- `filter: blob:none` omits blobs only. Commits and trees are fetched, which is all that `git merge-base` and `git diff --name-only --no-renames` need, because rename detection, which reads blobs, is off.

### 1.4 Rename and copy handling (fix scope item 3)

- git-diff manual (verified): `--no-renames` "Turn off rename detection, even when the configuration file gives the default to do so". `diff.renames` defaults to `true` for porcelain `git diff`, and copy detection is a mode of rename detection (`diff.renames=copies`, `-C`).
- With `--no-renames`, a rename is reported as a deletion of the old path plus an addition of the new path. `--name-only` then lists both paths, so **both sides of every rename are already classified** by `Get-CiChangeScopePathDecision`. A rename from `scripts/x.ps1` into `docs/features/archive/x.md`, or the reverse, already yields `NON_ALLOWLISTED_PATH`. A copy is reported as an addition of the new path only. The source is unchanged and is correctly not listed.
- Caveat: the manual describes `--name-only` as "name of each changed file in the post-image tree". The claim that a deleted path appears in `--name-only --no-renames` output is standard git behavior, but it was not executed here. It is **NEEDS-ORCHESTRATOR-CONFIRMATION** with one local check in a scratch clone: rename a tracked file, commit, run `git diff --name-only --no-renames HEAD~1 HEAD`, and expect both paths.
- No production change is needed for item 3. The merge-base path must reuse the same diff argument list. New Pester rows pin the two-sided classification.

### 1.5 Allowlist `config/ci-docs-only-paths.json`

- Include: `docs/features/active/`, `docs/features/completed/`, `docs/features/potential/`, `docs/research/`.
- Exclude: `docs/features/potential/template.md`, `docs/features/templates/`.
- Extensions: `.md`, `.txt`, `.log`, `.json`, `.xml`.
- Contents of the new trees (Glob): `docs/features/parallel/` holds only `.md` files (`parallel.md`, `parallel-kickoff.md`, `parallel-status.md`, and `evidence/other/*.md`). `docs/features/epics/` holds only `.md` files (`epic.md`, `epic-kickoff.md`, `epic-status.md`, `issue.md`, `objective-source.md`). Under `docs/features/archive/`, the only "template" matches are evidence files whose names contain the word. No template file exists in any of the three trees. The only template sources are `docs/features/templates/README.md` (already excluded) and `docs/features/potential/template.md` (already excluded). **No new exclude prefix is needed.**
- Tests that mention those trees use in-memory fixture strings (hook and epic-scope suites). No test reads committed files under the three trees, so allowlisting them does not hide a test input.

### 1.6 Coverage and scan

- `config/poshqc-coverage.json` roots include `scripts`, so both production files are in the PowerShell coverage denominator. The line gate is 85% per changed file, with no branch gate.
- `config/poshqc-scan.json` `scanFolders` include `tests/scripts`, so a new `tests/scripts/ci/*.Tests.ps1` file is assigned to a shard automatically.

## 2. Candidate Approaches

### A. Recommended: merge-base fallback anchored on the payload base SHA, restricted to base ref `main`

- `ci.yml` passes `BASE_SHA: ${{ github.event.pull_request.base.sha }}` and `BASE_REF: ${{ github.base_ref }}`. `github.base_ref` is documented as available only for `pull_request` and `pull_request_target` (verified, GitHub contexts reference).
- When the primary reason is `NO_FULL_GREEN_RUN`, `BASE_NOT_PRESENT`, or `BASE_NOT_ANCESTOR`, and `BaseRef -ceq 'main'`, the script resolves the merge base as follows:
  1. `BaseSha` must not be blank.
  2. `git cat-file -e <BaseSha>^{commit}` must succeed.
  3. `git merge-base <BaseSha> <HeadSha>` must exit 0 and print exactly one full SHA.
  4. Any failure gives `code=true reason=MERGE_BASE_UNRESOLVED`.
  5. The script then runs the same diff from the merge base to the head and the same path decision. On success the decision is `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<sha>` with `BaseSha=<sha>`.
- Advantages:
  - The base SHA is immutable and supplied by GitHub, not by the PR author.
  - The design does not depend on the existence of a remote-tracking ref.
  - The ref name is only compared to `main` and is never passed to git, so ref-name injection is not possible.
  - It reuses the existing fail-closed patterns and the `DOCS_ONLY_SINCE_` guard in `New-CiChangeScopeDecision`.
- Robustness when the base branch advances: `git merge-base X head` returns the newest common ancestor. If `base.sha` is newer than the fork point, the result is the fork point. If `base.sha` is stale and older than a main merge that the head already contains, the result is `base.sha` itself. The diff then also contains main's intervening changes, which can only add paths and turn a skip into a full run, never the reverse. A stale base SHA therefore fails safe. When GitHub refreshes `pull_request.base.sha` on `synchronize` events is **NEEDS-ORCHESTRATOR-CONFIRMATION**; the safety argument does not depend on it.
- Use an explicit two-dot diff from the computed merge base rather than `git diff base...head`. The two forms are equivalent per the manual. The explicit form logs the merge-base SHA and gives a distinct reason when resolution fails.

### Rejected alternatives (brief)

- **`git merge-base origin/<BASE_REF> HEAD`**: gives a slightly more precise merge base when `base.sha` is stale. It depends on the remote-tracking ref being fetched and passes a payload ref name to git. Rejected in favor of the immutable SHA.
- **Fixed `origin/main` with no new env (no `ci.yml` change)**: a PR into `development` or `epic/**` would be compared against main, which is wrong. The base ref is needed in any case to restrict the fallback.
- **Merge base as the primary comparison**: this would lose the #962 case, a code PR followed by docs-only evidence commits, where only the narrower green-run diff can skip. The green-run base stays primary.

## 3. Behavior Semantics

### 3.1 Decision order after the fix (`Resolve-CiChangeScopeDecision`)

1. Event and fork gate (unchanged): `merge_group`, `push`, `workflow_dispatch` give `EVENT_NOT_PULL_REQUEST`. A fork gives `FORK_PULL_REQUEST`. Neither invoker is called.
2. Required context check (unchanged four values). `BaseSha` and `BaseRef` are **not** added to the throw list. They are consulted only at the fallback, so a blank value cannot turn into `UNEXPECTED_ERROR` on the primary path.
3. Config parse (unchanged).
4. Green-run base (unchanged). `RUN_LIST_FAILED` and `JOB_LIST_FAILED` stay terminal full runs: unreadable API data indicates an anomalous environment, and the existing tests and README rule are kept. `ANCESTRY_CHECK_FAILED`, `DIFF_FAILED`, `EMPTY_DIFF`, and `NON_ALLOWLISTED_PATH` on the green-run diff stay terminal.
5. Fallback trigger set: `NO_FULL_GREEN_RUN`, `BASE_NOT_PRESENT`, `BASE_NOT_ANCESTOR`.
   - Justification for including the last two: after a rebase or force-push, the recorded green head is no longer an ancestor. The merge-base diff is sound by itself, because it describes the whole PR against tested main and does not depend on the stale run.
   - Expected effect on existing rows: if their contexts gain a `BaseRef` key with value `main`, those rows would then reach the merge-base step. They are kept unchanged by leaving `BaseRef` absent (section 5).
6. Fallback applicability: `BaseRef -ceq 'main'`. Otherwise the primary reason is returned unchanged (`code=true`).
7. Merge-base resolution failure gives `MERGE_BASE_UNRESOLVED` (`code=true`, `BaseSha` blank). This covers a blank `BASE_SHA`, a missing commit (shallow or partial history), a `git merge-base` exit code other than 0 (exit 1 means no common ancestor), and output that is empty, multi-line, or not a SHA.
8. Merge-base diff: the same arguments as the primary diff. A failure gives `DIFF_FAILED`. An empty diff gives `EMPTY_DIFF`. Any rejected path gives `NON_ALLOWLISTED_PATH: <path>`. Otherwise the decision is `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<sha>`. In all of these cases `BaseSha` is the merge base, so the summary records `base=<sha>`.
9. Envelope (unchanged): any throw gives `UNEXPECTED_ERROR` plus a warning.

### 3.2 Main-push behavior (manual-verification note in the issue)

`ci.yml` triggers on `push` to `main` and `development`. `Test-CiChangeScopeEventEligible` returns `EVENT_NOT_PULL_REQUEST` for `push` before any gh or git call. This is pinned by the `-ForEach` rows for `merge_group`, `push`, and `workflow_dispatch` in both `CiChangeScope.Tests.ps1` and `Invoke-CiChangeScope.Tests.ps1`. The push CI run on main after a docs-only merge is therefore always a full run with `CI full run` succeeding. The fix does not touch step 1. The issue's manual note is answered by design and by those rows. A live confirmation is one `gh run view` of the main push run after the item merges (**NEEDS-ORCHESTRATOR-CONFIRMATION**).

### 3.3 Security

- **Trust assumption:** the fallback trusts that main's merge-base commit was validated. Main accepts merges only after the 11 required contexts of ruleset 15241672 pass, and every push to main runs a full CI run. A docs-only PR changes no code, so its `success` makes no claim about code. This is the same statement the brief already makes for docs-only commits.
- **Residual risk 1:** under non-strict required checks, main can contain a combination of PRs that was never tested together. A docs-only PR then reports green while main's push run may be red. Visibility comes from the main push run. This risk exists before this fix and does not depend on it.
- **Residual risk 2:** PR base other than main. `development` has push CI, but whether a ruleset protects it is **NEEDS-ORCHESTRATOR-CONFIRMATION**. `epic/**` receives no push CI at all (the `push` trigger lists only `main` and `development`). Recommendation: apply the fallback **only for base ref `main`**. Other bases keep the #962 behavior (`NO_FULL_GREEN_RUN`, `code=true`).
- **Residual risk 3:** forks. The fork gate stays first, so payload values from a fork PR are never consulted. `BASE_SHA` and `BASE_REF` come from the GitHub event payload, not from the head commit.
- **Residual risk 4:** the allowlist file itself. `config/ci-docs-only-paths.json` is under `config/`, which is not an include prefix, so a PR that edits it always runs in full. The existing row 'Test-CiDocsOnlyPath rejects config/ci-docs-only-paths.json' already pins this.

## 4. Requirements Mapping and File Changes

| Fix scope item | Design | Files |
|---|---|---|
| 1 Merge-base fallback | Section 3.1 steps 5 to 8. New pure helpers in the module. Context and orchestration in the entry script. | `scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`, `.github/workflows/ci.yml` |
| 2 Fail closed | `MERGE_BASE_UNRESOLVED` | same |
| 3 Renames and copies | No production change (section 1.4). Reuse the diff argument list. Add tests. | tests only |
| 4 Prefixes | Add `docs/features/archive/`, `docs/features/parallel/`, `docs/features/epics/`. No new exclude. | `config/ci-docs-only-paths.json` |
| 5 Never-skip and fork | Step 1 unchanged. Rows retained. | none |

Proposed pure helpers for `CiChangeScope.psm1`, held to the module's no-I/O rule:

- `Test-CiMergeBaseFallbackApplicable -PrimaryReason <string> -BaseRef <string>`: returns `$true` only when the reason is in `{NO_FULL_GREEN_RUN, BASE_NOT_PRESENT, BASE_NOT_ANCESTOR}` and `BaseRef -ceq 'main'`.
- `ConvertFrom-CiMergeBaseOutput -Text <string>`: returns the trimmed SHA when the text is exactly one line of 40 lower-case hex characters (64 also accepted for SHA-256 repositories), otherwise `''`.

The module goes from 346 lines to about 400. Add both helpers to `Export-ModuleMember`.

Entry-script changes in `Invoke-CiChangeScope.ps1`:

- `Get-CiChangeScopeContext` also reads `BASE_SHA` and `BASE_REF`. The comment "six decision inputs" becomes "eight".
- A new function, `Find-CiChangeScopeMergeBase` (`-BaseSha`, `-HeadSha`, `-GitInvoker`), returns `{ Reason; BaseSha }`.
- The diff and classification steps move into a shared helper, for example `Get-CiChangeScopeDiffDecision` (`-BaseSha`, `-HeadSha`, `-Config`, `-GitInvoker`, `-DocsOnlyReasonPrefix`). The green-run path and the merge-base path both call it, which avoids duplicating the diff code.
- The `.DESCRIPTION` text is updated.
- The script grows from 271 lines to about 340.

Batch budget: the fix touches two PowerShell production files, under the cap of three. `ci.yml`, the JSON config, and Markdown files do not count. No new production `.ps1` or `.psm1` file is recommended.

`ci.yml`: add two env lines to step `scope`:

```yaml
          BASE_SHA: ${{ github.event.pull_request.base.sha }}
          BASE_REF: ${{ github.base_ref }}
```

Both lines are empty on `merge_group`, `push`, and `workflow_dispatch`, and the decision returns before using them.

## 5. Testing Implications

### 5.1 Existing rows and disposition

- `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`, row 'configures exactly the D3 include prefixes and extensions (AC-15)': **must be updated**. Its exact string becomes `docs/features/active/,docs/features/archive/,docs/features/completed/,docs/features/epics/,docs/features/parallel/,docs/features/potential/,docs/research/` (ordinal sort). Add a `-ForEach` row asserting that each new prefix is listed. The 'does not let any include prefix cover <Path>' rows (`docs/features/templates/`, `docs/engineering/`, `docs/discovery/`) stay valid, because no new prefix is a prefix of those paths and none of those paths is a prefix of a new prefix. Final size is about 115 lines.
- `tests/scripts/ci/CiChangeScope.Tests.ps1`, row 'defines only the eight pure functions ... (AC-17)': **must be updated**. Add the two helper names to `$expected` and change the wording from eight to ten. Other rows are unaffected. Their inline config is test-local and need not change, but rows for the new prefixes should use a local config that contains them. New rows (about 60 lines, giving about 385):
  - `Test-CiDocsOnlyPath` accepts a path under each new prefix.
  - `Get-CiChangeScopePathDecision` gives `NON_ALLOWLISTED_PATH` for a two-sided rename list in both directions.
  - `Test-CiMergeBaseFallbackApplicable` truth table: each trigger reason with `main`; `development`, `epic/x`, `''`, and `Main` give false; `RUN_LIST_FAILED` with `main` gives false.
  - `ConvertFrom-CiMergeBaseOutput` returns `''` for valid, empty, multi-line, short, upper-case or non-hex, and whitespace-padded input.
- `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` (411 lines): leave it **unchanged**, apart from an optional comment. Its scenario context has no `BaseRef` key, so `[string]$Context['BaseRef']` is `''`, the fallback is not applicable, and every `NO_FULL_GREEN_RUN`, `BASE_NOT_PRESENT`, and `BASE_NOT_ANCESTOR` row keeps its reason. The AC-8 diff-argument row still sees exactly one diff call in the standard scenario. The 'reads the six context values' row still passes, because it asserts named values and not a count. Coverage of the two new reads goes into the new file. Do not extend this file, because it is close to the 500-line limit.
- `tests/scripts/workflows/CiWorkflow.Tests.ps1`, row 'reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph': **must be updated**. Its pattern matches `github\.event\.pull_request|github\.base_ref`, so the two new env lines must be added to `$allowedEventFieldLines` (`'BASE_SHA: ${{ github.event.pull_request.base.sha }}'` and `'BASE_REF: ${{ github.base_ref }}'`). The comment changes from "these five pull-request fields" to "these seven". Without this update, the row fails as soon as `ci.yml` changes.
- `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`: no existing row breaks. The checkout, permissions, step, and marker rows are unaffected. Add one row in the `ci.yml decision jobs` context asserting that step `scope` carries both new env lines.
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: no row breaks if the brief keeps its required tokens (`` `Change scope` ``, `` `CI full run` ``, `` `scripts/ci/Invoke-CiChangeScope.ps1` ``, `` `config/ci-docs-only-paths.json` ``, `` `run-heavy: false` ``, the 11 contexts, `ruleset 15241672`, `2026-10-16`, `Refresh rule`, `` `merge_group` ``). `test_brief_copies_are_byte_identical` requires all six copies to be identical. `test_brief_has_no_g11_or_g12_findings` forbids line-number or commit-SHA citations, so write `DOCS_ONLY_SINCE_MERGE_BASE_<merge base sha>` with a placeholder.
- No test pins the text of the `.github/workflows/README.md` section (Grep for `Change-Scope Decision` and `workflows/README` under `tests/` found only an unrelated blast-radius fixture).

### 5.2 New test file

`tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1` goes in the mirrored `tests/scripts/ci/` location and is about 250 lines. It dot-sources the entry script and uses compact in-memory fakes with the same shape as the existing suite. Its fake git invoker distinguishes `merge-base --is-ancestor` from the bare `merge-base <a> <b>` form by `$args[1]`. Rows:

1. No green run, base ref `main`, docs-only merge-base diff: `code=false`, Log `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<mb>`, Summary `base=<mb>`.
2. Same, with one non-allowlisted path: `NON_ALLOWLISTED_PATH: <path>`.
3. Rename out of the allowlist (`scripts/x.ps1` deleted, `docs/features/archive/x.md` added): full run. The reverse direction also gives a full run.
4. Each new prefix (`archive`, `parallel`, `epics`) through the merge-base path using the committed config (`-OmitConfigJson`).
5. `MERGE_BASE_UNRESOLVED` for each case: blank `BaseSha`; `cat-file` exit 128; `merge-base` exit 1 (no common ancestor or shallow history); `merge-base` exit 128; empty output; non-SHA output.
6. `BASE_NOT_ANCESTOR` and `BASE_NOT_PRESENT` primary reasons fall back with base ref `main`.
7. Base ref `development` or `epic/x` keeps `NO_FULL_GREEN_RUN`, and no `merge-base <a> <b>` call is made.
8. `RUN_LIST_FAILED` and `JOB_LIST_FAILED` do not fall back.
9. Merge-base diff failure gives `DIFF_FAILED`. Empty merge-base diff gives `EMPTY_DIFF`.
10. The merge-base diff uses the same seven flags plus `<mb> <head>`.
11. `push`, `merge_group`, `workflow_dispatch`, and fork events with `BaseRef=main` still decide before any invoker call (never-skip regression).
12. `Get-CiChangeScopeContext` reads `BASE_SHA` and `BASE_REF`.

### 5.3 Gates

- PowerShell line coverage of at least 85% applies to both changed production files, read from `artifacts/pester/powershell-coverage.xml`.
- Run the isolation checks from the brief: at least three seeded shuffled file-order runs of the touched Pester suites, and a fresh single-process run over `tests/scripts`.
- Run the brief contract tests and the push-down resource contract tests after editing the bundled brief copies.

## 6. CI-Dependent Proof (S9)

- **Why the positive path cannot run on the item's own PR:** the change-scope script runs from the PR head checkout. The positive merge-base path needs a PR whose whole diff against main is docs-only *and* whose head contains the new script. Before the item merges, any such head also carries the item's code changes. These options were evaluated and rejected:
  - A probe branch off the item branch with a PR into main: the diff includes the code changes.
  - A probe PR targeting the item branch: `pull_request` does not trigger on that base, and the base is not main.
  - A docs-only branch off main: it runs main's old script.
- **Pre-merge proof on the item PR:**
  - (a) The first run logs `code=true reason=NON_ALLOWLISTED_PATH: <first code path>` and not `NO_FULL_GREEN_RUN`. The old script would log `NO_FULL_GREEN_RUN`, so this line shows that the merge-base branch executed. The job summary shows `base=<merge base sha>`. `CI full run` succeeds and all 11 required contexts report `success`.
  - (b) A later docs-only evidence commit on the same PR logs `code=false reason=DOCS_ONLY_SINCE_<green head sha>`. This is a #962 regression proof of the primary path.
- **Post-merge proof (recommended to close the positive-path acceptance criterion):** use the item's own closure PR, opened from main after the merge, which moves the feature folder from `docs/features/active/` to `docs/features/archive/`. It is docs-only and consists of renames into a new prefix, so it exercises fix items 1, 3, and 4 at once. Evidence to record from that PR:
  - The `Change scope` log line `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<sha>`.
  - The heavy jobs reporting every step skipped, with the `poshqc / PowerShell QC static` and shard jobs skipped at job level.
  - `CI full run` skipped.
  - All 11 required contexts `success`.
- **Integration scenario part 2:** push one non-allowlisted commit to a throwaway probe PR from main, and confirm a full run whose log line starts with `code=true reason=NON_ALLOWLISTED_PATH:`. Then close the probe PR without merging.
- Commands and run identifiers are **NEEDS-ORCHESTRATOR-CONFIRMATION** (`gh run view --log`, `gh pr checks`).

## 7. Documentation That Must Change in the Same Change

- Execution-environment brief, bullet `Change-scope decision (issue #962)` under `## CI Shape and Required Checks`, in six byte-identical copies. All six paths were verified to exist, by Grep hits and by `_BRIEF_COPIES` in the contract test:
  - `.claude/skills/execution-environment/SKILL.md`
  - `.agents/skills/execution-environment/SKILL.md`
  - `.github/skills/execution-environment/SKILL.md`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
  - `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`

  The bullet must state:
  - the merge-base fallback, its trigger reasons, and that it applies only to base `main`;
  - the seven include prefixes;
  - `MERGE_BASE_UNRESOLVED` in the full-run list;
  - that both sides of a rename are classified.

  The bullet text "no earlier full green run" in the full-run list becomes conditional on the base not being main or the merge base being unresolved.
- `.github/workflows/README.md` `## Change-Scope Decision (Issue #962)`: update `### Decision` (fallback paragraph), the reason-code list (add `DOCS_ONLY_SINCE_MERGE_BASE_<merge base sha>` and `MERGE_BASE_UNRESOLVED`), `### Allowlist` (seven prefixes), and `### Fail-closed rules`. Optionally rename the heading to `(Issues #962 and #973)`. No test pins the heading.
- Contract tests to run after the brief edit: `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, `test_push_down_claude_resource_contracts.py`, and `test_push_down_codex_and_agents_resource_contracts.py`. The pack-manifest completeness tests are unaffected, because no new bundled file is added.

## Pre-Mortem

- Review checklists: preflight must search `tests/` for the reason codes, `include_prefixes`, the env-line allowlist, and the eight-function list, and must name each matching row with its disposition (section 5.1). Missing the `CiWorkflow.Tests.ps1` event-field allowlist update is the most likely review-blocking defect.
- Coverage: both changed production files (`scripts/ci/CiChangeScope.psm1`, `scripts/ci/Invoke-CiChangeScope.ps1`) fall under the `scripts` coverage root and need at least 85% line coverage, read from `artifacts/pester/powershell-coverage.xml`. Every new branch (each `MERGE_BASE_UNRESOLVED` cause, the non-main base ref, and each fallback trigger reason) needs a row. The rows must use fakes and not blanket mocks.
- Mirror parity: the brief bullet must be edited identically in all six copies, three of which are bundled under `extensions/drm-copilot/resources/`. Run `test_execution_environment_brief_contracts.py` and both push-down resource contract tests. The bundled copies are Markdown and do not consume batch-budget slots.
- File size: projected sizes are `CiChangeScope.psm1` about 400 lines, `Invoke-CiChangeScope.ps1` about 340, `CiChangeScope.Tests.ps1` about 385, `CiDocsOnlyPathsConfig.Tests.ps1` about 115, and the new merge-base test file about 250. `Invoke-CiChangeScope.Tests.ps1` (411) is not extended. Confirm the physical line counts with `wc -l` after editing.
- Test isolation: the new suite dot-sources the entry script, and that imports `CiChangeScope.psm1` with `-Force`. Keep helper functions in `BeforeAll`, change no environment variables, and create no files. Run at least three seeded shuffled file-order runs of the five touched suites and one fresh single-process run over `tests/scripts`.
- CI-only behavior: the remote-tracking ref and the refresh semantics of `pull_request.base.sha` are unverified locally, and the design does not depend on either. The positive merge-base path can run only after merge (section 6). The item PR's first run must log `NON_ALLOWLISTED_PATH:` and not `NO_FULL_GREEN_RUN`. If it logs `MERGE_BASE_UNRESOLVED`, the checkout lacks the base commit and needs investigation before merge.
- Evidence: record the item PR's `Change scope` log line, the 11 contexts, and the post-merge closure-PR proof under `<FEATURE>/evidence/regression-testing/` and `<FEATURE>/evidence/qa-gates/`, with UTC timestamps read from the clock and no absolute paths.

## Numeric Derivation Evidence

### Claim N1: include prefixes after the fix number 7

- Complete Family: the `include_prefixes` entries of `config/ci-docs-only-paths.json` after the fix.
- Exhaustive Search Scope: the committed config file, plus the prefix additions required by issue #973 (`issue.md` Summary and Proposed Fix).
- Inclusion Rules: every string in `include_prefixes` now, plus every prefix the issue requires to be added.
- Exclusion Rules: `exclude_prefixes` entries and extensions.
- Primary Search Strategy or Query Expression: Read `config/ci-docs-only-paths.json` (`include_prefixes` array) and union it with the three prefixes named in `issue.md` `## Summary`.
- Primary Member Set: `docs/features/active/`, `docs/features/completed/`, `docs/features/potential/`, `docs/research/`, `docs/features/archive/`, `docs/features/parallel/`, `docs/features/epics/`.
- Primary Count: 7.
- Cross-check Search Strategy or Query Expression: the exact-string assertion in `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`, row 'configures exactly the D3 include prefixes' (4 members), and the `### Allowlist` paragraph of `.github/workflows/README.md` (4 members), unioned with `issue.md` `## Proposed Fix / Validation Ideas` ("Add `docs/features/archive/`, `docs/features/parallel/` and `docs/features/epics/` to `include_prefixes`").
- Cross-check Member Set: `docs/features/active/`, `docs/features/completed/`, `docs/features/potential/`, `docs/research/`, `docs/features/archive/`, `docs/features/parallel/`, `docs/features/epics/`.
- Cross-check Count: 7.
- Member-set Comparison: the sets are identical after normalization (exact strings, ordinal). No duplicates. Agree.

### Claim N2: 11 required contexts must report success on a docs-only run

- Complete Family: required status contexts of ruleset 15241672.
- Exhaustive Search Scope: the brief bullet `Required contexts of ruleset 15241672`, the README table `### Required contexts under a docs-only run`, and `_REQUIRED_CONTEXTS` in `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`.
- Inclusion Rules: contexts listed as required.
- Exclusion Rules: non-required jobs (`Change scope`, `CI full run`, `root-typescript-tests`, `NPM Audit Gate`, `poshqc / PowerShell QC static`, shards, Linux hook suites).
- Primary Search Strategy or Query Expression: Read the brief bullet that begins `Required contexts of ruleset 15241672`.
- Primary Member Set: Extension Tests (ubuntu-latest); Extension Tests (windows-latest); Documentation Validation; PowerShell QC; Shell Coverage (Bats + kcov); Security Scanning; Code Quality & Tests (3.10); (3.11); (3.12); (3.13); Build Package.
- Primary Count: 11.
- Cross-check Search Strategy or Query Expression: Read the README table rows numbered 1 to 11, independently of the brief.
- Cross-check Member Set: the same 11 names (rows 1 to 11).
- Cross-check Count: 11.
- Member-set Comparison: identical, and also identical to the 11-tuple `_REQUIRED_CONTEXTS`. Agree. The live ruleset was confirmed by the orchestrator on 2026-10-16 per the brief. Re-confirmation before S9 is **NEEDS-ORCHESTRATOR-CONFIRMATION** per the brief's Refresh rule.

## Recommendations

### Design decisions

1. Keep the green-run base as the primary comparison. Fall back to the merge base on `NO_FULL_GREEN_RUN`, `BASE_NOT_PRESENT`, and `BASE_NOT_ANCESTOR` only. Keep `RUN_LIST_FAILED`, `JOB_LIST_FAILED`, and `ANCESTRY_CHECK_FAILED` terminal.
2. Apply the fallback only when `BASE_REF` is exactly `main`. Other bases keep the primary reason.
3. Compute `git merge-base <BASE_SHA> <HEAD_SHA>` from the payload base SHA after `git cat-file -e`. Validate the output as a single SHA. Diff two-dot from the merge base with the unchanged seven-flag argument list.
4. Classify renames on both sides by keeping `--no-renames` with `--name-only` (no production change). Pin it with tests. Confirm deletion listing locally once.
5. Add `docs/features/archive/`, `docs/features/parallel/`, `docs/features/epics/` to `include_prefixes`. Add no new exclude prefix.
6. Leave event and fork gating untouched, so `push`, `merge_group`, and `workflow_dispatch` always run in full and main push CI runs in full after a docs-only merge.
7. Keep `BaseSha` and `BaseRef` out of the required-context throw list. Leave the existing `Invoke-CiChangeScope.Tests.ps1` rows unchanged, and put new entry-script rows in a new test file.
8. S9 proof: the pre-merge log line `NON_ALLOWLISTED_PATH:` (not `NO_FULL_GREEN_RUN`) on the item PR, the #962 docs-only evidence commit, and post-merge positive proof on the docs-only archive-move closure PR.

### Reason codes to add

- `DOCS_ONLY_SINCE_MERGE_BASE_<merge base sha>` (`code=false`; satisfies the existing `DOCS_ONLY_SINCE_` guard).
- `MERGE_BASE_UNRESOLVED` (`code=true`).

### Files the fix must write (repository-relative)

- `scripts/ci/CiChangeScope.psm1`
- `scripts/ci/Invoke-CiChangeScope.ps1`
- `.github/workflows/ci.yml`
- `config/ci-docs-only-paths.json`
- `tests/scripts/ci/CiChangeScope.Tests.ps1`
- `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`
- `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1` (new)
- `tests/scripts/workflows/CiWorkflow.Tests.ps1`
- `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`
- `.github/workflows/README.md`
- `.claude/skills/execution-environment/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`

`tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` is intentionally not written. It is unaffected (section 5.1).
