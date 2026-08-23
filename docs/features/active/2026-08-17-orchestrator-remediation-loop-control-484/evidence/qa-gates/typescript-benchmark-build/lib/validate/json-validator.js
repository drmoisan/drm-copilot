"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.collectSchemaErrors = collectSchemaErrors;
exports.loadSchema = loadSchema;
exports.validateFile = validateFile;
exports.collectTargets = collectTargets;
exports.runValidation = runValidation;
const file_system_1 = require("../file-system");
const json_config_1 = require("../json-config");
/**
 * Type guard for a plain object (non-null, non-array).
 *
 * @param value Candidate value.
 * @returns True when the value is a non-null, non-array object.
 */
function isObject(value) {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}
/**
 * Validate data against a minimal subset of JSON Schema keywords.
 *
 * Mirrors Python `_collect_schema_errors`: rejects a non-object root when the
 * schema expects an object, reports missing required properties, and reports
 * `number` type mismatches for schema-defined properties present in the data.
 *
 * @param schema JSON schema object to validate against.
 * @param data Parsed JSON object to validate.
 * @returns Human-readable error strings describing validation failures.
 * @throws Error when the schema expects an object root but data is not an object.
 */
function collectSchemaErrors(schema, data) {
    const errors = [];
    const schemaType = schema["type"];
    // Reject non-object roots when the schema expects an object. `data` is already
    // an object here, so this guard mirrors the Python raise for completeness.
    if (schemaType === "object" && !isObject(data)) {
        throw new Error("Schema expects an object at the root.");
    }
    const properties = isObject(schema["properties"]) ? schema["properties"] : {};
    const required = Array.isArray(schema["required"]) ? schema["required"] : [];
    // Track missing required properties for clear diagnostic output.
    for (const key of required) {
        if (typeof key === "string" && !(key in data)) {
            errors.push(`['${key}']: is a required property`);
        }
    }
    // Validate types for schema-defined properties present in the data.
    for (const [key, descriptor] of Object.entries(properties)) {
        if (!(key in data)) {
            continue;
        }
        const expected = isObject(descriptor) ? descriptor["type"] : undefined;
        if (expected === "number" && typeof data[key] !== "number") {
            errors.push(`['${key}']: expected number`);
        }
    }
    return errors;
}
/**
 * Parse a URI's scheme, mirroring the subset of `urlparse` the validator needs.
 *
 * @param uri Schema URI from a document's `$schema` field.
 * @returns The lowercase scheme, or empty string when no scheme is present.
 */
function uriScheme(uri) {
    // A scheme is `[a-z][a-z0-9+.-]*` followed by `:`; anything else (including a
    // bare relative path) has no scheme.
    const match = /^([a-zA-Z][a-zA-Z0-9+.-]*):/.exec(uri);
    return match ? (match[1] ?? "").toLowerCase() : "";
}
/**
 * Resolve a POSIX path by collapsing `.` and `..` segments.
 *
 * @param path A POSIX-style path that may contain `.`/`..` segments.
 * @returns The normalized path.
 */
function resolvePosix(path) {
    const isAbsolute = path.startsWith("/");
    const resolved = [];
    // Collapse navigation segments the way Path.resolve does for the parts present.
    for (const segment of path.split("/")) {
        if (segment === "" || segment === ".") {
            continue;
        }
        if (segment === "..") {
            if (resolved.length > 0 && resolved[resolved.length - 1] !== "..") {
                resolved.pop();
            }
            else if (!isAbsolute) {
                resolved.push("..");
            }
            continue;
        }
        resolved.push(segment);
    }
    return (isAbsolute ? "/" : "") + resolved.join("/");
}
/**
 * Return the parent directory of a POSIX path.
 *
 * @param path A POSIX-style path.
 * @returns The parent directory path.
 */
function parentDir(path) {
    const normalized = (0, file_system_1.toPosixPath)(path);
    const index = normalized.lastIndexOf("/");
    return index === -1 ? "" : normalized.slice(0, index);
}
/**
 * Load a schema referenced from a document's `$schema` field.
 *
 * Supports local relative paths (resolved against the source file's directory)
 * and `file:` URIs. Throws for `http`/`https` and any other scheme, mirroring
 * the Python `Unsupported schema URI scheme: <scheme>` error.
 *
 * @param fs Injected filesystem.
 * @param uri The `$schema` URI.
 * @param basePath The source document path used to resolve relative URIs.
 * @returns The parsed schema object.
 * @throws Error for unsupported schemes, missing schema files, or no base path.
 */
