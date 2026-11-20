# Code Review: Stage J, review/verdict Commit Status (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `60e92a837ca2c8815a79c1c782924e3a8a66c459`
- **Base:** `main`, merge base `70e66be7566f4c7259acce97449c769f7ff3854a` (equal to `origin/main`)
- **Scope:** full branch diff, 32 files, 24 commits including the main-sync merge `23a4ba42d`
- **Reviewer:** feature-review agent, 2026-11-08

## Executive Summary

- **The design is narrow and pure.** `ReviewVerdictEligibility.psm1` holds every rule as a pure decision over a Fact table. When the next rule needs a fact, the decision returns `REVIEW_VERDICT_FACT_REQUIRED` with one gh or git request. `Invoke-ReviewVerdictStatus.ps1` runs exactly that request, so no later process runs once a rule refuses. The only POST is built by `Get-ReviewVerdictStatusArgument`. It validates the head as a 40 or 64 character lowercase object id and caps the description at 140 characters.
- **The rules match D16.** Mode Review requires a last `review_outcomes` verdict of exactly `PASS`, an object-id `head_sha`, a matching OPEN pull request, a valid feature folder, and a committed `<feature-folder>/policy-audit.<timestamp>.md` in the live head. It posts on the live head when that head equals the reviewed head, or when it descends from it and every changed path lies under the feature folder. MainSync requires two parents, a successful `review/verdict` on the first, the second on `origin/main`, disjoint branch and main sets, and no change beyond them. RecordsPr and PromotionPr key on the branch pattern into `main` and on the diff.
- **Real-process probes agree with the mocked tests.** Through the real `Invoke-ReviewVerdictGitExe` seam, the NUL listing of the stage diff parses to 32 entries. Mode Review run with real git facts posts on `60e92a837` for reviewed heads `5c633cb07` and `1f6b0a336` (records-only), and refuses `03ecc8c47` and `70e66be75` with `REVIEW_VERDICT_NOT_RECORDS_ONLY`. It also refuses an artifact name absent from the head with `REVIEW_VERDICT_ARTIFACT_NOT_COMMITTED`. A failing native command with stderr did not throw under `$ErrorActionPreference = 'Stop'`.
- **Mirrors and placement hold.** Both orchestrate pairs and both library pairs have equal blob ids. The section sits after `## PR Creation Gate` and before `## Step 6 Delegation` in all four copies, with 0 deleted lines. No hook, workflow, ruleset, or fixture changed.
- **One blocking finding.** F1: `.claude/lib/review-verdict` is a new project with no `quality-tiers.yml` entry, so `check_quality_tiers` and the CI `tier-classification` step fail.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `quality-tiers.yml` (not in the diff); `.claude/lib/review-verdict/` | `projects` list | F1. Rule R4 of `scripts/dev_tools/quality_tiers_contract.py` makes every `.claude/lib/<name>` folder holding a file a project. The new folder has no entry, so `check_quality_tiers` exits 1 with `QT008: discovered project '.claude/lib/review-verdict' has no entry`. CI job `quality-checks7 / Code Quality & Tests (3.11)` failed at step `tier-classification` on `60e92a837`, and the pytest and coverage steps after it were skipped. The executor gates and the closing-criteria walk did not run this check. | Add `- path: ".claude/lib/review-verdict"`, `tier: T3`, with a rationale in the form of the other `.claude/lib/*` entries, next to `.claude/lib/ci-gate`. Re-run `check_quality_tiers` (exit 0) and record it in a gate artifact. No stored ledger patch touches `quality-tiers.yml`. | `.claude/rules/quality-tiers.md`: when `quality-tiers.yml` exists, every project must be classified; the CI step fails an unclassified project, so the PR cannot go green. | Reviewer run of `check_quality_tiers` from the worktree; CI job 128897774473 step list |
| Minor | `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1` | `Get-ReviewVerdictReviewDecision`, artifact rule | CR1. The artifact rule checks the name form and that the file is committed in the live head, but does not tie it to the PASS outcome. The reviewer's probe accepted `policy-audit.2026-11-08T20-30.md`, the stage I audit, for a stage J PASS, and the description would name that older file. | Optionally record the policy-audit path in the `review_outcomes` entry and compare it, or require the artifact timestamp to be the newest policy audit in the folder. | The skill states the status records a passing review and does not prove one, and the orchestrator supplies the path. The risk is a misleading description, not a post without a PASS. | Real-process probe output |
| Nit | `.claude/rules/orchestrator-state.md` line 350; `.claude/skills/orchestrate/SKILL.md` `## Post-Review Outcome Evaluation` step 6 | `head_sha` wording | CR2. The new section item 1 requires `head_sha` on every `review_outcomes` entry in every review mode. The rule file still describes `head_sha` for a concurrent run, and step 6 lists `verdict` and `findings[]` only. | Align the rule bullet and step 6 in a later change, with mirrors. | Not contradictory: plain validation does not read `head_sha`, so an extra key passes. A sequential run that omits it gets `REVIEW_VERDICT_HEAD_ABSENT` and no post, which fails closed. | `grep head_sha` over the rule and skill |
| Nit | `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1` | `Get-ReviewVerdictFactOutput` synopsis | CR3. The synopsis says it returns the trimmed Output; the code returns it untrimmed. | Correct the synopsis or trim. | Callers do not depend on trimming: JSON parses with whitespace, and NUL listings must keep their terminator. | Lines 156 to 169 |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest added covered file is `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1` at 495 logical lines; the entry point has 203. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Eligibility module

