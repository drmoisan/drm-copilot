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
 * Excludes any Python file and any entry under a `scripts/` path segment so no
 * Python ships with the MCP server. Every other path is copied, preserving the
 * PowerShell and customization-data payloads.
 *
 * @param {string} source Absolute source path being considered by cpSync.
 * @returns {boolean} True to copy the path; false to skip it.
 */
function shouldCopy(source) {
  // Normalize to forward slashes so segment matching is OS-neutral.
  const normalized = source.replace(/\\/g, "/");

  // Skip Python source files regardless of where they appear in the tree.
  if (normalized.endsWith(".py")) {
    return false;
  }

  // Skip the bundled scripts subtree (the directory and anything beneath it).
  // Match a `/scripts` segment at the resources root or a nested `/scripts/`.
  if (/(^|\/)scripts(\/|$)/.test(normalized)) {
    return false;
  }

  return true;
}

cpSync(SOURCE_DIR, DESTINATION_DIR, {
  recursive: true,
  force: true,
  filter: shouldCopy,
});
