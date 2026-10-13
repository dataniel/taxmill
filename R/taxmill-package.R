#' taxmill: PDF financial statements, milled into a dataset
#'
#' A financial statement is a table. It was a table when it was drawn up,
#' and it is still a table when it arrives as a PDF -- only now the
#' structure is in the layout rather than in the file. `taxmill` is the
#' route back: pull the text out of the PDF, shape the statement into
#' simple space-delimited lines, and parse every file at once into one
#' validated Excel workbook in tidy form.
#'
#' Tax accounts and ordinary annual accounts both work, because both are
#' laid out as tables. That layout is the only thing the format relies on.
#'
#' @section Everything stays on the machine:
#' Nothing here touches the network. The documents this package is pointed
#' at are usually confidential -- a tax account is not a public annual
#' report -- so there is no upload, no API call, and no service to trust.
#' [accounts_pdf_to_txt()] reads local PDFs and writes local text files;
#' [accounts_txt_to_xlsx()] reads those and writes one workbook.
#'
#' @section The three steps:
#' ```r
#' library(taxmill)
#'
#' accounts_pdf_to_txt("data/pdf", "data/txt")
#'
#' # ... shape the statements into category and data lines by hand ...
#'
#' accounts_txt_to_xlsx("data/txt", "data/accounts.xlsx", year = 2024)
#' ```
#'
#' The step in the middle is manual, and it is the slow one. That is not a
#' gap waiting to be automated away: a PDF financial statement has no
#' reliable machine-readable structure, the line labels differ between
#' preparers, and a parser that guessed would produce numbers that look
#' right and are wrong. Shaping the lines is the point at which a person
#' decides what the table actually says. `vignette("taxmill")` documents
#' the format exactly.
#'
#' What the package can do is make everything around that step cheap:
#' extraction is one call, PDFs with no extractable text are skipped with a
#' warning rather than silently, and validation problems are collected
#' across *all* files and reported together at the end -- so one malformed
#' line in the twentieth file does not cost you nineteen files' worth of
#' feedback.
#'
#' @section If you do not have the PDFs yet:
#' For *published* Danish annual reports, `cvrr` searches Erhvervsstyrelsens
#' distribution service and downloads them; point [accounts_pdf_to_txt()] at
#' the directory it filled. For a filing that exists as XBRL, use that
#' instead -- `cvrr::read_xbrl()` parses it with no manual step at all.
#'
#' @section The functions:
#' * [accounts_pdf_to_txt()] -- PDF financial statements to text files.
#' * [accounts_txt_to_xlsx()] -- shaped text files to one tidy Excel
#'   workbook, validated first.
#'
#' @keywords internal
"_PACKAGE"
