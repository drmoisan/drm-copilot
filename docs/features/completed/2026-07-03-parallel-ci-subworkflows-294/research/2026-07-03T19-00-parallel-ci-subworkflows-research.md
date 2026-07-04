# Research: Parallel CI Subworkflows (Issue #294)

- Timestamp: 2026-07-03T19-00
- Issue: #294
- Scope: `.github/workflows/**` only (CI-gate structure). No `src/` or
  `extensions/drm-copilot/src` application behavior is in scope. This research pass had
  `Read`, `Grep`, `Glob`, `WebFetch`, `Write` tools only — no `Bash`/`gh` access — so any
  claim that would normally be confirmed with `gh api` or a live workflow run is flagged
  explicitly as unverified-by-this-pass rather than stated as fact.

## 1. Current-State Analysis — `.github/workflows/ci.yml` Job Inventory

Full file read (`ci.yml`, 325 lines, top-level `on:` = `push` to `main`/`development`,
`pull_request` to `main`/`development`, `workflow_dispatch`). Seven jobs, in file order:

| Job (id) | Display name | Runner(s) | Matrix | External deps / caches | Step count | Notes |
|---|---|---|---|---|---|---|
| `quality-checks7` | Code Quality & Tests | `ubuntu-latest` | `python-version: ["3.10","3.11","3.12","3.13"]` (4-way) | Poetry install, `actions/cache@v6` keyed on `venv-${{ runner.os }}-${{ matrix.python-version }}-${{ hashFiles('**/poetry.lock') }}`, Codecov upload (only on 3.13) | 8 steps | Runs Black/Ruff/Pyright/Pytest; `poetry check --lock` + `git diff --exit-code poetry.lock` guard |
| `security-scan` | Security Scanning | `ubuntu-latest` | none | Poetry, `pip install safety` | 4 steps | `continue-on-error: true` on the safety-check step — this job cannot fail the run today regardless of findings |
| `docs-validation` | Documentation Validation | `ubuntu-latest` | none | none | 3 steps | Pure filesystem checks (README/LICENSE/instruction-file existence) |
| `build-check` | Build Package | `ubuntu-latest` | none | Poetry | 4 steps | `poetry build` + venv install smoke test of `atomic-executor --help`/`shell-qc --help` |
| `poshqc` | PowerShell QC | `windows-latest` | none | none (imports `scripts/powershell/PoshQC/PoshQC.psm1` directly from checkout) | 5 steps | Only Windows-runner job; uploads Pester/coverage artifacts via `actions/upload-artifact@v7` |
| `shell-coverage` | Shell Coverage (Bats + kcov) | `ubuntu-latest` | none | Poetry, apt packages (`shellcheck`, `bats`), `shfmt` binary download, `actions/cache@v6` keyed `kcov-v43-ubuntu-latest` for a from-source kcov build | 9 steps | Longest/heaviest job on a cache miss (kcov built from source via `cmake`/`make`); uploads coverage artifacts |
| `drm-copilot-extension-tests` | drm-copilot Extension Tests (`${{ matrix.os }}`) | `windows-latest`, `ubuntu-latest` | `os: [windows-latest, ubuntu-latest]` (2-way) | `actions/setup-node@v6` with npm cache keyed on `extensions/drm-copilot/package-lock.json` | 3 steps | Smallest/simplest job |

**Total concurrently-schedulable job runs per CI trigger**: 4 (quality-checks7 matrix) + 1
(security-scan) + 1 (docs-validation) + 1 (build-check) + 1 (poshqc) + 1 (shell-coverage) + 2
(extension-tests matrix) = **11 job runs**.

### `needs:` confirmation

`grep -n "needs:" .github/workflows/ci.yml` returns zero matches. Read of the full file
confirms no job block contains a `needs:` key. **The premise "no job currently has a `needs:`
dependency on another job" is confirmed true.** All 11 job runs are already DAG-independent
and GitHub Actions is already free to schedule all of them concurrently, subject only to
runner-concurrency limits (below) and available runner supply.

### `poshqc` job vs. `.claude/rules/ci-workflows.md`

