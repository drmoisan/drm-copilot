# Lockfile Negative Assertions — Both Affected Lockfiles (#414, [P3-T1])

Timestamp: 2026-07-25T21-48

Scope: `package-lock.json` (repository root) and `extensions/drm-copilot/package-lock.json`, both regenerated in [P1-T2] and [P2-T2].

## Assertion (a) — no `brace-expansion` node at a version `<=5.0.7`

Literal greps for the two flagged resolved versions. A grep exit code of `1` means zero matches, which is the passing outcome for a negative assertion.

| Working directory | Command | EXIT_CODE | Match count |
|---|---|---|---|
| repository root | `grep -c 'brace-expansion-2.1.2.tgz' package-lock.json` | 1 | 0 |
| repository root | `grep -c 'brace-expansion-5.0.7.tgz' package-lock.json` | 1 | 0 |
| `extensions/drm-copilot` | `grep -c 'brace-expansion-2.1.2.tgz' package-lock.json` | 1 | 0 |
| `extensions/drm-copilot` | `grep -c 'brace-expansion-5.0.7.tgz' package-lock.json` | 1 | 0 |

Result: PASS in both lockfiles. Zero `brace-expansion` nodes at `2.1.2` or `5.0.7`.

## Assertion (b) — no `minimatch` node at any `9.x` version

| Working directory | Command | EXIT_CODE | Match count |
|---|---|---|---|
| repository root | `grep -cE 'minimatch-9\.[0-9]+\.[0-9]+\.tgz' package-lock.json` | 1 | 0 |
| `extensions/drm-copilot` | `grep -cE 'minimatch-9\.[0-9]+\.[0-9]+\.tgz' package-lock.json` | 1 | 0 |

Result: PASS in both lockfiles. The `minimatch@9.0.9` node that consumed `brace-expansion` via a default import is eliminated from both trees.

## Assertion (c) — exactly one hoisted `node_modules/brace-expansion` node per lockfile, at `5.0.8`

| Working directory | Command | EXIT_CODE | Match count |
|---|---|---|---|
| repository root | `grep -c '"node_modules/brace-expansion":' package-lock.json` | 0 | 1 |
| `extensions/drm-copilot` | `grep -c '"node_modules/brace-expansion":' package-lock.json` | 0 | 1 |

Contextual grep confirming the resolved version of that single node:

Command: `grep -n -A 2 'node_modules/brace-expansion' package-lock.json` (repository root)
EXIT_CODE: 0

```text
2580:    "node_modules/brace-expansion": {
2581-      "version": "5.0.8",
2582-      "resolved": "https://registry.npmjs.org/brace-expansion/-/brace-expansion-5.0.8.tgz",
```

Command: `grep -n -A 2 'node_modules/brace-expansion' package-lock.json` (`extensions/drm-copilot`)
EXIT_CODE: 0

```text
2838:    "node_modules/brace-expansion": {
2839-      "version": "5.0.8",
2840-      "resolved": "https://registry.npmjs.org/brace-expansion/-/brace-expansion-5.0.8.tgz",
```

(The additional `node_modules/brace-expansion/node_modules/balanced-match` line each grep returns is a nested `balanced-match` dependency, not a second `brace-expansion` node.)

Result: PASS in both lockfiles. Exactly one hoisted node each, at `5.0.8`.

## Structured cross-check (all three assertions in one pass)

Command: `node -e "for (const f of ['package-lock.json','extensions/drm-copilot/package-lock.json']){const l=JSON.parse(require('fs').readFileSync(f,'utf8'));let be=[],mm=[],hoist=0;for(const [k,v] of Object.entries(l.packages||{})){if(/(^|\/)node_modules\/brace-expansion$/.test(k)){be.push(k+'@'+v.version);if(k==='node_modules/brace-expansion')hoist++;}if(/(^|\/)node_modules\/minimatch$/.test(k))mm.push(k+'@'+v.version);}console.log(f);console.log('  lockfileVersion:',l.lockfileVersion);console.log('  brace-expansion nodes:',JSON.stringify(be));console.log('  minimatch nodes:',JSON.stringify(mm));console.log('  hoisted brace-expansion count:',hoist);console.log('  any be <=5.0.7:',be.some(x=>/@(2\.1\.2|5\.0\.[0-7])$/.test(x)));console.log('  any minimatch 9.x:',mm.some(x=>/@9\./.test(x)));}"` (working directory: repository root)
EXIT_CODE: 0

```text
package-lock.json
  lockfileVersion: 3
  brace-expansion nodes: ["node_modules/brace-expansion@5.0.8"]
  minimatch nodes: ["node_modules/minimatch@10.2.5"]
  hoisted brace-expansion count: 1
  any be <=5.0.7: false
  any minimatch 9.x: false
extensions/drm-copilot/package-lock.json
  lockfileVersion: 3
  brace-expansion nodes: ["node_modules/brace-expansion@5.0.8"]
  minimatch nodes: ["node_modules/minimatch@10.2.5"]
  hoisted brace-expansion count: 1
  any be <=5.0.7: false
  any minimatch 9.x: false
```

This enumerates every `node_modules/brace-expansion` and `node_modules/minimatch` key at any nesting depth, so it covers nodes a `resolved`-URL grep could miss.

Output Summary: All three assertions PASS in both affected lockfiles. Zero `brace-expansion` nodes at `2.1.2` or `5.0.7` (grep exit 1, no match, in all four checks); zero `minimatch` nodes at any `9.x` version (grep exit 1, no match, in both lockfiles); exactly one hoisted `node_modules/brace-expansion` per lockfile, resolving to `5.0.8`. The structured enumeration confirms each tree now holds a single `brace-expansion@5.0.8` and a single `minimatch@10.2.5` node at any depth, and both lockfiles retain `"lockfileVersion": 3`. This satisfies the `spec.md` acceptance criteria on residual `brace-expansion <=5.0.7` nodes and residual `minimatch@9.x` nodes.
