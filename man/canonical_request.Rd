\name{canonical_request}
\alias{canonical_request}
\title{Construct a Canonical Request}
\description{Construct a Canonical Request from request elements}
\usage{
canonical_request(verb, canonical_uri = "", query_string = "",
                  canonical_headers, signed_headers, request_body)
}
\arguments{
    \item{verb}{A character string containing the HTTP verb being used in the request.}
    \item{canonical_uri}{A character string containing the \dQuote{canonical URI}, meaning the contents of the API request URI excluding the host and the query parameters.}
    \item{query_string}{A character string containing the query string (if any) used in the API request.}
    \item{canonical_headers}{A named list of character strings containing the headers used in the request.}
    \item{signed_headers}{A character vector containing the names of the headers used in the signature process.}
    \item{request_body}{The body of the HTTP request.}
}
\details{This function creates a \dQuote{Canonical Request}, which is part of the Signature Version 4.}
\value{A list containing}
\author{Thomas J. Leeper <thosjleeper@gmail.com>}
\references{
\href{http://docs.aws.amazon.com/general/latest/gr/sigv4-create-canonical-request.html}{Create a Canonical Request For Signature Version 4}
}
%\keyword{}
\seealso{
\code{\link{signature_v4}}
\code{\link{signature_v4_auth}}
}
\examples{
# From AWS documentation
}