The rule targets a `pwsh` step whose `run:` block "intentionally invokes a command expected to
fail" as a synthetic negative-path check (e.g., asserting a gate catches a regression), and
requires the residual `$LASTEXITCODE` not leak. The `poshqc` job's "Format PowerShell" step
(lines 184–192 of `ci.yml`) does the opposite: it calls `Invoke-PoshQCFormat`, checks
`git status --porcelain` for a real (not synthetic) dirty working tree, and calls
`Write-Error "..."` when files were reformatted. This is the job's actual primary failure
path, not a deliberately-failing nested command exercising a negative-path assertion — so
**`.claude/rules/ci-workflows.md` does not apply to this step**, confirming the task's
hypothesis. Separately (out of this feature's scope, but worth flagging since the step is
carried over verbatim into the extracted `_poshqc.yml`): `Write-Error` alone, without
`$ErrorActionPreference = 'Stop'` or an explicit `exit 1`, raises a non-terminating error and
does not by itself set a non-zero process/step exit code in a `pwsh`-shell Actions step. This
is a pre-existing characteristic of the step being relocated, not something introduced by the
extraction, and is not one of the six acceptance criteria for #294 — noted here only so a
future editor does not assume the extraction changes this step's pass/fail semantics.

### Benchmark jobs — `.claude/rules/benchmark-baselines.md`

No job in `ci.yml` invokes BenchmarkDotNet, `scripts/benchmarks/**`, or any baseline-comparison
tooling. Confirmed by the full-file read above (no matches for "benchmark" anywhere in the
file). **`.claude/rules/benchmark-baselines.md` does not apply to this feature.**

### `.github/workflows/README.md` — confirmed absent

