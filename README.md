# Amazon Web Services Request Signatures #

**aws.signature** is a simple R package to create request signatures for Amazon Web Services (AWS) RESTful APIs.

## Installation ##

[![Build Status](https://travis-ci.org/cloudyr/aws.signature.png?branch=master)](https://travis-ci.org/cloudyr/aws.signature) [![codecov.io](http://codecov.io/github/cloudyr/aws.signature/coverage.svg?branch=master)](http://codecov.io/github/cloudyr/aws.signature?branch=master)

There is little reason to install this package directly (without also installing a client package for a particular AWS API), but to install the latest development version from GitHub, run the following:

```R
if(!require("devtools")){
    install.packages("devtools")
    library("devtools")
}
install_github("cloudyr/aws.signature")
```

To install the latest version from CRAN, simply use `install.packages("aws.signature")`.

---
[![cloudyr project logo](http://i.imgur.com/JHS98Y7.png)](https://github.com/cloudyr)
