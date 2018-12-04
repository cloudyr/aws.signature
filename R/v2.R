#' @title Signature Version 2
#' @description Generates AWS Signature Version 2
#' @param datetime A character string containing a date in the form of \dQuote{YYYY-MM-DDTH:M:S}. If missing, it is generated automatically using \code{\link[base]{Sys.time}}.
#' @param verb A character string specify an HTTP verb/method (e.g., \dQuote{GET}).
#' @param service A character string containing the full hostname of an AWS service (e.g., \dQuote{iam.amazonaws.com}, etc.)
#' @param path A character string specify the path to the API endpoint.
#' @param query_args A list containing named query arguments.
#' @template key
#' @template secret
#' @template region
#' @template force_credentials
#' @template verbose
#' @details This function generates an AWS Signature Version 2 for authorizing API requests. The function returns both an updated set of query string parameters, containing the required signature-related entries, as well as a \code{Signature} field containing the Signature string itself. Version 2 is mostly deprecated and in most cases users should rely on \code{\link{signature_v4_auth}} for Version 4 signatures instead.
#' @return A list.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @references \href{http://docs.aws.amazon.com/general/latest/gr/signature-version-2.html}{AWS General Reference: Signature Version 2 Signing Process}
#' @examples
#' \dontrun{
#' # examples from:
#' # http://docs.aws.amazon.com/general/latest/gr/signature-version-2.html
#' 
#' true_string <- paste0("GET\n",
#' "elasticmapreduce.amazonaws.com\n",
#' "/\n",
#' "AWSAccessKeyId=AKIAIOSFODNN7EXAMPLE",
#' "&Action=DescribeJobFlows",
#' "&SignatureMethod=HmacSHA256",
#' "&SignatureVersion=2",
#' "&Timestamp=2011-10-03T15\%3A19\%3A30",
#' "&Version=2009-03-31", collapse = "")
#' true_sig <- "i91nKc4PWAt0JJIdXwz9HxZCJDdiy6cf/Mj6vPxyYIs="
#' 
#' q1 <- 
#' list(Action = "DescribeJobFlows",
#'      Version = "2009-03-31",
#'      AWSAccessKeyId = "AKIAIOSFODNN7EXAMPLE",
#'      SignatureVersion = "2",
#'      SignatureMethod = "HmacSHA256",
#'      Timestamp = "2011-10-03T15:19:30")
#' 
#' sig1 <- 
#' signature_v2_auth(datetime = "2011-10-03T15:19:30",
#'                   service = "elasticmapreduce.amazonaws.com",
#'                   verb = "GET",
#'                   path = "/",
#'                   query_args = q1,
#'                   key = q1$AWSAccessKeyId,
#'                   secret = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
#' identical(true_string, sig1$CanonicalRequest)
#' identical(true_sig, sig1$Signature)
#' 
#' # leaving out some defaults
#' q2 <- 
#' list(Action = "DescribeJobFlows",
#'      Version = "2009-03-31",
#'      Timestamp = "2011-10-03T15:19:30")
#' sig2 <- 
#' signature_v2_auth(datetime = "2011-10-03T15:19:30",
#'                   service = "elasticmapreduce.amazonaws.com",
#'                   verb = "GET",
#'                   path = "/",
#'                   query_args = q2,
#'                   key = "AKIAIOSFODNN7EXAMPLE",
#'                   secret = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
#' identical(true_string, sig2$CanonicalRequest)
#' identical(true_sig, sig2$Signature)
#' }
#' @seealso \code{\link{signature_v4_auth}}, \code{\link{use_credentials}}
#' @importFrom digest digest hmac
#' @importFrom base64enc base64encode
#' @export
signature_v2_auth <- function(datetime = format(Sys.time(), "%Y-%m-%dT%H:%M:%S", tz = "UTC"),
                              verb,
                              service,
                              path,
                              query_args = list(),
                              key = NULL,
                              secret = NULL,
                              region = NULL,
                              force_credentials = FALSE,
                              verbose = getOption("verbose", FALSE)){
  
    if (isTRUE(force_credentials)) {
        credentials <- list(key = key, secret = secret, region = region)
        if (isTRUE(verbose)) {
            if (!is.null(key)) {
                message("Using user-supplied value for AWS Access Key ID")
            }
            if (!is.null(secret)) {
                message("Using user-supplied value for AWS Secret Access Key")
            }
            if (!is.null(region)) {
                message(sprintf("Using user-supplied value for AWS Region ('%s')", region))
            }
        }
    } else {
        credentials <- locate_credentials(key = key,
                                          secret = secret,
                                          region = region,
                                          verbose = verbose)
    }
    
    # set sort locale
    lc <- Sys.getlocale(category = "LC_COLLATE")
    Sys.setlocale(category = "LC_COLLATE", locale = "C")
    on.exit(Sys.setlocale(category = "LC_COLLATE", locale = lc))
    
    # sort query arguments
    if (!"Timestamp" %in% names(query_args)) {
        query_args$Timestamp = datetime
    } else {
        datetime <- query_args$Timestamp
    }
    if (!"SignatureVersion" %in% names(query_args)) {
        query_args$SignatureVersion = "2"
    }
    if (!"SignatureMethod" %in% names(query_args)) {
        query_args$SignatureMethod = "HmacSHA256"
    }
    if (!"AWSAccessKeyId" %in% names(query_args)) {
        query_args$AWSAccessKeyId = credentials$key
    }
    query_to_parse <- unlist(query_args[order(names(query_args))])
    a <- paste0(sapply(names(query_to_parse), URLencode, reserved = TRUE), "=", 
                sapply(as.character(query_to_parse), URLencode, reserved = TRUE))
    query_string <- paste(a, sep = "", collapse = "&")
    
    canonical_request <- paste(verb, service, path, query_string, sep = "\n")
    signature <- digest::hmac(key = credentials$secret,
                              object = canonical_request, 
                              algo = "sha256",
                              serialize = FALSE,
                              raw = TRUE)
    
    sig_encoded <- base64enc::base64encode(signature)
    query_args$Signature <- sig_encoded
    
    # return list
    structure(list(CanonicalRequest = canonical_request,
                   StringToSign = canonical_request,
                   Verb = verb,
                   Query = query_args,
                   Service = service,
                   Path = path,
                   Signature = sig_encoded,
                   AccessKeyId = credentials[["key"]],
                   SecretAccessKey = credentials[["secret"]],
                   SessionToken = credentials[["session_token"]],
                   Region = credentials[["region"]]),
              class = "aws_signature_v2")
}
