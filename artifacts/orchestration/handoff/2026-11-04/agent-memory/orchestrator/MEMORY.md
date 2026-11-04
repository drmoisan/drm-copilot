# Orchestrator Memory Index

- [Green-CI merge must be unchained](green-ci-merge-must-be-unchained.md) — a chained gh pr merge is denied as STANDALONE_MERGE_AUTHORIZATION_ABSENT; merge in its own call
- [Docs-only head blocks merge](docs-only-head-blocks-merge.md) — docs-only final head leaves 8 required matrix contexts unreported; ensure a full run on the last head; no --repo on merge
- [Epic-child S9 check-off makes a docs-only head](epic-child-s9-checkoff-creates-docs-only-head.md) — dispatch 403s from Codespace; ruleset 15241672 covers only main
- [Completion hook checks folder at session root](completion-hook-checks-folder-at-session-root.md) — step10 completed denied when the folder is only in the item worktree; keep step8 delegated; no sed on the checkpoint
- [Session resume revives background agents](session-resume-revives-background-agents.md) — no commits + missing SCRATCH after `claude --resume` is not death; relaunch caused two executors
- [Epic-child execution checkpoint shape](epic-child-execution-checkpoint-shape.md) — lifecycle_ready, route_id, carried-forward prep receipts with routing receipts, issue_adoption with feature_folder_record
