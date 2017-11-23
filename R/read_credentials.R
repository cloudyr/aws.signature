#' @rdname read_credentials
#' @title Use Credentials from .aws/credentials File
#' @description Use a profile from a \samp{.aws/credentials} file
#' @param profile A character string specifing which profile to use from the file. By default, the \dQuote{default} profile is used.
#' @param file A character string containing a path to a \samp{.aws/credentials} file. By default, the standard/centralized file is used. For \code{use_credentials}, this can also be an object of class \dQuote{aws_credentials} (as returned by \code{use_credentials}).
#' @details \code{read_credentials} reads and parses a \samp{.aws/credentials} file into an object of class \dQuote{aws_credentials}.
#' 
#' \code{use_credentials} uses credentials from a profile stored in a credentials file to set the environment variables used by this package.
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @references
#'   \href{https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs}{Amazon blog post describing the format}
#' @seealso \code{\link{signature_v2_auth}}, \code{\link{locate_credentials}}
#' @examples
#' \dontrun{
#' # set environment variables from a profile
#' use_credentials()
#' 
#' # read and parse a file
#' read_credentials()
#' }
#' @export
read_credentials <- function(file = default_credentials_file()) {
    file <- path.expand(file)
    if (!file.exists(file)) {
        stop(paste0("File ", shQuote(file), " does not exist."))
    }
    char <- rawToChar(readBin(file, "raw", n = 1e5L))
    parse_credentials(char)
}

#' @rdname read_credentials
#' @export
use_credentials <- function(profile = "default", file = default_credentials_file()) {
    if (inherits(file, "aws_credentials")) {
        x <- file
    } else {
        x <- read_credentials(file)
    }
    if ("AWS_ACCESS_KEY_ID" %in% names(x[[profile]])) {
        Sys.setenv("AWS_ACCESS_KEY_ID" = x[[profile]][["AWS_ACCESS_KEY_ID"]])
    }
    if ("AWS_SECRET_ACCESS_KEY" %in% names(x[[profile]])) {
        Sys.setenv("AWS_SECRET_ACCESS_KEY" = x[[profile]][["AWS_SECRET_ACCESS_KEY"]])
    }
    if ("AWS_SESSION_TOKEN" %in% names(x[[profile]])) {
        Sys.setenv("AWS_SESSION_TOKEN" = x[[profile]][["AWS_SESSION_TOKEN"]])
    }
    if ("AWS_DEFAULT_REGION" %in% names(x[[profile]])) {
        Sys.setenv("AWS_DEFAULT_REGION" = x[[profile]][["AWS_DEFAULT_REGION"]])
    }
    invisible(x)
}

homePath <- function() {
  if (.Platform[["OS.type"]] == "windows") {
    return(Sys.getenv("USERPROFILE"))
  } else {
    return("~")
  }
}

#' @rdname read_credentials
#' @export
default_credentials_file <- function() {
    suppressWarnings(normalizePath(file.path(homePath(), '.aws', 'credentials')))
}

parse_credentials <- function(char) {
    s <- c(gregexpr("\\[", char)[[1]], nchar(char))

    make_named_vec <- function(x) {
        elem <- strsplit(x, "[ ]?=[ ]?")
        out <- lapply(elem, `[`, 2)
        names(out) <- trimws(toupper(sapply(elem, `[`, 1)))
        out
    }

    creds <- list()
    for (i in seq_along(s)[-1]) {
        tmp <- strsplit(substr(char, s[i-1], s[i]-1), "[\n\r]+")[[1]]
        creds[[i-1]] <- make_named_vec(tmp[-1])
        names(creds)[[i-1]] <- gsub("\\[", "", gsub("\\]", "", tmp[1]))
    }
    structure(creds, class = "aws_credentials")
}
