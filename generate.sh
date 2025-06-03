#!/bin/bash

# Clean old generated files
dart pub run build_runner clean

# Generate new files
dart pub run build_runner build --delete-conflicting-outputs 