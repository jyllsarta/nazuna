# nazuna

A interpolation of [ghkw](https://github.com/kyoshidajp/ghkw) by ruby.

- - -

## Description

Works almost same as [ghkw](https://github.com/kyoshidajp/ghkw).

Using GitHub API v3, compares count of keyword used all public repository.

## Requirement

* Ruby
    * HTTParty

## Usage

```
$ export GITHUB_TOKEN='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$ ruby nazuna.rb fire flame burn
| RANK | KEYWORD |  TOTAL   |
|------|---------|----------|
|    1 |    fire | 80289147 |
|    2 |    burn |  6358959 |
|    3 |   flame |  3432800 |
```

## Install

* clone
* set Environmental valiable 'GITHUB_TOKEN' by your GitHub access token with full repository access.

## Licence

MIT

## Author

[jyllsarta](jyllsarta.net)
