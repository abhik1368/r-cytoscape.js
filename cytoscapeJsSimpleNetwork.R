#' Generate a CytoscapeJS compatible network 
#' 
#' @param nodeData a data.frame with at least two columns: id and name
#' @param edgeData a data.frame with at least two columns: source and target
#' @param nodeColor a hex color for nodes (default: #666666)
#' @param nodeShape a shape for nodes (default: ellipse)
#' @param edgeColor a hex color for edges (default: #666666)
#' @param edgeSourceShape a shape for arrow sources (default: none)
#' @param edgeTargetShape a shape for arrow targets (default: triangle)
#'  
#' @return a list with two entries: 
#'   nodes: a JSON string with node information compatible with CytoscapeJS
#'   edges: a JSON string with edge information compatible with CytoscapeJS
#'   
#'   If no nodes exist, then NULL is returned
#'   
#' @details See http://cytoscape.github.io/cytoscape.js/ for shape details
#' 
#' @examples 
#' id <- c("Jerry", "Elaine", "Kramer", "George")
#' name <- id
#' nodeData <- data.frame(id, name, stringsAsFactors=FALSE)
#' 
#' source <- c("Jerry", "Jerry", "Jerry", "Elaine", "Elaine", "Kramer", "Kramer", "Kramer", "George")
#' target <- c("Elaine", "Kramer", "George", "Jerry", "Kramer", "Jerry", "Elaine", "George", "Jerry")
#' edgeData <- data.frame(source, target, stringsAsFactors=FALSE)
#' 
#' network <- createCytoscapeNetwork(nodeData, edgeData)
createCytoscapeNetwork <- function(nodeData, edgeData, 
                                   nodeColor="#888888", nodeShape="ellipse", 
                                   edgeColor="#888888", edgeSourceShape="none", 
                                   edgeTargetShape="triangle", nodeHref="") {  
    
    # There must be nodes and nodeData must have at least id and name columns
    if(nrow(nodeData) == 0 || !(all(c("id", "name") %in% names(nodeData)))) {
        return(NULL)
    }
    
    # There must be edges and edgeData must have at least source and target columns
    if(nrow(edgeData) == 0 || !(all(c("source", "target") %in% names(edgeData)))) {
        return(NULL)
    }
        
    # NODES
    ## Add color/shape columns if not present
    if(!("color" %in% colnames(nodeData))) {
        nodeData$color <- rep(nodeColor, nrow(nodeData))
    }

    if(!("shape" %in% colnames(nodeData))) {
        nodeData$shape <- rep(nodeShape, nrow(nodeData))
    }
    
    if(!("href" %in% colnames(nodeData))) {
        nodeData$href <- rep(nodeHref, nrow(nodeData))
    }
    
    nodeEntries <- NULL
    
    for(i in 1:nrow(nodeData)) {   
        tmpEntries <- NULL
        
        for(col in colnames(nodeData)) {
            tmp2 <- paste0(col, ":'", nodeData[i, col], "'")
            tmpEntries <- c(tmpEntries, tmp2)
        }
        
        tmpEntries <- paste(tmpEntries, collapse=", ")
        
        tmp <- paste0("{ data: { ", tmpEntries, "} }")
        
        nodeEntries <- c(nodeEntries, tmp)
    }
    
    nodeEntries <- paste(nodeEntries, collapse=", ")
    
    # EDGES 
    ## Add color/shape columns if not present
    if(!("color" %in% colnames(edgeData))) {
        edgeData$color <- rep(edgeColor, nrow(edgeData))
    }
    
    if(!("sourceShape" %in% colnames(edgeData))) {
        edgeData$sourceShape <- rep(edgeSourceShape, nrow(edgeData))
    }
    
    if(!("targetShape" %in% colnames(edgeData))) {
        edgeData$targetShape <- rep(edgeTargetShape, nrow(edgeData))
    }
    
    edgeEntries <- NULL
    
    for(i in 1:nrow(edgeData)) {   
        tmpEntries <- NULL
        
        for(col in colnames(edgeData)) {
            tmp2 <- paste0(col, ":'", edgeData[i, col], "'")
            tmpEntries <- c(tmpEntries, tmp2)
        }
        
        tmpEntries <- paste(tmpEntries, collapse=", ")
        
        tmp <- paste0("{ data: { ", tmpEntries, "} }")
        
        edgeEntries <- c(edgeEntries, tmp)
    }
    
    edgeEntries <- paste(edgeEntries, collapse=", ")
    
    network <- list(nodes=nodeEntries, edges=edgeEntries)
    
    return(network)
}

