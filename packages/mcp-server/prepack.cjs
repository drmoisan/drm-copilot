"use strict";

// Copy the extension's bundled resources into the MCP-server package for
// packaging, excluding Python. After F11 removed the dead Python bridge and
// bundled Python, the standalone MCP server ships no `.py` file and no
// (removed) bundled `scripts/` subtree, except the Python-native documentation
// analyzer helper of issue #1031 under the Claude docs library, which ships in
// the python pack; bytecode and `__pycache__` directories are never copied. Non-Python payloads (PowerShell
// wrappers, policy_audit assets, the PoshQC tree, and the customization data
// payloads) are still copied so the server's commands keep working.

const { cpSync } = require("node:fs");
const path = require("node:path");

const SOURCE_DIR = path.join(
  __dirname,
  "..",
  "..",
  "extensions",
  "drm-copilot",
  "resources",
);
const DESTINATION_DIR = path.join(__dirname, "resources");
// The only Python source copied: the issue #1031 helper, relative to SOURCE_DIR.
const PYTHON_HELPER_PREFIX = "claude-customizations/.claude/lib/docs/python/";

/**
 * Decide whether a source path should be copied into the packaged resources.
 *
 * Excludes every `__pycache__` path and every `.pyc` and `.pyo` file, every
 * Python file at any depth except those under PYTHON_HELPER_PREFIX, and the
 * resources-root `scripts/` subtree (the removed bundled Python tree). The exclusion is anchored at the
 * resources root, so nested `scripts` directories such as the Codex bundle's
 * `.codex/scripts` PowerShell wrappers are still copied. Every other path is
 * copied, preserving the PowerShell and customization-data payloads.
 *
 * @param {string} source Absolute source path being considered by cpSync.
 * @returns {boolean} True to copy the path; false to skip it.
 */
function shouldCopy(source) {
  const posix = source.replace(/\\/g, "/");
  const relative = path.relative(SOURCE_DIR, source).replace(/\\/g, "/");

  // Never copy bytecode or a __pycache__ directory, at any depth.
  if (
    posix.split("/").includes("__pycache__") ||
    posix.endsWith(".pyc") ||
    posix.endsWith(".pyo")
  ) {
    return false;
  }

  // Skip Python source files except the issue #1031 docs helper.
  if (posix.endsWith(".py")) {
    return relative.startsWith(PYTHON_HELPER_PREFIX);
  }

  // Skip only the resources-root scripts subtree (the directory itself and
  // anything beneath it), comparing the root-relative path in POSIX form.
  if (relative === "scripts" || relative.startsWith("scripts/")) {
    return false;
  }

  return true;
}

module.exports = { SOURCE_DIR, PYTHON_HELPER_PREFIX, shouldCopy };

// Copy only when run as `node prepack.cjs` (the package prepack script), so a
// test can require this module without copying anything.
if (require.main === module) {
  cpSync(SOURCE_DIR, DESTINATION_DIR, {
    recursive: true,
    force: true,
    filter: shouldCopy,
  });
}
