# Amazon Web Services Request Signatures

**aws.signature** is a simple R package to create request signatures for Amazon Web Services (AWS) RESTful APIs.

To use the package, you will need an AWS account and enter your credentials into R. Your keypair can be generated on the [IAM Management Console](https://aws.amazon.com/) under the heading *Access Keys*. Note that you only have access to your secret key once. After it is generated, you need to save it in a secure location. New keypairs can be generated at any time if yours has been lost, stolen, or forgotten. 

By default, all **cloudyr** packages look for the access key ID and secret access key in environment variables. You can also use this to specify a default region or a temporary "session token". For example:

```R
Sys.setenv("AWS_ACCESS_KEY_ID" = "mykey",
           "AWS_SECRET_ACCESS_KEY" = "mysecretkey",
           "AWS_DEFAULT_REGION" = "us-east-1",
           "AWS_SESSION_TOKEN" = "mytoken")
```

These can alternatively be set on the command line prior to starting R or via an `Renviron.site` or `.Renviron` file, which are used to set environment variables in R during startup (see `? Startup`).

If you work with multiple AWS accounts, another option that is consistent with other Amazon SDKs is to create [a centralized `~/.aws/credentials` file](https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs), containing credentials for multiple accounts. You can then use credentials from this file on-the-fly by simply doing:

```R
# use your 'default' account credentials
use_credentials()

# use an alternative credentials profile
use_credentials(profile = "bob")
```

Temporary session tokens are stored in environment variable `AWS_SESSION_TOKEN` (and will be stored there by the `use_credentials()` function). The [aws.iam package](https://github.com/cloudyr/aws.iam/) provides an R interface to IAM roles and the generation of temporary session tokens via the security token service (STS).

## Installation

[![CRAN](https://www.r-pkg.org/badges/version/aws.signature)](https://cran.r-project.org/package=aws.signature)
![Downloads](https://cranlogs.r-pkg.org/badges/aws.signature)
[![Build Status](https://travis-ci.org/cloudyr/aws.signature.png?branch=master)](https://travis-ci.org/cloudyr/aws.signature) 
[![codecov.io](https://codecov.io/github/cloudyr/aws.signature/coverage.svg?branch=master)](https://codecov.io/github/cloudyr/aws.signature?branch=master)

To install the latest package version, it is recommended to install from the cloudyr drat repository:

```R
# latest stable version
install.packages("aws.signature", repos = c(cloudyr = "http://cloudyr.github.io/drat", getOption("repos")))
```

Or, to pull a potentially unstable version directly from GitHub:

```R
if (!require("ghit")) {
    install.packages("ghit")
}
ghit::install_github("cloudyr/aws.signature")
```

To install the latest version from CRAN, simply use `install.packages("aws.signature")`.

---
[![cloudyr project logo](http://i.imgur.com/JHS98Y7.png)](https://github.com/cloudyr)
