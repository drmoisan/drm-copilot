# Prior Art — `2f67b888:tests/unit/vscode-test-removal.test.ts` (#421)

Timestamp: 2026-07-26T05-12

Task: [P0-T11] — source material for the [P2-T1] regression guard.

Command:

```
git show 2f67b888:tests/unit/vscode-test-removal.test.ts
```

EXIT_CODE: 0

Provenance: commit `2f67b888` ("(fix(tests)): drop vscode-test harness and make npm test container-safe", Refs #12) exists on an abandoned pre-rewrite lineage, reachable via `git log --all` but not from `main`'s current lineage. It implemented the same option (a) selected by this spec's Scope Decision. This file is retrieved as design reference only; it is not restored verbatim.

## Verbatim Content

```typescript
import { describe, expect, test } from "@jest/globals";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

type PackageJson = {
  scripts?: Record<string, string>;
};

const repoRoot = path.resolve(__dirname, "../..");

const loadPackageJson = (): PackageJson => {
  const packageJsonPath = path.join(repoRoot, "package.json");
  const raw = readFileSync(packageJsonPath, "utf-8");
  return JSON.parse(raw) as PackageJson;
};

describe("VS Code test harness removal", () => {
  test("scripts avoid vscode-test electron harness", () => {
    // Arrange
    const packageJson = loadPackageJson();
    const scriptValues = Object.values(packageJson.scripts ?? {});

    // Act
    const hasVscodeTestElectron = scriptValues.some((value) =>
      value.includes("@vscode/test-electron"),
    );
    const hasVscodeTestRunner = scriptValues.some((value) =>
      value.includes("vscode-test"),
    );

    // Assert
    expect(hasVscodeTestElectron).toBe(false);
    expect(hasVscodeTestRunner).toBe(false);
  });

  test("vscode-test mjs removed", () => {
    // Arrange
    const vscodeTestPath = path.join(repoRoot, ".vscode-test.mjs");

    // Act
    const exists = existsSync(vscodeTestPath);

    // Assert
    expect(exists).toBe(false);
  });

  test("vscode-test tsconfig removed", () => {
    // Arrange
    const tsconfigPath = path.join(repoRoot, "tsconfig.vscode-test.json");

    // Act
    const exists = existsSync(tsconfigPath);

    // Assert
    expect(exists).toBe(false);
  });
});
```

## Adaptation Notes for [P2-T1]

The prior art establishes the pattern (read the committed root `package.json`, assert no script invokes `vscode-test`, assert dead config files are absent, Arrange–Act–Assert, no temporary files, deterministic). Two adaptations are required by the spec's AC3:

1. **Config-file coverage must be broadened.** The prior art checks only `.vscode-test.mjs` and `tsconfig.vscode-test.json`. AC3 requires all five: `.vscode-test.mjs`, `.vscode-test.js`, `.vscode-test.cjs`, `.vscode-test.json`, and `tsconfig.vscode-test.json`.
2. **Failure messages.** Per `.claude/rules/general-unit-test.md`, assertions must produce clear, actionable failure messages. The prior art's boolean assertions (`expect(hasVscodeTestRunner).toBe(false)`) report only `true !== false` and do not name the offending script or file. The adaptation asserts on the offending names themselves so a failure identifies the specific script key or config path.

Retained without change: the `repoRoot` derivation via `path.resolve(__dirname, "../..")` (path-independent, no `<rootDir>` dependency, so it is unaffected by #414 Condition 3), the read-only filesystem access to versioned repository files, and the `tests/unit/` location that matches the existing jest `testMatch` without any configuration edit.

Output Summary: `git show 2f67b888:tests/unit/vscode-test-removal.test.ts` succeeded with EXIT_CODE 0 and the full 57-line file content is captured above. The prior art contains three tests in one `describe` block: script-value assertions against `@vscode/test-electron` and `vscode-test`, and existence assertions for `.vscode-test.mjs` and `tsconfig.vscode-test.json`. Two adaptations are required for AC3 (five config files instead of two; actionable failure messages).
