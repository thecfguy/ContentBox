﻿/**
* Visit page hierarchies and create breadcrumbs
*/
component singleton="true"{
	
	property name="CBHelper" inject="CBHelper@cb";
	
	PageBreadcrumbVisitor function init(){
		
		// Plugin Properties
		setPluginName("PageBreadcrumbVisitor");
		setPluginVersion("1.0");
		setPluginDescription("Visit page hierarchies and create breadcrumbs");
		setPluginAuthor("Luis Majano");
		setPluginAuthorURL("http://www.ortussolutions.com");
		
		return this;
	}
	
	// visit
	function visit(page,separator=">"){
		var bc	= "";
		
		if( arguments.page.hasParent() ){
			bc &= visit( arguments.page.getParent() );
		}
		
		bc &= '#arguments.separator# <a href="#CBHelper.linkPage(arguments.page)#">#arguments.page.getTitle()#</a> ';
		
		return bc;
	}
	
}
