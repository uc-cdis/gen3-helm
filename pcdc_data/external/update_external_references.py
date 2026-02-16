import json
import sys
from pathlib import Path


def ensure_subjects_list(ref):
    """
    This function ensures we are looking at a list.
    """
    subjects = ref.get("subjects")

    # If it's a dict (one subject), wrap it in a list
    if isinstance(subjects, dict):
        return [subjects]

    # If it's already a list, just return it
    elif isinstance(subjects, list):
        return subjects

    # If it's missing or an unexpected format, return a list with a blank dict
    else:
        return [{"submitter_id": ""}]


def update_external_refs(subject_path, external_ref_path, output_path=None):
    """
    This function reads a list of subjects and external references,
    then updates each external reference's subjects[0]['submitter_id']
    with the matching subject's submitter_id (by index).
    """

    # Load the subject file (expects a list of subject objects)
    with open(subject_path) as f:
        subjects = json.load(f)

    # Extract just the top-level 'submitter_id' from each subject
    subject_ids = [s["submitter_id"] for s in subjects]

    # Load the external_reference file (expects a list of reference objects)
    with open(external_ref_path) as f:
        external_refs = json.load(f)

    # Flatten outer list if needed
    if isinstance(external_refs, list) and isinstance(external_refs[0], list):
        external_refs = [item for sublist in external_refs for item in sublist]

    # Loop over each external reference
    for i, ref in enumerate(external_refs):
        # If there are more external references than subjects, warn and skip
        if i >= len(subject_ids):
            print(f"Warning: Not enough subject IDs for external reference {i}")
            continue

        # Get the corresponding subject submitter_id
        subject_id = subject_ids[i]

        # Make sure the 'subjects' field is a list with one dict
        ref["subjects"] = ensure_subjects_list(ref)

        # Update the first subject's submitter_id with the new one
        ref["subjects"][0]["submitter_id"] = subject_id

    # Use the provided output path, or overwrite the original file
    output_path = output_path or external_ref_path

    # Save the updated external references back to a JSON file
    with open(output_path, "w") as f:
        json.dump(external_refs, f, indent=4)

    print(f"Updated file written to {output_path}")


# This block only runs if the script is called directly, not if imported
if __name__ == "__main__":
    # Expect at least 2 arguments: subject.json and external_reference.json
    if len(sys.argv) < 3:
        print(
            "Usage: python update_external_references.py <subject.json> <external_reference.json> [output.json]"
        )
        sys.exit(1)  # Exit with error if not enough arguments are provided

    # Read the input file paths from the command-line arguments
    subject_file = Path(sys.argv[1])
    external_ref_file = Path(sys.argv[2])

    # Optional third argument: a custom output file path
    output_file = Path(sys.argv[3]) if len(sys.argv) > 3 else None

    # Call the main function
    update_external_refs(subject_file, external_ref_file, output_file)
