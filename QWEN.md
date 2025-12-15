# Ainski's Blog - Project Overview

## Project Description
Ainski's Blog is a Jekyll-based static blog hosted on GitHub Pages. It's a personal blog featuring technical tutorials, course reviews, literary creations, and algorithm solutions. The blog is maintained by Ainski (GitHub: Ainski), who describes himself as a Tongji University undergraduate student studying Computer Science and Technology.

## Technologies Used
- **Jekyll**: Static site generator
- **SCSS**: Styling with modular components
- **HTML**: Static page templating
- **JavaScript**: Search functionality and Gitalk integration
- **Markdown**: Blog post content creation

## Site Configuration
The blog is configured in `_config.yml` with the following notable features:
- Pagination enabled (8 posts per page)
- Header navigation with Blog, About, Archive, Tags, and Likes sections
- Social media links (GitHub, Email)
- Gitalk for comments
- Custom search functionality
- Busuanzi visitor statistics included

## Directory Structure
```
D:\Gitblog\
├── _config.yml           # Jekyll configuration
├── README.md             # Basic copyright notice
├── about.md              # Author information
├── index.html            # Homepage with search and pagination
├── CNAME                 # Custom domain configuration
├── style.scss            # Main stylesheet (compiled to style.css)
├── _includes/            # Reusable components (head, nav, footer, etc.)
├── _layouts/             # Page templates (default, post, page)
├── _posts/               # Blog posts organized by date
├── _sass/                # SCSS partials
├── archive/              # Archive page
├── js/                   # JavaScript files
├── tags/                 # Tags index page
├── images/               # Image assets
└── ...
```

## Blog Post Format
Posts are written in Markdown and stored in the `_posts` directory with the naming convention `YYYY-MM-DD-title.md`. Each post contains:
- YAML front matter with title, date, tags, layout, etc.
- Content with detailed explanations and examples
- Tagging system for categorization

## Key Features
1. **Search Functionality**: Custom search using Simple-Jekyll-Search
2. **Tag System**: Organized tags with dedicated tag index page
3. **Archive System**: Chronologically organized posts
4. **Comment System**: Gitalk integration for post comments
5. **Responsive Design**: Mobile-friendly layout
6. **Visitor Statistics**: Integrated Busuanzi statistics
7. **TOC (Table of Contents)**: For posts with many headings
8. **Pagination**: For easier browsing of posts

## Development Conventions
- Posts are categorized using tags (e.g., "教程" for tutorials, "学校课程复习" for course reviews)
- Chinese titles and content are used throughout
- Gitalk is configured for post comments with GitHub OAuth
- SCSS modular architecture for maintainable styling

## Building and Running
To build and run the blog locally:

1. Install Jekyll and Bundler gems:
   ```
   gem install jekyll bundler
   ```

2. Install dependencies:
   ```
   bundle install
   ```

3. Run the development server:
   ```
   bundle exec jekyll serve
   ```

4. Visit `http://localhost:4000` to view the site

## Content Themes
The blog covers diverse topics including:
- Technical tutorials (Redis configuration, leetcode solutions, database concepts)
- School course reviews in Computer Science subjects (AI, Operating Systems, Computer Networks, Algorithms)
- Literary creations and book reviews
- Programming exercises and algorithm explanations

## Copyright Information
According to the README, all blog posts in the `_posts` folder are copyrighted by Ainski and require authorization for reproduction.