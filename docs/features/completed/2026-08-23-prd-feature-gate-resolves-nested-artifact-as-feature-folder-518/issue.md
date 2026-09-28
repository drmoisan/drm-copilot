# prd-feature-gate-resolves-nested-artifact-as-feature-folder (Issue #518)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/prd-feature-gate-resolves-nested-artifact-as-feature-folder/ (Issue #518)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #518
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/518
- Last Updated: 2026-08-23
- Work Mode: full-bug

## Summary

`enforce-prd-feature-before-planner.ps1` identifies the active feature folder by scanning the delegation prompt for `docs/features/active/<token>` paths and taking the **longest** match, using its parent when the match ends in `.md`. Citing any artifact nested below the feature folder — a `research/` finding, an `evidence/` file — produces a longer match than the folder itself, so the gate resolves to the subdirectory, finds no `issue.md` there, cannot read a work-mode marker, and fails closed demanding both `spec.md` and `user-story.md` inside that subdirectory.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a — hooks are PowerShell; PowerShell 7.6.5
- Command/flags used: `Agent` delegation to `atomic-planner` with a prompt citing a research artifact by full repo-relative path
- Data source or fixture: `.claude/hooks/enforce-prd-feature-before-planner.ps1` at commit `bee15c06`; observed live during an orchestration run on 2026-08-23

## Steps to Reproduce

1. Prepare an active feature folder that legitimately satisfies the gate: `issue.md` carrying a `- Work Mode: full-bug` marker, and `spec.md` present. `user-story.md` is correctly absent for that work mode.
2. Delegate to `atomic-planner` with a prompt that names both the feature folder and a research artifact inside it, for example `docs/features/active/<slug>/research/<timestamp>-findings.md`.
3. Observe the gate decision.
4. Re-issue the identical delegation with the research artifact expressed folder-relative — `research/<timestamp>-findings.md` — so the longest `docs/features/active/...` token in the prompt is the feature folder itself.
5. Compare.

## Expected Behavior

Both delegations describe the same feature folder and should produce the same decision. A prompt that cites supporting artifacts is normal and expected: the orchestrator is required to hand the planner its research findings, and `.claude/skills/orchestrate/SKILL.md` names the research path as a delegation input. Citing an input should not change which folder the gate believes is in scope.

## Actual Behavior

Step 2 is denied. Step 4 is allowed.

```text
PRD_FEATURE_BLOCKED: cannot delegate to atomic-planner before prd-feature outputs are
present in 'docs/features/active/<slug>/research'. Missing: spec.md, user-story.md.
Work mode could not be determined from 'docs/features/active/<slug>/research/issue.md'
(marker absent, unreadable, or unrecognized); failing closed to the strictest
prerequisite set (spec.md, user-story.md). Invoke the prd-feature subagent first.
```

The message is self-diagnosing if read closely — it names `.../research` as the folder and `.../research/issue.md` as the file it could not read — but the headline is "invoke the prd-feature subagent first", which is wrong and misdirects the reader toward re-running a step that has already completed correctly.

Two failure modes compound:

1. **Longest-match folder resolution.** The hook's documented strategy is that "the longest match wins; when it points at a `.md`, use its parent". Any nested artifact is a longer path than the folder, so the deeper directory wins.
2. **Fail-closed to the strictest set.** Having resolved to a directory with no `issue.md`, the hook cannot read the work-mode marker and demands both `spec.md` and `user-story.md`. For a `full-bug` feature that is doubly wrong: `user-story.md` must be *absent* under `.claude/skills/feature-promotion-lifecycle/SKILL.md`, so the gate demands a file whose presence the lifecycle rules treat as an integrity failure. No valid state satisfies it.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet is inlined under **Actual Behavior** above.
- Workaround used at the time: express nested artifact paths folder-relative in the delegation prompt, keeping the feature folder as the longest matching token. This is undiscoverable without reading the hook source.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. It fails closed so it is not a safety hole, but it blocks a mandated delegation on a correctly prepared feature, the block message points at the wrong remedy, and the demanded remedy is unsatisfiable for `full-bug` work. An agent following the message would either re-run `prd-feature` pointlessly or create a `user-story.md` that violates the lifecycle contract — the second outcome is actively harmful, since the gate would then pass while the feature folder had become non-compliant.

Not a Blocker because a workaround exists once the cause is known, and because the correct delegation form is reachable.

## Suspected Cause / Notes

- Longest-match is the wrong selection rule for this purpose. The feature folder is identifiable structurally, not by length: it is the path segment immediately below `docs/features/active/`. Truncating any matched path to exactly two segments past that prefix resolves every case correctly and is insensitive to how deep the cited artifact sits.
- The `.md`-implies-parent rule is a partial approximation of the same idea and should be removed once truncation is in place, since a `.md` directly inside the feature folder is handled by truncation anyway.
- The fail-closed branch deserves separate attention. Failing closed is right in principle, but failing closed to a set that includes `user-story.md` is wrong for two of the three work modes. Consider failing closed to `spec.md` only, or reporting "work mode indeterminate" as its own distinct reason rather than folding it into a missing-file message.
- The block message should name the resolved folder in the headline rather than the remedy, so the next reader sees the path problem first.
- Check `enforce-feature-folder-order.ps1` and any other hook that infers a feature folder from prompt text for the same selection rule.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas — cases asserting the same resolved folder for a prompt citing the folder alone, the folder plus a `research/` artifact, the folder plus an `evidence/<kind>/` artifact, and a nested artifact alone. Add a case asserting a `full-bug` feature with `user-story.md` correctly absent is allowed, which is the case that currently cannot pass.
- [x] Integration scenario to retest — the differential above: identical delegations differing only in whether the research path is folder-relative or full must produce the same decision.
- [x] Manual verification notes — confirm the gate still denies when `prd-feature` genuinely has not run: no `spec.md` for a `full-feature` or `full-bug` folder must still block. A fix that resolved the folder correctly but stopped denying would remove the gate's purpose.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
