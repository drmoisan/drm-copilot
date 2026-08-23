"use strict";

const { createHash } = require("node:crypto");
const {
  existsSync,
  mkdirSync,
  readFileSync,
  writeFileSync,
} = require("node:fs");
const path = require("node:path");

const BUNDLE_IDENTITY_DEFINE = "__DRM_MCP_BUNDLE_SHA256__";
const BUNDLE_IDENTITY_PLACEHOLDER = `sha256:${"0".repeat(64)}`;

function fail(message) {
  throw new Error(`MCP_BUNDLE_IDENTITY_ERROR: ${message}`);
}

function readPackageVersion(packageJsonPath) {
  const manifest = JSON.parse(readFileSync(packageJsonPath, "utf8"));
  if (typeof manifest.version !== "string" || manifest.version.length === 0) {
    fail(`package manifest '${packageJsonPath}' has no version`);
  }
  return manifest.version;
}

function sha256(bytes) {
  return createHash("sha256").update(bytes).digest("hex");
}

function assertEqualBytes(left, right, description) {
  if (!left.equals(right)) {
    fail(`${description} diverged`);
  }
}

function createVscodeShimPlugin() {
  return {
    name: "vscode-shim",
    setup(build) {
      build.onResolve({ filter: /^vscode$/ }, () => ({
        path: "vscode",
        namespace: "vscode-shim",
      }));
      build.onLoad({ filter: /.*/, namespace: "vscode-shim" }, () => ({
        contents: "module.exports = {};",
        loader: "js",
      }));
    },
  };
}

function readSingleBuildOutput(result) {
  if (!Array.isArray(result.outputFiles) || result.outputFiles.length !== 1) {
    fail("esbuild did not return exactly one executable output");
  }
  return Buffer.from(result.outputFiles[0].contents);
}

function deriveBundleSha256(preliminaryBundle, routingPolicy, packageVersion) {
  const hash = createHash("sha256");
  hash.update("drm-copilot-mcp-bundle-identity-v1\0", "utf8");
  hash.update(preliminaryBundle);
  hash.update("\0routing-policy\0", "utf8");
  hash.update(routingPolicy);
  hash.update("\0package-version\0", "utf8");
  hash.update(packageVersion, "utf8");
  return `sha256:${hash.digest("hex")}`;
}

async function buildInMemory(esbuild, options, bundleSha256) {
  return readSingleBuildOutput(
    await esbuild.build({
      ...options,
      define: {
        [BUNDLE_IDENTITY_DEFINE]: JSON.stringify(bundleSha256),
      },
      write: false,
    }),
  );
}

/**
 * Build one MCP executable from canonical source and embed its deterministic
 * code/resource/package identity.
 */
async function buildMcpServerBundle({
  esbuild,
  repositoryRoot,
  dependencyRoot,
  outputPath,
  compareOutputPath,
}) {
  const extensionManifestPath = path.join(
    repositoryRoot,
    "extensions",
    "drm-copilot",
    "package.json",
  );
  const packageManifestPath = path.join(
    repositoryRoot,
    "packages",
    "mcp-server",
    "package.json",
  );
  const canonicalRoutingPath = path.join(
    repositoryRoot,
    "config",
    "orchestration-routing.json",
  );
  const extensionRoutingPath = path.join(
    repositoryRoot,
    "extensions",
    "drm-copilot",
    "resources",
    "config",
    "orchestration-routing.json",
  );
  const packageRoutingPath = path.join(
    repositoryRoot,
    "packages",
    "mcp-server",
    "resources",
    "config",
    "orchestration-routing.json",
  );
  const extensionVersion = readPackageVersion(extensionManifestPath);
  const packageVersion = readPackageVersion(packageManifestPath);
  if (extensionVersion !== packageVersion) {
    fail(
      `package versions diverged: extension=${extensionVersion}; package=${packageVersion}`,
    );
  }

  const canonicalRouting = readFileSync(canonicalRoutingPath);
  const extensionRouting = readFileSync(extensionRoutingPath);
  assertEqualBytes(
    canonicalRouting,
    extensionRouting,
    "canonical and extension routing policy",
  );
  if (existsSync(packageRoutingPath)) {
    assertEqualBytes(
      canonicalRouting,
      readFileSync(packageRoutingPath),
      "canonical and packaged routing policy",
    );
  }

  const buildOptions = {
    absWorkingDir: repositoryRoot,
    entryPoints: ["extensions/drm-copilot/src/mcp-server.ts"],
    bundle: true,
    platform: "node",
    target: "node18",
    format: "cjs",
    outfile: outputPath,
    allowOverwrite: true,
    banner: { js: "#!/usr/bin/env node" },
    charset: "utf8",
    legalComments: "none",
    logLevel: "silent",
    nodePaths: [path.join(dependencyRoot, "node_modules")],
    plugins: [createVscodeShimPlugin()],
    tsconfig: path.join(
      repositoryRoot,
      "extensions",
      "drm-copilot",
      "tsconfig.json",
    ),
  };
  const preliminaryBundle = await buildInMemory(
    esbuild,
    buildOptions,
    BUNDLE_IDENTITY_PLACEHOLDER,
  );
  const bundleSha256 = deriveBundleSha256(
    preliminaryBundle,
    canonicalRouting,
    packageVersion,
  );
  const finalBundle = await buildInMemory(esbuild, buildOptions, bundleSha256);
  const normalizedBundle = Buffer.from(
    finalBundle
      .toString("utf8")
      .split(bundleSha256)
      .join(BUNDLE_IDENTITY_PLACEHOLDER),
    "utf8",
  );
  assertEqualBytes(
    preliminaryBundle,
    normalizedBundle,
    "normalized executable bundle identity input",
  );
  if (compareOutputPath !== undefined && existsSync(compareOutputPath)) {
    assertEqualBytes(
      finalBundle,
      readFileSync(compareOutputPath),
      "source and package executable bundle identity",
    );
  }

  mkdirSync(path.dirname(outputPath), { recursive: true });
  writeFileSync(outputPath, finalBundle);
  process.stdout.write(`MCP_PACKAGE_VERSION=${packageVersion}\n`);
  process.stdout.write(
    `MCP_ROUTING_POLICY_SHA256=sha256:${sha256(canonicalRouting)}\n`,
  );
  process.stdout.write(`MCP_BUNDLE_SHA256=${bundleSha256}\n`);
}

module.exports = { buildMcpServerBundle };
