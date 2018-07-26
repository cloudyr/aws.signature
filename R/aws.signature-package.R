#' @name aws.signature-package
#' @aliases aws.signature-package aws.signature
#' @docType package
#' @title Amazon Web Services Request Signatures
#' @description Generates Amazon Web Services (AWS) request signatures for RESTful APIs.
#' @details This package contains functions mostly intended for developers to use in building API client packages for Amazon Web Services APIs.
#' 
#' The main function of interest is \code{\link{signature_v4_auth}}, which wraps the other internal functions and returns a named list of elements to be used in authenticating an API request using AWS Signature Version 4. Another function, \code{\link{signature_v2_auth}} implements the older, mostly deprecated Version 2 algorithm.
#' 
#' Recent versions of the package (>= 0.2.8) identify credentials by walking through a tree of possible sources of values (described in \code{\link{locate_credentials}}), with optional verbosity, in a manner similar to the Python boto 3 library.
#' 
#' A lower-level function that may be of use to end users is \code{\link{use_credentials}}, which sets the environment variables used by this package based upon values specified in a \samp{.aws/credentials} file. That function is called by default during package load, if no environment variables are set.
#' 
#' To use this (and any cloudyr package) on AWS EC2 instances or ECS tasks, users will also need to install the \href{https://cran.r-project.org/package=aws.ec2metadata}{aws.ec2metadata} package, which allows \code{\link{locate_credentials}} to know it is running in an instance and check for relevant values.
#' 
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @keywords package
#' @seealso \code{\link{signature_v4_auth}}, \code{\link{signature_v2_auth}}, \code{\link{locate_credentials}}, \code{\link{use_credentials}}
NULL
