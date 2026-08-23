"use strict";
/**
 * Engine half of the Copilot customization push-down publisher.
 *
 * Purpose:
 *     Port the orchestration core of `push_down_copilot_customizations.py`:
 *     deterministic source enumeration, destination validation, summary-artifact
 *     naming and rendering, and the copy/rewrite loop. The public CLI-facing
 *     surface lives in `copilot-customizations.ts`; this module holds the engine
 *     so each file stays within the 500-line limit.
 *
 * Responsibilities:
 *     - Enumerate scoped source files in root-order then path-order.
 *     - Validate the destination (missing dir / destination-equals-source).
 *     - Build the deterministic JSON artifact path.
 *     - Render the summary as 2-space, sorted-key JSON.
 *     - Run the copy/rewrite loop and accumulate counts and unmatched refs.
 *
 * Side effects:
 *     Reads source files and writes destination files plus the summary artifact
 *     through the injected {@link PushDownFileSystem}.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.COPILOT_ROOT_FOLDERS = exports.ARTIFACT_DIRECTORY = void 0;
exports.enumerateSourceFiles = enumerateSourceFiles;
exports.validateDestination = validateDestination;
exports.buildArtifactPath = buildArtifactPath;
exports.renderPushDownSummary = renderPushDownSummary;
exports.writeSummaryArtifact = writeSummaryArtifact;
exports.pushDownCustomizations = pushDownCustomizations;
const filesystem_adapter_1 = require("./filesystem-adapter");
const reference_rewrites_1 = require("./reference-rewrites");
/** Default artifact directory for the Copilot push-down summary. */
exports.ARTIFACT_DIRECTORY = "artifacts/copilot-customizations";
/**
 * Inlined `agentic_sync.ROOT_FOLDERS` (copilot). The Python source imports
 * these scoped `.github` roots; the port inlines the typed tuple so no Python
 * dependency remains. Order is the enumeration contract.
 */
exports.COPILOT_ROOT_FOLDERS = [
    ".github/agents",
    ".github/instructions",
    ".github/prompts",
    ".github/skills",
];
/**
 * Join a root and relative path using forward-slash separators.
 *
 * @param root Base path.
 * @param relative Path relative to the base.
 * @returns The combined POSIX-style path.
 */
function joinPosix(root, relative) {
    const normalizedRoot = (0, filesystem_adapter_1.toPosixPath)(root).replace(/\/+$/, "");
    const normalizedRelative = (0, filesystem_adapter_1.toPosixPath)(relative).replace(/^\/+/, "");
    if (normalizedRoot === "") {
        return normalizedRelative;
    }
    if (normalizedRelative === "") {
        return normalizedRoot;
    }
    return `${normalizedRoot}/${normalizedRelative}`;
}
/**
 * Return the POSIX path relative to a root, or null when not under the root.
 *
 * Mirrors Python `Path.relative_to` containment semantics on normalized POSIX
 * strings so the port stays host-independent and hermetic.
 *
 * @param path Candidate child POSIX path.
 * @param root Candidate parent POSIX path.
 * @returns The relative POSIX path, or `null` when `path` is not under `root`.
 */
function relativeToPosix(path, root) {
    const normalizedPath = (0, filesystem_adapter_1.toPosixPath)(path).replace(/\/+$/, "");
    const normalizedRoot = (0, filesystem_adapter_1.toPosixPath)(root).replace(/\/+$/, "");
    if (normalizedPath === normalizedRoot) {
        return "";
    }
    const prefix = `${normalizedRoot}/`;
    if (normalizedPath.startsWith(prefix)) {
        return normalizedPath.slice(prefix.length);
    }
    return null;
}
/**
 * Enumerate scoped source files in deterministic root and path order.
 *
 * Preserves the `rootFolders` ordering contract while keeping file order stable
 * within each scoped root (sorted by the path relative to that root).
 *
 * @param fs Filesystem adapter.
 * @param sourceRoot Effective source root to enumerate from.
 * @param rootFolders Ordered scoped roots.
 * @returns Ordered source file POSIX paths.
 */
function enumerateSourceFiles(fs, sourceRoot, rootFolders) {
    const orderedFiles = [];
    // Enumerate by scoped root first so summaries match the feature contract; the
    // per-root files are sorted by their root-relative POSIX path for stability.
    for (const root of rootFolders) {
        const rootPath = joinPosix(sourceRoot, root);
        const rootFiles = fs.listFiles(rootPath);
        const sorted = [...rootFiles].sort((left, right) => {
            const leftRel = relativeToPosix(left, rootPath) ?? left;
            const rightRel = relativeToPosix(right, rootPath) ?? right;
            return leftRel < rightRel ? -1 : leftRel > rightRel ? 1 : 0;
        });
        orderedFiles.push(...sorted);
    }
    return orderedFiles;
}
/**
 * Validate the destination before any copy action begins.
 *
 * @param destinationRoot Destination workspace root POSIX path.
 * @param repoRoot Source repository root POSIX path.
 * @param fs Filesystem adapter.
 * @throws Error When the destination is missing or equals the source repo root.
 */
