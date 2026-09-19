# nolint start
# contracts.R — the project's producer contracts, read as data.
#
# hazard.json and newmark.json declare where each producer writes its tables and
# the scientific selection this report publishes. They are the only declaration:
# there is no default location and no fallback to a previous layout. A missing
# contract, a missing key or a declared path without its table is an error that
# names the contract, the key and the resolved path.

.readContract <- function(root, product) {
  FILE <- file.path(root, paste0(product, ".json"))
  if (!file.exists(FILE)) {
    stop("Missing project contract: ", FILE,
         ". Declare it with its path block; this report has no default data location.",
         call. = FALSE)
  }
  OUT <- tryCatch(
    jsonlite::read_json(FILE, simplifyVector = TRUE),
    error = function(e) stop("Project contract is not valid JSON: ", FILE, call. = FALSE)
  )
  if (!is.list(OUT) || is.null(names(OUT))) {
    stop("Project contract must be a JSON object: ", FILE, call. = FALSE)
  }
  attr(OUT, "file") <- FILE
  OUT
}

# The declared root for one key of a contract's path block, resolved against the
# project. A path that escapes the project is refused: render stages the project
# into a temporary copy and relative paths must keep their meaning there.
.contractRoot <- function(contract, key, root) {
  FILE <- attr(contract, "file", exact = TRUE)
  PATH <- contract$path
  if (!is.list(PATH) || is.null(names(PATH))) {
    stop(FILE, ": path must be an object declaring the producer's roots.", call. = FALSE)
  }
  Value <- PATH[[key]]
  if (!is.character(Value) || length(Value) != 1L || !nzchar(Value)) {
    stop(FILE, ": path.", key, " is required and must be one non-empty string.", call. = FALSE)
  }
  if (grepl("(^|/)\\.\\.(/|$)", Value)) {
    stop(FILE, ": path.", key, " must not escape the project: ", Value, call. = FALSE)
  }
  OUT <- if (grepl("^(/|[A-Za-z]:)", Value)) Value else file.path(root, Value)
  if (!dir.exists(OUT)) {
    stop(FILE, ": path.", key, " declares a directory that does not exist here: ", OUT,
         call. = FALSE)
  }
  OUT
}

# One scientific value of a contract, or its documented absence.
.contractValue <- function(contract, key, required = TRUE) {
  Value <- contract[[key]]
  if (is.null(Value) || length(Value) == 0L) {
    if (!required) return(NULL)
    stop(attr(contract, "file", exact = TRUE), ": ", key,
         " is required by this report.", call. = FALSE)
  }
  Value
}

Contracts <- list(hazard = .readContract(root, "hazard"),
                  newmark = .readContract(root, "newmark"))
DataRoot <- list(hazard = .contractRoot(Contracts$hazard, "data", root),
                 newmark = .contractRoot(Contracts$newmark, "data", root))

# A declared root that holds no product of its producer is a misconfigured
# project, not a project without results: it is the case that used to publish
# empty chapters after the data moved. Which tables a producer wrote is its own
# business — a project that never ran the gmpe step has no GMPETable and still
# renders — so only the empty root fails.
for (Product in names(DataRoot)) {
  if (!length(list.files(DataRoot[[Product]], pattern = "[.]Rds$"))) {
    stop(attr(Contracts[[Product]], "file", exact = TRUE), ": path.data resolves to ",
         DataRoot[[Product]], ", which holds no ", Product, " product.", call. = FALSE)
  }
}

# Provenance of every table this report reads: which contract declared it, the
# resolved root, and the identity of the file. Table metadata is recorded when
# the producer wrote it; most products carry none, so it is never relied upon.
Provenance <- data.table::data.table(
  product = character(), table = character(), contract = character(),
  root = character(), file = character(), md5 = character(), written = character(),
  producer = character()
)

.recordProvenance <- function(product, name, FILE, DT) {
  Meta <- attr(DT, "oqt", exact = TRUE)
  Provenance <<- data.table::rbindlist(list(Provenance, data.table::data.table(
    product = product, table = name,
    contract = attr(Contracts[[product]], "file", exact = TRUE),
    root = DataRoot[[product]], file = FILE,
    md5 = unname(tools::md5sum(FILE)),
    written = format(file.info(FILE)$mtime, "%Y-%m-%dT%H:%M:%S"),
    producer = if (is.list(Meta) && !is.null(Meta$producer)) as.character(Meta$producer)[[1L]] else NA_character_
  )))
  invisible(NULL)
}

# One table of a producer. A table its project never produced stays absent, as
# the blocks that consume it already expect; the misconfiguration that used to
# hide behind that silence is caught above, when the whole root is empty.
.loadTable <- function(name, product) {
  FILE <- file.path(DataRoot[[product]], paste0(name, ".Rds"))
  if (!file.exists(FILE)) return(NULL)
  DT <- readRDS(FILE)
  .recordProvenance(product, name, FILE, DT)
  if ("p" %in% names(DT)) DT[p == "0.1", p := "0.10"]
  DT
}
# nolint end
