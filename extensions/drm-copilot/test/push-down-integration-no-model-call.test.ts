/**
 * No-model-call text test of the push-down integration modules (issue #1051,
 * S49). Each new production module is read from the tracked source tree and
 * checked for forbidden imports and tokens.
 */

import { readFileSync } from "node:fs";
import { join } from "node:path";

const SOURCE_ROOT = join(__dirname, "..", "src");

/** Every new production module of the feature, relative to `src/`. */
const MODULES = [
  "lib/push-down-integration/workflow-yaml-reader.ts",
  "lib/push-down-integration/integration-items.ts",
  "lib/push-down-integration/integration-ecosystems.ts",
  "lib/push-down-integration/integration-detect.ts",
  "lib/push-down-integration/integration-validate.ts",
  "lib/push-down-integration/integration-validate-artifacts.ts",
  "lib/push-down/push-down-integration-needed.ts",
  "mcp-push-down-integration-tool-definitions.ts",
  "mcp-tool-inputs-push-down-integration.ts",
  "mcp-handlers/push-down-integration-handlers.ts",
  "repo-automation-service-push-down-integration.ts",
] as const;

/** Modules whose import is forbidden. */
const FORBIDDEN_MODULES = [
  "child_process",
  "node:child_process",
  "http",
  "node:http",
  "https",
  "node:https",
  "net",
  "node:net",
  "vscode",
] as const;

/** Tokens whose presence is forbidden. */
const FORBIDDEN_TOKENS = [
  "fetch(",
  "createMessage",
  "sampling",
  "getClientCapabilities",
  "elicit",
  "languageModel",
  "LanguageModelChat",
] as const;

/**
 * Return the forbidden imports and tokens found in a module text.
 *
 * @param text Module text.
 * @returns The findings, empty for a clean text.
 */
function findForbidden(text: string): string[] {
  const findings: string[] = [];
  for (const name of FORBIDDEN_MODULES) {
    const escaped = name.replace(/[.*+?^${}()|[\]\\/]/g, "\\$&");
    const pattern = new RegExp(
      `(from\\s+|import\\s*\\(\\s*|require\\s*\\(\\s*|import\\s+)["']${escaped}["']`,
    );
    if (pattern.test(text)) {
      findings.push(`import ${name}`);
    }
  }
  for (const token of FORBIDDEN_TOKENS) {
    if (text.includes(token)) {
      findings.push(token);
    }
  }
  return findings;
}

describe("push-down integration modules make no model call", () => {
  it.each(MODULES)(
    "S49 positive: %s has no forbidden import or token",
    (module) => {
      const text = readFileSync(
        join(SOURCE_ROOT, ...module.split("/")),
        "utf8",
      );

      expect(findForbidden(text)).toEqual([]);
    },
  );

  it.each(FORBIDDEN_MODULES)(
    "S49 negative: an import of %s is detected in every import form",
    (name) => {
      for (const text of [
        `import { x } from "${name}";`,
        `import * as y from '${name}';`,
        `import "${name}";`,
        `const z = require("${name}");`,
        `const w = await import("${name}");`,
      ]) {
        expect(findForbidden(text)).toContain(`import ${name}`);
      }
    },
  );

  it.each(FORBIDDEN_TOKENS)(
    "S49 negative: the token %s is detected",
    (token) => {
      expect(findForbidden(`const value = ${token};`)).toContain(token);
    },
  );

  it("S49 negative: an unrelated module name is not reported as a forbidden import", () => {
    expect(findForbidden('import { x } from "./netlify";')).toEqual([]);
  });
});
