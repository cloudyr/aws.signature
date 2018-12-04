#' @title Construct a String To Sign
#' @description Construct a String to Sign from request elements
#' @param algorithm A character string containing the hashing algorithm used in signing process. Should only be \dQuote{AWS4-HMAC-SHA256}.
#' @param datetime A character string containing a UTC date in the form of \dQuote{YYYYMMDDTHHMMSSZ}.
#' @param region A character string containing the AWS region for the request.
#' @param service A character string containing the AWS service (e.g., \dQuote{iam}, \dQuote{host}, \dQuote{ec2}).
#' @param request_hash A character string containing the hash of the canonical request, perhaps as returned by \code{\link{canonical_request}}.
#' @details This is a mostly internal function that creates a \dQuote{String To Sign}, which is part of the Signature Version 4. Users probably only need to use the \code{\link{signature_v4_auth}} function to generate signatures.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @references
#'   \href{http://docs.aws.amazon.com/general/latest/gr/sigv4-create-string-to-sign.html}{Create a String to Sign for Signature Version 4}
#' @examples
#' # From AWS documentation
#' rh <- "3511de7e95d28ecd39e9513b642aee07e54f4941150d8df8bf94b328ef7e55e2"
#' sts <- 
#' string_to_sign(datetime = "20110909T233600Z",
#'                region = "us-east-1",
#'                service = "iam",
#'                request_hash = rh)
#' identical(sts, "AWS4-HMAC-SHA256
#' 20110909T233600Z
#' 20110909/us-east-1/iam/aws4_request
#' 3511de7e95d28ecd39e9513b642aee07e54f4941150d8df8bf94b328ef7e55e2")
#'
#' @seealso \code{\link{signature_v4}}, \code{\link{signature_v4_auth}}
#' @export
string_to_sign <- function(algorithm = "AWS4-HMAC-SHA256",
                           datetime, 
                           region,
                           service,
                           request_hash){
    paste(algorithm,
          datetime, # format(Sys.time(),"%Y%m%dT%H%M%SZ", tz = "UTC")
          paste(substring(datetime,1,8),
                region,
                service,
                "aws4_request", sep = "/"),
          request_hash, sep = "\n")
}
