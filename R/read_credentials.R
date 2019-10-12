#' @rdname read_credentials
#' @title Use Credentials from .aws/credentials File
#' @description Use a profile from a \samp{.aws/credentials} file
#' @param profile A character string specifying which profile to use from the file. By default, the \dQuote{default} profile is used.
#' @param file A character string containing a path to a \samp{.aws/credentials} file. By default, the standard/centralized file given by \env{AWS_SHARED_CREDENTIALS_FILE} is used, otherwise an assumed default location is assumed. For \code{use_credentials}, this can also be an object of class \dQuote{aws_credentials} (as returned by \code{use_credentials}).
#' @details \code{read_credentials} reads and parses a \samp{.aws/credentials} file into an object of class \dQuote{aws_credentials}.
#'
#' \code{use_credentials} uses credentials from a profile stored in a credentials file to set the environment variables used by this package. It is called by default during package load if the \env{AWS_ACCESS_KEY_ID} and \env{AWS_SECRET_ACCESS_KEY} environment variables are not set.
#'
#' @author Thomas J. Leeper <thosjleeper@gmail.com>
#' @references
#'   \href{https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs}{Amazon blog post describing the format}
#' @seealso \code{\link{signature_v2_auth}}, \code{\link{locate_credentials}}
#' @examples
#' \dontrun{
#' # read and parse a credentials file
#' read_credentials()
#'
#' # set environment variables from a profile
#' use_credentials()
#' }
#' @export
read_credentials <-
function(
  file = Sys.getenv("AWS_SHARED_CREDENTIALS_FILE", default_credentials_file())
) {
    file <- path.expand(file)
    if (!credentials_exists(file)) {
        stop(paste0("File ", shQuote(file), " does not exist."))
    }
    char <- rawToChar(readBin(file, "raw", n = 1e5L))
    parse_credentials(char)
}

#' @rdname read_credentials
#' @export
credentials_exists <- function(
  file = Sys.getenv("AWS_SHARED_CREDENTIALS_FILE", default_credentials_file())
) {
  file.exists(file)
}

#' @rdname read_credentials
#' @export
use_credentials <-
function(
  profile = Sys.getenv("AWS_PROFILE", "default"),
  file = Sys.getenv("AWS_SHARED_CREDENTIALS_FILE", default_credentials_file())
) {
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

#' @rdname read_credentials
#' @export
default_credentials_file <-
function() {
    if (.Platform[["OS.type"]] == "windows") {
        home <- Sys.getenv("USERPROFILE")
    } else {
        home <- "~"
    }
    suppressWarnings(normalizePath(file.path(home, '.aws', 'credentials')))
}

parse_credentials <- function(char) {
    s <- c(gregexpr("\\[", char)[[1]], nchar(char)+1)
    # This regex finds the header lines which look like: [name]<any old junk>EOL
    sections <- gregexpr("(?m)^(?<header_line>\\[(?<header_contents>[^]]+)\\].*)$", char, perl=TRUE)[[1]]
    
    # the section starts from the start of the match, and the start of the line
    section_starts <- sections + attr(sections, "capture.length")[,"header_line"]
    # the section ends at the start of the next section, or the end
    section_ends   <- c(sections-1, nchar(char)+1)[-1]
    
    # header name bounds
    header_starts <- attr(sections, "capture.start")[,"header_contents"]
    header_ends   <- header_starts + attr(sections, "capture.length")[,"header_contents"] - 1
    
    # extract out our headers and sections
    headers <- substring(char, header_starts, header_ends)
    section_bodies <- substring(char, section_starts, section_ends)
    names(section_bodies) <- headers
    
    # now with the section bodies, parse our variables
    # variables MUST start at the start of a line
    variable_matches <- gregexpr("(?m)^(?<name>\\w+)[ \t]*=[ \t]*", section_bodies, perl=TRUE)
    
    creds <- mapply(process_variable, section_bodies, variable_matches, SIMPLIFY = FALSE)

    structure(creds, class = "aws_credentials")
}

process_variable <- function(text, var_match) {
  # parse out names based on the start/end of the capture
  name_starts <- attr(var_match, "capture.start")[,"name"]
  name_ends   <- name_starts + attr(var_match, "capture.length")[,"name"]
  var_names <- substring(text, name_starts, name_ends  - 1)
  
  # var values start at the end of the match (i.e after = and whitespace)
  value_starts <- var_match + attr(var_match, "match.length")
  # values end just before the next name starts
  value_ends   <- c(name_starts[-1]-1, nchar(text) + 1)
  
  var_values <- substring(text, value_starts, value_ends)
  # trim all whitespace around values.
  # This makes parsing nested sections impossible, but we're parsing and ignoring them for now
  var_values <- trimws(var_values)
  
  var_values <- as.list(var_values)
  names(var_values) <- toupper(var_names)
  
  var_values
}