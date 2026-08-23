"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.POSHQC_TEST_PICKER_TITLE = void 0;
exports.promptForPoshQcScanFolders = promptForPoshQcScanFolders;
const vscode = __importStar(require("vscode"));
const file_system_1 = require("./lib/file-system");
const poshqc_scan_config_1 = require("./poshqc-scan-config");
/** Title shown on the PoshQC test scan-folder multi-select QuickPick. */
exports.POSHQC_TEST_PICKER_TITLE = "drm-copilot: Run PoshQC Test";
/** Maximum enumeration depth for candidate workspace folders (folders and subfolders). */
const MAX_ENUMERATION_DEPTH = 2;
/** Message shown when the user confirms an empty selection. */
const EMPTY_SELECTION_MESSAGE = "No folders selected. The PoshQC test run was cancelled and the saved scan configuration was left unchanged.";
/**
 * Directory names excluded from candidate enumeration. This mirrors the
 * `DefaultExcludedDirs` list in `scripts/powershell/PoshQC/PoshQC.psm1`
 * (lines 5-9); keep the two lists in sync.
 */
const EXCLUDED_DIRECTORY_NAMES = new Set([
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
/**
 * Join a workspace-relative folder to the workspace root using forward slashes.
 *
 * @param workspaceRoot Workspace root.
 * @param folder Workspace-relative folder path.
 * @returns The joined POSIX-style path.
 */
function joinWorkspacePath(workspaceRoot, folder) {
    return `${(0, file_system_1.toPosixPath)(workspaceRoot).replace(/\/+$/, "")}/${folder}`;
}
/**
 * Enumerate candidate workspace directories to a bounded depth, excluding the
 * standard directory names shared with the PoshQC PowerShell module.
 *
 * @param fileSystem Injected filesystem seam.
 * @param workspaceRoot Workspace root to enumerate under.
 * @returns Workspace-relative, forward-slash folder paths to depth 2.
 */
function enumerateCandidateFolders(fileSystem, workspaceRoot) {
    const results = [];
    // Depth-first walk collecting directory paths down to MAX_ENUMERATION_DEPTH.
    const walk = (relativePrefix, depth) => {
        if (depth > MAX_ENUMERATION_DEPTH) {
            return;
        }
        const absoluteDir = relativePrefix === ""
            ? workspaceRoot
            : joinWorkspacePath(workspaceRoot, relativePrefix);
        // Inspect each immediate child, keeping directories that are not excluded.
        for (const name of fileSystem.listDirectory(absoluteDir)) {
            if (EXCLUDED_DIRECTORY_NAMES.has(name)) {
                continue;
            }
            const childRelative = relativePrefix === "" ? name : `${relativePrefix}/${name}`;
            if (!fileSystem.isDirectory(joinWorkspacePath(workspaceRoot, childRelative))) {
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
function buildScanFolderItems(fileSystem, workspaceRoot, configFolders) {
    const configuredSet = new Set(configFolders);
    const candidates = enumerateCandidateFolders(fileSystem, workspaceRoot);
    // Union candidate and configured folders so a configured folder is always
    // shown even when enumeration would not produce it.
    const allFolders = Array.from(new Set([...candidates, ...configFolders])).sort((left, right) => left.localeCompare(right));
    return allFolders.map((folder) => {
        const isConfigured = configuredSet.has(folder);
        const exists = fileSystem.isDirectory(joinWorkspacePath(workspaceRoot, folder));
        const item = {
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
async function promptForPoshQcScanFolders(fileSystem, workspaceRoot) {
    const configFolders = (0, poshqc_scan_config_1.readPoshQcScanFolders)(fileSystem, workspaceRoot);
    const items = buildScanFolderItems(fileSystem, workspaceRoot, configFolders);
    const selection = await vscode.window.showQuickPick(items, {
        canPickMany: true,
        ignoreFocusOut: true,
        title: exports.POSHQC_TEST_PICKER_TITLE,
        placeHolder: "Select folders to scan; the checked set is saved to config/poshqc-scan.json.",
    });
    if (selection === undefined) {
        return undefined;
    }
    if (selection.length === 0) {
        await vscode.window.showInformationMessage(EMPTY_SELECTION_MESSAGE);
        return undefined;
    }
    const selectedFolders = (0, poshqc_scan_config_1.canonicalizeFolders)(selection.map((item) => item.folder));
    // Persist the selection before the run so the choice survives a crash mid-run.
    (0, poshqc_scan_config_1.writePoshQcScanFolders)(fileSystem, workspaceRoot, selectedFolders);
    return selectedFolders;
}
