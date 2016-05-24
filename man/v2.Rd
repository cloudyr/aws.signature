\name{signature_v2}
\alias{signature_v2_auth}
\title{Signature Version 2}
\description{Generates AWS Signature Version 2}
\usage{
signature_v2_auth(datetime = format(Sys.time(),"\%Y\%M\%dT\%H\%M\%S", tz = "UTC"),
                  verb, service, path, query_args = list(),
                  key = Sys.getenv("AWS_ACCESS_KEY_ID", NULL),
                  secret = Sys.getenv("AWS_SECRET_ACCESS_KEY", NULL))
}
\arguments{
    \item{datetime}{A character string containing a date in the form of \dQuote{YYYY-MM-DDTH:M:S}. If missing, it is generated automatically using \code{\link[base]{Sys.time}}.}
    \item{verb}{A character string specify an HTTP verb/method (e.g., \dQuote{GET}).}
    \item{service}{A character string containing the full hostname of an AWS service (e.g., \dQuote{iam.amazonaws.com}, etc.)}
    \item{path}{A character string specify the path to the API endpoint.}
    \item{query_args}{A list containing named query arguments.}
    \item{key}{An AWS Access Key ID. If missing, it is retrieved using \code{Sys.getenv("AWS_ACCESS_KEY_ID")}.}
    \item{secret}{An AWS Secret Access Key. If missing, it is retrieved using \code{Sys.getenv("AWS_SECRET_ACCESS_KEY")}.}
}
\details{This function generates an AWS Signature Version 2 for authorizing API requests. The function returns both an updated set of query string parameters, containing the required signature-related entries, as well as a \code{Signature} field containing the Signature string itself.}
\author{Thomas J. Leeper <thosjleeper@gmail.com>}
\references{
\href{http://docs.aws.amazon.com/general/latest/gr/signature-version-2.html}{AWS General Reference: Signature Version 2 Signing Process}
}
%\keyword{}
\seealso{\code{\link{signature_v4_auth}}}
\examples{
# examples from:
# http://docs.aws.amazon.com/general/latest/gr/signature-version-2.html

true_string <- paste0("GET\n",
"elasticmapreduce.amazonaws.com\n",
"/\n",
"AWSAccessKeyId=AKIAIOSFODNN7EXAMPLE",
"&Action=DescribeJobFlows",
"&SignatureMethod=HmacSHA256",
"&SignatureVersion=2",
"&Timestamp=2011-10-03T15\%3A19\%3A30",
"&Version=2009-03-31", collapse = "")
true_sig <- "i91nKc4PWAt0JJIdXwz9HxZCJDdiy6cf/Mj6vPxyYIs="

q1 <- 
list(Action = "DescribeJobFlows",
     Version = "2009-03-31",
     AWSAccessKeyId = "AKIAIOSFODNN7EXAMPLE",
     SignatureVersion = "2",
     SignatureMethod = "HmacSHA256",
     Timestamp = "2011-10-03T15:19:30")

sig1 <- 
signature_v2_auth(datetime = "2011-10-03T15:19:30",
                  service = "elasticmapreduce.amazonaws.com",
                  verb = "GET",
                  path = "/",
                  query_args = q1,
                  key = q1$AWSAccessKeyId,
                  secret = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
identical(true_string, sig1$CanonicalRequest)
identical(true_sig, sig1$Signature)

# leaving out some defaults
q2 <- 
list(Action = "DescribeJobFlows",
     Version = "2009-03-31",
     Timestamp = "2011-10-03T15:19:30")
sig2 <- 
signature_v2_auth(datetime = "2011-10-03T15:19:30",
                  service = "elasticmapreduce.amazonaws.com",
                  verb = "GET",
                  path = "/",
                  query_args = q2,
                  key = "AKIAIOSFODNN7EXAMPLE",
                  secret = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
identical(true_string, sig2$CanonicalRequest)
identical(true_sig, sig2$Signature)
}
