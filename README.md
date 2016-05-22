# Amazon Web Services Request Signatures #

**aws.signature** is a simple R package to create request signatures for Amazon Web Services (AWS) RESTful APIs.

To use the package, you will need an AWS account and enter your credentials into R. Your keypair can be generated on the [IAM Management Console](https://aws.amazon.com/) under the heading *Access Keys*. Note that you only have access to your secret key once. After it is generated, you need to save it in a secure location. New keypairs can be generated at any time if yours has been lost, stolen, or forgotten. 

By default, all **cloudyr** packages look for the access key ID and secret access key in environment variables. You can also use this to specify a default region. For example:

```R
Sys.setenv("AWS_ACCESS_KEY_ID" = "mykey",
           "AWS_SECRET_ACCESS_KEY" = "mysecretkey",
           "AWS_DEFAULT_REGION" = "us-east-1")
```

These can alternatively be set on the command line or via an `Renviron.site` or `.Renviron` file ([see here for instructions](http://cran.r-project.org/web/packages/httr/vignettes/api-packages.html)).

## Installation ##

[![CRAN](http://www.r-pkg.org/badges/version/aws.signature)](http://cran.r-project.org/package=aws.signature)
[![Build Status](https://travis-ci.org/cloudyr/aws.signature.png?branch=master)](https://travis-ci.org/cloudyr/aws.signature) 
[![codecov.io](http://codecov.io/github/cloudyr/aws.signature/coverage.svg?branch=master)](http://codecov.io/github/cloudyr/aws.signature?branch=master)

There is little reason to install this package directly (without also installing a client package for a particular AWS API), but to install the latest version you can install from the cloudyr drat repository:

```R
# latest stable version
install.packages("aws.signature", repos = c(getOption("repos"), "http://cloudyr.github.io/drat"))
```

Or, to pull a potentially unstable version directly from GitHub:

```R
if(!require("ghit")){
    install.packages("ghit")
}
ghit::install_github("cloudyr/aws.signature")
```

To install the latest version from CRAN, simply use `install.packages("aws.signature")`.

---
[![cloudyr project logo](http://i.imgur.com/JHS98Y7.png)](https://github.com/cloudyr)
