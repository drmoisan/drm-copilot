# [P6-T1] Toolchain Stage Applicability Rationale

This change's diff consists entirely of `package.json` and `package-lock.json` edits across 3 npm manifests (`.`, `extensions/drm-copilot/`, `packages/mcp-server/`). No `.ts` source files were added, removed, or modified.

## Why Prettier, ESLint, and `tsc` are not standalone gates for this diff

1. **Formatting (Prettier / `npm run format`)** — Prettier formats `.ts`/`.tsx`/`.js`/`.mjs`/`.cjs`/`.json` source and config files under `src/**`, `tests/**`, and specific named config files (per each manifest's `format`/`format:check` script glob patterns). `package.json` itself is not in any of those glob patterns as a formatting target in this repo's scripts, and no `.ts` source file changed. Running `format`/`format:check` would exercise unrelated, unchanged files and would not validate anything about this diff.

2. **Linting (ESLint / `npm run lint`)** — ESLint in this repo lints `src` and `tests` directories (TypeScript sources). No TypeScript source changed, so ESLint has nothing new to lint as a result of this change.

3. **Type checking (`tsc` / `npm run typecheck`)** — `tsc` type-checks `.ts` sources against the resolved `node_modules` dependency tree. This stage **is** indirectly exercised by this change: the `npm run compile` tasks in Phase 0 (P0-T7, P0-T10) and Phase 6 (P6-T2, P6-T5) invoke `tsc -p ./ --noEmit` (extensions) or the root's compile wrapper, which type-checks the unchanged TypeScript sources against the newly regenerated `node_modules`/lock file produced by Phase 4. If the refreshed dependency tree introduced a type-incompatible transitive package version, the `tsc` step inside `npm run compile` would fail. It did not fail (see P6-T2/P6-T5 evidence), which is the functional equivalent of a passing standalone type-check gate for this diff.

## Conclusion

- Formatting and linting are not applicable as standalone gates because the diff contains no `.ts`/`.js` source files subject to those tools' glob patterns — only JSON manifest files.
- Type checking is exercised indirectly and successfully via the `npm run compile` tasks, which fail if the unchanged TypeScript sources no longer type-check against the refreshed dependency tree.
- Testing (Jest, `npm run test:unit` / `npm run test:unit:coverage` / `npm run test:coverage`) and build (`npm run build` for `packages/mcp-server`) remain full standalone gates in Phase 6 and are executed unconditionally.
