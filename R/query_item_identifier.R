#'
#'@title Query SB for items based on custom identifier
#'
#'@param scheme The identifier scheme
#'@param type (optional) The identifier type
#'@param key (optional) The identifier key
#'@param session (optional) SB Session to use, not provided queries public items only
#'@param limit Max number of matching items to return
#'
#'@return The SB item id for the matching item. NULL if no matching item found.
#'
#'
#'@export
query_item_identifier = function(scheme, type, key, session, limit=20){
	
	#not sure if this is necessary
	if(missing(session) || is.null(session)){
		session = handle(url_base)
	}
	
	filter_items = list()
	if(missing(type) & missing(key)){
		filter_items = list('scheme'=scheme)
		
	}else if(missing(key)){
		filter_items = list('scheme'=scheme, 'type'=type)
		
	}else if(!missing(scheme) && !missing(type) && !missing(key)){
		filter_items = list('scheme'=scheme, 'type'=type, 'key'=key)
		
	}else{
		stop('Must supply scheme, scheme & type, or scheme & type & key. No other combos allowed')
	}
	
	filter = paste0('itemIdentifier=', toJSON(filter_items, auto_unbox=TRUE))
	
	query = list('filter'=filter, 'max'=limit, 'format'='json')
	
	r = GET(url_items, query=query, handle=session)
	
	if(r$status_code == 409){
		stop('Multiple items described by that ID')
	}
	
	response = content(r, 'parsed')
	
	#check if no items matched
	if(length(response$items) == 0){
		return(data.frame())
	}
	
	out = data.frame(title=NA, id=NA)
	# if we have items, populate data.frame and return
	for(i in 1:length(response$items)){
		out[i,]$title = response$items[[i]]$title
		out[i,]$id = response$items[[i]]$id
	}
	
	return(out)
}


