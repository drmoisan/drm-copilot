# Research: epic-child-prs-trigger-no-ci (Issue #658)

- Issue: #658
- Branch: bug/epic-child-prs-trigger-no-ci-658
- Feature folder: docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/
- Work Mode (from issue.md line 12): minor-audit
- Researched: 2026-09-29T20-50

All paths are repository-relative. Line numbers were read from the worktree at the time of research.

## 1. Current State: `.github/workflows/ci.yml`

Full file (42 lines). The `on:` block is lines 3-8:

```yaml
on:
  push:
    branches: [main, development]      # line 5
  pull_request:
    branches: [main, development]      # line 7
  workflow_dispatch:                   # line 8
```

- No `concurrency:` key, no `paths:` / `paths-ignore:` filter, no top-level `permissions:`.
- Jobs (nine, each a `uses:` call to a reusable workflow, no `needs:` edges):

| Line | Job id | Reusable workflow |
|---|---|---|
| 11-12 | `quality-checks7` | `.github/workflows/_quality-checks.yml` |
| 14-15 | `security-scan` | `.github/workflows/_security-scan.yml` |
| 17-18 | `docs-validation` | `.github/workflows/_docs-validation.yml` |
| 20-21 | `build-check` | `.github/workflows/_build-check.yml` |
| 23-24 | `poshqc` | `.github/workflows/_poshqc.yml` |
| 26-27 | `shell-coverage` | `.github/workflows/_shell-coverage.yml` |
| 29-30 | `drm-copilot-extension-tests` | `.github/workflows/_drm-copilot-extension-tests.yml` |
| 32-33 | `root-typescript-tests` | `.github/workflows/_root-typescript-tests.yml` |
| 35-41 | `npm-audit-gate` | `.github/workflows/_npm-audit-gate.yml` (`permissions: contents: read`, `with: audit-level: moderate`) |

- Every `_*.yml` declares only `workflow_call` and `workflow_dispatch` (lines 3-5 in each; `_npm-audit-gate.yml` lines 4 and 13). They are reachable from a PR only through `ci.yml`.
- Job-level / step-level conditions: a search of `.github/workflows/` for `github.base_ref`, `github.head_ref`, `github.event.pull_request`, `github.ref`, and `github.event_name` finds no match in `ci.yml` or any `_*.yml`. The only step-level `if:` conditions in reusable workflows are cache/matrix conditions (`_quality-checks.yml:39`, `_quality-checks.yml:90`, `_shell-coverage.yml:34`). Conclusion: widening the `pull_request` trigger is sufficient for every job to run; no job would be skipped by a branch-name condition.

## 2. Integration-Branch Naming Conventions

Epic surface (single convention, `epic/<epic-slug>-integration`):

- `.claude/skills/epic-orchestrate/SKILL.md:36` (manifest schema), `:93-94` (create/push), `:96`, `:106`, `:118` (kickoff line: "PR base branch MUST be <integration_branch>, not main").
- `.claude/skills/epic-plan/SKILL.md:85-86`, `:96`, `:132`, `:156`, `:164`.
- `.claude/skills/epic-run/SKILL.md:23`, `:26`, `:31-32`.
- `.claude/agents/epic-orchestrator.md:76`, `:80-84`; `.claude/agents/epic-planner.md:92`.
- Machine-enforced form: `scripts/dev_tools/epic_kickoff_contract.py:11` `INTEGRATION_BRANCH_RE = re.compile(r"epic/[a-z0-9][a-z0-9-]*-integration")`; `scripts/dev_tools/epic_planner_readiness.py:300` `expected_branch = f"epic/{slug}-integration"`.
- Every committed epic manifest uses it: `docs/features/templates/epic/epic.md:13`, and `integration_branch:` line 3 of `docs/features/epics/{worktree-scoped-state-resolution,parallel-orchestration,legacy-discovery-and-parity,cleanup-merged-worktrees-hardening,claude-runtime-portability}/epic.md`.

