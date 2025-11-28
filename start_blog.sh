#!/bin/bash

# Script to start Ainski's Blog locally in Ubuntu

echo "Starting Ainski's Blog locally..."
echo "Checking prerequisites..."

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
    echo "Error: Ruby is not installed. Please install Ruby (version 2.5.0 or higher)."
    echo "You can install it using: sudo apt install ruby-full"
    exit 1
fi

# Check Ruby version
RUBY_VERSION=$(ruby -v | cut -d' ' -f2 | cut -d'.' -f1,2)
RUBY_MAJOR=$(echo $RUBY_VERSION | cut -d'.' -f1)
RUBY_MINOR=$(echo $RUBY_VERSION | cut -d'.' -f2)

if [ "$RUBY_MAJOR" -lt 2 ] || { [ "$RUBY_MAJOR" -eq 2 ] && [ "$RUBY_MINOR" -lt 5 ]; }; then
    echo "Error: Ruby version is too old. Please install Ruby version 2.5.0 or higher."
    exit 1
fi

echo "Ruby version $RUBY_VERSION is installed."

# Check if Bundler is installed
if ! command -v bundle &> /dev/null; then
    echo "Bundler is not installed. Installing Bundler..."
    sudo gem install bundler
fi

# Check if Jekyll is installed
if ! command -v jekyll &> /dev/null; then
    echo "Jekyll is not installed. Installing Jekyll..."
    sudo gem install jekyll
fi

echo "Bundler and Jekyll are installed."

# Install project dependencies
echo "Installing project dependencies..."
bundle install

# Start the Jekyll server
echo "Starting Jekyll server..."
echo "Your blog will be available at http://127.0.0.1:4000"
echo "Press Ctrl+C to stop the server."

bundle exec jekyll serve --watch --incremental