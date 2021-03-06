#' XML pretty printer & viewer
#'
#' This uses \code{vkbeautify} and \code{highlight.js} to format and
#' "pretty print" HTML/XML documents, nodes, node sets and plain character
#' HTML/XML in an \code{htmlwidget} pane.
#'
#' @param doc \code{xml2} document, node, nodeset or atomic character vector
#'        of HTML/XML content
#' @param style CSS stylesheet to use (see \code{higlight_styles()})
#' @param scroll should the \code{<div>} holding the HTML/XML content scroll
#'        (\code{TRUE}) or take up the full viewer/browser window (\code{FALSE}).
#'        Default is \code{FALSE} (take up the full viewer/browser window). If
#'        this is set to \code{TRUE}, \code{height} should be set to a value
#'        other than \code{NULL}.
#' @param add_filter show an XPath input box to enable live filtering?
#'        (default: \code{FALSE})
#' @param apply_xpath Add and apply an XPath query string to the view. If
#'        \code{add_filter} is \code{TRUE} then this query string will
#'        appear in the filter box and be applied to the passed in document.
#' @param elementId element id
#' @param width widget width (best to keep it at 100\%)
#' @param height widget height (kinda only useful for knitting since this is
#'        meant to be an interactive tool).
#' @export
#' @references \href{https://highlightjs.org/}{highlight.js},
#'             \href{http://www.eslinstructor.net/vkbeautify/}{vkbeautify}
#' @examples
#' library(xml2)
#'
#' # plain text
#' txt <- paste0("<note><to>Tove</to><from>Jani</from><heading>Reminder</heading>",
#'               "<body>Don't forget me this weekend!</body></note>")
#' xml_view(txt)
#'
#' # xml object
#' doc <- read_xml(txt)
#' xml_view(doc, style="obsidian")
#'
#' # different style
#' xml_view(xml_find_all(doc, ".//to"), style="github-gist")
#'
#' # some more complex daata
#' xml_view(read_xml(system.file("extdata/dwml.xml", package="xmlview")))
#' xml_view(read_xml(system.file("extdata/getHistory.xml", package="xmlview")),
#'          "androidstudio")
#' xml_view(read_xml(system.file("extdata/input.xml", package="xmlview")),
#'          "sunburst")
#'
#' # filter + apply an initial XPath query string
#' xml_view(read_xml(system.file("extdata/dwml.xml", package="xmlview")),
#'          add_filter=TRUE, apply_xpath=".//temperature")
xml_view <- function(doc, style="default", scroll=FALSE, add_filter=FALSE,
                     apply_xpath=NULL, elementId=NULL,
                     width="100%", height=NULL) {

  xml_doc_name <- "doc"

  if (!inherits(doc, "character") &
      inherits(substitute(doc), "name")) {
    xml_doc_name <- deparse(substitute(doc))
  }

  style <- trimws(tolower(style))

  if (!style %in% highlight_styles()) {
    style <- "default"
    warning(sprintf("Style '%s' not found, using 'default'", style))
  }

  if (inherits(doc, "character")) {
    doc <- paste0(doc, collapse="")
  } else if (inherits(doc, "xml_nodeset")) {
    doc <- paste0(as.character(doc), collapse="")
  } else if (inherits(doc, "xml_document") | inherits(doc, "xml_node")) {
    doc <- as.character(doc)
  }

  params <- list(
    xmlDoc = doc,
    styleSheet = style,
    addFilter = add_filter,
    applyXPath = apply_xpath,
    scroll=scroll,
    xmlDocName=xml_doc_name
  )

  htmlwidgets::createWidget(
    name = 'xmlview',
    params,
    width = width,
    height = height,
    package = 'xmlview',
    elementId = elementId
  )

}


#' List available styles
#'
#' Returns a character vector of available style sheets to use when displaying
#' an XML document.
#'
#' @references See \url{https://highlightjs.org/static/demo/} for a demo of all
#'             highlight.js styles
#' @export
#' @examples
#' highlight_styles()
highlight_styles <- function() {
  gsub("\\.css$", "",
       grep("\\.css$",
            list.files(system.file("htmlwidgets/lib/highlightjs/styles", package="xmlview")),
            value=TRUE))
}
