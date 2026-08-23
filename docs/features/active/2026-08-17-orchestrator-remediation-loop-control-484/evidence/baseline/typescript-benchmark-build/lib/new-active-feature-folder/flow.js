"use strict";
/**
 * Orchestration flow for active feature folder creation.
 *
 * Purpose:
 *     Direct TypeScript port of the bundled
 *     `dev_tools/new_active_feature_folder_flow.py` `create_active_folder`. The
 *     CLI `parse_args`/`main` entrypoint is intentionally NOT ported; the
 *     service supplies typed inputs directly.
 *
 * Parity:
 *     The control flow, every emitted line, and every error message are
 *     byte-identical to the Python source. All I/O flows through the injected
 *     {@link FolderFileSystem}, issue fetcher, and code launcher seams.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.createActiveFolder = createActiveFolder;
const prompt_mode_contract_1 = require("../prompt-mode-contract");
const subprocess_runner_1 = require("../subprocess-runner");
const file_system_1 = require("../file-system");
const models_1 = require("./models");
const markdown_1 = require("./markdown");
const io_1 = require("./io");
const docs_1 = require("./docs");
/** The feature types accepted by {@link createActiveFolder}. */
const VALID_FEATURE_TYPES = new Set(["feature", "refactor", "epic", "bug"]);
/**
 * Create and seed an active feature folder from templates and potential docs.
 *
 * Reproduces the Python `create_active_folder` control flow exactly (validate
 * type, resolve feature name, resolve template dir, find potential file, route
 * minor-audit vs full docs, materialize plan, move potential file, emit status
 * lines, optionally launch the editor) and returns the created folder path and
 * the moved `issue.md` path when applicable.
 *
 * @param options Inputs and injectable seams.
 * @returns The active-folder result (target dir + optional issue.md path).
 * @throws Error On an invalid type, an unresolvable feature name, a missing
 *   template folder, an existing target without `force`, or an invalid work
 *   mode (each message byte-identical to the Python source).
 */
