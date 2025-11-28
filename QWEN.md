# Ainski's Blog - Project Overview

## Project Type
This is a **Jekyll-based static blog/website** built using the Jekyll Now template. It's a personal blog hosted at `https://ainski.github.io` that focuses on computer science topics, particularly academic content related to computer systems and architecture.

## Project Structure
- `_posts/` - Contains all blog posts in Markdown format, organized by date
- `_layouts/` - Jekyll layout templates (default.html, page.html, post.html)
- `_includes/` - Reusable HTML components
- `_sass/` - SCSS stylesheets
- `archive/`, `tags/` - Archive and tag pages for organizing content
- `images/` - Image assets
- `js/` - JavaScript files (including search functionality)
- `about.md` - Author biography
- `index.html` - Main page with search functionality

## Content Focus
The blog primarily covers academic and technical topics, with a focus on:
- Computer science concepts (like pipeline CPU analysis in the example post)
- Computer systems architecture
- Academic course reviews and explanations
- Technical tutorials and explanations

## Key Features
1. **Search Functionality** - Integrated with simple-jekyll-search for easy content discovery
2. **Tag System** - Posts are categorized using tags for better organization
3. **Pagination** - Blog posts are paginated (8 per page)
4. **Comment System** - Uses Gitalk for post comments
5. **Statistics** - Includes visitor statistics using Busuanzi
6. **Mobile Responsive** - Responsive design for various devices

## Configuration (`_config.yml`)
- Site name: "Ainski's Blog"
- Description: "Ainski's Code and Blog"
- Author: Ainski (a Tongji University computer science student)
- Disqus and Gitalk integration for comments
- Social media links and footer text
- Pagination settings and SEO configuration

## Development Setup
This is a Jekyll site that can be developed locally with:
```bash
# Install Jekyll and Bundler gems
gem install jekyll bundler

# Install dependencies
bundle install

# Run the site locally
bundle exec jekyll serve
```

## Writing Posts
- Posts are stored in `_posts/` directory
- File naming convention: `YYYY-MM-DD-title.md`
- Posts use YAML front matter for metadata (title, date, tags, layout, etc.)
- Written in Markdown format with support for LaTeX math expressions

## Deployment
- Hosted on GitHub Pages via the user repository (ainski.github.io)
- Uses Jekyll plugins for sitemap, RSS feed, and pagination
- Custom domain configured via CNAME file

## Author Information
The blog is maintained by Ainski, a computer science student at Tongji University (class of 2023), with content focusing on technical and academic subjects related to computer systems and architecture.