The slug character class excludes `/`, so every legal integration branch is exactly one path segment below `epic/`.

Parallel surface: verified to have no integration branch.

- `.claude/rules/parallel-orchestration.md:158`: "There is no integration branch for a parallel run: each item opens its own pull request against `main`." Lines 160-162 make a top-level `integration_branch` a prohibited key.
- `.claude/agents/parallel-orchestrator.md:51` and `:148-149` state the same.
- `scripts/dev_tools/parallel_manifest_contract.py:74` (`MANIFEST_TOP_LEVEL_PROHIBITED_KEYS = ("integration_branch",)`) and `scripts/dev_tools/_parallel_state_common.py:101` enforce it.
- A search of `.claude/skills/parallel-*/SKILL.md` for `integration`, `--base`, and `base branch` returned no match.

Parallel item PRs target `main`, which `ci.yml` already covers. Only `epic/**` needs adding.

## 3. Other Workflows With the Same Gap

| File | Line | Filter | Gap? |
|---|---|---|---|
| `.github/workflows/ci.yml` | 5 | `push: branches: [main, development]` | Pushes to an integration branch (child merges) run no CI. Not required to close #658; see Open Decisions. |
| `.github/workflows/ci.yml` | 7 | `pull_request: branches: [main, development]` | Yes. This is the defect. |
| `.github/workflows/npm-audit-gate.yml` | 9 | `pull_request: branches: [main, development]` plus `paths:` lines 10-14 | Same base filter. The `ci.yml` `npm-audit-gate` job already calls the same `_npm-audit-gate.yml`, so widening `ci.yml` covers child PRs. Changing this file is optional, and it would bring a second workflow under `modified-workflow-needs-green-run`. |
| `publish-extension.yml` | 12-15 | `pull_request: paths:` only | No base filter. Runs for any base, which explains the three checks seen on child PRs. |
| `publish-mcp-npm.yml` | 12-13 | `pull_request: paths:` only | No base filter. |
| `verify-published-releases.yml` | 16-17 | `pull_request: paths:` only | No base filter. |

## 4. Trigger Documentation and Mirrors

- `.github/workflows/README.md`: it does not document `ci.yml`'s trigger branches. Line 36 refers to "`ci.yml`'s `push`/`pull_request` trigger" without naming branches. Existing drift, outside #658 scope: line 4 says "eight reusable per-stage workflows" and the table (lines 12-19) omits `_npm-audit-gate.yml`, while nine are called; lines 69-71 say "All seven jobs" and list seven, while `ci.yml` has nine.
- `README.md:392` describes `ci.yml` content without triggers. No update is required.
- `docs/ci*.md`: none exists (glob `docs/ci*` returned nothing).
- `.github/instructions/github-actions.instructions.md` and its Copilot bundle mirror `extensions/drm-copilot/resources/customizations/.github/instructions/github-actions.instructions.md` do not document triggers. No update is required.
- Epic S9 text: `.claude/skills/epic-orchestrate/SKILL.md` contains no S9 procedure of its own. Lines 108-111 and 120-124 defer to the child's S9. The S9 procedure is in `.claude/skills/orchestrate/SKILL.md:267-280`; step 2 (line 274) mandates `gh pr checks --required --json bucket,name,state,link,workflow`.
- Bundled mirrors:
  - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
  - `.agents/skills/{epic-orchestrate,orchestrate}/SKILL.md` and their copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/` are Codex variants with different text; neither contains `--required` or `gh pr checks`.
- Parity tests that pin the mirrors:
  - `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) requires every repo `.claude/**` file, except `settings.local.json` and `agent-memory/**`, to exist in the bundle with identical text. An edit to any `.claude/skills/*/SKILL.md` must be copied into `extensions/drm-copilot/resources/claude-customizations/.claude/...` in the same change.
  - `:159-174` additionally byte-pins `.claude/skills/orchestrate/SKILL.md`.
  - `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py:285-307` pins `.agents/skills/orchestrate/SKILL.md` (normalized text).
  - `.github/workflows/` has no bundle mirror (glob `extensions/drm-copilot/resources/**/workflows/**` returned nothing).

