#' @title Signature Version 4
#' @description AWS Signature Version 4 for use in query or header authorization
#' @param datetime A character string containing a datetime in the form of \dQuote{YYYYMMDDTHHMMSSZ}. If missing, it is generated automatically using \code{\link[base]{Sys.time}}.
#' @template region
#' @param service A character string containing the AWS service (e.g., \dQuote{iam}, \dQuote{host}, \dQuote{ec2}).
#' @param verb A character string containing the HTTP verb being used in the request.
#' @param action A character string containing the API endpoint used in the request.
#' @param query_args A named list of character strings containing the query string values (if any) used in the API request, passed to \code{\link{canonical_request}}.
#' @param canonical_headers A named list of character strings containing the headers used in the request.
#' @param request_body The body of the HTTP request.
#' @template key
#' @template secret
#' @param session_token Optionally, an AWS Security Token Service (STS) temporary Session Token. This is added automatically as a header to \code{canonical_headers}. See \code{\link{locate_credentials}}.
#' @param query A logical. Currently ignored.
#' @param algorithm A character string containing the hashing algorithm used in the request. Should only be \dQuote{SHA256}.
#' @template force_credentials
#' @template verbose
#' @details This function generates an AWS Signature Version 4 for authorizing API requests.
#' @return A list of class \dQuote{aws_signature_v4}, containing the information needed to sign an AWS API request using either query string authentication or request header authentication. Specifically, the list contains:
#' 
#'     \item{Algorithm}{A character string containing the hashing algorithm used during the signing process (default is SHA256).}
#'     \item{Credential}{A character string containing an identifying credential \dQuote{scoped} to the region, date, and service of the request.}
#'     \item{Date}{A character string containing a YYYYMMDD-formatted date.}
#'     \item{SignedHeaders}{A character string containing a semicolon-separated listing of request headers used in the signature.}
#'     \item{Body}{The value passed to \code{request_body}.}
#'     \item{BodyHash}{A character string containing a SHA256 hash of the request body.}
#'     \item{Verb}{The value passed to \code{verb}.}
#'     \item{Query}{The value passed to \code{query_args}.}
#'     \item{Service}{The value passed to \code{service}.}
#'     \item{Action}{The value passed to \code{action}.}
#'     \item{CanonicalRequest}{A character string containing the canonical request.}
#'     \item{StringToSign}{A character string containing the string to sign for the request.}
#'     \item{Signature}{A character string containing a request signature hash.}
#'     \item{SignatureHeader}{A character string containing a complete Authorization header value.}
#'     \item{AccessKeyId}{A character string containing the access key id identified by \code{\link{locate_credentials}}.}
#'     \item{SecretAccessKey}{A character string containing the secret access key identified by \code{\link{locate_credentials}}.}
#'     \item{SessionToken}{A character string containing the session token identified by \code{\link{locate_credentials}}.}
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
#' @seealso \code{\link{signature_v2_auth}}, \code{\link{locate_credentials}}
#' @export
signature_v4_auth <- 
function(
  datetime = format(Sys.time(),"%Y%m%dT%H%M%SZ", tz = "UTC"),
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
  force_credentials = FALSE,
  verbose = getOption("verbose", FALSE)
){
    if (isTRUE(force_credentials)) {
        if (isTRUE(verbose)) {
            if (!is.null(key)) {
                message("Using user-supplied value for AWS Access Key ID")
            }
            if (!is.null(secret)) {
                message("Using user-supplied value for AWS Secret Access Key")
            }
            if (!is.null(session_token)) {
                message("Using user-supplied value for AWS Secret Access Key")
            }
            if (!is.null(region)) {
                message(sprintf("Using user-supplied value for AWS Region ('%s')", region))
            }
        }
    } else {
        credentials <- locate_credentials(key = key, secret = secret, session_token = session_token, region = region, verbose = verbose)
        key <- credentials[["key"]]
        secret <- credentials[["secret"]]
        session_token <- credentials[["session_token"]]
        region <- credentials[["region"]]
    }
    
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
                   Body = request_body,
                   BodyHash = R$body,
                   Verb = verb,
                   Query = query_args,
                   Service = service,
                   Action = action,
                   CanonicalRequest = R$canonical,
                   StringToSign = S,
                   Signature = V4,
                   SignatureHeader = sigheader,
                   AccessKeyId = key,
                   SecretAccessKey = secret,
                   SessionToken = session_token,
                   Region = region), class = "aws_signature_v4")
}

