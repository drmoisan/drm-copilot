---
name: epic-child-s9-checkoff-creates-docs-only-head
description: The S9 CI-dependent AC check-off always makes the final epic-child head docs-only; workflow dispatch 403s from the Codespace token; ruleset 15241672 covers only the default branch
metadata:
  type: project
---

On an epic child PR into `epic/<slug>-integration`, the S9 check-off of CI-dependent criteria (coverage from the shard artifact) is a docs-only commit, so the next pull_request run is docs-only and skips 8 required matrix contexts (3 PowerShell shards, 2 root TypeScript tests, 3 NPM audits). `gh workflow run ci.yml --ref <branch>` returned HTTP 403 "Resource not accessible by integration" from the Codespace token (issue 1022, PR #1072, 2026-11-04).

Ruleset 15241672 has `ref_name.include: ["~DEFAULT_BRANCH"]` only, so integration branches carry no required-check rules and GitHub reports such a PR MERGEABLE regardless.

**Why:** an epic kickoff that demands "a full CI run on the final head" cannot be satisfied by the child run once the check-off lands, and the dispatch fallback is denied.

**How to apply:** at kickoff time, expect this; report `blocked_reason: external_dependency` with both unblock options (dispatch with an actions:write token, or accept the prior full green run on the pre-check-off head and merge with `--match-head-commit`) rather than inventing a code change. Related: [[docs-only-head-blocks-merge]], [[epic-child-execution-checkpoint-shape]].
