# Sourcemap / tsconfig Decision

Timestamp: 2026-07-03T15-27

## Confirmation

- `extensions/drm-copilot/jest.config.cjs`:
  - `testMatch: ["<rootDir>/test/**/*.test.ts"]` — tests are discovered directly from `test/**/*.test.ts` source files.
  - `testPathIgnorePatterns: ["/node_modules/", "/out/"]` — the compiled `out/` directory is explicitly excluded from test discovery.
  - `transform` wires `ts-jest` with `tsconfig: "<rootDir>/tsconfig.jest.json"` for `.ts`/`.tsx` files, meaning tests execute directly against TypeScript sources (not compiled JavaScript).
- `extensions/drm-copilot/tsconfig.jest.json`:
  - `include: ["src/**/*.ts", "test/**/*.ts"]` — ts-jest type-checks and transpiles source and test `.ts` files in-memory; it does not read from `out/`.

This confirms tests run via `ts-jest` directly against `src/**/*.ts` and `test/**/*.ts`, not against compiled `out/` output, and that `jest.config.cjs`'s `testPathIgnorePatterns` excludes `/out/`.

## Decisions

(a) The new `extensions/drm-copilot/esbuild-extension.cjs` will not enable sourcemaps, matching the existing convention in `extensions/drm-copilot/esbuild-mcp-server.cjs`, which also omits the `sourcemap` option from its `esbuild.build(...)` call.

(b) `extensions/drm-copilot/tsconfig.json`'s `outDir` (`out`) and `sourceMap` (`true`) settings require no change. `outDir` continues to control where `tsc -p ./ --noEmit` would have emitted output (now used only for type-checking, no emit); `sourceMap: true` has no effect under `--noEmit` and is unrelated to the esbuild bundling step, which reads `src/extension.ts` directly and writes `out/extension.js` independently of `tsc`'s emit settings.

## Conclusion

Because the test suite never depends on compiled `out/` artifacts, and the new bundler follows the existing no-sourcemap convention, the bundling change introduced in this plan has no effect on test execution or on `tsconfig.json`.
