#!/bin/bash

# Clean old generated files
flutter pub run build_runner clean

# Generate new files
flutter pub run build_runner build --delete-conflicting-outputs 