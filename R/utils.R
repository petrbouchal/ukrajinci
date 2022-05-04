write_data <- function(data, write_fn, path, ...) {
  write_fn(data, path, ...)
  return(path)
}
