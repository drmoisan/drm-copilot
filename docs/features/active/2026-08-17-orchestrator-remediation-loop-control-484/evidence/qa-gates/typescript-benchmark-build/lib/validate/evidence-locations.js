"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.findForbiddenPaths = findForbiddenPaths;
exports.formatViolation = formatViolation;
const file_system_1 = require("../file-system");
/**
 * Forbidden-evidence-location scanner.
 *
 * Purpose:
 *     Port `scripts/dev_tools/validate_evidence_locations.py`. Enforce the
 *     canonical evidence-path scheme `<FEATURE>/evidence/<kind>/` by reporting
 *     any file found under a forbidden `artifacts/` sub-path.
 *
 * Responsibilities:
 *     - `findForbiddenPaths`: enumerate files under a root and report each one
 *       that lives under a forbidden prefix, with the canonical replacement.
 *     - `formatViolation`: render the exact `VIOLATION:` report line.
 *
 * Invariants / Constraints:
 *     - The forbidden-prefix map and report message are identical to the Python
 *       source. Matching uses POSIX-normalized relative paths.
 *     - I/O is injected via the F1 `FileSystem` so the scanner stays hermetic.
 *
 * Side Effects:
 *     None directly; the injected `FileSystem` performs reads.
 */
/**
 * Map from forbidden relative-path prefix to the canonical replacement hint.
 *
 * Keys must NOT start with a leading slash; they are matched against the
 * POSIX-normalized path relative to the repository root.
 */
const FORBIDDEN_PREFIX_TO_CANONICAL = [
    ["artifacts/baselines/", "<FEATURE>/evidence/baseline/"],
    ["artifacts/baseline/", "<FEATURE>/evidence/baseline/"],
    ["artifacts/qa/", "<FEATURE>/evidence/qa-gates/"],
    ["artifacts/qa-gates/", "<FEATURE>/evidence/qa-gates/"],
    ["artifacts/coverage/", "<FEATURE>/evidence/qa-gates/"],
    ["artifacts/evidence/", "<FEATURE>/evidence/<kind>/"],
    ["artifacts/regression-testing/", "<FEATURE>/evidence/qa-gates/"],
    ["artifacts/post-change/", "<FEATURE>/evidence/qa-gates/"],
    [
        "artifacts/research/",
        "docs/features/active/<feature>/research/ or docs/research/",
    ],
];
/**
 * Walk `root` and return every file that lives under a forbidden evidence prefix.
 *
 * Purpose:
 *     Mirror Python `find_forbidden_paths`, which iterates all files reachable
 *     from the root and checks each against the forbidden-prefix table, reporting
 *     only the first matching prefix per file.
 *
 * @param fs Injected filesystem providing `glob` and `isFile`.
 * @param root Repository root (or any directory) to scan recursively.
 * @returns One violation per offending file, each with the canonical hint.
 */
function findForbiddenPaths(fs, root) {
    const normalizedRoot = (0, file_system_1.toPosixPath)(root).replace(/\/+$/, "");
    const violations = [];
    // Enumerate every reachable path, then keep only regular files (mirroring the
    // Python `candidate.is_file()` guard) before prefix matching.
    for (const candidate of fs.glob(normalizedRoot, "**")) {
        if (!fs.isFile(candidate)) {
            continue;
        }
        // Compute the POSIX-normalized path relative to root for prefix matching.
        const normalizedCandidate = (0, file_system_1.toPosixPath)(candidate);
        const prefix = `${normalizedRoot}/`;
        if (!normalizedCandidate.startsWith(prefix)) {
            // Guard defensively: a candidate outside root cannot be made relative.
            continue;
        }
        const relativePosix = normalizedCandidate.slice(prefix.length);
        // Report the first matching forbidden prefix and stop, matching the Python
        // `break` so each file produces at most one violation.
        for (const [forbiddenPrefix, canonical] of FORBIDDEN_PREFIX_TO_CANONICAL) {
            if (relativePosix.startsWith(forbiddenPrefix)) {
                violations.push({ path: candidate, canonical });
                break;
            }
        }
    }
    return violations;
}
/**
 * Render the exact `VIOLATION:` report line for a forbidden-location finding.
 *
 * @param path Offending file path.
 * @param canonical Canonical replacement hint.
 * @returns The report line, using the em dash (U+2014) as in the Python source.
 */
function formatViolation(path, canonical) {
    return `VIOLATION: ${path} — use ${canonical} instead`;
}
