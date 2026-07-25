# Manifest End-State Assertions — Both Affected Manifests (#414, [P3-T2])

Timestamp: 2026-07-25T21-50

Scope: `package.json` (repository root) and `extensions/drm-copilot/package.json`, edited in [P1-T1] and [P2-T1].

## Structured Overrides Inspection

Command: `node -e "for(const f of ['package.json','extensions/drm-copilot/package.json']){const o=JSON.parse(require('fs').readFileSync(f,'utf8')).overrides||{};console.log(f);console.log('  brace-expansion:',JSON.stringify(o['brace-expansion']));console.log('  minimatch:',JSON.stringify(o['minimatch']));console.log('  has c8 key:',Object.prototype.hasOwnProperty.call(o,'c8'));console.log('  all override keys:',JSON.stringify(Object.keys(o)));}"` (working directory: repository root)
EXIT_CODE: 0

```text
package.json
  brace-expansion: "^5.0.8"
  minimatch: "^10.2.5"
  has c8 key: false
  all override keys: ["diff","serialize-javascript","fast-uri","hono","ip-address","qs","@babel/core","js-yaml","@hono/node-server","brace-expansion","minimatch","babel-plugin-istanbul"]
extensions/drm-copilot/package.json
  brace-expansion: "^5.0.8"
  minimatch: "^10.2.5"
  has c8 key: false
  all override keys: ["fast-uri","hono","ip-address","qs","@babel/core","js-yaml","@hono/node-server","brace-expansion","minimatch","babel-plugin-istanbul"]
```

Both manifests parse as valid JSON (the inspection above uses `JSON.parse`, which would have thrown otherwise).

## Confirming Grep — no `c8` key anywhere in either manifest

A grep exit code of `1` means zero matches, the passing outcome for this negative assertion.

| Working directory | Command | EXIT_CODE | Match count |
|---|---|---|---|
| repository root | `grep -c '"c8"' package.json` | 1 | 0 |
| `extensions/drm-copilot` | `grep -c '"c8"' package.json` | 1 | 0 |

## Assertion Results

| Assertion | `package.json` | `extensions/drm-copilot/package.json` |
|---|---|---|
| `overrides` contains unscoped `"brace-expansion": "^5.0.8"` | PASS | PASS |
| `overrides` contains unscoped `"minimatch": "^10.2.5"` | PASS | PASS |
| no `"c8"` overrides entry | PASS | PASS |

## Change Confinement

The `git diff` for each manifest ([P1-T1], [P2-T1]) shows only the removed three-line `"c8": { "brace-expansion": "^5.0.7" }` block replaced by the two added scalar entries. Every other override key is preserved in its original order, as the `all override keys` listing above shows: the root retains `diff`, `serialize-javascript`, `fast-uri`, `hono`, `ip-address`, `qs`, `@babel/core`, `js-yaml`, `@hono/node-server`, and `babel-plugin-istanbul`; the extension retains the same set less `diff` and `serialize-javascript`, which it never carried.

Output Summary: Both `package.json` files carry the unscoped overrides `"brace-expansion": "^5.0.8"` and `"minimatch": "^10.2.5"`, and neither contains a `"c8"` overrides entry (structured inspection reports `has c8 key: false` for both; confirming greps return zero matches with exit 1). All pre-existing override entries are preserved. This satisfies the `spec.md` acceptance criterion on the override end-state.
