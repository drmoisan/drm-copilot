# Merge Queue on `main`: Ruleset Runbook (issue #952)

Status: shipped, not applied. This item applies nothing: issue #952 ships these payloads and this runbook, and every apply, rollback or alternative step below is a separate operator action.

This runbook covers ruleset 15241672 (`protect-main`) of `drmoisan/drm-copilot`. The three payloads in this folder were derived from the read-only snapshot `protect-main.current.2026-10-16.json`:

- `protect-main.merge-queue.apply.json` adds a `merge_queue` rule and keeps every other writable field of the snapshot.
- `protect-main.rollback.json` restores the snapshot's writable fields.
- `protect-main.non-strict.alternative.json` keeps the snapshot but sets `strict_required_status_checks_policy` to `false`, with no merge queue.

Run every command below from this folder (`docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/`).

## Preconditions

GitHub documents merge queues for organization-owned repositories, and `drmoisan/drm-copilot` is user-owned, so the `merge_queue` apply payload is expected to be rejected until the repository is organization-owned or the API accepts the rule.

- The issue #952 pull request is merged, so `.github/workflows/ci.yml` triggers on `merge_group` and every required check can report on a queue entry.
- The operator holds a token with repository administration write permission.
- `conditions.ref_name.include` is `~DEFAULT_BRANCH` with no wildcard, so the queue applies to `main` only.

## Capture and Diff Before Applying

1. Capture the live ruleset to a scratch directory outside the repository: `gh api repos/drmoisan/drm-copilot/rulesets/15241672 > <scratch-dir>/protect-main.live.json`, where `<scratch-dir>` is any directory outside the working tree. The capture file is not committed.
2. Diff the capture against `protect-main.current.2026-10-16.json`.
3. If any writable field differs (`name`, `target`, `enforcement`, `conditions`, `rules`, `bypass_actors`), regenerate the three payloads from the fresh capture before applying anything. Differences in read-only fields (`id`, `source_type`, `source`, `node_id`, `created_at`, `updated_at`, `current_user_can_bypass`, `_links`) do not require regeneration.

## Apply

Apply the merge-queue payload:

`gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input protect-main.merge-queue.apply.json`

## Post-Apply Verification

1. Read the ruleset again with `gh api repos/drmoisan/drm-copilot/rulesets/15241672` and confirm that its `rules` array contains the `merge_queue` rule.
2. Add one green pull request to the queue and confirm that every context listed in `required_status_checks` reports on a `merge_group` run of `ci.yml`.
3. Queue two green pull requests and confirm that both merge without a `gh pr update-branch` cycle.
4. Add a pull request whose merge state is `BEHIND` to the queue and confirm that the queue accepts it while `strict_required_status_checks_policy` is `true`. If the queue refuses it, apply a follow-up payload that sets `strict_required_status_checks_policy` to `false` alongside the `merge_queue` rule.

## Expected Failure on a User-Owned Repository

While the repository is user-owned, the PUT in `## Apply` is expected to fail with HTTP 422. This outcome is expected from the GitHub documentation and has not been observed. No partial change is expected, because the API rejects the whole payload. Take no further action on the apply payload, and see the two fallbacks below: `## Rollback` and `## Non-Strict Alternative (Separate Operator Decision)`.

## Rollback

Restore the snapshot's writable fields:

`gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input protect-main.rollback.json`

Roll back when a required context does not report within `check_response_timeout_minutes` (60 minutes) for queue entries, or when the queue blocks merges for any other reason. The rollback payload restores every writable field of the snapshot, including `strict_required_status_checks_policy: true` and no `merge_queue` rule.

## Non-Strict Alternative (Separate Operator Decision)

Applying `protect-main.non-strict.alternative.json` is a separate operator decision and is not part of issue #952.

The payload removes the branch re-sync loop now and works on a user-owned repository. It does not validate the combined result before merging: a pull request can merge while it is behind `main`, and `push` CI on `main` detects any breakage only after it lands. To apply it, run `gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input protect-main.non-strict.alternative.json`; to revert it, use `## Rollback`.

## Admin Merges Skip the Queue

`gh pr merge --admin` merges directly for the bypass actor (user 54180981, `bypass_mode: pull_request`) and skips the queue. The merge gate `.claude/hooks/enforce-epic-merge-gate.ps1` requires an authorization record for `--admin` like any other merge spelling.
