"use strict";

// Synchronize the extension's bundled resources into the MCP-server package,
// excluding only Python and the removed top-level resources/scripts subtree.

const { createHash } = require("node:crypto");
const {
  cpSync,
  existsSync,
  readFileSync,
  readdirSync,
  rmSync,
  statSync,
} = require("node:fs");
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
const CANONICAL_ROUTING_PATH = path.join(
  __dirname,
  "..",
  "..",
  "config",
  "orchestration-routing.json",
);
const EXTENSION_ROUTING_PATH = path.join(
  SOURCE_DIR,
  "config",
  "orchestration-routing.json",
);
const REQUIRED_CUSTOMIZATION_DIRS = [
  "claude-customizations",
  "claude-dir-customizations",
  "codex-and-agents-customizations",
  "customizations",
];

function fail(message) {
  throw new Error(`MCP_PREPACK_RESOURCE_ERROR: ${message}`);
}

function requireDirectory(directoryPath, description) {
  if (!existsSync(directoryPath) || !statSync(directoryPath).isDirectory()) {
    fail(`missing ${description} directory '${directoryPath}'`);
  }
}

function requireFile(filePath, description) {
  if (!existsSync(filePath) || !statSync(filePath).isFile()) {
    fail(`missing ${description} file '${filePath}'`);
  }
}

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
  const relative = path.relative(SOURCE_DIR, source);
  if (relative.toLowerCase().endsWith(".py")) {
    return false;
  }
  if (relative === "scripts" || relative.startsWith(`scripts${path.sep}`)) {
    return false;
  }
  return true;
}

function inventoryFiles(root, applySourceFilter) {
  const files = [];
  function visit(directory) {
    for (const entry of readdirSync(directory, { withFileTypes: true }).sort(
      (left, right) => left.name.localeCompare(right.name),
    )) {
      const entryPath = path.join(directory, entry.name);
      if (applySourceFilter && !shouldCopy(entryPath)) {
        continue;
      }
      if (entry.isDirectory()) {
        visit(entryPath);
      } else if (entry.isFile()) {
        files.push(path.relative(root, entryPath).replace(/\\/g, "/"));
      }
    }
  }
  visit(root);
  return files;
}

function assertEqualBytes(leftPath, rightPath, description) {
  if (!readFileSync(leftPath).equals(readFileSync(rightPath))) {
    fail(`${description} diverged`);
  }
}

requireDirectory(SOURCE_DIR, "extension resource source");
requireFile(CANONICAL_ROUTING_PATH, "canonical routing policy");
requireFile(EXTENSION_ROUTING_PATH, "extension routing policy");
assertEqualBytes(
  CANONICAL_ROUTING_PATH,
  EXTENSION_ROUTING_PATH,
  "canonical and extension routing policy",
);
for (const relativeDirectory of REQUIRED_CUSTOMIZATION_DIRS) {
  requireDirectory(
    path.join(SOURCE_DIR, relativeDirectory),
    `customization '${relativeDirectory}'`,
  );
}

const resolvedDestination = path.resolve(DESTINATION_DIR);
if (
  resolvedDestination !== path.resolve(__dirname, "resources") ||
  path.dirname(resolvedDestination) !== path.resolve(__dirname)
) {
  fail(`unsafe destination '${resolvedDestination}'`);
}
rmSync(resolvedDestination, { recursive: true, force: true });

cpSync(SOURCE_DIR, DESTINATION_DIR, {
  recursive: true,
  force: true,
  filter: shouldCopy,
});

const sourceInventory = inventoryFiles(SOURCE_DIR, true);
const destinationInventory = inventoryFiles(DESTINATION_DIR, false);
if (JSON.stringify(sourceInventory) !== JSON.stringify(destinationInventory)) {
  fail("source and packaged resource inventories diverged");
}
for (const relativePath of sourceInventory) {
  assertEqualBytes(
    path.join(SOURCE_DIR, relativePath),
    path.join(DESTINATION_DIR, relativePath),
    `resource '${relativePath}'`,
  );
}
const routingSha256 = createHash("sha256")
  .update(readFileSync(CANONICAL_ROUTING_PATH))
  .digest("hex");
process.stdout.write(`MCP_RESOURCE_COUNT=${sourceInventory.length}\n`);
process.stdout.write(`MCP_ROUTING_POLICY_SHA256=sha256:${routingSha256}\n`);
