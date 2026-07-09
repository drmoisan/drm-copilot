/**
 * Document update helpers for active feature folder creation.
 *
 * Purpose:
 *     Direct TypeScript port of the bundled
 *     `dev_tools/new_active_feature_folder_docs.py`. Routes per-type section
 *     population and returns the ordered list of files to open. Section names,
 *     labels, ordering, and the `shouldUseMinorAuditMode` message are
 *     byte-identical to the Python source.
 */

import { type FolderFileSystem, joinPosix } from "./models";
import {
  formatChecklist,
  prependToSectionBody,
  setHeaderPlaceholder,
  setSection,
  updateSectionBody,
} from "./markdown";

/**
 * Apply header metadata and optional section overrides to a doc file.
 *
 * Mirrors Python `_apply_header_and_sections`: a no-op when the file does not
 * exist; otherwise reads the file, stamps the header, applies each
 * `[sectionName, body]` via {@link setSection}, and writes the file back.
 *
 * @param path Doc file path.
 * @param featureName Feature name for header stamping.
 * @param issueField Issue field value.
 * @param ownerField Owner field value.
 * @param updatedField Last-updated/date field value.
 * @param parentField Parent field value.
 * @param statusField Status field value.
 * @param versionField Version field value.
 * @param fs Filesystem seam.
 * @param updates Section overrides applied in order.
 */
function applyHeaderAndSections(
  path: string,
  featureName: string,
  issueField: string,
  ownerField: string,
  updatedField: string,
  parentField: string,
  statusField: string,
  versionField: string,
  fs: FolderFileSystem,
  updates: ReadonlyArray<[string, string]>,
): void {
  if (!fs.exists(path)) {
    return;
  }
  let content = fs.readText(path);
  content = setHeaderPlaceholder(
    content,
    featureName,
    issueField,
    ownerField,
    updatedField,
    statusField,
    parentField,
    versionField,
  );
  // Apply each requested section override in declaration order so later
  // sections can depend on earlier header normalization.
  for (const [sectionName, body] of updates) {
    content = setSection(content, sectionName, body);
  }
  fs.writeText(path, content);
}

/**
 * Populate active docs with header metadata and seeded content.
 *
 * Mirrors Python `update_feature_docs`. Routes by `featureType` with the exact
 * section mappings, ordering, `formatChecklist` wrapping, and `files_to_open`
 * ordering for `feature`, `refactor`, `epic`, and `bug`. The plan file always
 * uses `planUpdatedField` for its header.
 *
 * @param featureType Feature type.
 * @param featureName Feature name.
 * @param targetDir Active folder directory.
 * @param issueField Issue field value.
 * @param ownerField Owner field value.
 * @param updatedField Last-updated field for non-plan docs.
 * @param parentField Parent field value.
 * @param statusField Status field value.
 * @param versionField Version field value.
 * @param planUpdatedField Last-updated field for the plan file.
 * @param fs Filesystem seam.
 * @param sections Seeded section bodies keyed by logical name.
 * @param planPath Optional materialized plan path.
 * @returns The ordered list of files to open.
 */
