#' @title Signature Version 4
#' @description Generates AWS Signature Version 4
#' @param secret An AWS Secret Access Key. If \code{NULL}, it is retrieved using \code{\link{locate_credentials}}.
#' @param date A character string containing a date in the form of \dQuote{YYMMDD}. If missing, it is generated automatically using \code{\link[base]{Sys.time}}.
#' @param region A character string containing the AWS region for the request. If \code{NULL}, it is retrieved using \code{\link{locate_credentials}} or \dQuote{us-east-1} is used.
#' @param service A character string containing the AWS service (e.g., \dQuote{iam}, \dQuote{host}, \dQuote{ec2}).
#' @param string_to_sign A character string containing the String To Sign, possibly returned by \code{\link{string_to_sign}}.
#' @param verbose A logical indicating whether to be verbose.
#' @details This function generates an AWS Signature Version 4 for authorizing API requests.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @references
#'   \href{http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html}{AWS General Reference: Signature Version 4 Signing Process}
#'   
#'   \href{http://docs.aws.amazon.com/general/latest/gr/signature-v4-examples.html}{AWS General Reference: Examples of How to Derive a Version 4 Signing Key}
#'   
#'   \href{http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html}{Amazon S3 API Reference: Authenticating Requests (AWS Signature Version 4)}
#' @seealso \code{\link{signature_v2_auth}}, \code{\link{use_credentials}}
#' @examples
#' # From AWS documentation
#' # http://docs.aws.amazon.com/general/latest/gr/signature-v4-test-suite.html
#' StringToSign <- "AWS4-HMAC-SHA256
#' 20110909T233600Z
#' 20110909/us-east-1/host/aws4_request
#' e25f777ba161a0f1baf778a87faf057187cf5987f17953320e3ca399feb5f00d"
#' 
#' sig <- 
#' signature_v4(secret = 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY',
#'              date = '20110909',
#'              region = 'us-east-1',
#'              service = 'host',
#'              string_to_sign = StringToSign)
#' identical(sig, "be7148d34ebccdc6423b19085378aa0bee970bdc61d144bd1a8c48c33079ab09")
#' 
#' # http://docs.aws.amazon.com/general/latest/gr/sigv4-calculate-signature.html
#' StringToSign <- "AWS4-HMAC-SHA256
#' 20110909T233600Z
#' 20110909/us-east-1/iam/aws4_request
#' 3511de7e95d28ecd39e9513b642aee07e54f4941150d8df8bf94b328ef7e55e2"
#' 
#' sig <- 
#' signature_v4(secret = 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY',
#'              date = '20110909',
#'              region = 'us-east-1',
#'              service = 'iam',
#'              string_to_sign = StringToSign)
#' identical(sig, "ced6826de92d2bdeed8f846f0bf508e8559e98e4b0199114b84c54174deb456c")
#' @importFrom digest digest hmac
#' @export
signature_v4 <- 
function(secret = NULL,
         date = format(Sys.time(), "%Y%m%d"),
         region = NULL,
         service,
         string_to_sign,
         verbose = FALSE) {
    credentials <- locate_credentials(secret = secret, region = region, verbose = verbose)
    kDate <- digest::hmac(paste0("AWS4", credentials[["secret"]]), date, "sha256", raw = TRUE)
    kRegion <- digest::hmac(kDate, credentials[["region"]], "sha256", raw = TRUE)
    kService <- digest::hmac(kRegion, service, "sha256", raw = TRUE)
    kSigning <- digest::hmac(kService, "aws4_request", "sha256", raw = TRUE)
    signature <- digest::hmac(kSigning, string_to_sign, "sha256")
    return(signature)
}

