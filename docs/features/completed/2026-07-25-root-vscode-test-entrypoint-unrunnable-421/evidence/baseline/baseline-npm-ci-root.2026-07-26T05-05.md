# Baseline — Root `npm ci` (#421)

Timestamp: 2026-07-26T05-05

Task: [P0-T3]

Command:

```
npm ci
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ab68fbeb0ce28fc0d` (repository/worktree root)

EXIT_CODE: 0

## Raw Output

```
npm warn deprecated glob@10.5.0: Old versions of glob are not supported, and contain widely publicized security vulnerabilities, which have been fixed in the current version. Please update. Support for old versions may be purchased (at exorbitant rates) by contacting i@izs.me

added 525 packages, and audited 526 packages in 7s

129 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

## Lockfile Integrity Check

```
$ git status --porcelain package-lock.json
(no output)
```

`package-lock.json` is unchanged after `npm ci`, confirming the forbidden-file boundary is intact (`npm ci` installs from the lockfile without rewriting it).

Output Summary: `npm ci` succeeded with EXIT_CODE 0. 525 packages added, 526 audited, 0 vulnerabilities found. One deprecation warning for `glob@10.5.0` (transitive, pre-existing, out of scope — dependency work is owned by a sibling orchestration). `package-lock.json` unchanged (`git status --porcelain package-lock.json` returned empty).
