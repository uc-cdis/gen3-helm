#!/bin/bash

function bump_semver() {
    # Get the current version
    version=$1

    # Split the version into its components
    IFS='.' read -r -a version_components <<< "$version"

    # Increment the patch version
    version_components[2]=$((version_components[2] + 1))

    # Reassemble the version string
    new_version="${version_components[0]}.${version_components[1]}.${version_components[2]}"

    # Print the new version
    echo $new_version
}

# Array to track which charts were updated
declare -a updated_charts=()

diff=$(git diff --name-only master helm/* | awk -F '/' '{print $2}' | sort -u)

for i in $diff; do
    # Skip processing the gen3 umbrella chart in the first loop
    if [[ "$i" == "gen3" ]]; then
        continue
    fi
    
    if git show master:helm/$i/Chart.yaml > /dev/null 2>&1; then
        current_version=$(grep -E '^version:' helm/$i/Chart.yaml | awk '{print $2}')
        master_version=$(git show master:helm/$i/Chart.yaml | grep -E '^version:' | awk '{print $2}')
        if [[ "${current_version}" == "${master_version}" ]]; then 
            new_version=$(bump_semver $current_version)
            echo "Bumping chart version in $i to $new_version"
            # Creating a backup file so sed command works on both linux and mac
            sed -i.bak "s#^version:.*#version: ${new_version/v/}#g" "helm/$i/Chart.yaml" && rm "helm/$i/Chart.yaml.bak"
            
            # Track this chart as updated
            updated_charts+=("$i")
        else 
            echo "Chart $i already has version bumped from $master_version to $current_version"
            # Still track it as updated since it has changes
            updated_charts+=("$i")
        fi
    else
        echo "No Chart.yaml for $i in master branch. Maybe it's a new chart?" 
        # Track new charts too
        updated_charts+=("$i")
    fi
done

# Now handle the gen3 umbrella chart
umbrella_chart_path="helm/gen3/Chart.yaml"
umbrella_needs_update=false

# Check if gen3 umbrella chart itself was modified
if echo "$diff" | grep -q "^gen3$"; then
    umbrella_needs_update=true
fi

# Check if umbrella chart version needs bumping
if git show master:$umbrella_chart_path > /dev/null 2>&1; then
    current_umbrella_version=$(grep -E '^version:' $umbrella_chart_path | awk '{print $2}')
    master_umbrella_version=$(git show master:$umbrella_chart_path | grep -E '^version:' | awk '{print $2}')
    
    # Update dependency versions for changed charts
    for chart in "${updated_charts[@]}"; do
        # Get the new version of the dependency chart
        if [[ -f "helm/$chart/Chart.yaml" ]]; then
            new_dep_version=$(grep -E '^version:' helm/$chart/Chart.yaml | awk '{print $2}')
            
            # Update the dependency version in umbrella chart
            # Look for the dependency entry and update its version
            if grep -q "name: $chart" $umbrella_chart_path; then
                echo "Updating $chart dependency version to $new_dep_version in umbrella chart"
                # Use awk to update the version line that comes after the matching name
                awk -v chart="$chart" -v new_version="$new_dep_version" '
                /^  - name: / { in_dep = ($3 == chart) }
                /^    version: / && in_dep { 
                    print "    version: " new_version
                    in_dep = 0
                    next 
                }
                { print }
                ' $umbrella_chart_path > ${umbrella_chart_path}.tmp && mv ${umbrella_chart_path}.tmp $umbrella_chart_path
                
                umbrella_needs_update=true
            fi
        fi
    done
    
    # Bump umbrella chart version if needed
    if [[ "$umbrella_needs_update" == "true" ]]; then
        if [[ "${current_umbrella_version}" == "${master_umbrella_version}" ]]; then
            new_umbrella_version=$(bump_semver $current_umbrella_version)
            echo "Bumping gen3 umbrella chart version to $new_umbrella_version"
            sed -i.bak "s#^version:.*#version: ${new_umbrella_version/v/}#g" "$umbrella_chart_path" && rm "${umbrella_chart_path}.bak"
        else
            echo "Gen3 umbrella chart version already bumped from $master_umbrella_version to $current_umbrella_version"
        fi
    fi
else
    echo "No umbrella Chart.yaml found in master branch"
fi

# Handle common chart special case
if printf '%s\n' "${updated_charts[@]}" | grep -q "^common$"; then
    echo "Common chart was updated - this affects all charts that depend on it"
    # You might want to add logic here to bump versions of charts that depend on common
    # For now, just print a warning
    echo "WARNING: Common chart updated. Consider if other chart versions need manual bumping."
fi

echo "Charts updated: ${updated_charts[*]}"