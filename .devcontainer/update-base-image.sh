#!/bin/bash
# Automated script to update Dockerfile with latest Elixir version

set -e

echo "=== Elixir Docker Image Updater ==="

# Function to get latest Elixir tags from Docker Hub API
get_latest_elixir_tag() {
    echo "Fetching latest Elixir tags from Docker Hub..."
    
    # Get tags from Docker Hub API
    TAGS_JSON=$(curl -s "https://registry.hub.docker.com/v2/repositories/hexpm/elixir/tags/?page_size=100" | jq -r '.results[].name')
    
    # Filter for stable debian/ubuntu versions (exclude alpine and rc versions for stability)
    STABLE_TAGS=$(echo "$TAGS_JSON" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+-erlang-[0-9]+\.[0-9]+.*-(debian|ubuntu).*' | grep -v 'rc' | head -20)
    
    if [ -z "$STABLE_TAGS" ]; then
        echo "No stable tags found, trying broader search..."
        STABLE_TAGS=$(echo "$TAGS_JSON" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+-erlang-[0-9]+\.[0-9]+' | grep -v 'rc' | head -10)
    fi
    
    echo "Found stable tags:"
    echo "$STABLE_TAGS"
    echo
    
    # Get the latest version (first in the list)
    LATEST_TAG=$(echo "$STABLE_TAGS" | head -1)
    echo "Selected latest stable tag: $LATEST_TAG"
    echo "$LATEST_TAG"
}

# Function to update Dockerfile
update_dockerfile() {
    local new_tag="$1"
    local dockerfile_path=".devcontainer/Dockerfile"
    
    if [ ! -f "$dockerfile_path" ]; then
        echo "ERROR: Dockerfile not found at $dockerfile_path"
        return 1
    fi
    
    # Get current FROM line
    current_from=$(grep "^FROM hexpm/elixir:" "$dockerfile_path")
    echo "Current FROM line: $current_from"
    
    # Create new FROM line
    new_from="FROM hexpm/elixir:$new_tag"
    echo "New FROM line: $new_from"
    
    # Update the Dockerfile
    sed -i "s|^FROM hexpm/elixir:.*|$new_from|" "$dockerfile_path"
    
    echo "✅ Dockerfile updated successfully!"
    
    # Show the change
    echo "Updated FROM line:"
    grep "^FROM hexpm/elixir:" "$dockerfile_path"
}

# Function to validate the new tag exists
validate_tag() {
    local tag="$1"
    echo "Validating tag exists: $tag"
    
    if docker manifest inspect "hexpm/elixir:$tag" >/dev/null 2>&1; then
        echo "✅ Tag validation successful"
        return 0
    else
        echo "❌ Tag validation failed"
        return 1
    fi
}

# Main execution
main() {
    echo "Starting Elixir Docker image update process..."
    
    # Get latest tag
    LATEST_TAG=$(get_latest_elixir_tag)
    
    if [ -z "$LATEST_TAG" ]; then
        echo "ERROR: Could not determine latest tag"
        exit 1
    fi
    
    echo "Latest stable tag found: $LATEST_TAG"
    
    # Validate tag exists
    if validate_tag "$LATEST_TAG"; then
        # Update Dockerfile
        update_dockerfile "$LATEST_TAG"
        echo "✅ Update completed successfully!"
        echo "Remember to rebuild your devcontainer to use the new image."
    else
        echo "❌ Tag validation failed, not updating Dockerfile"
        exit 1
    fi
}

# Check if running in dry-run mode
if [ "$1" = "--dry-run" ]; then
    echo "=== DRY RUN MODE ==="
    LATEST_TAG=$(get_latest_elixir_tag)
    echo "Would update to: $LATEST_TAG"
    echo "Current Dockerfile FROM line:"
    grep "^FROM hexpm/elixir:" .devcontainer/Dockerfile 2>/dev/null || echo "Dockerfile not found"
    exit 0
fi

# Run main function
main