#' @title Signature Version 4
#' @description AWS Signature Version 4 for use in query or header authorization
#' @param datetime A character string containing a datetime in the form of \dQuote{YYYYMMDDTHHMMSSZ}. If missing, it is generated automatically using \code{\link[base]{Sys.time}}.
#' @param region A character string containing the AWS region for the request. See \code{\link{locate_credentials}}.
#' @param service A character string containing the AWS service (e.g., \dQuote{iam}, \dQuote{host}, \dQuote{ec2}).
#' @param verb A character string containing the HTTP verb being used in the request.
#' @param action A character string containing the API endpoint used in the request.
#' @param query_args A named list of character strings containing the query string values (if any) used in the API request, passed to \code{\link{canonical_request}}.
#' @param canonical_headers A named list of character strings containing the headers used in the request.
#' @param request_body The body of the HTTP request.
#' @param key An AWS Access Key ID. See \code{\link{locate_credentials}}.
#' @param secret An AWS Secret Access Key. See \code{\link{locate_credentials}}.
#' @param session_token Optionally, an AWS Security Token Service (STS) temporary Session Token. This is added automatically as a header to \code{canonical_headers}. See \code{\link{locate_credentials}}.
#' @param query A logical. Currently ignored.
#' @param algorithm A character string containing the hashing algorithm used in the request. Should only be \dQuote{SHA256}.
#' @param verbose A logical indicating whether to be verbose.
#' @details This function generates an AWS Signature Version 4 for authorizing API requests.
#' @return A list of class \dQuote{aws_signature_v4}, containing the information needed to sign an AWS API request using either query string authentication or request header authentication. Specifically, the list contains:
#' 
#'     \item{Algorithm}{A character string containing the hashing algorithm used during the signing process (default is SHA256).}
#'     \item{Credential}{A character string containing an identifying credential \dQuote{scoped} to the region, date, and service of the request.}
#'     \item{Date}{A character string containing a YYYYMMDD-formatted date.}
#'     \item{SignedHeaders}{A character string containing a semicolon-separated listing of request headers used in the signature.}
#'     \item{BodyHash}{A character string containing a SHA256 hash of the request body.}
#'     \item{StringToSign}{A character string containing the string to sign for the request.}
#'     \item{Signature}{A character string containing a request signature hash.}
#'     \item{SignatureHeader}{A character string containing a complete Authorization header value.}
#'     \item{Region}{A character string containing the region identified by \code{\link{locate_credentials}}.}
#' 
#' These values can either be used as query parameters in a REST-style API request, or as request headers. If authentication is supplied via query string parameters, the query string should include the following:
#' 
#' Action=\code{action}
#' &X-Amz-Algorithm=\code{Algorithm}
#' &X-Amz-Credential=\code{URLencode(Credentials)}
#' &X-Amz-Date=\code{Date}
#' &X-Amz-Expires=\code{timeout}
#' &X-Amz-SignedHeaders=\code{SignedHeaders}
#' 
#' where \code{action} is the API endpoint being called and \code{timeout} is a numeric value indicating when the request should expire.
#' 
#' If signing a request using header-based authentication, the \dQuote{Authorization} header in the request should be included with the request that looks as follows:
#' 
#' Authorization: \code{Algorithm} Credential=\code{Credential}, SignedHeaders=\code{SignedHeaders}, Signature=\code{Signature}
#' 
#' This is the value printed by default for all objects of class \dQuote{aws_signature_v4}.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @references
#' \href{http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html}{AWS General Reference: Signature Version 4 Signing Process}
#' 
#' \href{http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html}{Amazon S3 API Reference: Authenticating Requests (AWS Signature Version 4)}
#' 
#' \href{Add the Signing Information to the Request}{http://docs.aws.amazon.com/general/latest/gr/sigv4-add-signature-to-request.html}
#' @seealso \code{\link{signature_v4}}, \code{\link{signature_v2_auth}}
#' @export
signature_v4_auth <- 
function(datetime = format(Sys.time(),"%Y%M%dT%H%M%SZ", tz = "UTC"),
         region = NULL,
         service,
         verb,
         action,
         query_args = list(),
         canonical_headers, # named list
         request_body,
         key = NULL,
         secret = NULL,
         session_token = NULL,
         query = FALSE,
         algorithm = "AWS4-HMAC-SHA256",
         verbose = FALSE){
    credentials <- locate_credentials(key = key, secret = secret, session_token = session_token, region = region, verbose = verbose)
    key <- credentials[["key"]]
    secret <- credentials[["secret"]]
    session_token <- credentials[["session_token"]]
    region <- credentials[["region"]]
    
    date <- substring(datetime,1,8)
    
    if (isTRUE(query)) {
        # handle query-based authorizations, by including relevant parameters
    } 
    
    # Canonical Request
    if (!is.null(session_token) && session_token != "") {
        if (!missing(canonical_headers)) {
            canonical_headers <- c(canonical_headers, list("X-Amz-Security-Token" = session_token))
        } else {
            canonical_headers <- list("X-Amz-Security-Token" = session_token)
        }
    }
    R <- canonical_request(verb = verb,
                           canonical_uri = action,
                           query_args = query_args,
                           canonical_headers = canonical_headers,
                           request_body = request_body)
    
    # String To Sign
    S <- string_to_sign(algorithm = algorithm,
                        datetime = datetime,
                        region = region,
                        service = service,
                        request_hash = R$hash)
    
    # Signature
    V4 <- signature_v4(secret = secret,
                       date = date,
                       region = region,
                       service = service,
                       string_to_sign = S,
                       verbose = verbose)
    
    # return list
    credential <- paste(key, date, region, service, "aws4_request", sep="/")
    sigheader <- paste(algorithm,
                       paste(paste0("Credential=", credential),
                             paste0("SignedHeaders=", R$headers),
                             paste0("Signature=", V4),
                             sep = ", "))
    structure(list(Algorithm = algorithm,
                   Credential = credential,
                   Date = date,
                   SignedHeaders = R$headers,
                   BodyHash = R$body,
                   CanonicalRequest = R$canonical,
                   StringToSign = S,
                   Signature = V4,
                   SignatureHeader = sigheader,
                   Region = region), class = "aws_signature_v4")
}
