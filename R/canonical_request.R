#' @title Construct a Canonical Request
#' @description Construct a Canonical Request from request elements
#' @param verb A character string containing the HTTP verb being used in the request.
#' @param canonical_uri A character string containing the \dQuote{canonical URI}, meaning the contents of the API request URI excluding the host and the query parameters.
#' @param query_args A named list of character strings containing the query string values (if any) used in the API request.
#' @param canonical_headers A named list of character strings containing the headers used in the request.
#' @param request_body The body of the HTTP request, or a filename. If a filename, hashing is performed on the file without reading it into memory.
#' @details This function creates a \dQuote{Canonical Request}, which is part of the Signature Version 4. Users probably only need to use the \code{\link{signature_v4_auth}} function to generate signatures.
#' @return A list containing
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @references
#'   \href{http://docs.aws.amazon.com/general/latest/gr/sigv4-create-canonical-request.html}{Create a Canonical Request For Signature Version 4}
#' @seealso \code{\link{signature_v4}}, \code{\link{signature_v4_auth}}
#' @examples
#' # From AWS documentation
#' # http://docs.aws.amazon.com/general/latest/gr/sigv4-create-canonical-request.html
#' fromDocs <- "POST
#' /
#' 
#' content-type:application/x-www-form-urlencoded; charset=utf-8
#' host:iam.amazonaws.com
#' x-amz-date:20110909T233600Z
#' 
#' content-type;host;x-amz-date
#' b6359072c78d70ebee1e81adcbab4f01bf2c23245fa365ef83fe8f1f955085e2"
#' 
#' hdrs <- list(`Content-Type` = "application/x-www-form-urlencoded; charset=utf-8",
#'              Host = "iam.amazonaws.com",
#'              `x-amz-date` = "20110909T233600Z")
#' r <- canonical_request(verb = "POST",
#'                        canonical_uri = "/",
#'                        query_args = list(),
#'                        canonical_headers = hdrs,
#'                        request_body = "Action=ListUsers&Version=2010-05-08")
#' 
#' identical(fromDocs, r$canonical)
#' @seealso \code{link{signature_v4_aut}}, \code{\link{string_to_sign}}
#' @export
canonical_request <- function(verb,
                              canonical_uri = "",
                              query_args = list(),
                              canonical_headers,
                              request_body = ""){

    if (is.character(request_body) && file.exists(request_body)) {
        body_hash <- tolower(digest::digest(request_body,
                                            file = TRUE,
                                            algo = "sha256",
                                            serialize = FALSE))
    } else {
        body_hash <- tolower(digest::digest(request_body,
                                            algo = "sha256",
                                            serialize = FALSE))
    }

    # set sort locale
    lc <- Sys.getlocale(category = "LC_COLLATE")
    Sys.setlocale(category = "LC_COLLATE", locale = "C")
    on.exit(Sys.setlocale(category = "LC_COLLATE", locale = lc))
    
    names(canonical_headers) <- tolower(names(canonical_headers))
    canonical_headers <- canonical_headers[order(names(canonical_headers))]
    # trim leading, trailing, and all non-quoted duplicated spaces
    trimmed_headers <- gsub("[[:space:]]{2,}", " ", trimws(canonical_headers))
    header_string <- paste0(names(canonical_headers), ":", 
                            trimmed_headers, "\n",
                            collapse = "")
    signed_headers <- paste(names(canonical_headers), sep = "", collapse = ";")
    
    if(length(query_args)) {
        query_args <- unlist(query_args[order(names(query_args))])
        a <- paste0(sapply(names(query_args), URLencode, reserved = TRUE), "=", 
                    sapply(as.character(query_args), URLencode, reserved = TRUE))
        query_string <- paste(a, sep = "", collapse = "&")
    } else {
        query_string <- ""
    }
    
    out <- paste(verb, 
                 canonical_uri,
                 query_string,
                 header_string,
                 signed_headers,
                 body_hash,
                 sep = "\n")
    
  list(headers = signed_headers, 
       body = body_hash,
       canonical = out,
       hash = digest::digest(out, algo = "sha256", serialize = FALSE))
}
