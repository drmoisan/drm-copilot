/**
 * Validate rules V4 and V5 of the push-down integration tools (issue #1051,
 * S39 and S40).
 *
 * Purpose:
 *     V4 checks that the CI workflow found by V3 runs a coverage job, or
 *     names the coverage artifact path, for every selected language pack. V5
 *     checks every manifest entry's hash against the destination text, with
 *     paths listed in `.push-down-exclusions` treated as destination-owned.
 *
 * Side effects:
 *     Reads the destination through the injected read-only seam only.
 */

import { compareCodePoint } from "../string-ordering";
import {
  EXCLUSION_MANIFEST_RELATIVE_PATH,
  type ExclusionManifest,
  matchesExclusionEntry,
  parseExclusionManifest,
} from "../push-down/claude-exclusion-manifest";
import {
  DESTINATION_MANIFEST_RELATIVE_PATH,
  type DestinationManifest,
  hashPayloadText,
  parseDestinationManifest,
} from "../push-down/push-down-destination-manifest";
import { joinPosix } from "../push-down/push-down-pipeline";
import { type IntegrationReadFileSystem } from "./integration-ecosystems";
import { type DestinationWorkflow } from "./integration-detect";
import { readWorkflowText } from "./workflow-yaml-reader";

/** Coverage artifact path per language pack (S39). */
export const COVERAGE_ARTIFACT_PATHS: Readonly<Record<string, string>> = {
  "csharp-legacy": "artifacts/csharp/coverage.xml",
  "csharp-modern": "artifacts/csharp/coverage.xml",
  powershell: "artifacts/pester/powershell-coverage.xml",
  python: "artifacts/python/lcov.info",
  typescript: "coverage/lcov.info",
};

/** Workflow stem per language pack (#1050 D4). */
const PACK_STEMS: Readonly<Record<string, string>> = {
  "csharp-legacy": "dotnet",
  "csharp-modern": "dotnet",
  powershell: "powershell",
  python: "python",
  typescript: "typescript",
};

/** One rule failure. */
export interface ValidateFailure {
  readonly path: string;
  readonly message: string;
}

/** Read-only inputs of the validate rules. */
export interface ValidateReadInput {
  readonly fs: IntegrationReadFileSystem;
  /** Destination root (POSIX). */
  readonly destinationRoot: string;
}

/** Outcome of V4: `undefined` when the rule does not apply. */
export type CoverageRuleOutcome = ReadonlyArray<ValidateFailure> | undefined;

/** Outcome of V5. */
export interface ManifestHashOutcome {
  readonly failures: ReadonlyArray<ValidateFailure>;
  readonly destinationOwned: ReadonlyArray<string>;
}

/**
 * Return the selected language packs of the manifest selection union.
 *
 * @param manifest Destination manifest.
 * @returns Canonical pack names, sorted.
 */
export function selectedLanguagePacks(
  manifest: DestinationManifest | undefined,
): string[] {
  const names = new Set<string>();
  for (const selection of Object.values(manifest?.selection ?? {})) {
    for (const pack of selection.packs) {
      const name =
        pack === "csharp"
          ? `csharp-${selection.csharpVariant === "legacy" ? "legacy" : "modern"}`
          : pack;
      if (PACK_STEMS[name] !== undefined) {
        names.add(name);
      }
    }
  }
  return [...names].sort(compareCodePoint);
}

/**
 * Collect the texts of a workflow and every local workflow it reaches through
 * `uses: ./.github/workflows/<file>`, each file once.
 *
 * @param input Seam and destination root.
 * @param start The workflow found by V3.
 * @returns The texts in visit order.
 */
function reachedWorkflowTexts(
  input: ValidateReadInput,
  start: DestinationWorkflow,
): string[] {
  const texts: string[] = [];
  const visited = new Set<string>([start.path]);
  const queue: Array<{ text: string }> = [{ text: start.text }];
  for (let next = queue.shift(); next !== undefined; next = queue.shift()) {
    texts.push(next.text);
    const result = readWorkflowText(next.text);
    const jobs = result.status === "ok" ? result.jobs : [];
    for (const job of jobs) {
      const uses = job.uses ?? "";
      if (!uses.startsWith("./.github/workflows/")) {
        continue;
      }
      const relative = uses.slice(2);
      const absolute = joinPosix(input.destinationRoot, relative);
      if (!visited.has(relative) && input.fs.isFile(absolute)) {
        visited.add(relative);
        queue.push({ text: input.fs.readTextFile(absolute) });
      }
    }
  }
  return texts;
}

