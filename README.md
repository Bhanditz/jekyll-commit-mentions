# Jekyll Commit Mentions

Github commit sha mention support for your Jekyll site

[![Gem Version](https://badge.fury.io/rb/jekyll-commit-mentions.png)](http://badge.fury.io/rb/jekyll-commit-mentions)
[![Build Status](https://travis-ci.org/workato/jekyll-commit-mentions.svg?branch=master)](https://travis-ci.org/workato/jekyll-commit-mentions)

## Usage

Add the following to your site's `Gemfile`

```
gem 'jekyll-commit-mentions'
```

And add the following to your site's `_config.yml`

```yml
gems:
  - jekyll-commit-mentions
```

In any page or post, use commit SHA id as you would normally, e.g.

```markdown
Refer to this commit a5c3785ed8d6a35868bc169f07e40e889087fd2e for more
details
```

## Configuration

Set the Github repo url:

```yaml
jekyll-commit-mentions:
  base_url: https://github.com/workato/jekyll-commit-mentions/commit
```

Or, you can use this shorthand:

```yaml
jekyll-commit-mentions: https://github.com/workato/jekyll-commit-mentions/commit
```
