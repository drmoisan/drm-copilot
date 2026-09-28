# EA-2 — the false-allow (unauthorized-merge) direction of the whole-line PR-number defect

Timestamp: 2026-09-07T14-51

Task: binding execution amendment EA-2, additive to Phase 9 and carried in the delegation prompt
rather than in the plan file, so that amending the preflight-cleared plan would not invalidate its
clearance.

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context. Both runs recorded below were executed through `mcp__drm-copilot__run_poshqc_test` with
`scan_folders=["tests/scripts/claude-hooks"]`, and per-suite results were read from
`artifacts/pester/pester-junit.xml`.

## Why this artifact exists

The epic merge gate's whole-line PR-number extraction is not only a fail-closed defect. It is also a
**false-allow** defect. The plan's [P9-T3] AT-2 case uses a `cd` path component
(`2026-08-29T00-11`) that matches no authorized item, so it exercises the fail-closed direction only.
Shipping that case alone would leave the more dangerous direction untested.

## Fixture item table

Parallel-orchestrator checkpoint, injected through the mocked `Get-ParallelOrchestratorCheckpointContent`
read seam. The child and epic checkpoint seams are both mocked to `$null`, so the decision turns
solely on which pull request number the gate extracts.

```json
{"route_id":"parallel","items":[{"item_id":"item-501","pr_number":501,"merge_status":"ci_green"},{"item_id":"item-777","pr_number":777,"merge_status":"pr_open"}]}
```

| `item_id` | `pr_number` | `merge_status` | Authorized to merge? |
| --- | --- | --- | --- |
| `item-501` | 501 | `ci_green` | **yes** — this is the only status the parallel branch accepts |
| `item-777` | 777 | `pr_open` | **no** |

The authorized item's identifier `501` appears as a path component of the leading `cd` segment. The
actual operand of the `gh pr merge --merge` segment is the different, unauthorized number `777`.

## Command under test

```
cd /repo/worktrees/501 && gh pr merge --merge 777
```

## Run 1 — pre-change observation (executed, not derived)

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`, driven against the UNFIXED
`.claude/hooks/enforce-epic-merge-gate.ps1` at commit `f4d5afac`, through a throwaway suite
`tests/scripts/claude-hooks/ea2-prechange-observation.Tests.ps1` that was created and deleted within
this agent session. The throwaway suite asserted the pre-change values directly, so a PASS is the
positive observation of the defect.

EXIT_CODE: 3 (folder-wide failed-test count at that moment: 2 known-red inventory rows plus the 1
documented pre-existing `enforce-pr-author-skill.Tests.ps1` failure. The throwaway suite itself
contributed 0 failures.)

Observed, from `artifacts/pester/pester-junit.xml`:
`ea2-prechange-observation.Tests.ps1` — **2 tests, 0 errors, 0 failures.**

| Pre-change assertion | Observed |
| --- | --- |
| `PRE-CHANGE extracts 501 from the cd path component instead of the merge operand 777` | PASS — `Get-EpicMergeGateCommandPrNumber` returned **501** |
| `PRE-CHANGE allows merging unauthorized PR 777 because authorized item 501 appears earlier` | PASS — `Invoke-EpicMergeGateDecision` returned **allow** |

**Pre-change extraction result: 501.** **Pre-change decision: allow.** The gate authorized merging
pull request 777, which the checkpoint records at `pr_open` and never authorizes. This is an
unauthorized merge, not a blocked one.

Mechanism: the deleted branch at the pre-change line 154 tested
`$CommandText -match '(?<![-\w])(\d+)\b'` against the whole command line once `gh pr merge` appeared
anywhere in it. In `/repo/worktrees/501` the digit run `501` is preceded by `/`, which satisfies the
`(?<![-\w])` lookbehind, so `501` was returned before the merge segment's own operand was ever
consulted.

## Run 2 — post-change decision

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`, driven against the fixed hook after [P9-T1], through
the delivered suite `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`.

EXIT_CODE: 1 (folder-wide failed-test count: the 1 documented pre-existing
`enforce-pr-author-skill.Tests.ps1` failure only.)

Observed: `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` — **9 tests, 0 errors, 0 failures.**

The named EA-2 case is:

**`denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line`**

Its comment in the suite states that it pins the unauthorized-merge direction of the defect.

| Post-change assertion | Observed |
| --- | --- |
| `takes the PR number from the merge operand 777, not from the authorized item number 501 in the cd path` | PASS — extraction returned **777** |
| `denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line` | PASS — decision is **deny**, reason matching `EPIC_MERGE_GATE_BLOCKED` |
| `still allows merging the authorized PR 501 when 501 is the merge operand` | PASS — decision is **allow** for `cd /repo/worktrees/501 && gh pr merge --merge 501` |

**Post-change decision: deny.** The third case is the complement and confirms the correction is not a
blanket denial: with the same fixture and the same leading `cd` segment, naming the authorized `501`
as the merge operand still allows.

## Why the [P9-T1] correction closes both directions

`Get-EpicMergeGateCommandPrNumber` now resolves the number from the matched segment only, through
`Get-CommandLineOperand` for the positional spelling and `Get-CommandLineFlagValue` for the flag-led
and equals-joined spellings. A `cd <path>` segment chained before the invocation contributes no
operand and no flag value, so no digit run anywhere outside the `gh pr merge` segment can supply the
number. The fail-closed direction (`2026-08-29T00-11` misread as a PR number) and the false-allow
direction (an authorized item's number misread as the merge target) share that single cause and close
together.

## Scope note

This artifact does not address, and EA-2 does not authorize addressing, the separate weakness
recorded as EA-3 item (a): `Test-ChildCheckpointAllowsEpicMerge` declares only a `$Checkpoint`
parameter, is consulted first, and therefore authorizes merging any pull request when the child
checkpoint carries `epic_mode: true` and `step9_status: "passed"`. Every case above mocks the child
checkpoint seam to `$null` so that weakness cannot mask the behaviour under test.

Output Summary: EA-2 satisfied. Against a two-item parallel fixture in which item 501 is authorized
at `merge_status` `ci_green` and item 777 is unauthorized at `pr_open`, the command
`cd /repo/worktrees/501 && gh pr merge --merge 777` extracted **501** and was **allowed** before the
change — an unauthorized merge of PR 777 — and extracts **777** and is **denied** after the change.
Both observations are executed Pester runs, not derivations. The named case
`denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line`
ships in `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` and passes,
alongside a complement case confirming the authorized merge of PR 501 still allows.
