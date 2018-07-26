# Amazon Web Services Request Signatures

**aws.signature** is a package for creating request signatures for Amazon Web Services (AWS) APIs. It supports both the current [Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html) and the legacy [Signature Version 2](http://docs.aws.amazon.com/general/latest/gr/signature-version-2.html). The former is used by most services. The high-level functions `signature_v4_auth()` and `signature_v2_auth()` translate request parameters into appropriate HTTP Authorization headers to pass to the APIs.

To use the package, you will need an AWS account and to enter your credentials into R. Your keypair can be generated on the [IAM Management Console](https://aws.amazon.com/) under the heading *Access Keys*. Note that you only have access to your secret key once. After it is generated, you need to save it in a secure location. New keypairs can be generated at any time if yours has been lost, stolen, or forgotten. The [**aws.iam** package](https://github.com/cloudyr/aws.iam) profiles tools for working with IAM, including creating roles, users, groups, and credentials programmatically; it is not needed to *use* IAM credentials.

By default, when loaded the package checks for environment variables. If absent, it checks for a default credentials file and loads credentials from it into environment variables; the profile used from that file can be regulated by setting the `AWS_PROFILE` environment variable before loading this package (the `"default" profile is assumed if none is specified). This means the package and any dependencies should *just work* without needing to explicitly set or pass credentials within R code.

Regardless of this initial configuration, all **awspack** packages allow the use of credentials specified in a number of ways, in the following priority order:

 1. User-supplied values passed directly to functions.
 2. Environment variables, which can alternatively be set on the command line prior to starting R or via an `Renviron.site` or `.Renviron` file, which are used to set environment variables in R during startup (see `? Startup`). Or they can be set within R:
 
    ```R
    Sys.setenv("AWS_ACCESS_KEY_ID" = "mykey",
               "AWS_SECRET_ACCESS_KEY" = "mysecretkey",
               "AWS_DEFAULT_REGION" = "us-east-1",
               "AWS_SESSION_TOKEN" = "mytoken")
    ```
 3. If R is running on an EC2 instance, the role profile credentials provided by [**aws.ec2metadata**](https://cran.r-project.org/package=aws.ec2metadata), *if the **aws.ec2metadata** package is installed*.
 4. If R is running on an ECS task, the role profile credentials provided by [**aws.ec2metadata**](https://cran.r-project.org/package=aws.ec2metadata), *if the **aws.ec2metadata** package is installed*.
 5. Profiles saved in a `/.aws/credentials` "dot file" in the current working directory. The profile used can be regulated by the `AWS_PROFILE` environment variable, otherwise the `"default" profile is assumed if none is specified or the specified profile is missing.
 6. [A centralized credentials file](https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs), containing credentials for multiple accounts. The location of this file is given by the `AWS_SHARED_CREDENTIALS_FILE` environment variable or, if that is missing, by `~/.aws/credentials` (or an OS-specific equivalent). The profile used from that file can be regulated by the `AWS_PROFILE` environment variable, otherwise the `"default" profile is assumed if none is specified or the specified profile is missing.

Because all functions requesting a signature walk this entire list of potential credentials sources, it typically makes sense to set environment variables otherwise a potentially large performance penalty can be paid. For this reason, it is usually better to explicitly invoke a profiles stored in a local or centralized (e.g., `~/.aws/credentials`) credentials file using:

```R
# use your 'default' account credentials
use_credentials()

# use an alternative credentials profile
use_credentials(profile = "bob")
```

For purposes of debugging, it can be useful to set the `verbose = TRUE` argument (or globally set `options(verbose = TRUE)`) in order to see what values are being used for signing requests.

Temporary session tokens are stored in environment variable `AWS_SESSION_TOKEN` (and will be stored there by the `use_credentials()` function). The [aws.iam package](https://github.com/cloudyr/aws.iam/) provides an R interface to IAM roles and the generation of temporary session tokens via the security token service (STS). On EC2 instances or ECS tasks, the [**aws.ec2metadata**](https://cran.r-project.org/package=aws.ec2metadata) package should be installed so that signatures are signed with appropriate, dynamically updated credentials.

As a fail safe the `us-east-1` region is used whenever a region is not found.

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
if (!require("remotes")) {
    install.packages("remotes")
}
remotes::install_github("cloudyr/aws.signature")
```

To install the latest version from CRAN, simply use `install.packages("aws.signature")`.

---
[![cloudyr project logo](http://i.imgur.com/JHS98Y7.png)](https://github.com/cloudyr)
