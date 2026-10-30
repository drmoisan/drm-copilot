# discovery-shell-deny-observation-lacks-hash-ttl-checks (Issue #1008)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/discovery-shell-deny-observation-lacks-hash-ttl-checks/ (Issue #1008)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1008
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1008
- Last Updated: 2026-10-30
## Summary

The discovery capability probe accepts the sentinel's `SHELL` deny observation by matching `agent_id` only. It does not apply the handler-hash and `observed_at` TTL checks that the sentinel-tool observation receives, so a stale or foreign-handler deny record could satisfy that half of the attribution proof.

## Environment

- OS/version: any
- Python version: n/a (PowerShell probe)
- Command/flags used: `run_discovery_doctor` capability probe
- Data source or fixture: discovery host-observation store

## Steps to Reproduce

1. Record a `SHELL` deny observation for the sentinel `agent_id` with an `observed_at` older than the probe TTL, or with a handler hash that does not match the installed hook.
2. Record a valid sentinel-tool observation for the same `agent_id`.
3. Run the capability probe.

## Expected Behavior

The probe rejects the deny observation when its handler hash does not match or it is older than the TTL, exactly as for the sentinel-tool observation.

## Actual Behavior

The deny observation is accepted on `agent_id` alone.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: identified in code review `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/code-review.2026-10-30T10-19.md` (Nit).

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

`.claude/lib/discovery-validation/DiscoveryCapability.psm1` line 170 and its two bundled mirrors. Deferred from issue #980 by user decision so the feature can merge.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: Pester cases for stale and wrong-hash deny observations, using records produced by the gate's observation writer.
- [ ] Integration scenario to retest: probe still reports supported with fresh, matching observations.
- [ ] Manual verification notes: keep the three mirrors byte-identical.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
