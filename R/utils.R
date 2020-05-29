is_blank <- function(value) {
  return(is.null(value) || value == "")
}

vmsg <- function(verbose, msg, ...) {
  if (isTRUE(verbose)) {
    message(sprintf(msg, ...))
  }
}