## 5. Existing Tests on Workflow Content

- No test asserts on `ci.yml`. A search of `tests/` for `ci.yml` matched only blast-radius fixture JSON (`tests/fixtures/blast_radius/historical-runs/*.json`).
- Pester workflow-invariant precedent: `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` and `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1`. Each reads the YAML as text, isolates the `on:` block up to the next column-zero key (`PublishMcpNpmWorkflow.Tests.ps1:19-36`), and asserts with regex (`:73-75`). Neither imports a YAML module, starts a process, or writes a temporary file. Lines 5-8 of that file record why these suites live under `tests/scripts/workflows/`: Pester discovers only `scripts`, `tests/powershell`, and `tests/scripts` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:3`).
- pytest precedent: `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` uses `yaml.safe_load` (lines 15, 40). Hazard for a trigger assertion: PyYAML follows YAML 1.1 and loads the bare key `on` as boolean `True`, so `document["on"]` raises `KeyError`. This is known PyYAML behavior and was not exercised in this session.
- Run path for Pester: locally through PoshQC (`Import-Module scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root <repo>`), and in CI through `_poshqc.yml:38-42` on `windows-latest`, called from `ci.yml:23-24`. Coverage is an explicit allow-list (`pester.runsettings.psd1:17-330`). A YAML-reading test adds no production PowerShell, so no coverage entry is needed.
- Recommended home: new file `tests/scripts/workflows/CiWorkflow.Tests.ps1` (Pester 5), following the `PublishMcpNpmWorkflow.Tests.ps1` pattern.

## 6. `modified-workflow-needs-green-run`

- Defined at `.claude/skills/feature-review-workflow/SKILL.md:68-75`. It is cited at `.claude/rules/ci-workflows.md:37`, at `.claude/agents/orchestrator.md:122`, and in the rationale comments of `publish-extension.yml:8-11` and `PublishMcpNpmWorkflow.Tests.ps1:69-72`.
- Requirement: if the branch diff touches `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`, the policy audit raises a Blocking finding unless the remediation inputs contain evidence of a green run of the affected workflow whose head SHA equals the branch head. A green `workflow_dispatch` run against the branch head also qualifies (line 74).
- Application to #658: the fix PR targets `main`, so its own `pull_request` run of `ci.yml` against the head SHA satisfies the rule. Record the run id, head SHA, and conclusion as evidence.
- Defect found: line 75 names the supporting validator `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1`. A glob for `**/Test-ModifiedWorkflowNeedsGreenRun*` returned no file, so the rule is applied by reviewer reading only. This is out of scope for #658 and a candidate follow-up.

## 7. `.github/instructions/github-actions.instructions.md` Rules for `ci.yml`

- Line 8: do not change the overall job structure unless explicitly requested. The fix adds no job.
- Line 9: preserve `on:` triggers and branch filters "unless change is intentional and documented". The change is intentional, so it must be documented in the workflow README and the PR description.
- Lines 12-15: must pass `actionlint`; run locally with `scripts/dev-tools/run-actionlint.ps1` (exists; tested by `tests/scripts/dev-tools/run-actionlint.Tests.ps1`). Line 15 names a CI job `actionlint` in `ci.yml`, but no such job exists in `ci.yml` or any `_*.yml` (searched). Local `actionlint` is therefore the only lint gate for this edit. This is pre-existing instruction drift and out of scope.
- `.claude/rules/ci-workflows.md` (paths `.github/workflows/**`) governs only `pwsh` exit codes. It does not apply to a trigger-only edit.

## 8. Required Status Checks and Branch Protection (inferable only)

- The repository contains no branch-protection or ruleset configuration: no `.github/settings.yml` and no `.github/rulesets/`. The only related text is `.github/workflows/README.md:24-65`, which states that `required_status_checks` match literal check-run names and are configured per branch through `gh api .../branches/{branch}/protection`.
- `issue.md:45-46` records `gh pr checks 644 --required` returning `no required checks reported on the ... branch` for a child PR. This is consistent with integration branches having no protection.
- Consequence for S9: `.claude/skills/orchestrate/SKILL.md:274` uses `--required`, which filters to the base branch's required contexts. `.claude/lib/ci-gate/Invoke-CiGateParser.ps1:23-24` and `:130-134` return `success` for an empty check set ("vacuously satisfied"). After the trigger is widened, `ci.yml` checks will attach to child PRs, but S9 as written will still observe an empty required set and can pass vacuously. The trigger change alone does not close the Impact statement in `issue.md:56`.
- Adding `epic/**` to the trigger does not change check-run names, so `main`'s required-check contexts are unaffected. The README rename procedure (lines 32-65) is not triggered.

## Candidate Approaches

1. **Widen the trigger and make epic-mode S9 non-vacuous (selected).**
   - Add `"epic/**"` to `ci.yml:7`.
   - Amend S9 step 2 in `.claude/skills/orchestrate/SKILL.md:274` so that under `epic_mode: true` the check query omits `--required`, because the integration branch carries no protection. The orchestrator must also confirm that a `CI` workflow check exists for the head SHA before accepting `success`.
   - Advantages: child PRs run all nine gates in PR context; S9 observes them; no operator action outside the repo.
   - Limitations: one skill edit plus its byte-identical bundle mirror.
2. **Substitute-verification text only.** Document `gh workflow run ci.yml --ref <child-branch>` as mandatory S9 evidence in epic-orchestrate. Rejected: the checks tab stays empty, verification depends on manual procedure, and a `workflow_dispatch` run does not attach to the PR.
3. **Trigger widening only.** Rejected as incomplete: S9 still passes vacuously through `--required` (section 8).
4. **Branch-protection ruleset on `epic/**`.** Rejected as the primary fix: it is configured outside the repository, cannot be tested or reviewed in a diff, and must be repeated per required context.

## Recommended Minimal Fix

Files to write:

1. `.github/workflows/ci.yml`: line 7 becomes `branches: [main, development, "epic/**"]`. Quote the value. `epic/*-integration` would match the contract regex exactly. `epic/**` is the issue's proposal and is the more tolerant option. Per the GitHub filter-pattern cheat sheet, `*` does not match `/` and `**` does; that page could not be retrieved in this session, so this semantics claim is unverified here, and the regression test and the green-run evidence are the check.
2. `.github/workflows/README.md`: add a short "Triggers" section stating that `ci.yml` runs on `push` to `main`/`development`, on `pull_request` into `main`, `development`, and `epic/**` (epic integration branches, so epic child PRs run the full gate), and on `workflow_dispatch`. This satisfies the documentation requirement in `github-actions.instructions.md:9`, and the section could carry the docs-validation check the issue proposes. Optional in the same edit: correct the "eight"/"seven" counts and add `_npm-audit-gate.yml` to the table.
3. `.claude/skills/orchestrate/SKILL.md`: S9 step 2 (line 274) gains an epic-mode clause. When `epic_mode` is `true`, run `gh pr checks <PR> --json bucket,name,state,link,workflow` without `--required`, and require at least one check whose `workflow` is `CI` before a `success` conclusion is accepted.
4. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`: a byte-identical copy of item 3, required by `test_push_down_claude_resource_contracts.py:118-143` and `:159-174`.
5. Optional: a one-sentence cross-reference in `.claude/skills/epic-orchestrate/SKILL.md` near lines 120-124, plus its bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`.
6. Regression test: new `tests/scripts/workflows/CiWorkflow.Tests.ps1` (Pester 5, text and regex, the `on:`-block isolation pattern from `PublishMcpNpmWorkflow.Tests.ps1:19-36`). It should assert that the `pull_request:` sub-block's `branches` list contains `main`, `development`, and `epic/**`. It fails before item 1 and passes after. Run it through `Invoke-PoshQCTest` locally and `_poshqc.yml` in CI. If item 3 is adopted, add a text assertion on the S9 epic-mode clause, either in the same style or as a pytest contract next to existing skill-contract tests.
7. Evidence: under `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/<kind>/` per the evidence conventions. Record `actionlint` output, Pester fail-before and pass-after output, and the green `ci.yml` PR run (id, head SHA, conclusion) for `modified-workflow-needs-green-run`.

## Numeric Derivation Evidence

Claim: `ci.yml` calls nine reusable workflows (`issue.md:16` says "nine").

- Complete Family: reusable workflows invoked by `ci.yml` jobs.
- Exhaustive Search Scope: `.github/workflows/`.
- Inclusion Rules: a `uses: ./.github/workflows/_*.yml` reference in `ci.yml`.
- Exclusion Rules: top-level workflows that are not called.
- Primary Search Strategy: read `ci.yml` lines 10-41 and collect the `uses:` targets.
- Primary Member Set: `_quality-checks`, `_security-scan`, `_docs-validation`, `_build-check`, `_poshqc`, `_shell-coverage`, `_drm-copilot-extension-tests`, `_root-typescript-tests`, `_npm-audit-gate`.
- Primary Count: 9.
- Cross-check Search Strategy: glob `.github/workflows/*` filtered to `_`-prefixed files, confirmed by the grep result that each declares `workflow_call`.
- Cross-check Member Set: `_build-check`, `_docs-validation`, `_drm-copilot-extension-tests`, `_npm-audit-gate`, `_poshqc`, `_quality-checks`, `_root-typescript-tests`, `_security-scan`, `_shell-coverage`.
- Cross-check Count: 9.
- Member-set Comparison: the normalized sets are identical.

Claim withheld: "eleven required checks" (`issue.md:66`). Required-check contexts live in GitHub branch protection, which is not in the repository, and no independent second enumeration is possible here. Do not use this number in an acceptance criterion.

## Testing Implications

- The Pester text assertion (item 6) is the regression test. It is deterministic, uses no network or temporary files, and follows existing precedent.
- End-to-end proof that a child PR attaches checks needs a PR into an `epic/*` branch, as in `issue.md:66`. Timing risk: a `pull_request` run's `GITHUB_SHA` is the merge commit of head into base (GitHub events documentation, fetched this session). The trigger is therefore likely evaluated from the merged tree, so a throwaway integration branch must be created from `main` after the fix merges. The docs did not explicitly say which workflow-file version is evaluated; treat this as likely, not verified.
- `issue.md` (minor-audit) has no `## Acceptance Criteria` section. Per `feature-review-workflow/SKILL.md:64`, the reviewer will require remediation, so add one before review.

## Open Risks and Decisions

1. **In-flight integration branches.** Branches created before the fix carry the old `ci.yml`, so their child PRs likely stay untriggered until `main` is merged into them.
2. **Vacuous S9 remains unless item 3 lands.** The trigger change alone does not stop S9 passing vacuously through `--required`.
3. **`push` trigger (`ci.yml:5`).** Adding `"epic/**"` would run CI on the integration branch after each child merge and catch semantic conflicts between siblings. This is a user decision; it is not required by #658.
4. **`npm-audit-gate.yml:9`.** Leave unchanged, because the `ci.yml` job covers child PRs. Changing it adds a second workflow needing green-run evidence.
5. **CI cost.** Each epic child PR will run the full nine-workflow matrix, including Windows jobs.
6. **Pre-existing drift, candidates for follow-up issues outside #658:**
   - The validator `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` does not exist.
   - The CI job `actionlint` named at `github-actions.instructions.md:15` does not exist.
   - The workflow README job and workflow counts are stale.
