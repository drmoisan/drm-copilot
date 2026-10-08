# Git Baseline (P0-T8)

Timestamp: 2026-10-02T04-29
Command: git merge-base HEAD origin/main
EXIT_CODE: 0
Output Summary:
74e1d6741485aa38c28fecbbc77ea169f31df0ef
- git rev-parse HEAD exited 0
d679817614a46195400c893a97fd095bb7880614
- git rev-parse origin/main exited 0
74e1d6741485aa38c28fecbbc77ea169f31df0ef
PLAN DEVIATION DEV-1 - baseline anchor. The branch was merged with origin/main at 74e1d6741485aa38c28fecbbc77ea169f31df0ef as an operator requirement, so the merge-base is 74e1d674 rather than the plan's b7b4a2dc59682e5defb3e16d79b6fb8e2782d23e. Per the orchestrator-approved deviation this value is accepted and BLOCKED is not reported; every later `git diff ... b7b4a2dc` in this plan uses 74e1d674 as the anchor. The orchestrator verified that main did not change the validator, its tests, the TypeScript core, or its tests between b7b4a2dc and 74e1d674.
