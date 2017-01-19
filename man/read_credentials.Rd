\name{read_credentials}
\alias{read_credentials}
\alias{use_credentials}
\title{Use Credentials from .aws/credentials File}
\description{Use a profile from a \samp{.aws/credentials} file}
\usage{
use_credentials(profile = "default", file = default_credentials_file())

read_credentials(file = default_credentials_file())
}
\arguments{
    \item{profile}{A character string specifing which profile to use from the file. By default, the \dQuote{default} profile is used.}
    \item{file}{A character string containing a path to a \samp{.aws/credentials} file. By default, the standard/centralized file is used. For \code{use_credentials}, this can also be an object of class \dQuote{aws_credentials} (as returned by \code{use_credentials}).}
}
\details{\code{read_credentials} reads and parses a \samp{.aws/credentials} file into an object of class \dQuote{aws_credentials}.

\code{use_credentials} uses credentials from a profile stored in a credentials file to set the environment variables used by this package.}
\author{Thomas J. Leeper <thosjleeper@gmail.com>}
\references{
\href{https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs}{Amazon blog post describing the format}
}
%\keyword{}
\seealso{\code{\link{signature_v2_auth}}, \code{\link{use_credentials}}}
\examples{
\dontrun{
# set environment variables from a profile
use_credentials()

# read and parse a file
read_credentials()
}
}
