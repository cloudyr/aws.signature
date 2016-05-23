\name{string_to_sign}
\alias{string_to_sign}
\title{Construct a String To Sign}
\description{Construct a String to Sign from request elements}
\usage{
string_to_sign(algorithm = "AWS4-HMAC-SHA256",
               datetime, region = getOption(Sys.getenv("AWS_DEFAULT_REGION"), "us-east-1"), 
               service, request_hash)
}
\arguments{
    \item{algorithm}{A character string containing the hashing algorithm used in signing process. Should only be \dQuote{AWS4-HMAC-SHA256}.}
    \item{datetime}{A character string containing a UTC date in the form of \dQuote{YYYYMMDDTHHMMSSZ}.}
    \item{region}{A character string containing the AWS region for the request.}
    \item{service}{A character string containing the AWS service (e.g., \dQuote{iam}, \dQuote{host}, \dQuote{ec2}).}
    \item{request_hash}{A character string containing the hash of the canonical request, perhaps as returned by \code{\link{canonical_request}}.}
}
\details{This function creates a \dQuote{String To Sign}, which is part of the Signature Version 4.}
\author{Thomas J. Leeper <thosjleeper@gmail.com>}
\references{
\href{http://docs.aws.amazon.com/general/latest/gr/sigv4-create-string-to-sign.html}{Create a String to Sign for Signature Version 4}
}
%\keyword{}
\seealso{
\code{\link{signature_v4}}
\code{\link{signature_v4_auth}}
}
\examples{
# From AWS documentation
rh <- "3511de7e95d28ecd39e9513b642aee07e54f4941150d8df8bf94b328ef7e55e2"
sts <- 
string_to_sign(datetime = "20110909T233600Z",
               region = "us-east-1",
               service = "iam",
               request_hash = rh)
identical(sts, "AWS4-HMAC-SHA256
20110909T233600Z
20110909/us-east-1/iam/aws4_request
3511de7e95d28ecd39e9513b642aee07e54f4941150d8df8bf94b328ef7e55e2")
}
