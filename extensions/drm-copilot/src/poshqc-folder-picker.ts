import * as vscode from "vscode";
import type { FileSystem } from "./lib/file-system";
import { toPosixPath } from "./lib/file-system";
import {
  canonicalizeFolders,
  readPoshQcScanFolders,
  writePoshQcScanFolders,
} from "./poshqc-scan-config";

/** Title shown on the PoshQC test scan-folder multi-select QuickPick. */
export const POSHQC_TEST_PICKER_TITLE = "drm-copilot: Run PoshQC Test";

/** Maximum enumeration depth for candidate workspace folders (folders and subfolders). */
const MAX_ENUMERATION_DEPTH = 2;

/** Message shown when the user confirms an empty selection. */
const EMPTY_SELECTION_MESSAGE =
  "No folders selected. The PoshQC test run was cancelled and the saved scan configuration was left unchanged.";

/**
 * Directory names excluded from candidate enumeration. This mirrors the
 * `DefaultExcludedDirs` list in `scripts/powershell/PoshQC/PoshQC.psm1`
 * (lines 5-9); keep the two lists in sync.
 */
const EXCLUDED_DIRECTORY_NAMES = new Set<string>([
  ".git",
  ".venv",
  "venv",
  "node_modules",
  "dist",
  "build",
  ".pytest_cache",
  "__pycache__",
  ".mypy_cache",
  ".ruff_cache",
  ".vscode",
  ".idea",
  "artifacts",
  ".vscode-test",
]);

/** A QuickPick item that carries its workspace-relative folder path. */
interface ScanFolderQuickPickItem extends vscode.QuickPickItem {
  readonly folder: string;
}

/**
 * Join a workspace-relative folder to the workspace root using forward slashes.
 *
 * @param workspaceRoot Workspace root.
 * @param folder Workspace-relative folder path.
 * @returns The joined POSIX-style path.
 */
function joinWorkspacePath(workspaceRoot: string, folder: string): string {
  return `${toPosixPath(workspaceRoot).replace(/\/+$/, "")}/${folder}`;
}

/**
 * Enumerate candidate workspace directories to a bounded depth, excluding the
 * standard directory names shared with the PoshQC PowerShell module.
 *
 * @param fileSystem Injected filesystem seam.
 * @param workspaceRoot Workspace root to enumerate under.
 * @returns Workspace-relative, forward-slash folder paths to depth 2.
 */
function enumerateCandidateFolders(
  fileSystem: FileSystem,
  workspaceRoot: string,
): string[] {
  const results: string[] = [];

  // Depth-first walk collecting directory paths down to MAX_ENUMERATION_DEPTH.
  const walk = (relativePrefix: string, depth: number): void => {
    if (depth > MAX_ENUMERATION_DEPTH) {
      return;
    }
    const absoluteDir =
      relativePrefix === ""
        ? workspaceRoot
        : joinWorkspacePath(workspaceRoot, relativePrefix);
    // Inspect each immediate child, keeping directories that are not excluded.
    for (const name of fileSystem.listDirectory(absoluteDir)) {
      if (EXCLUDED_DIRECTORY_NAMES.has(name)) {
        continue;
      }
      const childRelative =
        relativePrefix === "" ? name : `${relativePrefix}/${name}`;
      if (
        !fileSystem.isDirectory(joinWorkspacePath(workspaceRoot, childRelative))
      ) {
        continue;
      }
      results.push(childRelative);
      walk(childRelative, depth + 1);
    }
  };

  walk("", 1);
  return results;
}

/**
 * Build the seeded QuickPick items: the union of enumerated candidate folders
 * and the configured folders, sorted, with configured folders pre-checked and
 * configured-but-missing folders marked with a warning.
 *
 * @param fileSystem Injected filesystem seam.
 * @param workspaceRoot Workspace root.
 * @param configFolders The persisted, canonical scan-folder list.
 * @returns The QuickPick items to display.
 */
function buildScanFolderItems(
  fileSystem: FileSystem,
  workspaceRoot: string,
  configFolders: readonly string[],
): ScanFolderQuickPickItem[] {
  const configuredSet = new Set(configFolders);
  const candidates = enumerateCandidateFolders(fileSystem, workspaceRoot);
  // Union candidate and configured folders so a configured folder is always
  // shown even when enumeration would not produce it.
  const allFolders = Array.from(
    new Set<string>([...candidates, ...configFolders]),
  ).sort((left, right) => left.localeCompare(right));

  return allFolders.map((folder) => {
    const isConfigured = configuredSet.has(folder);
    const exists = fileSystem.isDirectory(
      joinWorkspacePath(workspaceRoot, folder),
    );
    const item: ScanFolderQuickPickItem = {
      label: folder,
      folder,
      picked: isConfigured,
    };
    // A configured folder that no longer exists is marked, not dropped.
    if (isConfigured && !exists) {
      return { ...item, description: "$(warning) folder no longer exists" };
    }
    return item;
  });
}

/**
 * Prompt the user to select scan folders via a seeded multi-select QuickPick,
 * persisting an accepted non-empty selection to `config/poshqc-scan.json` before
 * returning it.
 *
 * Behavior:
 *     - Cancel (`undefined`): no persistence, no run — returns `undefined`.
 *     - Accept with an empty selection: show an information message and abort
 *       without persisting — returns `undefined`.
 *     - Accept with a non-empty selection: persist the canonical selection
 *       (workspace-relative, forward-slash, deduplicated, sorted) before
 *       returning it, so the write survives a crash mid-run.
 *
 * @param fileSystem Injected filesystem seam (in-memory fake in tests).
 * @param workspaceRoot Workspace root the scan folders resolve against.
 * @returns The persisted, canonical selected folders, or `undefined` on cancel
 *   or empty selection.
 */
export async function promptForPoshQcScanFolders(
  fileSystem: FileSystem,
  workspaceRoot: string,
): Promise<string[] | undefined> {
  const configFolders = readPoshQcScanFolders(fileSystem, workspaceRoot);
  const items = buildScanFolderItems(fileSystem, workspaceRoot, configFolders);

  const selection = await vscode.window.showQuickPick(items, {
    canPickMany: true,
    ignoreFocusOut: true,
    title: POSHQC_TEST_PICKER_TITLE,
    placeHolder:
      "Select folders to scan; the checked set is saved to config/poshqc-scan.json.",
  });

  if (selection === undefined) {
    return undefined;
  }
  if (selection.length === 0) {
    await vscode.window.showInformationMessage(EMPTY_SELECTION_MESSAGE);
    return undefined;
  }

  const selectedFolders = canonicalizeFolders(
    selection.map((item) => item.folder),
  );
  // Persist the selection before the run so the choice survives a crash mid-run.
  writePoshQcScanFolders(fileSystem, workspaceRoot, selectedFolders);
  return selectedFolders;
}
