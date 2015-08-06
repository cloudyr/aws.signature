\name{signature_v4}
\alias{signature_v4}
\title{Signature Version 4}
\description{Generates AWS Signature Version 4}
\usage{
signature_v4(secret = Sys.getenv("AWS_SECRET_ACCESS_KEY", NULL), 
             date = format(Sys.time(), "\%Y\%m\%d"), 
             region = Sys.getenv("AWS_DEFAULT_REGION", "us-east-1"), 
             service, string_to_sign)
}
\arguments{
    \item{secret}{An AWS Secret Access Key. If missing, it is retrieved using \code{Sys.getenv("AWS_SECRET_ACCESS_KEY")}}
    \item{date}{A character string containing a date in the form of \dQuote{YYMMDD}. If missing, it is generated automatically using \code{\link[base]{Sys.time}}.}
    \item{region}{A character string containing the AWS region for the request. By default, the \dQuote{us-east-1} region.}
    \item{service}{A character string containing the AWS service (e.g., \dQuote{iam}, \dQuote{host}, \dQuote{ec2}).}
    \item{string_to_sign}{A character string containing the String To Sign, possibly returned by \code{\link{string_to_sign}}}
}
\details{This function generates an AWS Signature Version 4 for authorizing API requests.}
\author{Thomas J. Leeper <thosjleeper@gmail.com>}
\references{
\href{http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html}{AWS General Reference: Signature Version 4 Signing Process}

\href{http://docs.aws.amazon.com/general/latest/gr/signature-v4-examples.html}{AWS General Reference: Examples of How to Derive a Version 4 Signing Key}

\href{http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html}{Amazon S3 API Reference: Authenticating Requests (AWS Signature Version 4)}
}
%\keyword{}
%\seealso{}
\examples{
# From AWS documentation
# http://docs.aws.amazon.com/general/latest/gr/signature-v4-test-suite.html
StringToSign <- "AWS4-HMAC-SHA256
20110909T233600Z
20110909/us-east-1/host/aws4_request
e25f777ba161a0f1baf778a87faf057187cf5987f17953320e3ca399feb5f00d"

sig <- 
signature_v4(secret = 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY',
             date = '20110909',
             region = 'us-east-1',
             service = 'host',
             string_to_sign = StringToSign)
identical(sig, "be7148d34ebccdc6423b19085378aa0bee970bdc61d144bd1a8c48c33079ab09")


# http://docs.aws.amazon.com/general/latest/gr/sigv4-calculate-signature.html
StringToSign <- "AWS4-HMAC-SHA256
20110909T233600Z
20110909/us-east-1/iam/aws4_request
3511de7e95d28ecd39e9513b642aee07e54f4941150d8df8bf94b328ef7e55e2"

sig <- 
signature_v4(secret = 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY',
             date = '20110909',
             region = 'us-east-1',
             service = 'iam',
             string_to_sign = StringToSign)
identical(sig, "ced6826de92d2bdeed8f846f0bf508e8559e98e4b0199114b84c54174deb456c")
}
