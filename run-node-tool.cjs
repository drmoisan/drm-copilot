const cp = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

function getToolSearchRoots(cwd = process.cwd()) {
  return [cwd, path.join(cwd, "extensions", "drm-copilot")];
}

function getNodePathEntries(cwd = process.cwd()) {
  return getToolSearchRoots(cwd)
    .map((root) => path.join(root, "node_modules"))
    .filter((candidate) => fs.existsSync(candidate));
}

function splitPackageRequest(moduleRequest) {
  const parts = moduleRequest.split("/");
  if (parts.length === 0) {
    return undefined;
  }

  if (moduleRequest.startsWith("@")) {
    if (parts.length < 3) {
      return undefined;
    }

    return {
      packageName: parts.slice(0, 2).join("/"),
      packageRelativePath: parts.slice(2).join("/"),
    };
  }

  if (parts.length < 2) {
    return undefined;
  }

  return {
    packageName: parts[0],
    packageRelativePath: parts.slice(1).join("/"),
  };
}

function findPackageRoot(startPath) {
  let currentPath = startPath;
  while (true) {
    const packageJsonPath = path.join(currentPath, "package.json");
    if (fs.existsSync(packageJsonPath)) {
      return currentPath;
    }

    const parentPath = path.dirname(currentPath);
    if (parentPath === currentPath) {
      throw new Error(`Unable to locate package root from '${startPath}'.`);
    }

    currentPath = parentPath;
  }
}

function resolveTool(moduleRequest, cwd = process.cwd()) {
  const searchRoots = getToolSearchRoots(cwd);
  try {
    return require.resolve(moduleRequest, {
      paths: searchRoots,
    });
  } catch (error) {
    if (error?.code !== "ERR_PACKAGE_PATH_NOT_EXPORTED") {
      throw error;
    }

    const requestParts = splitPackageRequest(moduleRequest);
    if (!requestParts) {
      throw error;
    }

    const packageEntryPoint = require.resolve(requestParts.packageName, {
      paths: searchRoots,
    });
    const packageRoot = findPackageRoot(path.dirname(packageEntryPoint));
    const candidatePath = path.join(
      packageRoot,
      requestParts.packageRelativePath,
    );
    if (!fs.existsSync(candidatePath)) {
      throw error;
    }

    return candidatePath;
  }
}

function buildToolEnvironment(cwd = process.cwd()) {
  const nodePathEntries = getNodePathEntries(cwd);
  if (nodePathEntries.length === 0) {
    return process.env;
  }

  return {
    ...process.env,
    NODE_PATH:
      process.env.NODE_PATH && process.env.NODE_PATH.length > 0
        ? `${nodePathEntries.join(path.delimiter)}${path.delimiter}${process.env.NODE_PATH}`
        : nodePathEntries.join(path.delimiter),
  };
}

function runNodeTool(moduleRequest, toolArgs, cwd = process.cwd()) {
  const result = cp.spawnSync(
    process.execPath,
    [resolveTool(moduleRequest, cwd), ...toolArgs],
    {
      stdio: "inherit",
      cwd,
      env: buildToolEnvironment(cwd),
    },
  );

  if (result.error) {
    console.error(result.error);
    return 1;
  }

  return result.status ?? 1;
}

if (require.main === module) {
  const [moduleRequest, ...toolArgs] = process.argv.slice(2);
  if (!moduleRequest) {
    console.error("Expected a module request.");
    process.exit(1);
  }

  process.exit(runNodeTool(moduleRequest, toolArgs));
}

module.exports = {
  buildToolEnvironment,
  resolveTool,
  runNodeTool,
};
