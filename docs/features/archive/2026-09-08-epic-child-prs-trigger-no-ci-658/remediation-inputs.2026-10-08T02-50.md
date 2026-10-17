# Remediation Inputs - Review Pass 1 (issue #658)

Timestamp: 2026-10-08T02-50 (supplied by the delegating orchestrator)
Branch: `bug/epic-child-prs-trigger-no-ci-658`, head `9686d975d85250814aba7e149ee6ac0cfeda562a`
Base for diffs: `08ee030d9584bf15882fbb3654c8e38f34c7c359` (merge-base with `origin/main`)
Verdict: AWAITING_CI
Blocking findings: 1 (awaiting_ci: 1; autonomous: 0)
Remediation plan target: none. Every Blocking finding is awaiting_ci, so no remediation handoff is triggered.

Source artifacts:
- `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/policy-audit.2026-10-08T02-50.md` (Section 8, B-1)
- `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/code-review.2026-10-08T02-50.md` (CR-2)
- `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/feature-audit.2026-10-08T02-50.md` (AC-7 PARTIAL)

## B-1 - modified-workflow-needs-green-run not satisfied at the current branch head (AC-7)

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: awaited workflow `CI` (`.github/workflows/ci.yml`) on the final PR head of `bug/epic-child-prs-trigger-no-ci-658`. The only recorded green run is 37717224700 on `8a1b9b8b66f4bb65ef0a5e3e1d0d883246d739f7`. The current head `9686d975` differs from it by feature-folder documents only (`git diff --name-only 8a1b9b8b HEAD`).
- Rule: `.claude/skills/feature-review-workflow/SKILL.md`, `modified-workflow-needs-green-run`. The branch modifies `.github/workflows/ci.yml` and `.github/workflows/README.md`, and the rule requires a green run whose head SHA equals the current branch head.
- AC impact: AC-7 is checked `[x]` in `issue.md` but is evaluated PARTIAL. This review did not uncheck it.
- Required evidence to clear: a `CI` run whose `headSha` equals the final PR head and whose `conclusion` is `success`. A `pull_request` run into `main` or a `workflow_dispatch` run on that head qualifies. Record the run id, head SHA, event, and conclusion from `gh run view <id> --json databaseId,headSha,conclusion,event,workflowName` under `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/qa-gates/`.
- Code change required: none.

## Non-blocking findings (not remediation triggers)

- CR-1: `Invoke-CiGateParser.ps1` returns `success` on an empty check set, so the S9 epic-child rule is enforced only by prose. Out of scope per `issue.md` line 28. Recommend a follow-up issue.
- CR-3: evidence timestamps are not host-clock capture times (`evidence-and-timestamp-conventions/SKILL.md:49`).
- CR-4: S9 step 3 wording still says "required checks" after the epic-child rule drops `--required`.
- CR-5: helper block-list and single-quote parsing branches are not exercised (test-support code).
- CR-6, CR-7, CR-8, N-4, N-7: informational (the trigger is not yet exercised by a real `epic/**` PR; pre-existing README count drift; branch behind `main` by #835; PowerShell line-coverage figure not cited; PR-context artifacts absent).
