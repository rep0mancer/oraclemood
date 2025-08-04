#!/bin/bash

##
# Generates strongly typed accessors for localized strings using SwiftGen.
# This script should be run whenever strings files change. The output is
# stored in the `Generated` directory of the app target.
##

set -euo pipefail

project_root=$(dirname "$0")/..

swiftgen config run --config "$project_root/swiftgen.yml"

