#' @title Signature Version 4
#' @description Generates AWS Signature Version 4
#' @template secret
#' @param date A character string containing a date in the form of \dQuote{YYMMDD}. If missing, it is generated automatically using \code{\link[base]{Sys.time}}.
#' @template region
#' @param service A character string containing the AWS service (e.g., \dQuote{iam}, \dQuote{host}, \dQuote{ec2}).
#' @param string_to_sign A character string containing the \dQuote{String To Sign}, possibly returned by \code{\link{string_to_sign}}.
#' @template verbose
#' @details This function generates an AWS Signature Version 4 for authorizing API requests from its pre-formatted components. Users probably only need to use the \code{\link{signature_v4_auth}} function to generate signatures.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @references
#'   \href{http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html}{AWS General Reference: Signature Version 4 Signing Process}
#'   
#'   \href{http://docs.aws.amazon.com/general/latest/gr/signature-v4-examples.html}{AWS General Reference: Examples of How to Derive a Version 4 Signing Key}
#'   
#'   \href{http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html}{Amazon S3 API Reference: Authenticating Requests (AWS Signature Version 4)}
#' @seealso \code{\link{signature_v4_auth}}, \code{\link{signature_v2_auth}}, \code{\link{use_credentials}}
#' @examples
#' \dontrun{
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
#' }
#' @importFrom digest hmac
#' @importFrom magrittr %>% 
#' @export
signature_v4 <- function(secret = NULL,
                         date = format(Sys.time(), "%Y%m%d"),
                         region = NULL,
                         service,
                         string_to_sign,
                         verbose = getOption("verbose", FALSE)){

  signature <- hmac(paste0("AWS4", secret), date, "sha256", raw = TRUE) %>% 
               hmac(region, "sha256", raw = TRUE) %>% 
               hmac(service, "sha256", raw = TRUE) %>% 
               hmac("aws4_request", "sha256", raw = TRUE) %>% 
               hmac(string_to_sign, "sha256")
  
  signature
}
