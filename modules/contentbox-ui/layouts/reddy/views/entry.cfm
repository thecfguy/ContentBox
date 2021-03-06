﻿<cfoutput>
<!--- ContentBoxEvent --->
#cb.event("cbui_preEntryDisplay")#

<!--- SideBar --->
<div id="sidebar">#cb.quickView(view='sidebar')#</div>

<!--- content --->
<div id="text" >
	
	<!--- post --->
	<div class="post" id="post_#prc.entry.getEntryID()#">
		
		<!--- Date --->
		<div class="post-date" title="Posted on #prc.entry.getDisplayPublishedDate()#">
			<span class="post-month">#dateFormat(prc.entry.getPublishedDate(),"MMM")#</span> 
			<span class="post-day">#dateFormat(prc.entry.getPublishedDate(),"dd")#</span>
		</div>
		
		<!--- Title --->
		<div class="post-title">
			
			<!--- content Author --->
			<div class="post-content-author">
				#cb.quickAvatar(author=prc.entry.getAuthor(),size=30)# #prc.entry.getAuthorName()#
			</div>
			
			<!--- Title --->
			<h2><a href="#cb.linkEntry(prc.entry)#" rel="bookmark" title="#prc.entry.getTitle()#">#prc.entry.getTitle()#</a></h2>
			
			<!--- Category Bar --->
			<span class="post-cat">#cb.quickCategoryLinks(prc.entry)#</span> 
			
			<!--- content --->
			<div class="post-content">
				#prc.entry.renderContent()#
			</div>
		</div>
				
		<!--- Comments Bar --->
		#html.anchor(name="comments")#
		<div class="post-comments">
			<div class="infoBar">
				<cfif NOT cb.isCommentsEnabled(prc.entry)>
				<img src="#cb.layoutRoot()#/includes/images/important.png" alt="warning" />
				Comments are currently closed
				<cfelse>
				<button class="button2" onclick="toggleCommentForm()"> Add Comment </button>
				<img src="#cb.layoutRoot()#/includes/images/comments_32.png" alt="comments" /> #prc.entry.getNumberOfApprovedComments()#
				</cfif>
			</div>
			<br/>										
		</div>
		
		<!--- Separator --->	
		<div class="separator"></div>
		
		<!--- Comment Form: I can build it or I can quick it? --->
		<div id="commentFormShell">
		#cb.quickCommentForm(prc.entry)#
		</div>
		
		<div class="clr"></div>
		
		<!--- Display Comments --->
		<div id="comments">
			#cb.quickComments()#
		</div>
		
	</div>
		
	
</div> 

<!--- ContentBoxEvent --->
#cb.event("cbui_postEntryDisplay")#

<!--- Custom JS --->
<script type="text/javascript">
$(document).ready(function() {
 	// form validator
	$("##commentForm").validator({position:'top left'});
	<cfif cb.isCommentFormError()>
	toggleCommentForm();
	</cfif>
});
function toggleCommentForm(){
	$("##commentForm").slideToggle();
}
</script>
</cfoutput>