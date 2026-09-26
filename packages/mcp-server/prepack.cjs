"use strict";

// Copy the extension's bundled resources into the MCP-server package for
// packaging, excluding all Python. After F11 removed the dead Python bridge and
// bundled Python, the standalone MCP server must not ship any `.py` file or the
// (removed) bundled `scripts/` subtree. Non-Python payloads (PowerShell
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

/**
 * Decide whether a source path should be copied into the packaged resources.
 *
 * Excludes any Python file at any depth, and the resources-root `scripts/`
 * subtree (the removed bundled Python tree). The exclusion is anchored at the
 * resources root, so nested `scripts` directories such as the Codex bundle's
 * `.codex/scripts` PowerShell wrappers are still copied. Every other path is
 * copied, preserving the PowerShell and customization-data payloads.
 *
 * @param {string} source Absolute source path being considered by cpSync.
 * @returns {boolean} True to copy the path; false to skip it.
 */
function shouldCopy(source) {
  // Skip Python source files regardless of where they appear in the tree.
  if (source.replace(/\\/g, "/").endsWith(".py")) {
    return false;
  }

  // Skip only the resources-root scripts subtree (the directory itself and
  // anything beneath it), comparing the root-relative path in POSIX form.
  const relative = path.relative(SOURCE_DIR, source).replace(/\\/g, "/");
  if (relative === "scripts" || relative.startsWith("scripts/")) {
    return false;
  }

  return true;
}

module.exports = { SOURCE_DIR, shouldCopy };

// Copy only when run as `node prepack.cjs` (the package prepack script), so a
// test can require this module without copying anything.
if (require.main === module) {
  cpSync(SOURCE_DIR, DESTINATION_DIR, {
    recursive: true,
    force: true,
    filter: shouldCopy,
  });
}
