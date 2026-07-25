# Extension Lockfile Regeneration — `npm install` (#414, [P2-T2])

Timestamp: 2026-07-25T21-44

Command: `npm install` (working directory: `extensions/drm-copilot`, AFTER the [P2-T1] `overrides` edit)
EXIT_CODE: 0

## Verbatim Output

```text
removed 3 packages, changed 1 package, and audited 458 packages in 890ms

103 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

## Delete-and-Reinstall Fallback

Not needed. The single `npm install` run resolved every flagged node on the first pass. No `node_modules` deletion was performed and `npm audit fix --force` was not used (prohibited by the plan and by `spec.md`).

## Post-Regeneration Lockfile Inspection

Command: `node -e "const l=JSON.parse(require('fs').readFileSync('package-lock.json','utf8'));console.log('lockfileVersion',l.lockfileVersion);const be=[],mm=[];for(const [k,v] of Object.entries(l.packages||{})){if(/(^|\/)node_modules\/brace-expansion$/.test(k)) be.push(k+' -> '+v.version);if(/(^|\/)node_modules\/minimatch$/.test(k)) mm.push(k+' -> '+v.version);}console.log('BRACE-EXPANSION NODES:');be.forEach(x=>console.log(' ',x));console.log('MINIMATCH NODES:');mm.forEach(x=>console.log(' ',x));"`
EXIT_CODE: 0

```text
lockfileVersion 3
BRACE-EXPANSION NODES:
  node_modules/brace-expansion -> 5.0.8
MINIMATCH NODES:
  node_modules/minimatch -> 10.2.5
```

No `brace-expansion` node at `2.1.2` or `5.0.7` remains; no `minimatch` node at any `9.x` version remains. The previously nested `node_modules/glob/node_modules/brace-expansion@2.1.2` node is gone — the unscoped `minimatch: ^10.2.5` override deduplicated the tree to a single hoisted node of each package.

## Working-Tree State

Command: `git status --porcelain extensions/drm-copilot/package-lock.json extensions/drm-copilot/package.json`
EXIT_CODE: 0

```text
 M extensions/drm-copilot/package-lock.json
 M extensions/drm-copilot/package.json
```

Output Summary: `npm install` in `extensions/drm-copilot` exited 0 after the `overrides` edit, removing 3 packages and changing 1 across 458 audited packages, and reported `found 0 vulnerabilities`. `extensions/drm-copilot/package-lock.json` is modified and retains `"lockfileVersion": 3`. The delete-and-reinstall fallback was not required. The regenerated tree contains exactly one hoisted `node_modules/brace-expansion` at `5.0.8` and one hoisted `node_modules/minimatch` at `10.2.5`, with no `brace-expansion` at `2.1.2`/`5.0.7` and no `minimatch` at `9.x`.