/**
 * Evaluate V4 (S39).
 *
 * @param input Seam and destination root.
 * @param ciWorkflow The workflow found by V3, or undefined when V3 failed.
 * @param manifest Destination manifest, when it parsed.
 * @returns One failure per pack that passes neither test, or undefined when
 *   the rule does not apply.
 */
export function evaluateCoverageArtifactRule(
  input: ValidateReadInput,
  ciWorkflow: DestinationWorkflow | undefined,
  manifest: DestinationManifest | undefined,
): CoverageRuleOutcome {
  const packs = selectedLanguagePacks(manifest);
  if (ciWorkflow === undefined || packs.length === 0) {
    return undefined;
  }
  const result = readWorkflowText(ciWorkflow.text);
  const uses = (result.status === "ok" ? result.jobs : []).map(
    (job) => job.uses ?? "",
  );
  const texts = reachedWorkflowTexts(input, ciWorkflow);
  const failures: ValidateFailure[] = [];
  for (const pack of packs) {
    const stem = PACK_STEMS[pack] ?? "";
    const artifact = COVERAGE_ARTIFACT_PATHS[pack] ?? "";
    const reference = new RegExp(
      `^drmoisan/drm-copilot/\\.github/workflows/harness-${stem}\\.yml@.+$`,
    );
    const viaJob = uses.some(
      (value) =>
        reference.test(value) ||
        value === `./.github/workflows/drm-copilot-${stem}.yml`,
    );
    const viaText = texts.some((text) => text.includes(artifact));
    if (!viaJob && !viaText) {
      failures.push({
        path: ciWorkflow.path,
        message: `pack ${pack}: no job uses harness-${stem}.yml or drm-copilot-${stem}.yml and no reached workflow names ${artifact}`,
      });
    }
  }
  return failures;
}

/**
 * Read the exclusion manifest, or return a failure when it is malformed.
 *
 * @param input Seam and destination root.
 * @returns The manifest, undefined when absent, or a failure.
 */
function readExclusions(
  input: ValidateReadInput,
): ExclusionManifest | undefined | ValidateFailure {
  const path = joinPosix(
    input.destinationRoot,
    EXCLUSION_MANIFEST_RELATIVE_PATH,
  );
  if (!input.fs.isFile(path)) {
    return undefined;
  }
  try {
    return parseExclusionManifest(
      input.fs.readTextFile(path),
      EXCLUSION_MANIFEST_RELATIVE_PATH,
    );
  } catch (error) {
    return {
      path: EXCLUSION_MANIFEST_RELATIVE_PATH,
      message: error instanceof Error ? error.message : String(error),
    };
  }
}

/**
 * Evaluate V5 (S40).
 *
 * @param input Seam and destination root.
 * @returns Failures and the sorted destination-owned paths.
 */
export function evaluateManifestHashRule(
  input: ValidateReadInput,
): ManifestHashOutcome {
  const manifestPath = joinPosix(
    input.destinationRoot,
    DESTINATION_MANIFEST_RELATIVE_PATH,
  );
  if (!input.fs.isFile(manifestPath)) {
    return {
      failures: [
        {
          path: DESTINATION_MANIFEST_RELATIVE_PATH,
          message: "the push-down manifest is absent",
        },
      ],
      destinationOwned: [],
    };
  }
  let manifest: DestinationManifest;
  try {
    manifest = parseDestinationManifest(input.fs.readTextFile(manifestPath));
  } catch (error) {
    return {
      failures: [
        {
          path: DESTINATION_MANIFEST_RELATIVE_PATH,
          message: error instanceof Error ? error.message : String(error),
        },
      ],
      destinationOwned: [],
    };
  }
  const exclusions = readExclusions(input);
  const failures: ValidateFailure[] = [];
  if (exclusions !== undefined && "message" in exclusions) {
    failures.push(exclusions);
  }
  const entries =
    exclusions !== undefined && "entries" in exclusions
      ? exclusions.entries
      : [];
  const owned: string[] = [];
  for (const [path, entry] of Object.entries(manifest.files)) {
    const absolute = joinPosix(input.destinationRoot, path);
    const status = !input.fs.isFile(absolute)
      ? "missing"
      : hashPayloadText(input.fs.readTextFile(absolute)) === entry.sha256
        ? "exempt"
        : "modified";
    if (status === "exempt") {
      continue;
    }
    if (entries.some((exclusion) => matchesExclusionEntry(exclusion, path))) {
      owned.push(path);
    } else {
      failures.push({
        path,
        message:
          status === "missing"
            ? "missing: the manifest lists the file but the destination has none"
            : "modified: the destination text does not match the recorded hash",
      });
    }
  }
  return { failures, destinationOwned: owned.sort(compareCodePoint) };
}