function createActiveFolder(options) {
    const featureType = options.featureType ?? "feature";
    const force = options.force ?? false;
    const workMode = options.workMode ?? "full";
    const emit = options.emit ?? (() => undefined);
    // Validate the feature type before any work occurs.
    if (!VALID_FEATURE_TYPES.has(featureType)) {
        throw new Error("Type must be one of: feature, refactor, epic, bug");
    }
    const workspacePath = options.workspace ?? (0, models_1.resolveWorkspace)();
    const filesystem = options.fs ?? new models_1.RealFolderFileSystem();
    const issueFetcher = options.issueFetcher ??
        ((issueNumber) => (0, io_1.defaultIssueFetcher)(issueNumber, new subprocess_runner_1.SubprocessRunner()));
    const codeLauncher = options.codeLauncher ?? io_1.defaultCodeLauncher;
    let resolvedFeatureName = options.featureName;
    let featureNameSource = "manual";
    // When an active-file path is supplied, resolve the feature name from its
    // stem after validating it is a .md file under docs/features/potential/promoted.
    if (options.activeFileForFeatureName !== undefined &&
        options.activeFileForFeatureName !== null) {
        const autoResolveError = "Select a promoted issue markdown file under " +
            "docs/features/potential/promoted or supply --feature-name directly.";
        let activeFilePath = (0, file_system_1.toPosixPath)(options.activeFileForFeatureName);
        if (!isAbsolutePosix(activeFilePath)) {
            activeFilePath = (0, models_1.joinPosix)(workspacePath, activeFilePath);
        }
        const promotedRoot = (0, models_1.joinPosix)(workspacePath, "docs/features/potential/promoted");
        const isInPromoted = isRelativeTo(activeFilePath, promotedRoot);
        // Reject when the suffix is not .md, the path is outside promoted, or the
        // file does not exist; all three are the same auto-resolve failure.
        if (!activeFilePath.toLowerCase().endsWith(".md") ||
            !isInPromoted ||
            !filesystem.exists(activeFilePath)) {
            throw new Error(autoResolveError);
        }
        resolvedFeatureName = posixStem(activeFilePath);
        featureNameSource = "active-file";
    }
    if (!resolvedFeatureName) {
        throw new Error("feature_name must be provided when " +
            "--active-file-for-feature-name is not used");
    }
    (0, models_1.validateFeatureName)(resolvedFeatureName);
    emit(`Feature name source: ${featureNameSource}`);
    // Resolve the template directory from the bundled template root when
    // provided, otherwise fall back to the workspace docs/features/templates tree.
    const templateDir = options.templateRoot !== undefined && options.templateRoot !== null
        ? (0, models_1.joinPosix)(options.templateRoot, featureType)
        : (0, models_1.joinPosix)(workspacePath, `docs/features/templates/${featureType}`);
    if (!filesystem.exists(templateDir)) {
        throw new Error(`Template folder not found: ${templateDir}`);
    }
    const potentialFile = (0, io_1.findPotentialFile)(resolvedFeatureName, workspacePath, filesystem);
    const potentialContent = potentialFile
        ? filesystem.readText(potentialFile)
        : "";
    const selectedWorkMode = (0, prompt_mode_contract_1.normalizeRequestedWorkMode)(workMode, featureType);
    const [useMinorAudit, fallbackReason] = (0, docs_1.shouldUseMinorAuditMode)(selectedWorkMode, featureType, potentialContent);
    // Normalize the issue number: blank -> null; "auto" -> null; fall back to the
    // potential file's parsed Issue line when still unset.
    let normalizedIssueNumber = (options.issueNumber ?? "").trim() || null;
    if (normalizedIssueNumber && normalizedIssueNumber.toLowerCase() === "auto") {
        normalizedIssueNumber = null;
    }
    if (!normalizedIssueNumber) {
        normalizedIssueNumber = (0, io_1.parseIssueNumber)(potentialContent);
    }
    // Epic scaffolding uses a single stable home under docs/features/epics/ keyed
    // by the bare epic slug, not the date/issue-stamped active-folder basename;
    // this is the single-home layout. All other types keep active/<folder-slug>.
    let targetDir;
    if (featureType === "epic") {
        const epicSlug = (0, io_1.buildFolderSlug)(resolvedFeatureName, null, null);
        targetDir = (0, models_1.joinPosix)(workspacePath, `docs/features/epics/${epicSlug}`);
    }
    else {
        const folderSlug = (0, io_1.buildFolderSlug)(resolvedFeatureName, potentialFile, normalizedIssueNumber);
        targetDir = (0, models_1.joinPosix)(workspacePath, `docs/features/active/${folderSlug}`);
    }
    if (filesystem.exists(targetDir) && !force) {
        throw new Error(`Target exists: ${targetDir}. Re-run with --force to overwrite.`);
    }
    filesystem.ensureDir(targetDir);
    // Minor-audit only copies the plan template; full flows copy the full tree
    // (or the selective bug template set).
    if (useMinorAudit) {
        (0, io_1.copyFeatureTemplateForMinorAudit)(templateDir, targetDir, filesystem);
    }
    else {
        (0, io_1.copyTemplate)(featureType, templateDir, targetDir, filesystem);
    }
    let issueMeta = null;
    if (normalizedIssueNumber) {
        issueMeta = issueFetcher(normalizedIssueNumber);
    }
    let issueField = normalizedIssueNumber ? `#${normalizedIssueNumber}` : "TBD";
    if (issueMeta) {
        issueField = `#${issueMeta.number}`;
    }
    const ownerField = issueMeta ? issueMeta.author : "TBD";
    const parentField = "none";
    const statusField = "Draft";
    const versionField = "0.1";
    const planTimestamp = (0, models_1.getEstTimestamp)(options.nowProvider);
    const updatedField = planTimestamp;
    const planPath = (0, io_1.materializePlanFile)(featureType, targetDir, resolvedFeatureName, issueField, ownerField, parentField, statusField, versionField, planTimestamp, filesystem);
    const planUpdatedField = planTimestamp;
    // Extract every seedable section from the potential content using the exact
    // heading strings from the Python source.
    const sections = {
        problem: (0, markdown_1.getSection)(potentialContent, "Problem / Why"),
        behavior: (0, markdown_1.getSection)(potentialContent, "Proposed Behavior"),
        criteria: (0, markdown_1.getSection)(potentialContent, "Acceptance Criteria (early draft)"),
        constraints: (0, markdown_1.getSection)(potentialContent, "Constraints & Risks"),
        tests: (0, markdown_1.getSection)(potentialContent, "Test Conditions to Consider"),
        bug_summary: (0, markdown_1.getSection)(potentialContent, "Summary"),
        bug_environment: (0, markdown_1.getSection)(potentialContent, "Environment"),
        bug_steps: (0, markdown_1.getSection)(potentialContent, "Steps to Reproduce"),
        bug_expected: (0, markdown_1.getSection)(potentialContent, "Expected Behavior"),
        bug_actual: (0, markdown_1.getSection)(potentialContent, "Actual Behavior"),
        bug_logs: (0, markdown_1.getSection)(potentialContent, "Logs / Screenshots"),
        bug_impact: (0, markdown_1.getSection)(potentialContent, "Impact / Severity"),
        bug_cause: (0, markdown_1.getSection)(potentialContent, "Suspected Cause / Notes"),
        bug_validation: (0, markdown_1.getSection)(potentialContent, "Proposed Fix / Validation Ideas"),
    };
    let filesToOpen;
    let potentialIssuePath = null;
    // Minor-audit routing: either move an existing potential file to issue.md with
    // the minor-audit marker, or write the verbatim no-potential issue.md body.
    if (useMinorAudit) {
        if (potentialFile) {
            potentialIssuePath = (0, models_1.joinPosix)(targetDir, "issue.md");
            filesystem.move(potentialFile, potentialIssuePath);
            const movedContent = filesystem.readText(potentialIssuePath);
            filesystem.writeText(potentialIssuePath, (0, markdown_1.upsertWorkModeMarker)(movedContent, "minor-audit"));
            filesToOpen = [potentialIssuePath];
        }
        else {
            const issueDoc = (0, models_1.joinPosix)(targetDir, "issue.md");
            const issueBody = [
                `# ${resolvedFeatureName}`,
                "",
                "- Work Mode: minor-audit",
                "## Problem / Why",
                sections["problem"] || "(not provided in potential file)",
                "",
                "## Implementation Intent",
                sections["behavior"] || "(not provided in potential file)",
                "",
                "## Acceptance Criteria",
                sections["criteria"] || "(not provided in potential file)",
                "",
                "## Dependencies / Risks",
                sections["constraints"] || "(not provided in potential file)",
                "",
                "## Verification Steps",
                sections["tests"] || "(not provided in potential file)",
                "",
                "## Evidence Checklist",
                "- [ ] baseline",
                "- [ ] targeted verification",
                "- [ ] end-state",
            ].join("\n");
            filesystem.writeText(issueDoc, issueBody);
            filesToOpen = [issueDoc];
        }
    }
    else {
        filesToOpen = (0, docs_1.updateFeatureDocs)(featureType, resolvedFeatureName, targetDir, issueField, ownerField, updatedField, parentField, statusField, versionField, planUpdatedField, filesystem, sections, planPath);
    }
    // Potential-file move + marker for the FULL path (the minor-audit path moved
    // it already and only emits the moved-file line).
    if (potentialFile) {
        if (useMinorAudit) {
            if (potentialIssuePath !== null) {
                emit(`Moved potential file to ${potentialIssuePath}`);
            }
        }
        else {
            potentialIssuePath = (0, models_1.joinPosix)(targetDir, "issue.md");
            filesystem.move(potentialFile, potentialIssuePath);
            const movedContent = filesystem.readText(potentialIssuePath);
            filesystem.writeText(potentialIssuePath, (0, markdown_1.upsertWorkModeMarker)(movedContent, selectedWorkMode));
            emit(`Moved potential file to ${potentialIssuePath}`);
        }
    }
    if (potentialFile) {
        emit(`Seeded docs from potential: ${posixBaseName(potentialFile)}`);
    }
    emit(`Selected mode: ${useMinorAudit ? "minor-audit" : selectedWorkMode}`);
    // The Python should_use_minor_audit_mode always returns "" for the reason, so
    // this line is never emitted; the variable is kept for parity.
    if (fallbackReason) {
        emit(`Fallback reason: ${fallbackReason}`);
    }
    // Launch the editor on the existing target files (plus the moved issue.md);
    // when no editor resolves, emit the manual-open warning lines instead.
    if (filesToOpen.length > 0) {
        const existing = filesToOpen.filter((path) => filesystem.exists(path));
        if (potentialIssuePath) {
            existing.push(potentialIssuePath);
        }
        if (existing.length > 0) {
            const opened = codeLauncher(existing);
            if (!opened) {
                emit("VS Code 'code' command not found. Files to edit:");
                for (const path of existing) {
                    emit(`  ${path}`);
                }
            }
        }
    }
    emit(`Created/updated: ${targetDir}`);
    return {
        target: targetDir,
        potentialIssuePath: potentialIssuePath ?? null,
    };
}
/**
 * Return whether a forward-slash path is absolute.
 *
 * Treats POSIX-rooted (`/foo`) and Windows-rooted (`C:/foo`) paths as absolute.
 *
 * @param path Forward-slash path.
 * @returns True when the path is absolute.
 */