function validateDestination(destinationRoot, repoRoot, fs) {
    if (!fs.isDir(destinationRoot)) {
        throw new Error(`Invalid destination: destination directory does not exist: ${destinationRoot}`);
    }
    // Compare normalized POSIX paths so the destination-equals-source guard is
    // host-independent (Python compares resolved paths).
    if ((0, filesystem_adapter_1.toPosixPath)(destinationRoot).replace(/\/+$/, "") ===
        (0, filesystem_adapter_1.toPosixPath)(repoRoot).replace(/\/+$/, "")) {
        throw new Error(`Invalid destination: destination must not be the source repository root: ${destinationRoot}`);
    }
}
/**
 * Format a Date as the deterministic `%Y%m%dT%H%M%SZ` UTC timestamp.
 *
 * @param value The instant to format.
 * @returns The compact UTC timestamp string (e.g. `20260626T001500Z`).
 */
function formatArtifactTimestamp(value) {
    const iso = value.toISOString();
    // ISO form is `YYYY-MM-DDTHH:mm:ss.sssZ`; strip separators and fractional ms
    // to produce `YYYYMMDDTHHMMSSZ`, matching Python `strftime("%Y%m%dT%H%M%SZ")`.
    const compact = iso.replace(/[-:]/g, "").replace(/\.\d+Z$/, "Z");
    return compact;
}
/**
 * Build the deterministic JSON summary artifact path for a push-down run.
 *
 * @param startedAt UTC timestamp captured at run start.
 * @param artifactRoot Artifact root POSIX path.
 * @param artifactDirectory Artifact subdirectory.
 * @returns Artifact POSIX path beneath the configured artifact directory.
 */
function buildArtifactPath(startedAt, artifactRoot, artifactDirectory) {
    const timestamp = formatArtifactTimestamp(startedAt);
    return joinPosix(artifactRoot, `${artifactDirectory}/push-down-${timestamp}.json`);
}
/**
 * Render the push-down summary artifact as deterministic JSON.
 *
 * Produces 2-space-indented JSON with sorted keys (mirroring Python
 * `json.dumps(payload, indent=2, sort_keys=True)`). The per-file objects use the
 * same snake_case field names as the Python `asdict(result)` output.
 *
 * @param summary Completed push-down summary.
 * @returns Deterministic JSON payload string.
 */
function renderPushDownSummary(summary) {
    const payload = {
        repo_root: summary.repoRoot,
        destination_root: summary.destinationRoot,
        started_at: summary.startedAt.toISOString(),
        finished_at: summary.finishedAt.toISOString(),
        created_count: summary.createdCount,
        overwritten_count: summary.overwrittenCount,
        rewritten_reference_count: summary.rewrittenReferenceCount,
        placeholder_rewrite_count: summary.placeholderRewriteCount,
        unmatched_references: [...summary.unmatchedReferences],
        files: summary.files.map((result) => ({
            relative_path: result.relativePath,
            destination_status: result.destinationStatus,
            rewritten_reference_count: result.rewrittenReferenceCount,
            placeholder_rewrite_count: result.placeholderRewriteCount,
            unmatched_references: [...result.unmatchedReferences],
        })),
    };
    return stringifySorted(payload, 2);
}
/**
 * Serialize a value as JSON with recursively sorted object keys.
 *
 * Mirrors Python `json.dumps(..., sort_keys=True)`. Arrays preserve order;
 * object keys are emitted in lexicographic order at every depth.
 *
 * @param value The value to serialize.
 * @param indent Indentation width in spaces.
 * @returns Sorted-key JSON string.
 */
function stringifySorted(value, indent) {
    const sortKeys = (input) => {
        if (Array.isArray(input)) {
            return input.map(sortKeys);
        }
        if (input !== null && typeof input === "object") {
            const entries = Object.entries(input).sort(([leftKey], [rightKey]) => leftKey < rightKey ? -1 : leftKey > rightKey ? 1 : 0);
            const result = {};
            // Re-insert keys in sorted order so JSON.stringify emits them sorted.
            for (const [key, val] of entries) {
                result[key] = sortKeys(val);
            }
            return result;
        }
        return input;
    };
    return JSON.stringify(sortKeys(value), null, indent);
}
/**
 * Write the JSON summary artifact under the artifact directory.
 *
 * @param fs Filesystem adapter used for writes.
 * @param summary Summary to serialize.
 * @param artifactRoot Artifact root POSIX path.
 * @param artifactDirectory Artifact subdirectory.
 * @returns The written artifact POSIX path.
 */
