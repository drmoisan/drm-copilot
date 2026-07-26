# QA Gate — `ci.yml` Orchestrator Wiring Verification (#421)

Timestamp: 2026-07-26T05-41

Task: [P5-T5] — AC5 end-to-end evidence and green-run evidence for the `ci.yml` diff.

Command:

```
gh run view 30189336124 --json status,conclusion,url,headSha
gh run view 30189336124 --json jobs --jq '.jobs[] | "\(.conclusion)\t\(.name)"'
gh run watch 30189336124 --exit-status --interval 20
```

EXIT_CODE: 0

**Same run as [P5-T3]/[P5-T4]. No second dispatch was performed**, per the [P5-T5] task instruction.

## Run Identification

| Field | Value |
|---|---|
| Run URL | https://github.com/drmoisan/drm-copilot/actions/runs/30189336124 |
| Workflow | `ci.yml` (CI) |
| Trigger | `workflow_dispatch` |
| Ref | `bug/vscode-test-integration-entrypoint` |
| Head SHA | `df874e81fc9e741921376e621e171cfb2d2a31e2` |
| Overall conclusion | **`success`** |

## Per-Job Conclusions (all 16 jobs)

```
$ gh run view 30189336124 --json jobs --jq '.jobs[] | "\(.conclusion)\t\(.name)"'
success  docs-validation / Documentation Validation
success  NPM Audit Gate / npm audit (extensions/drm-copilot)
success  build-check / Build Package
success  NPM Audit Gate / npm audit (packages/mcp-server)
success  security-scan / Security Scanning
success  quality-checks7 / Code Quality & Tests (3.11)
success  shell-coverage / Shell Coverage (Bats + kcov)
success  poshqc / PowerShell QC
success  quality-checks7 / Code Quality & Tests (3.10)
success  quality-checks7 / Code Quality & Tests (3.13)
success  NPM Audit Gate / npm audit (.)
success  root-typescript-tests / Root TypeScript Tests (ubuntu-latest)
success  quality-checks7 / Code Quality & Tests (3.12)
success  drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)
success  drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)
success  root-typescript-tests / Root TypeScript Tests (windows-latest)
```

**16 of 16 jobs concluded `success`. Zero failures, zero cancellations, zero skips.**

## Wiring Confirmation

1. **The new job is present in the run's job list.** Both `root-typescript-tests / Root TypeScript Tests (ubuntu-latest)` and `root-typescript-tests / Root TypeScript Tests (windows-latest)` appear in the job list of a `ci.yml` run. Since the only path by which `ci.yml` can produce these jobs is the added `root-typescript-tests:` job block with `uses: ./.github/workflows/_root-typescript-tests.yml`, their presence proves the `uses:` reference resolves and the reusable workflow is invoked by the orchestrator.

2. **The run concludes `success` overall.**

3. **No pre-existing job regressed.** All eight previously existing `ci.yml` job groups are present with unchanged names and all conclude `success`: `quality-checks7` (four Python-version legs), `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, `drm-copilot-extension-tests` (two OS legs), and `NPM Audit Gate` (three manifest legs). The change is additive, as required by [P3-T2]: no existing job was renamed, removed, or reordered in effect, and no check-run name drifted.

## AC5 Requirement Coverage

| AC5 requirement | Verified by | Status |
|---|---|---|
| A new reusable workflow `_<name>.yml` exists under `.github/workflows/` | `.github/workflows/_root-typescript-tests.yml` created in [P3-T1] | PASS |
| Declares `on: workflow_call:` | [P3-T1]; YAML parse confirmed `on: {"workflow_call":null,"workflow_dispatch":null}`; and functionally proven — the job ran when called by `ci.yml` in this run | PASS |
| Declares `on: workflow_dispatch:` | [P3-T1]; YAML parse confirmed the trigger is declared (structural verification — see the dispatch note below) | PASS |
| Runs `npm ci` at the repository root | [P3-T1] step `Install root dependencies`; executed successfully in both matrix legs of this run | PASS |
| Runs root `npm test` | [P3-T1] step `Run root TypeScript toolchain and jest suite`; log excerpt in [P5-T4] shows `npm test` executing pretest + jest, 170/170 suites | PASS |
| Referenced from `ci.yml` via `uses:` | This run's job list contains `root-typescript-tests` — end-to-end proof | PASS |
| Listed in `.github/workflows/README.md` per-stage dispatch table | [P3-T3]; the table row and the corrected intro count ("eight reusable per-stage workflows") | PASS |

## Note on Direct `workflow_dispatch` of the New Workflow

Direct dispatch via `gh workflow run _root-typescript-tests.yml --ref bug/vscode-test-integration-entrypoint` is **unavailable until the workflow lands on the default branch**. GitHub's `workflow_dispatch` API resolves workflow files from the repository's default branch, so a newly added workflow file cannot be addressed by filename before it merges to `main` (repo precedent: `docs/features/completed/npm-audit-gate-and-dependabot/policy-audit.2026-06-20T00-43.md`).

AC5's `workflow_dispatch` requirement is therefore satisfied **structurally**, by the declared trigger in the committed workflow file (verified in [P3-T1] and by YAML parse). Direct-dispatch runtime verification is recorded here as a **post-merge verification follow-up**: after this branch merges to `main`, run

```
gh workflow run _root-typescript-tests.yml --ref main
```

and confirm the standalone dispatch produces a green run. This is a follow-up action, not a gap in this change: the `workflow_call` path — the one `ci.yml` actually uses — is fully exercised and green in this run.

## Green-Run Policy Evidence for the `ci.yml` Diff

Run 30189336124 is a green run of the modified `ci.yml` against the branch head SHA `df874e81fc9e741921376e621e171cfb2d2a31e2`, satisfying the `modified-workflow-needs-green-run` feature-review policy rule for the `ci.yml` diff as well as for the new `_root-typescript-tests.yml` file.

## Blocked-State Check

The [P5-T5] task requires stopping if a job unrelated to this change fails. **No job failed.** All 16 jobs concluded `success`, so no blocked state applies and this task is completed normally.

Output Summary: The single `ci.yml` run **30189336124** (https://github.com/drmoisan/drm-copilot/actions/runs/30189336124, head SHA `df874e81fc9e741921376e621e171cfb2d2a31e2`) concluded **`success`** overall with **16 of 16 jobs `success`**. The job list includes the new `root-typescript-tests` job on both `ubuntu-latest` and `windows-latest`, proving the `uses: ./.github/workflows/_root-typescript-tests.yml` reference in `ci.yml` resolves end-to-end. All eight pre-existing job groups are present with unchanged names and all green, confirming the change is additive with no check-run name drift. Direct `gh workflow run _root-typescript-tests.yml --ref <branch>` is unavailable until the workflow lands on the default branch; AC5's `workflow_dispatch` requirement is satisfied structurally by the declared trigger, with direct-dispatch runtime verification recorded as a post-merge follow-up. No job failed, so no blocked state applies.
