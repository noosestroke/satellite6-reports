# satellite6-reports

Tools package to generate Linux host and package report from Satellite 6 API.

## Pre-requisites for sucessfull build

Some ruby gems are required for offline gem install. Use bundler to install \*.gem files to SOURCES/vendor/cache :

```
cd SOURCES && bundle package
```

## Build package

`rpmbuild --bb --prod SPECS/jb_lxreport.spec`