- `Test-ReviewVerdictRecordsOnlyPath` requires the path to start with `<feature-folder>/` and be longer than that prefix, so a sibling-prefix folder and the folder itself are refused (tested).
- `Test-ReviewVerdictFeatureFolder` refuses backslashes, trailing slashes, and blank, `.`, or `..` segments. The artifact pattern is anchored with `\z` and escapes the folder.
- MainSync set logic is sound: with `B` the merge base, disjoint `diff(B,R)` and `diff(B,M)`, `diff(R,H)` within `diff(B,M)`, and `diff(M,H)` within `diff(B,R)`. A path main changed must therefore match main in H, a path the branch changed must match R, and any other path must be unchanged. A conflict resolution that alters either side is refused (tested).
- PromotionPr allows any status under `docs/features/potential/` except `template.md`, and only `A` entries under exactly one `docs/features/active/<name>-<number>/` folder whose suffix equals the branch number and which is absent at the merge base.
- RecordsPr accepts `docs/features/` paths except `templates/` and the potential template, plus `.claude/agent-memory/`. It refuses an empty diff.

### Entry point

- Usage errors exit 2 before any read. `-PrNumber` must match `^[1-9][0-9]{0,8}\z`.
- The fact loop is bounded at 16 passes; exhausting it throws and exits 1 with no POST (tested).
- `REVIEW_VERDICT_GIT_FAILED` is mapped to exit 1, not exit 3, so a git failure is not reported as a refusal.
- `Invoke-ReviewVerdictNativeCommand` reads `$global:LASTEXITCODE` and drops error records, so Output is stdout only. The P3-T2 fix `03ecc8c47` passes a scriptblock that names the executable literally.

### Skill text

- Items 1 to 9 cover when to post, a new push, records before posting with the records-only re-post, before the merge, the three non-feature modes, the absent entry point, parallel and epic runs, not CI, and the limit. Item 9 reads: "Anyone with write access, including any agent with `gh`, can post the status. It records a passing review and does not prove one."
- Codex item 6 adds that the absent-entry-point rule is not the parser-absent stop rule of the Codex `## CI Green Gate` (preflight fix 1). Claude and Codex wording differ in two places (item 1, item 4), matching each runtime's section names. Each pair is byte-identical.

### Merge and CI controls

No merge-gate, review-gate, or child-CI file changed. The RG/RGC allow rows and the HookAllowance suite show that the statuses POST and the entry-point text pass `enforce-pr-author-skill.ps1`, `validate-bash.ps1`, `enforce-promotion-mcp-only.ps1`, `enforce-docs-complete-gate.ps1`, and the merge review guard. Each suite has a deny control.

### Security and correctness

Arguments are arrays, never a shell string. The description is built from a regex-validated file name. Every refusal returns before the POST. The entry point writes no file.

## Verification Performed

- Blob-id comparison of the four orchestrate copies and both library pairs.
- Real-process probes of the git seam and of Mode Review with real git facts (no gh call, no POST).
- Coverage XML and lcov parsing; logical line counts of the added covered files.
- `check_quality_tiers` at head; CI job step list for `60e92a837`.
- In-memory `Test-ProcessReductionLedger` and `Invoke-ProcessReductionChain` (both valid, 0 errors).

## Verdict

REMEDIATION_REQUIRED. One blocking finding (F1). CR1 to CR3 are non-blocking.
