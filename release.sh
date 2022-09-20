#!/usr/bin/env bash
set -euo pipefail

# Release script
#
# Usage:
# 1. Set new version in mix.exs
# 2. Commit and push
# 3. Run ./release.sh
# 4. Let .github/workflows/publish.yml to publish

version=$(mix run -e 'IO.puts(Mix.Project.config[:version])')
git tag "v$version"
git push origin "v$version"