function writeSummaryArtifact(fs, summary, artifactRoot, artifactDirectory) {
    const artifactPath = buildArtifactPath(summary.startedAt, artifactRoot, artifactDirectory);
    const parent = artifactPath.slice(0, artifactPath.lastIndexOf("/"));
    fs.ensureDir(parent);
    fs.writeTextFile(artifactPath, renderPushDownSummary(summary));
    return artifactPath;
}
/**
 * Copy scoped customizations into the destination workspace.
 *
 * Executes validation, deterministic enumeration, text rewriting, overwrite-
 * aware writes, and summary-artifact emission. Mirrors the Python
 * `push_down_customizations` orchestration exactly, including first-seen
 * unmatched-reference accumulation and per-file classification.
 *
 * @param options Engine options (roots, filesystem, rewrite fn, clock).
 * @returns The completed run summary including the written artifact path.
 * @throws Error When destination validation fails.
 */
function pushDownCustomizations(options) {
    const { repoRoot, destinationRoot, fs, sourceRoot, artifactRoot, rootFolders, artifactDirectory, rewriteReferences, clock, } = options;
    const effectiveSource = sourceRoot ?? repoRoot;
    const effectiveArtifact = artifactRoot ?? repoRoot;
    const effectiveRoots = rootFolders ?? exports.COPILOT_ROOT_FOLDERS;
    const effectiveArtifactDir = artifactDirectory ?? exports.ARTIFACT_DIRECTORY;
    const rewrite = rewriteReferences ?? reference_rewrites_1.rewriteTextReferences;
    const now = clock ?? (() => new Date());
    validateDestination(destinationRoot, repoRoot, fs);
    const startedAt = now();
    let createdCount = 0;
    let overwrittenCount = 0;
    let rewrittenReferenceCount = 0;
    let placeholderRewriteCount = 0;
    const unmatchedReferences = [];
    const fileResults = [];
    // Process files in stable order so artifacts and test expectations reproduce.
    for (const sourcePath of enumerateSourceFiles(fs, effectiveSource, effectiveRoots)) {
        const relativePath = relativeToPosix(sourcePath, effectiveSource);
        if (relativePath === null) {
            // The enumerator only yields files under the source root; skip otherwise.
            continue;
        }
        const destinationPath = joinPosix(destinationRoot, relativePath);
        const destinationStatus = fs.isFile(destinationPath)
            ? "overwritten"
            : "created";
        if (destinationStatus === "created") {
            createdCount += 1;
        }
        else {
            overwrittenCount += 1;
        }
        const sourceText = fs.readTextFile(sourcePath);
        const [rewrittenText, rewrittenDelta, placeholderDelta, unmatched] = rewrite(sourceText);
        rewrittenReferenceCount += rewrittenDelta;
        placeholderRewriteCount += placeholderDelta;
        // Accumulate unmatched references in first-seen order across all files.
        for (const reference of unmatched) {
            if (!unmatchedReferences.includes(reference)) {
                unmatchedReferences.push(reference);
            }
        }
        // Create the destination parent first so both write paths share one
        // deterministic directory-preparation step.
        const destParent = destinationPath.slice(0, destinationPath.lastIndexOf("/"));
        fs.ensureDir(destParent);
        fs.writeTextFile(destinationPath, rewrittenText);
        fileResults.push({
            relativePath,
            destinationStatus,
            rewrittenReferenceCount: rewrittenDelta,
            placeholderRewriteCount: placeholderDelta,
            unmatchedReferences: unmatched,
        });
    }
    const finishedAt = now();
    const provisionalSummary = {
        repoRoot: (0, filesystem_adapter_1.toPosixPath)(repoRoot),
        destinationRoot: (0, filesystem_adapter_1.toPosixPath)(destinationRoot),
        startedAt,
        finishedAt,
        createdCount,
        overwrittenCount,
        rewrittenReferenceCount,
        placeholderRewriteCount,
        unmatchedReferences,
        files: fileResults,
        artifactPath: "",
    };
    const artifactPath = writeSummaryArtifact(fs, provisionalSummary, effectiveArtifact, effectiveArtifactDir);
    return { ...provisionalSummary, artifactPath };
}
