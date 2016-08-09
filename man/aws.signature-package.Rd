\name{aws.signature-package}
\alias{aws.signature-package}
\alias{aws.signature}
\docType{package}
\title{Amazon Web Services Request Signatures}
\description{Generates Amazon Web Services (AWS) request signatures for RESTful APIs.}
\details{This package contains functions mostly intended for developers to use in building API client packages for Amazon Web Services APIs.

The main function of interest is \code{\link{signature_v4_auth}}, which wraps the other internal functions and returns a named list of elements to be used in authenticating an API request using AWS Signature Version 4.

Another function, \code{\link{signature_v2_auth}} implements the older, mostly deprecated Version 2 algorithm.

A function that may be of use to end users is \code{\link{use_credentials}}, which sets the environment variables used by this package based upon values specified in a \samp{.aws/credentials} file.
}
\author{Thomas J. Leeper <thosjleeper@gmail.com>}
%\references{}
\keyword{ package }
%\seealso{}
%\examples{}
