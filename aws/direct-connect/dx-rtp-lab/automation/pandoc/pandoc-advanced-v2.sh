#!/usr/bin/env bash

# Set the base directory
BASE_DIR="$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")"

# Function to generate HTML from markdown
generate_html() {
    local input_file="$1"
    local output_file="${input_file%.md}.html"
    local css_file="${BASE_DIR}/style.css"
    local resource_path="${BASE_DIR}"

    echo "Generating HTML for $input_file..."
    if pandoc "$input_file" -s -o "$output_file" --self-contained -c "$css_file" --resource-path="$resource_path"; then
        echo "Successfully generated $output_file"
    else
        echo "Error generating $output_file" >&2
        exit 1
    fi
}

echo "Starting HTML generation..."

# Array of markdown files to convert
markdown_files=("AWS-DX-Topology.md" "AWS-DX-RTP-LAB.md" "AWS-DX-Telemetry.md")

# Loop through each markdown file and generate HTML
for md_file in "${markdown_files[@]}"; do
    full_md_file="${BASE_DIR}/${md_file}"
    generate_html "$full_md_file"
done

echo "Done generating HTML files."
