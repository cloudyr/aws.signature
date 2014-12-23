\name{signature_v4_auth}
\alias{signature_v4_auth}
\title{Signature Version 4}
\description{AWS Signature Version 4 for use in query or header authorization}
\usage{
signature_v4_auth(datetime, region, service, verb,
                  action, query_string = "",
                  canonical_headers, request_body,
                  key, secret, query = FALSE, algorithm = "SHA256")
}
\arguments{
    \item{datetime}{A character string containing a datetime in the form of \dQuote{YYMMDDTHHMMSSZ}. If missing, it is generated automatically using \code{\link[base]{Sys.time}}.}
    \item{region}{A character string containing the AWS region for the request.}
    \item{service}{A character string containing the AWS service (e.g., \dQuote{iam}, \dQuote{host}, \dQuote{ec2}).}
    \item{verb}{A character string containing the HTTP verb being used in the request.}
    \item{action}{A character string containing the API endpoint used in the request.}
    \item{query_string}{A character string containing the query string (if any) used in the API request.}
    \item{canonical_headers}{A named list of character strings containing the headers used in the request.}
    \item{request_body}{The body of the HTTP request.}
    \item{key}{An AWS Access Key ID. If missing, it is retrieved using \code{Sys.getenv("AWS_ACCESS_KEY_ID")}}
    \item{secret}{An AWS Secret Access Key. If missing, it is retrieved using \code{Sys.getenv("AWS_SECRET_ACCESS_KEY")}}
    \item{query}{A logical. Currently ignored.}
    \item{algorithm}{A character string containing the hashing algorithm used in the request. Should only be \dQuote{SHA256}.}
}
\details{This function generates an AWS Signature Version 4 for authorizing API requests.}
\value{A list of class \dQuote{aws_signature_v4}, containing the information needed to sign an AWS API request using either query string authentication or request header authentication. Specifically, the list contains:

    \item{Algorithm}{A character string containing the hashing algorithm used during the signing process (default is SHA256).}
    \item{Credential}{A character string containing an identifying credential \dQuote{scoped} to the region, date, and service of the request.}
    \item{Date}{A character string containing a YYYYMMDD-formatted date.}
    \item{SignedHeaders}{A character string containing a semicolon-separated listing of request headers used in the signature.}
    \item{Signature}{A character string containing a request signature hash.}
    
These values can either be used as query parameters in a REST-style API request, or as request headers. If authentication is supplied via query string parameters, the query string should include the following:

Action=\code{action}
&X-Amz-Algorithm=\code{Algorithm}
&X-Amz-Credential=\code{URLencode(Credentials)}
&X-Amz-Date=\code{Date}
&X-Amz-Expires=\code{timeout}
&X-Amz-SignedHeaders=\code{SignedHeaders}

where \code{action} is the API endpoint being called and \code{timeout} is a numeric value indicating when the request should expire.

If signing a request using header-based authentication, the \dQuote{Authorization} header in the request should be included with the request that looks as follows:

Authorization: \code{Algorithm} Credential=\code{Credential}, SignedHeaders=\code{SignedHeaders}, Signature=\code{Signature}

This is the value printed by default for all objects of class \dQuote{aws_signature_v4}.
}
\author{Thomas J. Leeper <thosjleeper@gmail.com>}
\references{
\href{http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html}{AWS General Reference: Signature Version 4 Signing Process}

\href{http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html}{Amazon S3 API Reference: Authenticating Requests (AWS Signature Version 4)}

\href{Add the Signing Information to the Request}{http://docs.aws.amazon.com/general/latest/gr/sigv4-add-signature-to-request.html}
}
%\keyword{}
\seealso{
\code{\link{signature_v4}}
}
%\examples{}
