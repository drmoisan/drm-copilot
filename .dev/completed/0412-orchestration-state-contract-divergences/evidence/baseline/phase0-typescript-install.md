# Phase 0 — TypeScript Toolchain Install (Issue #412)

Task: [P0-T9]

Timestamp: 2026-07-25T17-30

Command: `cd extensions/drm-copilot && npm ci` (workspace root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`)

EXIT_CODE: 0

Output Summary:

```
npm warn deprecated glob@10.5.0: Old versions of glob are not supported ...
added 460 packages, and audited 461 packages in 5s
104 packages are looking for funding
20 high severity vulnerabilities
```

**Package count: 460 packages added, 461 audited.** Install succeeded from the committed
`extensions/drm-copilot/package-lock.json`.

### Acceptance verification

`extensions/drm-copilot/node_modules/.bin/jest` exists:

```
-rwxr-xr-x 1 DanMoisan 197121 381 Jul 25 17:30 extensions/drm-copilot/node_modules/.bin/jest
```

### Execution note (first attempt ran from the wrong directory)

The Bash tool resets the working directory to the workspace root before every invocation, so
an initial attempt that issued `cd extensions/drm-copilot` as a separate call and then `npm ci`
as the next call executed `npm ci` against the **repository-root** `package.json` instead
(533 packages added, 534 audited, 22 high-severity advisories). That run installed the root
project's own dependencies into a git-ignored `node_modules/` at the repository root and
changed no tracked file — `git status --porcelain` immediately afterwards showed only this
feature's plan edit and evidence directory. The command was then re-executed as a single
`cd extensions/drm-copilot && npm ci` invocation; the figures recorded above are from that
correct run. This task was left unchecked in the plan until the correct run completed.

### Pre-existing advisories (not remediated here)

`npm ci` reports 20 high-severity vulnerabilities for the extension package, including the
repo-wide `brace-expansion` advisory GHSA-mh99-v99m-4gvg, plus a deprecation warning for
`glob@10.5.0`. These are pre-existing conditions of the committed lockfile, are unrelated to
this branch, and are owned by a separate effort. They are recorded here for baseline fidelity
and are explicitly **not** remediated as part of issue #412. `npm ci` itself exited 0; the
advisory count does not fail this task.
