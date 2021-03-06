﻿/**
* ContentBox main module configuration
*/
component {
	
	// Module Properties
	this.title 				= "ContentBox Core";
	this.author 			= "Ortus Solutions, Corp";
	this.webURL 			= "http://www.ortussolutions.com";
	this.description 		= "An enterprise modular content platform";
	this.version			= "1.0";
	this.viewParentLookup 	= true;
	this.layoutParentLookup = true;
	this.entryPoint			= "cbcore";
	
	function configure(){
		// contentbox settings
		settings = {};
		
		// interceptor settings
		interceptorSettings = {
			// ContentBox Custom Events
			customInterceptionPoints = arrayToList([
				// Code Rendering
				"cb_onContentRendering","cb_onCustomHTMLRendering"
			])
		};
				
		// interceptors
		interceptors = [
			// CB RSS Cache Cleanup Ghost
			{class="contentbox.model.rss.RSSCacheCleanup",name="RSSCacheCleanup@cb" },
			// Notification service interceptor
			{class="contentbox.model.system.NotificationService",name="NotificationService@cb" },
			// Content Renderers, remember order is important.
			{class="contentbox.model.content.renderers.WidgetRenderer"}		
		];
		
		// Security/System
		binder.map("securityService@cb").to("contentbox.model.security.SecurityService");
		binder.map("settingService@cb").to("contentbox.model.system.SettingService");
		binder.map("authorService@cb").to("contentbox.model.security.AuthorService");
		binder.map("permissionService@cb").to("contentbox.model.security.PermissionService");
		binder.map("roleService@cb").to("contentbox.model.security.RoleService");
		binder.map("securityRuleService@cb").to("contentbox.model.security.SecurityRuleService");
		// Entry services
		binder.map("entryService@cb").to("contentbox.model.content.EntryService");
		binder.map("categoryService@cb").to("contentbox.model.content.CategoryService");
		// Page services
		binder.map("pageService@cb").to("contentbox.model.content.PageService");
		// Commenting services
		binder.map("commentService@cb").to("contentbox.model.comments.CommentService");
		// RSS services
		binder.map("rssService@cb").to("contentbox.model.rss.RSSService");	
		// UI services
		binder.map("widgetService@cb").to("contentbox.model.ui.WidgetService");	
		binder.map("layoutService@cb").to("contentbox.model.ui.LayoutService");
		binder.map("customHTMLService@cb").to("contentbox.model.ui.CustomHTMLService");
		binder.map("CBHelper@cb").toDSL("coldbox:myplugin:CBHelper@contentbox");
		// utils
		binder.map("zipUtil@cb").to("coldbox.system.core.util.Zip");
		binder.map("HQLHelper@cb").to("contentbox.model.util.HQLHelper");
		binder.map("Validator@cb").to("coldbox.system.core.util.Validator");
		// importers
		binder.map("mangoImporter@cb").to("contentbox.model.importers.MangoImporter");
		binder.map("wordpressImporter@cb").to("contentbox.model.importers.WordpressImporter");
		
		// Load Hibernate Transactions for ContentBox
		loadHibernateTransactions(binder);
	}
	
	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
	}
	
	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){
	}
	
	/************************************** PRIVATE *********************************************/
	
	/**
	* load hibernatate transactions via AOP
	*/
	private function loadHibernateTransactions(binder){
		// map the hibernate transaction for contentbox
		binder.mapAspect(aspect="CBHibernateTransaction",autoBinding=false)
			.to("coldbox.system.aop.aspects.HibernateTransaction");	
			
		// bind the aspect
		binder.bindAspect(classes=binder.match().regex("contentbox.*"),
									methods=binder.match().annotatedWith("transactional"),
									aspects="CBHibernateTransaction");
	}
	
}