#' Generate an HTML string for a network visualized using CytoscapeJS 
#' 
#' @param a string with JSON for node information for CytoscapeJS
#' @param a stirng with JSON for edge information for CytoscapeJS
#' 
#' @return a string with a complete HTML file containing network
#' 
#' @examples 
#' id <- c("Jerry", "Elaine", "Kramer", "George")
#' name <- id
#' nodeData <- data.frame(id, name, stringsAsFactors=FALSE)
#' 
#' source <- c("Jerry", "Jerry", "Jerry", "Elaine", "Elaine", "Kramer", "Kramer", "Kramer", "George")
#' target <- c("Elaine", "Kramer", "George", "Jerry", "Kramer", "Jerry", "Elaine", "George", "Jerry")
#' edgeData <- data.frame(source, target, stringsAsFactors=FALSE)
#' 
#' network <- createCytoscapeNetwork(nodeData, edgeData)
#' 
#' output <- cytoscapeJsSimpleNetwork(network$nodes, network$edges)
#' fileConn <- file("cytoscapeJsR_example.html")
#' writeLines(output, fileConn)
#' close(fileConn)
cytoscapeJsSimpleNetwork <- function(nodeEntries, edgeEntries, 
                                     standAlone=FALSE, layout="cose") {
	# Create webpage
	PageHeader <- "
	<!DOCTYPE html>
	<html>
	<head>
	<meta name='description' content='[An example of getting started with Cytoscape.js]' />
	<script src='http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js'></script>
    <script src='http://cytoscape.github.io/cytoscape.js/api/cytoscape.js-latest/cytoscape.min.js'></script>
	<meta charset='utf-8' />
	<title>Cytoscape.js initialisation</title>"
	
    if(standAlone) {
        NetworkCSS <- "<style>
        	#cy {
        	  height: 100%; 
        	  width: 100%;
        	  position: absolute; 
        	  left: 0;
              top: 200;
              border: 2px solid; 
        	}
        	</style>"    
    } else {
        NetworkCSS <- "<style>
        	#cy {
        	  height: 600px; 
        	  width: 600px;
        	  position: relative;
        	  left: 0;
              top: 200;
              border: 2px solid; 
        	}</style>"        
    }

	# Main script for creating the graph
	MainScript <- paste0("
  <script>
	$(function(){ // on dom ready
	
	var cy = cytoscape({
        container: $('#cy')[0],

		style: cytoscape.stylesheet()
		.selector('node')
		.css({
		'content': 'data(name)',
		'text-valign': 'center',
		'color': 'white',
		'text-outline-width': 2,
        'shape': 'data(shape)',
        'text-outline-color': 'data(color)',
        'background-color': 'data(color)'
		})
		.selector('edge')
		.css({
    	'line-color': 'data(color)',
        'source-arrow-color': 'data(color)',
    	'target-arrow-color': 'data(color)',
        'source-arrow-shape': 'data(sourceShape)',
		'target-arrow-shape': 'data(targetShape)'
		})
		.selector(':selected')
		.css({
		'background-color': 'black',
		'line-color': 'black',
		'target-arrow-color': 'black',
		'source-arrow-color': 'black'
		})
		.selector('.faded')
		.css({
		'opacity': 0.25,
		'text-opacity': 0
		}),
		
		elements: {
		nodes: [",
			nodeEntries,
		"],
		edges: [",
			edgeEntries,
		"]
		},
		
		layout: {
		name: '", layout, "',
		padding: 10
		}
    });

    cy.on('tap', 'node', function(){
      if(this.data('href').length > 0) {
        window.open(this.data('href'));
      }
     
      //console.log(this.data('href'));
    });

		}); // on dom ready
</script>")
	
	PageBody <- "</head><body><div id='cy'></div>"
	PageFooter <- "</body></html>"	
		
    if(standAlone) {
        results <- paste0(PageHeader, NetworkCSS, MainScript, PageBody, PageFooter)	        
        return(results)
    } else {
        results <- paste0(NetworkCSS, MainScript)    
        cat(results)
    }
}
