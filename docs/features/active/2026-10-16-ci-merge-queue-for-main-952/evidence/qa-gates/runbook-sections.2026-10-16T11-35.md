# Runbook Sections and Operator Statements (P7-T5, AC-24, coordinator R5)

Timestamp: 2026-10-16T11-35
Command: git grep -n -F -e "## Preconditions" -e "## Capture and Diff Before Applying" -e "## Apply" -e "## Post-Apply Verification" -e "## Expected Failure on a User-Owned Repository" -e "## Rollback" -e "## Non-Strict Alternative (Separate Operator Decision)" -e "## Admin Merges Skip the Queue" -e "gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input" -e "422" -e "gh pr update-branch" -e "This item applies nothing" -e "merge queues for organization-owned repositories" -e "is expected to be rejected" -e "is a separate operator decision" -e "--input protect-main.rollback.json" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md
EXIT_CODE: 0
Output Summary: TOKENS_FOUND=16/16

Pattern-to-line mapping (each pattern has at least one output line):

| # | Pattern | Runbook line(s) |
|---|---|---|
| 1 | ## Preconditions | 13 |
| 2 | ## Capture and Diff Before Applying | 21 |
| 3 | ## Apply | 27 (also 42 by substring) |
| 4 | ## Post-Apply Verification | 33 |
| 5 | ## Expected Failure on a User-Owned Repository | 40 |
| 6 | ## Rollback | 44 (also 42, 56 by substring) |
| 7 | ## Non-Strict Alternative (Separate Operator Decision) | 52 (also 42) |
| 8 | ## Admin Merges Skip the Queue | 58 |
| 9 | gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input | 31, 48, 56 |
| 10 | 422 | 42 |
| 11 | gh pr update-branch | 37 |
| 12 | This item applies nothing | 3 (R5 statement (c)) |
| 13 | merge queues for organization-owned repositories | 15 (R5 statement (a), ownership precondition) |
| 14 | is expected to be rejected | 15 (R5 statement (a), expected rejection of the apply payload) |
| 15 | is a separate operator decision | 54 (R5 statement (b), non-strict fallback) |
| 16 | --input protect-main.rollback.json | 48 (R5 statement (b), rollback payload) |

Output (verbatim, the runbook path prefix `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md:` is shortened to `runbook.md:`):
```
runbook.md:3:Status: shipped, not applied. This item applies nothing: issue #952 ships these payloads and this runbook, and every apply, rollback or alternative step below is a separate operator action.
runbook.md:13:## Preconditions
runbook.md:15:GitHub documents merge queues for organization-owned repositories, and `drmoisan/drm-copilot` is user-owned, so the `merge_queue` apply payload is expected to be rejected until the repository is organization-owned or the API accepts the rule.
runbook.md:21:## Capture and Diff Before Applying
runbook.md:27:## Apply
runbook.md:31:`gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input protect-main.merge-queue.apply.json`
runbook.md:33:## Post-Apply Verification
runbook.md:37:3. Queue two green pull requests and confirm that both merge without a `gh pr update-branch` cycle.
runbook.md:40:## Expected Failure on a User-Owned Repository
runbook.md:42:While the repository is user-owned, the PUT in `## Apply` is expected to fail with HTTP 422. This outcome is expected from the GitHub documentation and has not been observed. No partial change is expected, because the API rejects the whole payload. Take no further action on the apply payload, and see the two fallbacks below: `## Rollback` and `## Non-Strict Alternative (Separate Operator Decision)`.
runbook.md:44:## Rollback
runbook.md:48:`gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input protect-main.rollback.json`
runbook.md:52:## Non-Strict Alternative (Separate Operator Decision)
runbook.md:54:Applying `protect-main.non-strict.alternative.json` is a separate operator decision and is not part of issue #952.
runbook.md:56:The payload removes the branch re-sync loop now and works on a user-owned repository. It does not validate the combined result before merging: a pull request can merge while it is behind `main`, and `push` CI on `main` detects any breakage only after it lands. To apply it, run `gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input protect-main.non-strict.alternative.json`; to revert it, use `## Rollback`.
runbook.md:58:## Admin Merges Skip the Queue
```