function isAbsolutePosix(path) {
    return path.startsWith("/") || /^[A-Za-z]:\//.test(path);
}
/**
 * Return whether `child` is the same as or nested under `root`.
 *
 * Mirrors Python `Path.relative_to` used as a containment check.
 *
 * @param child Candidate descendant path.
 * @param root Ancestor path.
 * @returns True when `child` equals `root` or is under it.
 */
function isRelativeTo(child, root) {
    const normalizedChild = (0, file_system_1.toPosixPath)(child);
    const normalizedRoot = (0, file_system_1.toPosixPath)(root);
    return (normalizedChild === normalizedRoot ||
        normalizedChild.startsWith(`${normalizedRoot}/`));
}
/**
 * Return the final path segment of a forward-slash path.
 *
 * @param path Forward-slash path.
 * @returns The basename.
 */
function posixBaseName(path) {
    const normalized = (0, file_system_1.toPosixPath)(path).replace(/\/+$/, "");
    const slash = normalized.lastIndexOf("/");
    return slash === -1 ? normalized : normalized.slice(slash + 1);
}
/**
 * Return the file stem (basename without the final suffix).
 *
 * @param path Forward-slash path.
 * @returns The stem.
 */
function posixStem(path) {
    const name = posixBaseName(path);
    const dot = name.lastIndexOf(".");
    return dot <= 0 ? name : name.slice(0, dot);
}
