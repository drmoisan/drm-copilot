# epic-require-complete-demands-launch-binding-no-agent-ever-writes (Issue #598)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-require-complete-demands-launch-binding-no-agent-ever-writes/ (Issue #598)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #598
- Issue URL: https://github.com/drmoisan/TaskMaster/issues/598
- Last Updated: 2026-08-23
## Summary

The epic-orchestrator-state `require_complete` gate demands a per-feature `launch_binding` whose `launch_receipt_path` and `launch_status_path` resolve under `artifacts/orchestration/epic-child-launches/`. No agent ever writes that directory, so the gate emits five errors per feature and **can never pass** — however clean the epic run was. Two separate epics in a destination repository have now recorded the failure rather than closed it, which is the correct response and also proof the gate is unsatisfiable.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a in the affected destination — the portable PowerShell validators under `.claude/lib/orchestrator-state/` are what run there
- Command/flags used: epic completion validation with `require_complete`, via the MCP `validate_orchestration_artifacts` surface and the completion hook
- Data source or fixture: destination repository `drmoisan/TaskMaster`, epics `quickfiler-suite-determinism-foundation` and `build-ci-coverage-gate-fidelity`

## Steps to Reproduce

1. Run an epic to completion in a destination repository: children prepared, executed, fanned in, final PR merged, `epic-status.md` current.
2. Validate the epic-orchestrator-state checkpoint with `require_complete`.
3. Read the error list.
4. Look for `artifacts/orchestration/epic-child-launches/` on disk, and grep the epic-orchestrator agent and skill for any write to it.

## Expected Behavior

An epic whose children all reached a terminal state, whose final PR merged, and whose status document is current should satisfy `require_complete`. Where the gate wants launch evidence, it should read the shape the orchestrator actually writes, or the orchestrator should write the shape the gate reads. The two must agree.

## Actual Behavior

`require_complete` fails with 21 errors on `quickfiler-suite-determinism-foundation`. Only **one** is a genuine finding — a deliberately descoped child. The other **20 are five per feature across four features**, each demanding a `launch_binding` with `launch_receipt_path` and `launch_status_path` under `artifacts/orchestration/epic-child-launches/`.

That directory has never existed in the destination, because `epic-orchestrator` writes no launch receipt at delegation time. The launch facts are recorded truthfully — in `delegation_receipts[]` and `model_routing_receipts[]` — merely not in the shape the gate reads.

The same gate produced **25 errors** on the earlier `build-ci-coverage-gate-fidelity` epic in the same repository, which likewise recorded rather than closed it.

The consequence is worse than a nuisance. A gate that cannot pass carries no information: it fails identically for an exemplary run and a broken one, so it cannot distinguish them, and the rational response is to ignore it. That trains operators to disregard a completion gate, which is the opposite of what it exists to do. It is the same defect class the plan-acceptance-gate rules were written to catch — an acceptance condition that cannot fail is not a check, and one that cannot pass is not either.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Shape of the 20: for each feature, five errors requiring `launch_binding.launch_receipt_path` and `launch_binding.launch_status_path` to be present and to resolve under `artifacts/orchestration/epic-child-launches/`.
- Corroboration across two independent epics in the same destination: 21 errors (1 real, 20 from this gap) and 25 errors respectively. Both runs were otherwise complete, with merged final PRs.
- Plain validation (without `require_complete`) passes in both cases, which isolates the gate as the sole source.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High rather than Blocker: it blocks no merge and breaks no build, because operators record the failure and proceed. That workaround is exactly the harm — the completion gate has been reduced to noise for every epic, so a genuine completion defect now arrives indistinguishable from the standing 20.

## Suspected Cause / Notes

Three candidate resolutions, in descending preference:

1. **Make `epic-orchestrator` write the launch receipt** at delegation time, into `artifacts/orchestration/epic-child-launches/`, and keep the gate. This is right if launch evidence is genuinely wanted — a receipt written at delegation is stronger evidence than a receipt reconstructed afterwards.
2. **Point the gate at `delegation_receipts[]`**, which already records the launch facts. Cheapest, and loses nothing if the delegation receipt carries the same information the launch receipt would have.
3. **Drop the requirement.** Only correct if launch evidence turns out not to be wanted, which the presence of the gate argues against.

Deciding between 1 and 2 requires knowing what `launch_binding` was intended to prove that `delegation_receipts[]` does not. That intent is not recoverable from the destination side and should be settled here.

Whichever is chosen, the fix must land in this repository: the epic-orchestrator agent, the orchestrator-state validators under `.claude/lib/orchestrator-state/`, `.claude/hooks/validate-orchestrator-output.ps1`, and `.claude/rules/orchestrator-state.md` are all push-down destinations in the consuming repository, so a fix committed there is destroyed by the next sync.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas — a validator case per resolution: under option 1, a checkpoint with well-formed `launch_binding` entries passes and one with a missing or unresolvable path still fails; under option 2, a checkpoint carrying only `delegation_receipts[]` passes. In both cases keep a negative case, so the gate can still fail — that is the property currently missing.
- [x] Integration scenario to retest — re-validate the two recorded epic checkpoints from the destination repository. The expected result is that the 20 (and 25) `launch_binding` errors disappear while the one genuine descoped-child error on `quickfiler-suite-determinism-foundation` **remains**. A fix that also silences that error has gone too far.
- [x] Manual verification notes — confirm `require_complete` can still fail on a deliberately incomplete epic. The whole point is restoring discrimination, so a change that makes the gate always pass is worse than the current state, not better.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