`Glob` for `.github/workflows/*` returns exactly five files: `_npm-audit-gate.yml`, `ci.yml`,
`npm-audit-gate.yml`, `publish-extension.yml`, `publish-mcp-npm.yml`. **No `README.md` exists
in `.github/workflows/`**, despite `CLAUDE.md`'s Architecture section and
`.claude/skills/orchestrate/SKILL.md`'s "GitHub Actions Reusable Workflows" section both
referring to it ("See `.github/workflows/README.md` for the full per-stage dispatch and
branch-protection rename procedure"). This is a genuine documentation gap this feature must
close (AC-6 in the issue), not an assumption — confirmed by direct `Glob`.

### Existing convention: `_npm-audit-gate.yml` / `npm-audit-gate.yml`

Full read of both files confirms the target pattern already in production:
- `_npm-audit-gate.yml`: `on: workflow_call:` and `on: workflow_dispatch:`, each declaring the
  same `audit-level` input (`type: string`, `default: moderate`); one job (`npm-audit`) with
  `strategy.matrix.manifest: [".", "extensions/drm-copilot", "packages/mcp-server"]`.
- `npm-audit-gate.yml`: `on: schedule` (weekly cron), `on: pull_request` (path-filtered to
  `**/package.json`, `**/package-lock.json`, and the two workflow files themselves),
  `on: workflow_dispatch`; a single job `npm-audit` whose only body is
  `uses: ./.github/workflows/_npm-audit-gate.yml` with `with: audit-level: moderate` — no
  inline `steps:`, confirming the "thin orchestrator" shape.

### `publish-extension.yml` / `publish-mcp-npm.yml` — out of scope, confirmed unaffected

Both files retain their own `needs: drm-copilot-extension-tests` chain (test job → publish job,
tag-triggered). Neither references `ci.yml`, `_npm-audit-gate.yml`, or any of the seven jobs
targeted by this feature. No reason found in this research pass for #294 to touch either file;
this matches the explicit out-of-scope instruction.

## 2. Candidate Approaches

### Approach A — Extract each job into `_<name>.yml`, thin `ci.yml` orchestrator

Each of the seven current jobs becomes its own reusable workflow (`workflow_call` +
`workflow_dispatch`), and `ci.yml` is rewritten to contain only seven `uses:` job bodies (no
`needs:` between them, no inline `steps:`), mirroring `_npm-audit-gate.yml` /
`npm-audit-gate.yml` exactly.

- **Advantages**: matches the already-documented target architecture (`CLAUDE.md`,
  `.claude/skills/orchestrate/SKILL.md`); gives each gate an independent
  `workflow_dispatch` entry point (a maintainer can re-run just `_shell-coverage.yml` without
  re-running the other six); reduces single-file blast radius (a syntax error in one gate's
  YAML no longer risks the whole `ci.yml` file); each gate gets its own required-status-check
  identity that is stable across future `ci.yml` restructuring, since the identity now lives in
  the callee file rather than being tied to `ci.yml`'s own job block.
- **Limitations**: seven new files plus a rewritten `ci.yml` plus a new `README.md` — larger
  diff surface than the current single-file job set; introduces the required-status-check
  rename risk described in Section 3 below, which is a real, non-trivial one-time maintenance
  cost; does not, by itself, change wall-clock CI duration (see Approach B).

### Approach B — No extraction; tune matrix/concurrency settings in place

Leave `ci.yml` as a single file. Investigate whether the user's "runs everything sequentially"
observation is explained by something other than job-DAG structure — e.g. `max-parallel` caps,
runner-concurrency plan limits, or one dominant slow job — and address that specific bottleneck
directly (for example, priming the `kcov` cache more aggressively, or trimming the
`quality-checks7` Python matrix).

**Is the premise "CI runs everything sequentially" literally true at the job-DAG level?**
No. Section 1 confirms zero `needs:` edges across all seven jobs; GitHub Actions is already
free to schedule all 11 job runs concurrently. Concurrency-limit math: per GitHub's documented
account-plan concurrent-job caps (`docs.github.com/en/actions/reference/actions-limits`),
Free-tier accounts get 20 concurrent GitHub-hosted-runner jobs, Pro 40, Team 60, Enterprise 500.
This repository's per-trigger job count is 11 (Section 1), which is below even the lowest
published tier (20), so — absent other concurrent workflow runs competing for the same
account's runner budget — none of the seven jobs should be concurrency-throttled against each
other under normal conditions. This research pass had no `gh`/`Bash` access and therefore could
not pull actual historical run timing data (e.g. `gh run view --json jobs` timestamps) to
directly measure whether jobs observably overlapped in a real run; this specific measurement
is flagged as unverified-by-this-pass and is a reasonable follow-up for whoever executes this
feature (a `workflow_dispatch` or PR run against the branch head will produce this evidence
directly, and is already required by AC-6 / `modified-workflow-needs-green-run` regardless).

**What is the user likely actually observing?** Given the DAG is already parallel and unlikely
to be concurrency-throttled at this job count, the most evidence-supported explanation is that
total wall-clock time for "CI to go green" is bound by the single slowest job in the set, not
by serial execution. `shell-coverage` (apt package installs, a from-source `kcov` build on cache
miss, `cmake`/`make`) and the Windows-only `poshqc` job (Windows runners typically have slower
cold-start/provisioning than Linux) are the two jobs in this inventory most likely to dominate
wall-clock, particularly on a cold cache. A single-workflow-file view in the GitHub Actions UI
where jobs are listed top-to-bottom can also visually resemble a sequential list even when the
jobs are executing concurrently, which is a plausible source of the "runs everything
sequentially" perception independent of actual scheduling behavior.

- **Advantages**: no new files, no required-status-check rename risk, smallest possible diff;
  directly targets a measurable bottleneck if one is confirmed.
- **Limitations**: does not address any of the six acceptance criteria in `issue.md`, all of
  which specifically ask for the `_<name>.yml` / thin-orchestrator structure, per-gate
  `workflow_dispatch`, and a `README.md` procedure — none of which follow from tuning
  matrix/cache settings alone. Leaves the repository's own documented target architecture
  (`CLAUDE.md`) unmet for this CI file specifically, while it is already met for
  `_npm-audit-gate.yml`.

### Recommendation

**Approach A**, justified on grounds independent of a concurrency claim that the evidence does
not support: the job DAG is already parallel (Section 1), so extraction is not being
recommended to "make CI parallel" — it already is, modulo whatever the single slowest job costs
in wall-clock. Approach A is recommended because it (1) satisfies all six acceptance criteria in
`issue.md` as written, (2) closes the gap between this workflow and the target architecture
already documented and already realized once in this repository (`_npm-audit-gate.yml`), (3)
gives each gate an independent `workflow_dispatch` re-run entry point, which is operationally
useful regardless of scheduling concurrency, and (4) reduces the blast radius of a single
malformed YAML edit. The research recommends the orchestrator/implementer record, as part of
this feature's evidence, an explicit statement (in `README.md` or the PR description) that
extraction does not change job-DAG concurrency — it was already concurrent — so a future reader
does not infer a wall-clock improvement that the job-DAG restructuring itself does not produce.
Any actual wall-clock reduction, if pursued, is a separate, measurable follow-on (e.g., cache
warming for `shell-coverage`, or a smaller Python matrix), not a consequence of this refactor.

**Rejected alternative (brief)**: Approach B (tuning in place, no extraction) is rejected as the
primary approach because it does not satisfy the issue's explicit acceptance criteria, all of
which specify the `_<name>.yml` reusable-workflow structure. It remains a valid, independent
follow-up investigation (measuring actual run-timing data via `gh run view --json jobs` on a few
recent runs) that the implementer may perform alongside Approach A, since nothing in Approach A
requires or precludes it.

## 3. Behavior Semantics and Edge Cases

### Required-status-check naming for `workflow_call`-invoked jobs

GitHub's official "Reusing workflows" documentation (`docs.github.com/en/actions/sharing-
automations/reusing-workflows`, fetched directly for this research) does not, in the text
retrievable via this pass's `WebFetch` tool, spell out the exact string-composition rule for how
a status-check name is displayed when a caller job's body is only a `uses:` reference to a
reusable workflow. This research pass could not reach a definitive documentation citation for
the exact composition string despite three targeted fetch attempts against GitHub's docs and one
attempt against a GitHub Community discussion and a Stack Overflow page (the latter could not be
fetched by the tool at all). **This specific point should be treated as not independently
confirmed by this research pass** and is flagged for direct empirical verification once a real
run exists (see below), rather than asserted as settled fact.

What can be stated with the confidence of directly observed, in-repo precedent: this repository
already has one reusable-workflow split in production (`_npm-audit-gate.yml` /
`npm-audit-gate.yml`), but that gate is a **newly introduced** required check (there was no
pre-existing "npm audit" required check to rename), so its introduction created no rename
event to observe. This feature (#294) is different in kind: it is extracting **already-existing,
presumably-already-required** check names (e.g. whatever exact string branch protection
currently requires for `quality-checks7`'s four matrix legs, `poshqc`, etc.) into a new caller/
callee shape, which is exactly the scenario the rename risk in the issue's Constraints section
describes.

**Recommended verification procedure for the implementer** (since this cannot be settled from
static file reads alone): after the extraction lands and a green `workflow_dispatch` or PR run
exists against the branch head (required anyway by AC-6/`modified-workflow-needs-green-run`),
run `gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs` (or inspect the PR's "Checks"
tab) to read the **actual** composed check names GitHub produced for each extracted job, and use
those exact strings — not an assumed format — when updating branch protection. This sidesteps
the need to guess the composition rule correctly in documentation before the fact, and matches
the general engineering-caution principle already applied elsewhere in this repository's CI
rules (e.g. `.claude/rules/benchmark-baselines.md`'s provenance requirement: prefer captured
truth over assumed values).

### Reusable-workflow nesting-depth cap

`CLAUDE.md` (via `.claude/skills/orchestrate/SKILL.md`'s "GitHub Actions Reusable Workflows"
section) states: "The GitHub Actions reusable-workflow nesting depth cap is 4; this repository
uses one level of nesting and does not introduce additional levels without an explicit design
review." Direct `WebFetch` of GitHub's current "Reusing workflows" documentation states instead:
"You can connect a maximum of ten levels of workflows — that is, the top-level caller workflow
and up to nine levels of reusable workflows." **The repository's documented cap of 4 is more
conservative than GitHub's actual current platform limit of 10 total levels (1 caller + 9
reusable).** This is a discrepancy worth flagging to a maintainer (the repo-local "4" figure may
predate a GitHub platform increase, or may be an intentionally more conservative self-imposed
policy — this research pass cannot determine which from the text alone), but it does not affect
this feature: Approach A introduces exactly one level of nesting (orchestrator `ci.yml` →
`_<name>.yml`), which is within both the repository's stated cap of 4 and GitHub's actual cap of
10 by a wide margin.

### Cross-job file dependencies

Full read of all seven jobs in `ci.yml` (Section 1) found no step in any job that reads a file
produced by another job. Each job independently checks out the repository fresh
(`actions/checkout@v7`) and installs its own toolchain (Poetry/Node/PoshQC as applicable); the
only `actions/upload-artifact@v7` usages (`poshqc`, `shell-coverage`) upload their own
job-local outputs and are not consumed by any other job in this file (no
`actions/download-artifact` step exists anywhere in `ci.yml`). **Confirmed: none of the seven
jobs has a cross-job filesystem dependency.** No new `actions/upload-artifact` +
`actions/download-artifact` pairing is required by this feature beyond what already exists
(the two existing uploads, which extract 1:1 into their respective new `_<name>.yml` files with
no behavior change).

### `workflow_dispatch` + `workflow_call` + `strategy.matrix` interaction

Directly confirmed both from GitHub's documentation (fetched for this research: "the
documentation includes a section titled 'Using a matrix strategy with a reusable workflow'…") and
from in-repo precedent (`_npm-audit-gate.yml`'s `npm-audit` job declares
`strategy.matrix.manifest` on a job whose workflow is invoked via `workflow_call` from
`npm-audit-gate.yml`, and is also independently dispatchable via its own `on: workflow_dispatch:`
trigger). **Yes — a reusable workflow invoked via `uses:` can still declare its own
`strategy.matrix`.** This directly supports extracting `quality-checks7` (4-way Python matrix)
and `drm-copilot-extension-tests` (2-way OS matrix) into `_quality-checks.yml` and
`_drm-copilot-extension-tests.yml` respectively without flattening or otherwise restructuring
their matrices — the matrix stays declared inside the callee, unchanged.

## 4. Requirements Mapping to Design

| Acceptance criterion (from `issue.md`) | Concrete file changes |
|---|---|
| Each job extracted into its own `_<name>.yml` (`workflow_call` + `workflow_dispatch`) | New: `.github/workflows/_quality-checks.yml`, `.github/workflows/_security-scan.yml`, `.github/workflows/_docs-validation.yml`, `.github/workflows/_build-check.yml`, `.github/workflows/_poshqc.yml`, `.github/workflows/_shell-coverage.yml`, `.github/workflows/_drm-copilot-extension-tests.yml` |
| Thin orchestrator (retains `ci.yml` name/triggers) invokes each via `uses:`, no inline `steps:`, no artificial `needs:` | Rewritten: `.github/workflows/ci.yml` — seven jobs, each body only `uses: ./.github/workflows/_<name>.yml`, same `on: push/pull_request/workflow_dispatch` triggers as today |
| Cross-job file dependency uses explicit upload/download artifact | No file change required — Section 3 confirms zero cross-job dependencies exist to convert |
| Required-status-check names continue to resolve (renamed or preserved, documented) | New/updated: `.github/workflows/README.md` (rename procedure) plus a one-time branch-protection settings update (see Section 5) — not a workflow YAML file |
| `.github/workflows/README.md` documents per-stage dispatch + rename procedure | New: `.github/workflows/README.md` (currently absent, confirmed in Section 1) |
| Green workflow run against branch head captured before merge | Evidence artifact under this feature's `evidence/` directory (workflow-run URL/SHA), not a source file |

**Proposed naming scheme** (mirrors `_npm-audit-gate.yml`'s `_<gate-name>.yml` convention,
one file per current job id, using the job's existing display-name concept collapsed to
kebab-case):

- `_quality-checks.yml` (callee job retains the 4-way Python matrix; keep `python-version` matrix
  inline, not as a `workflow_call` input, since it is not varied by any caller)
- `_security-scan.yml`
- `_docs-validation.yml`
- `_build-check.yml`
- `_poshqc.yml`
- `_shell-coverage.yml`
- `_drm-copilot-extension-tests.yml` (retains the 2-way OS matrix)

Each declares `on: workflow_call:` and `on: workflow_dispatch:` (mirroring
`_npm-audit-gate.yml`'s shape — no inputs are strictly required by any of these seven jobs,
since none of them take parameters from a caller today, but declaring the two `on:` triggers
with no `inputs:` block is sufficient and matches the minimum contract the issue specifies).

### Required-status-check rename procedure — manual vs. scriptable

The rename step is **not** genuinely unautomatable via API: GitHub exposes
`GET /repos/{owner}/{repo}/branches/{branch}/protection/required_status_checks` (read current
required contexts) and `PATCH /repos/{owner}/{repo}/branches/{branch}/protection/
required_status_checks` (update the `checks` array, each entry `{ "context": string, "app_id":
integer|null }`) per GitHub's REST API documentation (fetched directly for this research). Both
endpoints are reachable via `gh api` and require only repository admin/owner permission plus
branch protection already being enabled — no browser-only or third-party-UI step is involved.
Because this is scriptable, this research does **not** treat the rename as a `human_interaction`
candidate for the orchestrator. It is, however, sequence-dependent on real data that does not
exist until after the extraction lands and produces its first real check-run names (Section 3),
so the practical procedure is: (1) land the extraction with a `workflow_dispatch`/PR run against
the branch head (already required by AC-6), (2) read the actual produced check-run names via
`gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs`, (3) `gh api … PATCH …
required_status_checks` with the confirmed new context strings, removing the old (pre-extraction)
context strings from the `checks` array once the new checks are verified present, (4) document
both the old and new context strings, plus the exact `gh api` commands used, in
`.github/workflows/README.md` so the procedure is repeatable. This four-step procedure is what
`README.md` should document as "the full per-stage dispatch and branch-protection rename
procedure" referenced by `CLAUDE.md` and `.claude/skills/orchestrate/SKILL.md` — filling the gap
confirmed in Section 1.

## 5. Testing Implications

- Each new `_<name>.yml` reusable workflow should be independently exercised via its own
  `on: workflow_dispatch:` trigger (`gh workflow run _<name>.yml`) before being wired into the
  rewritten `ci.yml`, confirming the extraction preserved the job's existing pass/fail behavior
  byte-for-byte (steps are lifted verbatim; only the `on:`/wrapper shape changes).
- The rewritten `ci.yml` orchestrator, and each of the seven new `_<name>.yml` files, fall under
  `.github/workflows/**`, which triggers the `modified-workflow-needs-green-run` policy rule
  (`.claude/skills/feature-review-workflow/SKILL.md`): a Blocking finding is raised unless a
  green workflow run against the branch head is present in remediation inputs before merge. A
  `workflow_dispatch` run against the branch head satisfies this rule (not only a PR-context
  run), which matters here because `ci.yml`'s own `pull_request` trigger is what would normally
  produce this evidence — the same chicken-and-egg case the rule's documentation already
  anticipates.
- No YAML file in scope triggers `.claude/rules/benchmark-baselines.md` (confirmed no benchmark
  job exists, Section 1) or invokes a deliberately-failing nested command under
  `.claude/rules/ci-workflows.md` (confirmed for the one candidate step, `poshqc`'s "Format
  PowerShell" step, Section 1) — no additional workflow-specific validator run is implied beyond
  the standard `actionlint`/YAML-parse check already used for `_npm-audit-gate.yml`
  (`feature-audit.2026-06-20T00-43.md`, AC-5).
- This feature has no application-level unit/integration tests to write or update: all seven
  jobs' actual test invocations (Pytest, Pester, Bats, npm test) are unchanged by the
  extraction — only the YAML wrapper shape changes. The testing surface for #294 itself is: (a)
  YAML validity (`actionlint` + a YAML parse check per manifest, matching the existing
  `_npm-audit-gate.yml` precedent), (b) a successful `workflow_dispatch` run per new `_<name>.yml`
  file, and (c) the green branch-head run required by `modified-workflow-needs-green-run`.
- No test code is proposed here per this agent's research-only scope.
