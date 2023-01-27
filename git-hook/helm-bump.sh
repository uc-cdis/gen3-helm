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
    exit
}


diff=$(git diff --name-only master helm/* | awk -F '/' '{print $2}' | sort -u)


for i in $diff; do
    if git show master:helm/$i/Chart.yaml > /dev/null; then
        current_version=$(grep -E '^version:' helm/$i/Chart.yaml | awk '{print $2}')
        master_version=$(git show master:helm/$i/Chart.yaml | grep -E '^version:' | awk '{print $2}')
        if [[ "${current_version}" == "${master_version}" ]]; then 
            new_version=$(bump_semver $current_version)
            echo "Bumping chart version in $i to $new_version"
            # Creating a backup file so sed command works on both linux and mac
            # https://stackoverflow.com/questions/16745988/sed-command-with-i-option-in-place-editing-works-fine-on-ubuntu-but-not-mac
            sed -i.bak "s#^version:.*#version: ${new_version/v/}#g" "helm/$i/Chart.yaml" && rm "helm/$i/Chart.yaml.bak"

            # TODO: Update all versions in gen3 umbrella chart too
            # TODO: Also check if common chart is being updated, and bump it in all charts. 
            # echo "update version in gen3 umbrella chart too."

        else 
            echo "current_version: $current_version"
            echo "master_version: $master_version"
        fi
    else
        echo "No Chart.yaml for $i in master branch. Maybe it's a new chart?" 
    fi

done

