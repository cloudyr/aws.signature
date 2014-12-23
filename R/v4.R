canonical_request <- 
function(verb,
         canonical_uri = "",
         query_string = "",
         canonical_headers,
         signed_headers,
         request_body
         ) {
    out <- paste(verb, 
                 paste0("/", canonical_uri),
                 query_string,
                 canonical_headers,
                 signed_headers,
                 tolower(digest(request_body, algo = "sha256", serialize = FALSE)),
                 sep = "\n")
    return(digest(out, algo = "sha256", serialize = FALSE))
}

string_to_sign <- 
function(algorithm = "AWS4-HMAC-SHA256",
         datetime, # format(Sys.time(),"%Y%M%dT%H%M%SZ", tz = "UTC")
         region,
         service,
         request_hash
         ) {
    paste(algorithm,
          datetime,
          paste(substring(datetime,1,8),
                region,
                service,
                "aws4_request", sep = "/"),
          request_hash, sep = "\n")
}

signature_v4 <- 
function(secret,
         date,
         region,
         service,
         string_to_sign){
    if(missing(secret)){
        date <- Sys.getenv("AWS_SECRET_ACCESS_KEY")
    }
    if(missing(date)){
        date <- format(Sys.time(), "%Y%m%d")
    }
    kDate <- hmac(paste0("AWS4", secret), date, "sha256", raw = TRUE)
    kRegion <- hmac(kDate, region, "sha256", raw = TRUE)
    kService <- hmac(kRegion, service, "sha256", raw = TRUE)
    kSigning <- hmac(kService, "aws4_request", "sha256", raw = TRUE)
    signature <- hmac(kSigning, string_to_sign, "sha256")
    return(signature)
}

signature_v4_auth <- 
function(datetime,
         region,
         service,
         verb,
         action,
         query_string = "",
         canonical_headers, # named list
         request_body,
         key,
         secret,
         query = FALSE,
         algorithm = "SHA256"){
    if(missing(key)){
        key <- Sys.getenv("AWS_ACCESS_KEY_ID")
    }
    if(key == "")
        stop("Missing AWS Access Key ID")
    if(missing(secret)){
        secret <- Sys.getenv("AWS_SECRET_ACCESS_KEY")
    }
    if(secret == "")
        stop("Missing AWS Secret Access Key")
    date <- substring(datetime,1,8)
    
    if(query){
        # handle query-based authorizations, by including relevant parameters
    } 
    
    # Canonical Request
    H <- paste(tolower(names(canonical_headers)), , sep = ":")
    H <- H[order(names(H))]
    # trim leading, trailing, and all non-quoted duplicated spaces
    # gsub("^\\s+|\\s+$", "", x)
    H_signed <- paste(names(H), sep = "", collapse = ";")
    R <- canonical_request(verb = verb,
                           canonical_uri = action,
                           query_string = query_string,
                           canonical_headers = H,
                           signed_headers = H_signed,
                           request_body = request_body)
    
    # String To Sign
    S <- string_to_sign(algorithm = algorithm,
                        datetime = datetime,
                        region = region,
                        service = service,
                        request_hash = R)
    
    # Signature
    V4 <- signature_v4(secret = secret,
                       date = date,
                       region = region,
                       service = service,
                       string_to_sign = S)
    
    # return list
    structure(list(Algorithm = algorithm,
                   Credential = paste(key, date, region, service, "aws4_request", sep="/"),
                   Date = date,
                   SignedHeaders = H_signed,
                   Signature = V4), class = "aws_signature_v4")
    
}

print.aws_signature_v4 <- function(x, ...){
    paste(paste0("AWS4-HMAC-", x$Algorithm),
          paste(paste0("Credential=", x$Credential),
                paste0("SignedHeaders=", x$SignedHeaders),
                paste0("Signature=", x$Signature),
                sep = ", "))
}
