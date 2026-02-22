---
layout: post
title: "git commit 规范"
date:   2026-02-22
tags: [教程]
comments: true
author: Ainski
---

# Conventional Commits

请参照[约定式提交](https://www.conventionalcommits.org/zh-hans/v1.0.0/#约定式提交规范)

## 1 表述规范

```
<类型>[范围]:<描述>
[可选 正文]
[可选 脚注]
```

其中类型包括

- fix 修复了某个bug
- feat 新增了某个功能
- build 一些影响构建系统的更新
- chore 一些不更改核心系统的更新
- ci 变更了一些ci系统的配置
- docs 文档
- test 新增或修改测试文件
- refactor 重构了代码，无新增

| Commit Type | Title                    | Description                                                  | Emoji | Release                        | Include in changelog |
| ----------- | ------------------------ | ------------------------------------------------------------ | ----- | ------------------------------ | -------------------- |
| `feat`      | Features                 | A new feature                                                | ✨     | `minor`                        | `true`               |
| `fix`       | Bug Fixes                | A bug Fix                                                    | 🐛     | `patch`                        | `true`               |
| `docs`      | Documentation            | Documentation only changes                                   | 📚     | `patch` if `scope` is `readme` | `true`               |
| `style`     | Styles                   | Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc) | 💎     | -                              | `true`               |
| `refactor`  | Code Refactoring         | A code change that neither fixes a bug nor adds a feature    | 📦     | -                              | `true`               |
| `perf`      | Performance Improvements | A code change that improves performance                      | 🚀     | `patch`                        | `true`               |
| `test`      | Tests                    | Adding missing tests or correcting existing tests            | 🚨     | -                              | `true`               |
| `build`     | Builds                   | Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm) | 🛠     | `patch`                        | `true`               |
| `ci`        | Continuous Integrations  | Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs) | ⚙️     | -                              | `true`               |
| `chore`     | Chores                   | Other changes that don't modify src or test files            | ♻️     | -                              | `true`               |
| `revert`    | Reverts                  | Reverts a previous commit                                    | 🗑     | -                              | `true`               |