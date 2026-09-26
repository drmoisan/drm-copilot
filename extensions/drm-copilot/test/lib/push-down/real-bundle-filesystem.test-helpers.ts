/**
 * Test helpers that publish from the real Codex bundle into memory (issue #697).
 *
 * Purpose:
 *     Let an integration test drive the production publisher over the real
 *     `extensions/drm-copilot/resources` tree while every destination write
 *     lands in an in-memory filesystem, so no temporary file is created and the
 *     tracked bundle can never be modified by a test.
 */

import * as fs from "node:fs";
import * as nodePath from "node:path";

import {
  type PushDownFileSystem,
  RealPushDownFileSystem,
  toPosixPath,
} from "../../../src/lib/push-down/filesystem-adapter";
import { InMemoryPushDownFileSystem } from "./push-down.test-helpers";

/**
 * Read-through filesystem: real reads under one root, memory everywhere else.
 *
 * `listFiles`, `isDir`, `isFile`, and `readTextFile` for a path under the read
 * root delegate to {@link RealPushDownFileSystem}; every other path uses the
 * wrapped {@link InMemoryPushDownFileSystem}. Any write or directory creation
 * under the read root throws, so the real bundle is read-only to the test.
 */
export class ReadThroughPushDownFileSystem implements PushDownFileSystem {
  private readonly readRoot: string;
  private readonly real = new RealPushDownFileSystem();

  /**
   * @param readRoot Directory whose real contents are exposed read-only.
   * @param memory In-memory filesystem that receives every other call.
   */
  constructor(
    readRoot: string,
    readonly memory: InMemoryPushDownFileSystem,
  ) {
    this.readRoot = toPosixPath(readRoot).replace(/\/+$/, "");
  }

  private isUnderReadRoot(path: string): boolean {
    const normalized = toPosixPath(path);
    return (
      normalized === this.readRoot || normalized.startsWith(`${this.readRoot}/`)
    );
  }

  private backing(path: string): PushDownFileSystem {
    return this.isUnderReadRoot(path) ? this.real : this.memory;
  }

  private assertWritable(path: string): void {
    if (this.isUnderReadRoot(path)) {
      throw new Error(`Refusing to modify the real bundle at ${path}`);
    }
  }

  listFiles(root: string): string[] {
    return this.backing(root).listFiles(root);
  }

  isDir(path: string): boolean {
    return this.backing(path).isDir(path);
  }

  isFile(path: string): boolean {
    return this.backing(path).isFile(path);
  }

  readTextFile(path: string): string {
    return this.backing(path).readTextFile(path);
  }

  writeTextFile(path: string, content: string): void {
    this.assertWritable(path);
    this.memory.writeTextFile(path, content);
  }

  ensureDir(path: string): void {
    this.assertWritable(path);
    this.memory.ensureDir(path);
  }
}

/** Relative-path operand of `Join-Path`, from the script dir or its parent. */
const PATH_EXPRESSION =
  "Join-Path\\s+(\\$PSScriptRoot|\\(Split-Path\\s+\\$PSScriptRoot\\s+-Parent\\))\\s+'([^']+)'";
const DIRECT_DOT_SOURCE = new RegExp(
  `^\\s*\\.\\s+\\(${PATH_EXPRESSION}\\)\\s*$`,
);
const VARIABLE_ASSIGNMENT = new RegExp(
  `^\\s*(\\$[\\w:]+)\\s*=\\s*${PATH_EXPRESSION}\\s*$`,
);
const VARIABLE_DOT_SOURCE = /^\s*\.\s+(\$[\w:]+)\s*$/;
const HOOK_COMMAND_PATH = /\/(\.codex\/hooks\/[^/"']+\.ps1)/;

/**
 * Resolve a dot-source operand to a bundle-relative POSIX path.
 *
 * @param scriptPath Bundle-relative path of the script holding the line.
 * @param base `$PSScriptRoot` or the `Split-Path ... -Parent` expression.
 * @param relative The quoted `Join-Path` operand.
 * @returns The normalized bundle-relative target path.
 */
function resolveTarget(
  scriptPath: string,
  base: string,
  relative: string,
): string {
  let directory = nodePath.posix.dirname(scriptPath);
  if (base.startsWith("(")) {
    directory = nodePath.posix.dirname(directory);
  }
  return nodePath.posix.normalize(nodePath.posix.join(directory, relative));
}

/**
 * Return the files one script dot-sources, using the same three forms as the
 * Python guard `tests/scripts/dev_tools/test_codex_core_manifest_closure.py`.
 *
 * @param scriptPath Bundle-relative path of the script.
 * @param text Script source text.
 * @returns Bundle-relative dot-source targets.
 */
function dotSourceTargets(scriptPath: string, text: string): string[] {
  const targets: string[] = [];
  const assigned = new Map<string, string>();
  // Walk lines in order so a variable counts only when dot-sourced after
  // its assignment; a variable never dot-sourced is not a dependency.
  for (const line of text.split(/\r?\n/)) {
    const direct = DIRECT_DOT_SOURCE.exec(line);
    if (direct !== null) {
      targets.push(resolveTarget(scriptPath, direct[1] ?? "", direct[2] ?? ""));
      continue;
    }
    const assignment = VARIABLE_ASSIGNMENT.exec(line);
    if (assignment !== null) {
      assigned.set(
        (assignment[1] ?? "").toLowerCase(),
        resolveTarget(scriptPath, assignment[2] ?? "", assignment[3] ?? ""),
      );
      continue;
    }
    const variableSource = VARIABLE_DOT_SOURCE.exec(line);
    const target = assigned.get((variableSource?.[1] ?? "").toLowerCase());
    if (target !== undefined) {
      targets.push(target);
    }
  }
  return targets;
}

/**
 * Return every hook registered by a bundle's `.codex/config.toml` plus the
 * transitive dot-source closure of those hooks, as bundle-relative paths.
 *
 * @param bundleRoot Absolute path of the Codex bundle root.
 * @returns Sorted bundle-relative paths.
 */
export function collectRegisteredHookClosure(bundleRoot: string): string[] {
  const configText = fs.readFileSync(
    nodePath.join(bundleRoot, ".codex", "config.toml"),
    "utf8",
  );
  const pending: string[] = [];
  // Collect every hook script named by a `command` line of any event.
  for (const line of configText.split(/\r?\n/)) {
    const match = /^command\s*=/.test(line)
      ? HOOK_COMMAND_PATH.exec(line)
      : null;
    if (match?.[1] !== undefined) {
      pending.push(match[1]);
    }
  }
  const closure = new Set<string>();
  // Follow dot-source edges until no new file is found.
  for (let path = pending.pop(); path !== undefined; path = pending.pop()) {
    if (closure.has(path)) {
      continue;
    }
    closure.add(path);
    const absolute = nodePath.join(bundleRoot, ...path.split("/"));
    if (fs.existsSync(absolute)) {
      pending.push(
        ...dotSourceTargets(path, fs.readFileSync(absolute, "utf8")),
      );
    }
  }
  return [...closure].sort();
}
