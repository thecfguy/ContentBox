﻿/**
* Handler For ContentBox blog pages
*/
component extends="BaseContentHandler" singleton{

	// DI
	property name="entryService"		inject="id:entryService@cb";
	
	// pre Handler
	function preHandler(event,action,eventArguments){
		// super call
		super.preHandler(argumentCollection=arguments);
	}
	
	/**
	* The preview page
	*/
	function preview(event,rc,prc){
		event.paramValue("h","");
		event.paramValue("l","");
		
		var author = getModel("securityService@cb").getAuthorSession();
		// valid Author?
		if( author.isLoaded() AND author.isLoggedIn() AND compareNoCase( hash(author.getAuthorID()), rc.h) EQ 0){
			// Override layouts
			event.setLayout("#rc.l#/layouts/blog").overrideEvent("contentbox-ui:blog.index");
			// Place layout on scope
			prc.cbLayout = rc.l;
			// Place layout root location
			prc.cbLayoutRoot = prc.cbRoot & "/layouts/" & rc.l;
			// preview it
			index(argumentCollection=arguments);
		}
		else{
			setNextEvent(URL=CBHelper.linkHome());
		}
	}

	/**
	* The home page
	*/
	function index(event,rc,prc){
		// incoming params
		event.paramValue("page",1);
		event.paramValue("category","");
		event.paramValue("q","");
		
		// prepare paging plugin
		prc.pagingPlugin 		= getMyPlugin(plugin="Paging",module="contentbox");
		prc.pagingBoundaries	= prc.pagingPlugin.getBoundaries();
		prc.pagingLink 			= CBHelper.linkHome() & "?page=@page@";
		
		// Search Paging Link Override?
		if( len(rc.q) ){
			prc.pagingLink = CBHelper.linkHome() & "/search/#rc.q#/@page@?";
		}
		// Category Filter Link Override
		if( len(rc.category) ){
			prc.pagingLink = CBHelper.linkHome() & "/category/#rc.category#/@page@?";
		}
		
		// get published entries
		var entryResults = entryService.findPublishedEntries(offset=prc.pagingBoundaries.startRow-1,
											   				 max=prc.cbSettings.cb_paging_maxentries,
											   				 category=rc.category,
											   				 searchTerm=rc.q);
		prc.entries 		= entryResults.entries;
		prc.entriesCount  	= entryResults.count;
		
		// announce event
		announceInterception("cbui_onIndex",{entries=prc.entries,entriesCount=prc.entriesCount});
		
		// set skin view
		event.setView("#prc.cbLayout#/views/index");
	}
	
	/**
	* The archives
	*/
	function archives(event,rc,prc){
		// incoming params
		event.paramValue("page",1);
		// archived params
		event.paramValue("year","0");
		event.paramValue("month","0");
		event.paramValue("day","0");
		
		// prepare paging plugin
		prc.pagingPlugin 		= getMyPlugin(plugin="Paging",module="contentbox");
		prc.pagingBoundaries	= prc.pagingPlugin.getBoundaries();
		prc.pagingLink 			= CBHelper.linkHome() & event.getCurrentRoutedURL() & "?page=@page@";
		
		// get published entries
		var entryResults = entryService.findPublishedEntriesByDate(year=rc.year,
											   				  	   month=rc.month,
											   				 	   day=rc.day,
											   				 	   offset=prc.pagingBoundaries.startRow-1,
											   					   max=prc.cbSettings.cb_paging_maxentries);
		prc.entries 		= entryResults.entries;
		prc.entriesCount  	= entryResults.count;
		
		// announce event
		announceInterception("cbui_onArchives",{entries=prc.entries,entriesCount=prc.entriesCount});
		
		// set skin view
		event.setView("#prc.cbLayout#/views/archives");
	}
	
	/**
	* An entry page
	*/
	function entry(event,rc,prc){
		// incoming params
		event.paramValue("entrySlug","");
		
		// Try to retrieve by slug
		prc.entry = entryService.findBySlug(rc.entrySlug);
		
		// Check if loaded, else not found
		if( prc.entry.isLoaded() ){
			// Record hit
			entryService.updateHits( prc.entry );
			// Retrieve Comments
			// TODO: paging
			var commentResults 	= commentService.findApprovedComments(entryID=prc.entry.getEntryID());
			prc.comments 		= commentResults.comments;
			prc.commentsCount 	= commentResults.count;
			// announce event
			announceInterception("cbui_onEntry",{entry=prc.entry,entrySlug=rc.entrySlug});
			// set skin view
			event.setView("#prc.cbLayout#/views/entry");	
		}
		else{
			// announce event
			announceInterception("cbui_onEntryNotFound",{entry=prc.entry,entrySlug=rc.entrySlug});
			// missing page
			prc.missingPage = rc.entrySlug;
			// set 404 headers
			event.setHTTPHeader("404","Entry not found");
			// set skin not found
			event.setView("#prc.cbLayout#/views/notfound");
		}	
	}
	
	/**
	* Display the RSS feeds
	*/
	function rss(event,rc,prc){
		// params
		event.paramValue("category","");
		event.paramValue("entrySlug","");
		event.paramValue("commentRSS",false);
		
		// Build out the RSS feeds
		var feed = RSSService.getRSS(comments=rc.commentRSS,category=rc.category,entrySlug=rc.entrySlug);
		
		// Render out the feed xml
		event.renderData(type="plain",data=feed,contentType="text/xml");
	}
	
	/**
	* Comment Form Post
	*/
	function commentPost(event,rc,prc){
		// incoming params
		event.paramValue("entrySlug","");
		
		// Try to retrieve entry by slug
		var thisEntry = entryService.findBySlug( rc.entrySlug );
		
		// If null, kick them out
		if( isNull( thisEntry ) ){ setNextEvent( prc.cbEntryPoint ); }
		
		// validate incoming comment post
		prc.commentErrors = validateCommentPost(event,rc,prc,thisEntry);
		
		// Validate if comment errors exist
		if( arrayLen( prc.commentErrors ) ){
			// MessageBox
			getPlugin("MessageBox").warn(messageArray=prc.commentErrors);
			// put slug in request
			rc.entrySlug = thisEntry.getSlug();
			// Execute entry again, need to correct form
			entry(argumentCollection=arguments);
			return;	
		}
		
		// Valid commenting, so go and save
		saveComment( thisEntry );		
	}

}