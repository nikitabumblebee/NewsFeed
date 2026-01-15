#
//  format.sh
//  HealthTracker
//
//  Created by Nikita Shmelev on 25.12.2025.
//

#!/bin/bash
set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

SOURCE_DIR="${1:-.}"

echo "Starting SwiftFormat..."
mint run swiftformat "$SOURCE_DIR" --swiftversion 6.0
echo "SwiftFormat completed!"
