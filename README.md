# PodLocalize

本库是用来同步 CocoaPods 包到本地 Gitlab 仓库。



## 如何使用本包

### build

``` bash
$ bundle update

$ gem build pod-localize.gemspec
# 会生成一个 .gem 文件 > pod-localize-0.2.0.gem
```


### Install

```bash
$ gem install pod-localize-0.2.0.gem --local
```


### RUN


``` ruby
$ pod-localize sync config.yml
```



## Config

XNGPodSynchronizer takes a `config.yml` as an argument an example `Yaml` would look like this:

```yaml
# config.yml
---
master_repo: https://github.com/CocoaPods/Specs.git
mirror:
  specs_push_url: git@git.hooli.xyz:pods-mirror/Specs.git
  source_push_url: git@git.hooli.xyz:pods-mirror
  source_clone_url: git://git.hooli.xyz/pods-mirror
  github:
    acccess_token: 0y83t1ihosjklgnuioa
    organisation: pods-mirror
    endpoint: https://git.hooli.xyz/api/v3
podfiles:
  - "https://git.hooli.xyz/ios/moonshot/raw/master/Podfile.lock"
  - "https://git.hooli.xyz/ios/nucleus/raw/master/Podfile.lock"
  - "https://git.hooli.xyz/ios/bro2bro/raw/master/Podfile.lock"
```

|key|meaning|
|:----|:----|
|master_repo|CocoaPods master repository (usually: https://github.com/CocoaPods/Specs.git)|
|mirror.specs_push_url|Git URL used to clone & push the mirrored specs|
|mirror.source_push_url|Git URL used to push the mirrored repositories|
|mirror.source_clone_url|Git URL used to change the download URLs in the podspecs|
|mirror.github.access_token|Access token used to create new repositories|
|mirror.github.organisation|The GitHub organization used for mirrored repositories|
|mirror.github.endpoint|API Endpoint of your GitHub api|
|podfiles|List of __Podfile.lock__ in __Plain Text__ format|

We use Jenkins to run the synchronize process twice daily. To do that use the following command:

```
$ pod-synchronize synchronize config.yml
```


## TODO

- 现在是代码都存在 tmp 里，每次都需要重新接取（git clone），而不能更新 （git pull）。比较慢。
- 有些项目用的是文件引用，而不是源码引用，下载文件时，依然很慢。
