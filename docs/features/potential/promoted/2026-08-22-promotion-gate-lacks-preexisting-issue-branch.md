# promotion-gate-lacks-preexisting-issue-branch (Issue #509)

- Date captured: 2026-08-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/promotion-gate-lacks-preexisting-issue-branch/ (Issue #509)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: full-bug

- Issue: #509
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/509
- Last Updated: 2026-08-23
## Summary

The routing-contract completion gate unconditionally requires a promotion receipt for every required MCP tool, including the promote-to-issue tool. When an issue already exists, for example because it was transferred from another repository, that tool cannot be run truthfully: it has no idempotent path and always files a new issue. The orchestration is then forced to choose between filing a duplicate issue and failing its own completion gate.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: 3.13.12 (Poetry 2.3.2)
- Command/flags used: `validate_orchestration_artifacts orchestrator-state <path> --require-complete`
- Data source or fixture: `scripts/dev_tools/_orchestrator_state_routing.py` and `config/orchestration-routing.json`

## Steps to Reproduce

1. Begin an orchestration against an issue that already exists on GitHub and has no local potential record, which is the normal state after an issue is transferred between repositories.
2. Run the promotion lifecycle. The potential-entry and active-folder tools run truthfully; the promote-to-issue tool cannot, because it would create a second issue for the same defect.
3. Complete the work and run the completion validator.

## Expected Behavior

An orchestration working a pre-existing issue can reach a clean completion without filing a duplicate. The gate recognises that the promote-to-issue step was satisfied out of band and accepts evidence of the existing issue in place of a receipt.

## Actual Behavior

`validate_routing_contract` requires a receipt for every entry in the route's `required_mcp_tools` and offers no branch for an already-existing issue, so completion reports a missing MCP receipt. The only ways forward are to file a duplicate issue purely to satisfy the gate, or to complete with a documented gate exception.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet, the shape of the failure:

  ```text
  Checkpoint missing successful MCP receipt: <promote-to-issue tool>.
  ```

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. It does not affect delivered code, but it makes the completion gate unsatisfiable for a legitimate and recurring situation, and it creates pressure to either fabricate a receipt or pollute the issue tracker with duplicates. Encountered directly while orchestrating issue #500, which was transferred from another repository; that run proceeded by recording the substitution under `human_interaction.requirements[]` and accepting the delta.

## Suspected Cause / Notes

The routing matrix models promotion as a single linear path from potential entry to issue to folder, and the validator treats each step as mandatory. Transfers, manually filed issues, and issues created before an orchestration begins all break that assumption. Note also that the promote-to-issue implementation parses the URL of a freshly created issue, so it has no way to recognise or adopt an existing one.

## Proposed Fix / Validation Ideas

- [ ] Add a recognised alternative receipt, for example an `issue_adopted` record naming the existing issue number and its origin, that satisfies the same required-tool slot.
- [ ] Alternatively, make the promote-to-issue tool idempotent by accepting an existing issue number and annotating the potential record rather than creating a new issue.
- [ ] Unit coverage areas: `validate_routing_contract` accepting the alternative receipt, and rejecting a fabricated one.
- [ ] Integration scenario to retest: a full orchestration against a pre-existing issue reaches completion with no duplicate filed.
- [ ] Manual verification notes: also review the promotion-only hook, which blocks read-only inspection of the promotion sources because it pattern-matches the tool name anywhere in a shell command.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
