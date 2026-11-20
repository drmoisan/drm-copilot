# TypeScript Dependency Install Baseline — [P0-T8]

Timestamp: 2026-08-26T07-56
Task: [P0-T8]
Command: `npm ci`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6b0c3b38073271d8/extensions/drm-copilot`
EXIT_CODE: 0

## Full output

```
npm warn deprecated glob@10.5.0: Old versions of glob are not supported, and contain widely publicized security vulnerabilities, which have been fixed in the current version. Please update. Support for old versions may be purchased (at exorbitant rates) by contacting i@izs.me

added 457 packages, and audited 458 packages in 12s

103 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

## Observation 1 — the added-package count line, reproduced verbatim

```
added 457 packages, and audited 458 packages in 12s
```

**457 packages added; 458 audited.** This is the first of the two observations the task requires beyond the exit code. It distinguishes a populated dependency tree from an empty one: `npm ci` exits 0 on a lockfile-consistent install regardless of how much it actually installed, so the count is what establishes the tree was populated rather than merely validated.

The audit reported `found 0 vulnerabilities`. The single `npm warn deprecated glob@10.5.0` line is a transitive-dependency advisory, not an install failure; it does not affect the exit code and no action is taken on it by this plan.

## Observation 2 — the jest binary exists and resolves

```
$ ls -la node_modules/.bin/jest*
-rwxr-xr-x 1 DanMoisan 197121 381 Aug 26 07:52 node_modules/.bin/jest
-rw-r--r-- 1 DanMoisan 197121 321 Aug 26 07:52 node_modules/.bin/jest.cmd
-rwxr-xr-x 1 DanMoisan 197121 789 Aug 26 07:52 node_modules/.bin/jest.ps1
$ echo "exit=$?"
exit=0
```

`extensions/drm-copilot/node_modules/.bin/jest` **exists**, alongside its Windows `.cmd` and `.ps1` shims.

Existence alone would only prove a file was written, so the binary was additionally executed to prove it resolves its own module graph:

```
$ ./node_modules/.bin/jest --version
30.4.1
$ echo "exit=$?"
exit=0
```

Jest 30.4.1 resolved and reported its version, exiting 0. This is the second required observation. Every later TypeScript test task in this plan — [P0-T12], [P1-T5], [P3-T6], [P3-T7], [P3-T8], [P4-T3], [P4-T5], [P4-T6], and [P8-T9] — depends on this binary, so its resolvability is verified once here rather than discovered as a failure later.

## Why the exit code alone is insufficient here

`npm ci` exits 0 for a successful install, and the exit code carries no information about how many packages landed or whether the resulting tree can execute anything. A run that exits 0 against an unexpectedly minimal lockfile, or one whose binaries fail to resolve, would be indistinguishable from a correct one on the exit code alone. The package count and the resolved binary are the two observations that make the difference visible, which is why the task states both.

## Register status — `npm ci` is deliberately not a write-mode register member

`npm ci` deletes and recreates `node_modules`, so it unambiguously writes. It is nevertheless excluded from the G7 write-mode register, because its only write target is git-ignored: it rewrites no tracked source, and the register exists because a *source* rewrite leaves the exit code unchanged. This is one of the two exclusions [P7-T2] records in `.claude/rules/plan-acceptance-gates.md`, the other being `git add`. The exclusion is stated here at the point the command actually runs so the boundary is visible in the evidence as well as in the rule file.

Note the distinction the exclusion turns on: excluding `npm ci` from the register does not mean this task needs no observation beyond the exit code. It means no *rule* will demand one. The plan demands two anyway, for the reason given in the preceding section.

## Exit-code capture method

Output redirected to a file; exit code read from `$?` with no pipe in the chain.

## Output Summary

`npm ci` exited 0 from `extensions/drm-copilot`, reporting `added 457 packages, and audited 458 packages in 12s` with `found 0 vulnerabilities`. One deprecation warning for the transitive dependency `glob@10.5.0` was emitted and is not an install failure. `extensions/drm-copilot/node_modules/.bin/jest` exists and resolves, reporting version 30.4.1 and exiting 0, so the TypeScript test toolchain is available for every later task in this plan that depends on it.
