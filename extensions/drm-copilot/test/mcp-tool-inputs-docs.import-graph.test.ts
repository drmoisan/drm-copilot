/**
 * Import-graph checks for the docs MCP input modules (issue #1173, remediation
 * cycle 1, finding R1).
 *
 * The extension has no architecture-boundary tool for TypeScript, so these
 * tests are the boundary check for the docs input modules: a test-local helper
 * builds the module graph from the committed source text (read-only) and
 * reports every import cycle reachable from a start module. Type-only imports
 * count as edges, because a cycle through them still couples the modules.
 */

import { describe, expect, it } from "@jest/globals";
import { existsSync, readFileSync } from "node:fs";
import * as path from "node:path";

const SRC_ROOT = path.resolve(__dirname, "..", "src");

/** Reads the source text of a module key, or undefined when it is absent. */
type SourceReader = (moduleKey: string) => string | undefined;

/** Resolves a relative specifier of a module to a module key. */
type SpecifierResolver = (
  fromKey: string,
  specifier: string,
) => string | undefined;

const SPECIFIER_PATTERNS: ReadonlyArray<RegExp> = [
  /^\s*(?:import|export)\b[^;]*?\bfrom\s*["'](\.[^"']*)["']/gm,
  /^\s*import\s*["'](\.[^"']*)["']/gm,
  /\bimport\s*\(\s*["'](\.[^"']*)["']\s*\)/g,
];

/**
 * Collects every relative specifier of the import, re-export, side-effect
 * import and dynamic import forms in a source text.
 */
function collectRelativeSpecifiers(sourceText: string): string[] {
  const specifiers: string[] = [];
  for (const pattern of SPECIFIER_PATTERNS) {
    for (const match of sourceText.matchAll(pattern)) {
      const specifier = match[1];
      if (specifier !== undefined) {
        specifiers.push(specifier);
      }
    }
  }
  return specifiers;
}

/**
 * Builds the module graph reachable from a start module.
 *
 * @throws Error when the start module or a reached module cannot be read.
 */
function buildModuleGraph(
  startKey: string,
  readSource: SourceReader,
  resolveSpecifier: SpecifierResolver,
): Map<string, string[]> {
  const graph = new Map<string, string[]>();
  const pending = [startKey];
  while (pending.length > 0) {
    const key = pending.pop();
    if (key === undefined || graph.has(key)) {
      continue;
    }
    const sourceText = readSource(key);
    if (sourceText === undefined) {
      throw new Error(`module ${key} cannot be read.`);
    }
    const edges = collectRelativeSpecifiers(sourceText)
      .map((specifier) => resolveSpecifier(key, specifier))
      .filter((target): target is string => target !== undefined);
    graph.set(key, [...new Set(edges)]);
    pending.push(...edges);
  }
  return graph;
}

/** Returns every cycle reachable from the start module as a path list. */
function findImportCycles(
  graph: ReadonlyMap<string, ReadonlyArray<string>>,
  startKey: string,
): string[][] {
  const cycles: string[][] = [];
  const seen = new Set<string>();
  const done = new Set<string>();
  const stack: string[] = [];
  const visit = (key: string): void => {
    const position = stack.indexOf(key);
    if (position >= 0) {
      const cycle = [...stack.slice(position), key];
      const signature = [...cycle.slice(0, -1)].sort().join("|");
      if (!seen.has(signature)) {
        seen.add(signature);
        cycles.push(cycle);
      }
      return;
    }
    if (done.has(key)) {
      return;
    }
    stack.push(key);
    for (const target of graph.get(key) ?? []) {
      visit(target);
    }
    stack.pop();
    done.add(key);
  };
  visit(startKey);
  return cycles;
}

/** Reads a committed module under src/ read-only. */
function readCommittedSource(moduleKey: string): string | undefined {
  const filePath = path.join(SRC_ROOT, moduleKey);
  return existsSync(filePath) ? readFileSync(filePath, "utf8") : undefined;
}

/** Resolves a relative specifier to a `.ts` or `index.ts` module under src/. */
function resolveCommittedSpecifier(
  fromKey: string,
  specifier: string,
): string | undefined {
  const base = path.posix.join(path.posix.dirname(fromKey), specifier);
  const stem = base.endsWith(".js") ? base.slice(0, -3) : base;
  const candidates = [`${stem}.ts`, `${stem}/index.ts`];
  return candidates.find(
    (candidate) =>
      !candidate.startsWith("..") && existsSync(path.join(SRC_ROOT, candidate)),
  );
}

function committedCycles(startKey: string): string[][] {
  const graph = buildModuleGraph(
    startKey,
    readCommittedSource,
    resolveCommittedSpecifier,
  );
  return findImportCycles(graph, startKey);
}

function describeCycles(cycles: ReadonlyArray<ReadonlyArray<string>>): string {
  return cycles.map((cycle) => cycle.join(" -> ")).join("; ");
}

describe("docs input module import graph", () => {
  it("reports a two-module cycle in an in-memory graph", () => {
    // Arrange
    const sources = new Map<string, string>([
      ["a.ts", 'import { b } from "./b";\nexport const a = 1;\n'],
      ["b.ts", 'import type { A } from "./a";\nexport const b = 2;\n'],
    ]);
    const resolveInMemory: SpecifierResolver = (fromKey, specifier) => {
      const key = `${path.posix.join(path.posix.dirname(fromKey), specifier)}.ts`;
      return sources.has(key) ? key : undefined;
    };

    // Act
    const graph = buildModuleGraph(
      "a.ts",
      (key) => sources.get(key),
      resolveInMemory,
    );
    const cycles = findImportCycles(graph, "a.ts");

    // Assert
    expect(cycles).toEqual([["a.ts", "b.ts", "a.ts"]]);
  });

  it("has no import cycle reachable from mcp-tool-inputs-docs.ts", () => {
    // Arrange and Act
    const cycles = committedCycles("mcp-tool-inputs-docs.ts");

    // Assert
    expect(describeCycles(cycles)).toBe("");
  });

  it("has no import cycle reachable from mcp-tool-inputs-docs-ledger-batch.ts", () => {
    // Arrange and Act
    const cycles = committedCycles("mcp-tool-inputs-docs-ledger-batch.ts");

    // Assert
    expect(describeCycles(cycles)).toBe("");
  });

  it("keeps mcp-tool-inputs-docs-grammar.ts free of imports of either docs input module", () => {
    // Arrange and Act
    const graph = buildModuleGraph(
      "mcp-tool-inputs-docs-grammar.ts",
      readCommittedSource,
      resolveCommittedSpecifier,
    );

    // Assert
    expect([...graph.keys()]).not.toContain("mcp-tool-inputs-docs.ts");
    expect([...graph.keys()]).not.toContain(
      "mcp-tool-inputs-docs-ledger-batch.ts",
    );
  });
});
