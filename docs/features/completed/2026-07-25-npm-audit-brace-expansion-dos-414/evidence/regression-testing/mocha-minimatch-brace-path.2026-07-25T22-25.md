# Substitute Verification — mocha's Forced `minimatch` Consumption Path (#414, [P6-T4])

Timestamp: 2026-07-25T22-25

## Why This Verification Is Required

Root `npm run test:integration` cannot execute (no `.vscode-test.{json,js,cjs,mjs}` configuration exists, so `@vscode/test-cli` exits before starting a runner — see [P0-T17] and [P4-T6]), and no workflow in this repository invokes it. Mocha's `minimatch` call site is therefore not exercised by any runnable gate. It is verified directly here.

This is the direct negative control for the brace-expansion-only failure mode. `minimatch@9.0.9` consumes `brace-expansion` as a default import (`__importDefault(require('brace-expansion'))` then `(0, brace_expansion_1.default)(pattern)`), and `brace-expansion@5.0.8` has no default export, so a `minimatch@9.0.9` node would throw `TypeError` at exactly this call — but only for a brace-containing pattern. The pattern below (`**/*.{ts,js}`) contains braces and so reaches the expansion path.

## Note on the Plan's Example Command

The plan's illustrative command (prefixed "for example") derived the version via `path.join(path.dirname(p),'..','package.json')`. That path is off by one directory level: `require.resolve('minimatch', ...)` returns `node_modules/minimatch/dist/commonjs/index.js`, so `..` lands on `node_modules/minimatch/dist/package.json`, which does not exist, and the command exits 1 with `MODULE_NOT_FOUND` on the version lookup alone. Module resolution and the `minimatch()` call are unaffected by this defect. The command below uses `require.resolve('minimatch/package.json', {paths:[mochaDir]})` for the version and is otherwise identical: same resolution root, same entry point, same pattern, same options.

## Command 1 — resolve from mocha's root and exercise a brace-containing pattern

Command: `node -e "const path=require('node:path');const mochaDir=path.dirname(require.resolve('mocha/package.json'));const p=require.resolve('minimatch',{paths:[mochaDir]});const pkg=require.resolve('minimatch/package.json',{paths:[mochaDir]});const {minimatch}=require(p);console.log('mochaDir:',mochaDir);console.log('minimatch entry:',p);console.log('minimatch version:',require(pkg).version);console.log('brace match:',minimatch('a/b.ts','**/*.{ts,js}',{dot:true,windowsPathsNoEscape:true}));"` (working directory: repository root, against the regenerated tree)
EXIT_CODE: 0

```text
mochaDir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5\node_modules\mocha
minimatch entry: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5\node_modules\minimatch\dist\commonjs\index.js
minimatch version: 10.2.5
brace match: true
```

## Command 2 — consumer context

Command: `node -e "const path=require('node:path');const m=require('mocha/package.json');console.log('mocha version:',m.version);console.log('mocha declared minimatch range:',m.dependencies.minimatch);const mochaDir=path.dirname(require.resolve('mocha/package.json'));const bep=require.resolve('brace-expansion/package.json',{paths:[path.dirname(require.resolve('minimatch',{paths:[mochaDir]}))]});console.log('brace-expansion consumed by that minimatch:',require(bep).version);"` (working directory: repository root)
EXIT_CODE: 0

```text
mocha version: 11.7.6
mocha declared minimatch range: ^9.0.5
brace-expansion consumed by that minimatch: 5.0.8
```

## Acceptance Evaluation

| Acceptance condition | Observed | Status |
|---|---|---|
| `EXIT_CODE: 0` | 0 | PASS |
| Resolved `minimatch` version is `10.x` | `10.2.5` | PASS |
| Brace-containing pattern returns `true` | `true` | PASS |
| No `TypeError` | none thrown | PASS |

## Interpretation

`mocha@11.7.6` declares `minimatch: ^9.0.5`, so the unscoped `"minimatch": "^10.2.5"` override forces it outside its declared range. Resolving `minimatch` from mocha's own resolution root (`node_modules/mocha`) returns the hoisted `node_modules/minimatch` at version `10.2.5`, confirming the override reaches this consumer rather than leaving a nested `minimatch@9.x` behind. That `minimatch@10.2.5` in turn consumes `brace-expansion@5.0.8` — the exact version pair the override pins.

Calling the named `minimatch` export with the brace-containing pattern `**/*.{ts,js}` and the options mocha passes (`{ dot: true, windowsPathsNoEscape: true }`) returns `true` and throws nothing. `minimatch@10.2.5` calls the named export `(0, brace_expansion_1.expand)(pattern, { max: options.braceExpandMax })`, which `brace-expansion@5.0.8` provides; the failure mode that would occur under `minimatch@9.0.9` does not arise.

This is the plan's evidence that the forced `minimatch` 9→10 bump is safe for the mocha consumer.

Output Summary: PASS. Resolving `minimatch` from mocha's own resolution root (`node_modules/mocha`) against the regenerated tree returns version **`10.2.5`**, and calling it with the brace-containing pattern `**/*.{ts,js}` under mocha's options `{dot:true, windowsPathsNoEscape:true}` returns `true` with exit code 0 and no `TypeError`. `mocha@11.7.6` declares `minimatch: ^9.0.5`, so the override successfully forces the bump, and that `minimatch@10.2.5` consumes `brace-expansion@5.0.8`. This directly verifies the one consumption path no runnable gate in this repository exercises, and is the negative control proving the forced 9→10 bump is safe. The plan's illustrative command contained an off-by-one directory in its version lookup only; the corrected form is recorded above.