function loadSchema(fs, uri, basePath) {
    const scheme = uriScheme(uri);
    // No scheme: resolve as a relative path against the source file's directory.
    if (scheme === "") {
        if (basePath === undefined) {
            throw new Error("Unsupported schema URI scheme: missing");
        }
        const localPath = resolvePosix(`${parentDir(basePath)}/${uri}`);
        if (!fs.isFile(localPath)) {
            throw new Error(`Schema file not found: ${localPath}`);
        }
        return JSON.parse(fs.readTextFile(localPath));
    }
    // `file:` URIs reference an explicit local path.
    if (scheme === "file") {
        const localPath = uri.replace(/^file:\/\//, "").replace(/^file:/, "");
        if (!fs.isFile(localPath)) {
            throw new Error(`Schema file not found: ${localPath}`);
        }
        return JSON.parse(fs.readTextFile(localPath));
    }
    // Remote and any other scheme is rejected (accepted divergence; see header).
    throw new Error(`Unsupported schema URI scheme: ${scheme}`);
}
/**
 * Validate a JSON file against its declared `$schema`.
 *
 * @param fs Injected filesystem.
 * @param path Path to the JSON file being validated.
 * @returns A tuple of success flag and a human-readable message.
 */
function validateFile(fs, path) {
    let dataRaw;
    try {
        dataRaw = JSON.parse(fs.readTextFile(path));
    }
    catch (exc) {
        return [false, `${path}: invalid JSON (${errorText(exc)})`];
    }
    if (!isObject(dataRaw)) {
        return [false, `${path}: JSON root must be an object for validation`];
    }
    const data = dataRaw;
    const schemaValue = data["$schema"];
    if (typeof schemaValue !== "string") {
        return [false, `${path}: missing $schema`];
    }
    try {
        const schema = loadSchema(fs, schemaValue, path);
        const errors = collectSchemaErrors(schema, data);
        if (errors.length > 0) {
            return [false, `${path}: schema validation failed: ${errors.join("; ")}`];
        }
    }
    catch (exc) {
        return [false, `${path}: validation error (${errorText(exc)})`];
    }
    return [true, `${path}: ok`];
}
/**
 * Render an error's message for interpolation into result strings.
 *
 * @param exc Caught error value.
 * @returns The error message text.
 */
function errorText(exc) {
    return exc instanceof Error ? exc.message : String(exc);
}
/**
 * Resolve validation targets from explicit paths or the governed-file globs.
 *
 * @param fs Injected filesystem.
 * @param root Repository root for governed-file discovery.
 * @param paths Explicit file/dir targets; empty falls back to governed globs.
 * @returns The resolved target file paths.
 */
function collectTargets(fs, root, paths) {
    if (paths.length > 0) {
        const targets = [];
        // Expand directory targets to their contained *.json files; keep file
        // targets verbatim, mirroring the Python rglob/append split.
        for (const candidate of paths) {
            const normalized = (0, file_system_1.toPosixPath)(candidate);
            if (isDirectory(fs, normalized)) {
                targets.push(...fs.glob(normalized, "**/*.json").filter((p) => fs.isFile(p)));
            }
            else {
                targets.push(normalized);
            }
        }
        return targets;
    }
    return (0, json_config_1.iterGovernedFiles)(fs, root);
}
/**
 * Return true when a path refers to an existing directory.
 *
 * The injected `FileSystem` exposes `isFile`; a path that is not a file but does
 * yield glob matches under it is treated as a directory.
 *
 * @param fs Injected filesystem.
 * @param path Candidate path.
 * @returns True when the path is a directory.
 */
function isDirectory(fs, path) {
    if (fs.isFile(path)) {
        return false;
    }
    return fs.glob(path, "**/*.json").length > 0;
}
/**
 * Run validation over a set of targets and aggregate the outcome.
 *
 * @param fs Injected filesystem.
 * @param targets Target file paths to validate.
 * @param verbose When true, record messages for passing files as well.
 * @returns The aggregated {@link ValidateResult}.
 */
function runValidation(fs, targets, verbose = false) {
    const result = { failed: false, messages: [] };
    // Validate each target and collect messages per the verbose/failure policy.
    for (const path of targets) {
        const [ok, msg] = validateFile(fs, path);
        if (verbose || !ok) {
            result.messages.push(msg);
        }
        if (!ok) {
            result.failed = true;
        }
    }
    return result;
}
