/**
 * Feature-folder rename derivation (issue #1016, spec "Feature-folder rename
 * derivation (research section 6)", rules 1 to 8).
 *
 * Input folders are the direct child folders of `active`, `completed` and
 * `archive`, as repository-relative paths. Only the top-level folder name is
 * renamed; nested `v1/`, `audit-*` and `evidence/` folders are never inputs.
 */
import {
  formatFeatureFolderName,
  parseFeatureFolderName,
} from "../development-docs/feature-folder-name";

/** Why a folder is held for a decision. */
export type HeldReason =
  "non-matching" | "multi-folder-issue" | "formatter-error" | "collision";

/** A mechanical rename (rule 2). */
export interface FolderRename {
  readonly source: string;
  readonly area: string;
  readonly from: string;
  readonly to: string;
}

/** A folder held for a decision (rules 4, 6, 7 and 8). */
export interface HeldFolder {
  readonly source: string;
  readonly reason: HeldReason;
  readonly candidate: string | null;
  readonly detail?: string;
}

/** A folder kept because no issue number is recoverable (rule 5). */
export interface KeptFolder {
  readonly source: string;
  readonly format: "date-first" | "other";
}

/** Result of {@link planFolderRenames}. */
export interface FolderRenamePlan {
  readonly renames: ReadonlyArray<FolderRename>;
  readonly held: ReadonlyArray<HeldFolder>;
  readonly kept: ReadonlyArray<KeptFolder>;
}

interface Candidate {
  readonly source: string;
  readonly area: string;
  readonly name: string;
  readonly issueNumber: number;
  readonly format: "date-first" | "other";
  readonly candidate: string | null;
  readonly error: string | null;
}

/**
 * Split a folder path into its area and name.
 *
 * @param source Repository-relative folder path.
 * @returns The parent segment (the area) and the last segment.
 */
export function splitFolderPath(source: string): {
  area: string;
  name: string;
} {
  const segments = source.split("/");
  return {
    area: segments[segments.length - 2] ?? "",
    name: segments[segments.length - 1] ?? "",
  };
}

/**
 * Derive the folder renames, held folders and kept folders.
 *
 * @param folders Direct child folders of the three areas.
 * @returns Lists sorted by source path; nothing is thrown for bad names.
 */
export function planFolderRenames(
  folders: ReadonlyArray<string>,
): FolderRenamePlan {
  const kept: KeptFolder[] = [];
  const candidates: Candidate[] = [];
  const issueCounts = new Map<number, number>();
  for (const source of [...folders].sort()) {
    const { area, name } = splitFolderPath(source);
    const parsed = parseFeatureFolderName(name);
    // Rule 3: an issue-first folder is already migrated. It counts only as an
    // existing name for the collision check (rule 8), not toward rule 6.
    if (parsed.format === "issue-first") {
      continue;
    }
    if (parsed.issueNumber === null) {
      kept.push({ source, format: parsed.format });
      continue;
    }
    issueCounts.set(
      parsed.issueNumber,
      (issueCounts.get(parsed.issueNumber) ?? 0) + 1,
    );
    candidates.push(
      formatCandidate(source, area, name, parsed.issueNumber, parsed),
    );
  }

  const held: HeldFolder[] = [];
  const open: Candidate[] = [];
  for (const entry of candidates) {
    if (entry.error !== null) {
      held.push({
        source: entry.source,
        reason: "formatter-error",
        candidate: null,
        detail: entry.error,
      });
    } else if ((issueCounts.get(entry.issueNumber) ?? 0) > 1) {
      held.push({
        source: entry.source,
        reason: "multi-folder-issue",
        candidate: entry.candidate,
      });
    } else {
      open.push(entry);
    }
  }

  const colliding = findCollisions(open, folders);
  const renames: FolderRename[] = [];
  for (const entry of open) {
    const candidate = entry.candidate ?? "";
    if (colliding.has(entry.source)) {
      held.push({ source: entry.source, reason: "collision", candidate });
    } else if (entry.format === "other") {
      held.push({ source: entry.source, reason: "non-matching", candidate });
    } else {
      renames.push({
        source: entry.source,
        area: entry.area,
        from: entry.name,
        to: candidate,
      });
    }
  }
  held.sort((left, right) => left.source.localeCompare(right.source));
  return { renames, held, kept };
}

/**
 * Compute the mechanical candidate of one folder, capturing formatter errors.
 *
 * @returns The candidate record; `error` is set when the formatter throws (rule 7).
 */
function formatCandidate(
  source: string,
  area: string,
  name: string,
  issueNumber: number,
  parsed: { format: "date-first" | "other"; feature: string },
): Candidate {
  try {
    const candidate = formatFeatureFolderName(issueNumber, parsed.feature);
    return {
      source,
      area,
      name,
      issueNumber,
      format: parsed.format,
      candidate,
      error: null,
    };
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    return {
      source,
      area,
      name,
      issueNumber,
      format: parsed.format,
      candidate: null,
      error: message,
    };
  }
}

/**
 * Find candidates whose target collides, case-insensitively and across all
 * three areas, with an existing folder name (rule 8).
 *
 * Two candidates can be equal only when they share an issue number, and every
 * folder of a shared issue number is already held by rule 6, so the open
 * candidates are compared with the existing names only.
 *
 * @param open Candidates still eligible for a rename.
 * @param folders Every input folder.
 * @returns The sources of every folder involved in a collision.
 */
function findCollisions(
  open: ReadonlyArray<Candidate>,
  folders: ReadonlyArray<string>,
): Set<string> {
  const bySource = new Map<string, string>();
  for (const folder of folders) {
    bySource.set(folder, splitFolderPath(folder).name.toLowerCase());
  }
  const colliding = new Set<string>();
  for (const entry of open) {
    const target = (entry.candidate ?? "").toLowerCase();
    for (const [source, name] of bySource) {
      if (source !== entry.source && name === target) {
        colliding.add(entry.source);
        colliding.add(source);
      }
    }
  }
  return colliding;
}