export function updateFeatureDocs(
  featureType: string,
  featureName: string,
  targetDir: string,
  issueField: string,
  ownerField: string,
  updatedField: string,
  parentField: string,
  statusField: string,
  versionField: string,
  planUpdatedField: string,
  fs: FolderFileSystem,
  sections: Record<string, string>,
  planPath?: string | null,
): string[] {
  const filesToOpen: string[] = [];
  const get = (key: string): string => sections[key] ?? "";

  // Routing table by feature type. Each branch stamps the type-specific docs
  // with its exact section mapping and records the files-to-open in the order
  // the Python source returns them.
  if (featureType === "feature") {
    const userStory = joinPosix(targetDir, "user-story.md");
    const spec = joinPosix(targetDir, "spec.md");
    const plan = planPath ?? joinPosix(targetDir, "plan.md");
    applyHeaderAndSections(
      userStory,
      featureName,
      issueField,
      ownerField,
      updatedField,
      parentField,
      statusField,
      versionField,
      fs,
      [
        ["Problem / Why", get("problem")],
        ["Acceptance Criteria", formatChecklist(get("criteria"))],
      ],
    );
    applyHeaderAndSections(
      spec,
      featureName,
      issueField,
      ownerField,
      updatedField,
      parentField,
      statusField,
      versionField,
      fs,
      [
        ["Overview", get("problem")],
        ["Behavior", get("behavior")],
        ["Constraints & Risks", get("constraints")],
        [
          "Seeded Test Conditions (from potential)",
          formatChecklist(get("tests")),
        ],
      ],
    );
    applyHeaderAndSections(
      plan,
      featureName,
      issueField,
      ownerField,
      planUpdatedField,
      parentField,
      statusField,
      versionField,
      fs,
      [],
    );
    filesToOpen.push(userStory, spec, plan);
  } else if (featureType === "refactor") {
    const spec = joinPosix(targetDir, "spec.md");
    const plan = planPath ?? joinPosix(targetDir, "plan.md");
    applyHeaderAndSections(
      spec,
      featureName,
      issueField,
      ownerField,
      updatedField,
      parentField,
      statusField,
      versionField,
      fs,
      [
        ["Intent & Outcomes", get("problem")],
        ["Scope (structural changes)", get("behavior")],
        ["Risks & Mitigations", get("constraints")],
        [
          "Seeded Test Conditions (from potential)",
          formatChecklist(get("tests")),
        ],
      ],
    );
    applyHeaderAndSections(
      plan,
      featureName,
      issueField,
      ownerField,
      planUpdatedField,
      parentField,
      statusField,
      versionField,
      fs,
      [],
    );
    filesToOpen.push(spec, plan);
  } else if (featureType === "epic") {
    // Epic scaffolding stamps the merged epic.md source of truth and opens it.
    // epic-status.md is a generated-only projection seeded by the template copy;
    // it is never stamped or opened here, and initiative.md is retired.
    const epic = joinPosix(targetDir, "epic.md");
    applyHeaderAndSections(
      epic,
      featureName,
      issueField,
      ownerField,
      updatedField,
      parentField,
      statusField,
      versionField,
      fs,
      [],
    );
    filesToOpen.push(epic);
  } else if (featureType === "bug") {
    const spec = joinPosix(targetDir, "spec.md");
    const plan = planPath ?? joinPosix(targetDir, "plan.md");

    // Build the Context body from the present bug parts, joined with blank
    // lines and prefixed by their fixed labels.
    const contextParts: string[] = [];
    if (get("bug_summary")) {
      contextParts.push(get("bug_summary"));
    }
    if (get("bug_environment")) {
      contextParts.push(`Environment:\n${get("bug_environment")}`);
    }
    if (get("bug_impact")) {
      contextParts.push(`Impact / Severity:\n${get("bug_impact")}`);
    }
    const contextBody = contextParts.join("\n\n");

    // Build the Repro & Evidence body: steps, then the expected/actual pair,
    // then logs, each only appended when present.
    const reproParts: string[] = [];
    if (get("bug_steps")) {
      reproParts.push(`Steps to Reproduce:\n${get("bug_steps")}`);
    }
    const expectedActual: string[] = [];
    if (get("bug_expected")) {
      expectedActual.push(`Expected:\n${get("bug_expected")}`);
    }
    if (get("bug_actual")) {
      expectedActual.push(`Actual:\n${get("bug_actual")}`);
    }
    if (expectedActual.length > 0) {
      reproParts.push(expectedActual.join("\n\n"));
    }
    if (get("bug_logs")) {
      reproParts.push(`Logs / Screenshots:\n${get("bug_logs")}`);
    }
    const reproBody = reproParts.join("\n\n");

    const updates: Array<[string, string]> = [];
    if (contextBody) {
      updates.push(["Context", contextBody]);
    }
    if (reproBody) {
      updates.push(["Repro & Evidence", reproBody]);
    }
    if (get("bug_cause")) {
      updates.push(["Root Cause Analysis", get("bug_cause")]);
    }

    const bugValidation = get("bug_validation").trim();

    applyHeaderAndSections(
      spec,
      featureName,
      issueField,
      ownerField,
      updatedField,
      parentField,
      statusField,
      versionField,
      fs,
      updates,
    );

    // Seed the Test Strategy section from the validation ideas when present,
    // prepending the seeded block to whatever already exists in that section.
    if (bugValidation) {
      let specContent = fs.readText(spec);
      const updateTestStrategy = (body: string): string =>
        prependToSectionBody(body, `Seeded from issue:\n\n${bugValidation}`);
      [specContent] = updateSectionBody(
        specContent,
        "Test Strategy",
        updateTestStrategy,
      );
      fs.writeText(spec, specContent);
    }

    applyHeaderAndSections(
      plan,
      featureName,
      issueField,
      ownerField,
      planUpdatedField,
      parentField,
      statusField,
      versionField,
      fs,
      [],
    );
    filesToOpen.push(spec, plan);
  }

  return filesToOpen;
}

/**
 * Return whether the minor-audit path should be used and a fallback reason.
 *
 * Mirrors Python `should_use_minor_audit_mode`. The `featureType` and
 * `potentialContent` arguments are unused (Python `del`); kept for signature
 * parity. Throws the byte-identical message when `workMode` is outside the
 * accepted set; returns `[false, ""]` for any non-`minor-audit` mode; otherwise
 * `[true, ""]`.
 *
 * @param workMode Selected work mode.
 * @param featureType Unused; kept for signature parity.
 * @param potentialContent Unused; kept for signature parity.
 * @returns A tuple of the minor-audit flag and the (always empty) reason.
 * @throws Error When `workMode` is outside the accepted set.
 */
export function shouldUseMinorAuditMode(
  workMode: string,
  featureType: string,
  potentialContent: string,
): [boolean, string] {
  void featureType;
  void potentialContent;
  if (!["minor-audit", "full-feature", "full-bug", "full"].includes(workMode)) {
    throw new Error(
      "work_mode must be one of: minor-audit, full-feature, full-bug, full",
    );
  }
  // Only the explicit minor-audit mode routes to the audit path; every other
  // accepted mode uses the full-document flow.
  if (workMode !== "minor-audit") {
    return [false, ""];
  }
  return [true, ""];
}
