DotNet.LoadAssembly "System.Xml"

	/*
	================================================
	----------------------------  這邊是人家的好用 lib   -------------------------
	================================================
	*/

-- This sctructure encapsulate a DotNet XML node (class System.Xml.XmlElement)
-- to facilitate its manipulation and to add several methods useful in a Maxscript context
struct tXMLNode
(
	mDotNetNode,		-- the DotNet node (of class System.Xml.XmlElement)
	
	-- *** Always call this method when instancianting a tXMLNode structure! ***
	-- Note: Well, technicaly we could use tXMLNode mDotNetNode:rDnNode but in case we may need an initialization... (cd constructors)
	fn mfInit rDotNetNode =
	(
	--	format "tXMLNode: mfInit: rDnNode: %\n" rDnNode
		mDotNetNode = rDotNetNode
	),
	
	fn mfConvertStringToLowercase rStr =
	(
		local lUpperArr = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		local lLowerArr = "abcdefghijklmnopqrstuvwxyz"

		local lNewStr = ""
		local lTmpInd
		for i=1 to rStr.count do
			if undefined != (lTmpInd = findString lUpperArr rStr[i]) then
				 lNewStr += lLowerArr[lTmpInd]
			else lNewStr += rStr[i]
			
		return lNewStr
	),
	
	-- ----------------------------------------------------------
	-- Node name (or tag name)
	-- Note: In this implementation, the node name refers to the DotNet attribute name, not localName
	fn mfGetName =
	(
		return mDotNetNode.name
	),
	
	fn mfSetName rNewNameStr =
	(
		mDotNetNode.name = rNewNameStr
	),
	
	-- ----------------------------------------------------------
	-- Text
	fn mfGetText =
	(
		mDotNetNode.InnerText
	), 
	
	fn mfSetText rTextStr =
	(
		mDotNetNode.InnerText = rTextStr
	),
	
	-- ----------------------------------------------------------
	-- Attributes
	-- rValue doesn't have to be a string
	fn mfAddAttribute rAttributeStr rValue =
	(
		mDotNetNode.SetAttribute rAttributeStr (rValue as string)
		return mDotNetNode.GetAttribute rAttributeStr
	),
	
	fn mfGetAttribute rAttributeStr =
	(
		mDotNetNode.GetAttribute rAttributeStr
	),
	
	-- rValue doesn't have to be a string
	fn mfSetAttribute rAttributeStr rValue =
	(
		mDotNetNode.SetAttribute rAttributeStr (rValue as string)
		return mDotNetNode.GetAttribute rAttributeStr
	),
	
	fn mfDeleteAttribute rAttributeStr =
	(
		mDotNetNode.RemoveAttribute rAttributeStr
	),
	
	fn mfGetAllAttributes =
	(
		local lAttributesArr = #()
		local lDotNetAttributesArr = mDotNetNode.Attributes
		for i = 0 to (lDotNetAttributesArr.Count - 1) do
		(
			itemsArr = #()
			item = (lDotNetAttributesArr.ItemOf i)
			append itemsArr item.Name
			append itemsArr item.Value
			append lAttributesArr itemsArr
		)
		
		return lAttributesArr
	),
	
	
	fn mfHasAttribute rAttributeStr rbBeCaseSensitive: =
	(
		local lbBeCaseSensitive = if unsupplied == rbBeCaseSensitive then true else rbBeCaseSensitive
		local lbAttributeFound = false
		
		if undefined == rAttributeStr then
			lbAttributeFound = false
		else if not lbBeCaseSensitive then
			(
				local lAttribsArr = mDotNetNode.Attributes
					
				local lAttribInd = 0		-- warning: index goes from 0 to count - 1
				-- get an attribute with same name as rAttributeStr
				while not lbAttributeFound and lAttribsArr.Count > lAttribInd do
				(
					if ((lAttribsArr.ItemOf lAttribInd).Name as name) == (rAttributeStr as name) do		-- matching attrib name
						lbAttributeFound = true
					lAttribInd += 1
				)
			)
		else lbAttributeFound = mDotNetNode.hasAttribute rAttributeStr
		
		return lbAttributeFound	
	),

	fn mfHasAttributeWithThisValue rAttributeStr rAttributeValueStr rbBeCaseSensitive: rbAttributeContainsValue: =
	(
		local lbBeCaseSensitive = if unsupplied == rbBeCaseSensitive then true else rbBeCaseSensitive
		local lbAttributeContainsValue = if unsupplied == rbAttributeContainsValue then false else rbAttributeContainsValue
		local lbAttributeFound = false
		
		if undefined == rAttributeStr or undefined == rAttributeValueStr then
			lbAttributeFound = false
		else
		(
			if not lbBeCaseSensitive then
			(
				local lAttribsArr = mDotNetNode.Attributes
						
				local lAttribInd = 0		-- warning: index goes from 0 to count - 1
				-- get an attribute with same name as rAttributeStr
				while not lbAttributeFound and lAttribsArr.Count > lAttribInd do
				(
					if ((lAttribsArr.ItemOf lAttribInd).Name as name) == (rAttributeStr as name) do		-- matching attrib name
							-- compare the value of the attribute
							if lbAttributeContainsValue then
							(
								local lTmpAttribValueStr = mfConvertStringToLowercase (lAttribsArr.ItemOf lAttribInd).Value
								local lAttributeValueStr = mfConvertStringToLowercase rAttributeValueStr
								if undefined != findString lTmpAttribValueStr lAttributeValueStr do
								(
									lbAttributeFound = true
								--	ltNewNode = tXMLNode()
								--	ltNewNode.mfInit mDotNetNode
								)
							)
							else if ((lAttribsArr.ItemOf lAttribInd).Value as name) == (rAttributeValueStr as name) do		-- perfect matching of attrib value (excemp case sensitive)
								(
									lbAttributeFound = true
								--	ltNewNode = tXMLNode()
								--	ltNewNode.mfInit mDotNetNode
								)
						lAttribInd += 1
				)
			)
			else								-- case sensitive
			(
				local lAttribsArr = mDotNetNode.Attributes
				
				local lAttribInd = 0		-- warning: index goes from 0 to count - 1
				-- get an attribute with same name as rAttributeStr
			--	format "lAttribsArr.Count: %\n" lAttribsArr.Count
				while undefined == ltNewNode and lAttribsArr.Count > lAttribInd do
				(
					if (lAttribsArr.ItemOf lAttribInd).Name == rAttributeStr do		-- matching attrib name
						-- compare the value of the attribute
						if lbAttributeContainsValue then
						(
							local lTmpAttribValueStr = (lAttribsArr.ItemOf lAttribInd).Value
							local lAttributeValueStr = rAttributeValueStr
							local lSubstringInd = findString lTmpAttribValueStr lAttributeValueStr
						--	format "lTmpAttribValueStr: %, lAttribInd:% \n" lTmpAttribValueStr lAttribInd
							if undefined != lSubstringInd do
							(
								-- case sensitive comparison of attribute values (utile??)
							--	local lSubstringStr = substring lTmpAttribValueStr lSubstringInd (lAttributeValueStr.count)
							--	if lSubstringStr == lAttributeValueStr do
								(
									lbAttributeFound = true
								--	ltNewNode = tXMLNode()
								--	ltNewNode.mfInit mDotNetNode
								)
							)
						)
				-- wkip compare les valeurs en case sensitive
						--else if (lAttribsArr.ItemOf lAttribInd).Value == rAttributeValueStr do		-- perfect matching of attrib value (excemp case sensitive)
						else if ((lAttribsArr.ItemOf lAttribInd).Value as name) == (rAttributeValueStr as name) do		-- perfect matching of attrib value (excemp case sensitive)
							(
								lbAttributeFound = true
								--	ltNewNode = tXMLNode()
								--	ltNewNode.mfInit mDotNetNode
							)
					lAttribInd += 1
				)
			)
		)
		
		return lbAttributeFound	
	),
	
	-- ----------------------------------------------------------
	-- Nodes

	-- Append the argument node as a child of the current node
	-- return true on success, false otherwise
	fn mfAppendChild rtNewNode =
	(
		--local lbContinue = (classof rtNewNode == tXMLNode)
		
		--if lbContinue do
			--mDotNetNode.AppendChild (mDotNetNode.OwnerDocument.ImportNode rtNewNode.mDotNetNode true)
		mDotNetNode.AppendChild rtNewNode.mDotNetNode
		return lbContinue
	),

	-- Create a new child node with the tag given as parameter
	-- returns the child as a tXMLNode instance on success, undefined otherwise
	fn mfCreateChildByName rName =
	(
		local lNewDotNetNode = mDotNetNode.OwnerDocument.CreateElement rName
		mDotNetNode.AppendChild (mDotNetNode.OwnerDocument.ImportNode lNewDotNetNode true)

		local ltNewNode = tXMLNode()
		ltNewNode.mfInit lNewDotNetNode

		return ltNewNode
	),
	
	-- Private - Call mfGetChildrenNodesByName instead
	fn mfGetChildrenNodesByNameRec rNodeNameStr rDotNetNode &rChildrenNodesArr rbBeCaseSensitive: =
	(
		local lbBeCaseSensitive = if unsupplied == rbBeCaseSensitive then true else rbBeCaseSensitive
		local lTmpNode
		
		for i=1 to rDotNetNode.ChildNodes.Count do
		(
			lTmpNode = rDotNetNode.ChildNodes.ItemOf (i - 1)
			
			if not lbBeCaseSensitive then		-- not case sensitive
				if (rNodeNameStr as name) == (lTmpNode.name as name) do
				(
					ltNewNode = tXMLNode()
					ltNewNode.mfInit lTmpNode
					append rChildrenNodesArr ltNewNode
				)
			else								-- case sensitive
				if rNodeNameStr == lTmpNode.name do
				(
					ltNewNode = tXMLNode()
					ltNewNode.mfInit lTmpNode
					append rChildrenNodesArr ltNewNode
				)
			
			mfGetChildrenNodesByNameRec rNodeNameStr lTmpNode &rChildrenNodesArr rbBeCaseSensitive:lbBeCaseSensitive
		)
	),
	
	-- return an array of tXMLNode containing all the nodes with the name rNodeNameStr contained in the current node
	fn mfGetChildrenNodesByName rNodeNameStr rbBeCaseSensitive: =
	(
		local lbBeCaseSensitive = if unsupplied == rbBeCaseSensitive then true else rbBeCaseSensitive
		local lChildrenNodesArr = #()
		
		mfGetChildrenNodesByNameRec rNodeNameStr mDotNetNode &lChildrenNodesArr rbBeCaseSensitive:lbBeCaseSensitive
		
		return lChildrenNodesArr
	),
		
	fn mfGetChildren =
	(
		local lChildrenNodesArr = #()
		local lDotNetNode
		
		for i = 0 to (mDotNetNode.ChildNodes.Count - 1) do
		(
			lDotNetNode = mDotNetNode.ChildNodes.ItemOf i
			local lNewNode = tXMLNode()
			lNewNode.mfInit lDotNetNode
			append lChildrenNodesArr lNewNode
		)
		
		return lChildrenNodesArr
	),

	-- rIndex starts at 1
	fn mfGetChildByIndex rIndex =
	(
		local lDotNetNode = mDotNetNode.ChildNodes.ItemOf (rIndex - 1)
		local ltNewNode 			-- new tXMLNode
		
		if undefined != lDotNetNode and lDotNetNode.name != "#text" do
		(
			ltNewNode = tXMLNode()
			ltNewNode.mfInit lDotNetNode
		)
		
		return ltNewNode
	),
	
	-- warning: node names and attributes are case sensitive!!! We only look for "Name" and "name"
	-- case sensitive by default
	-- all the mDotNetNode have a property called name (the name of the node), which is different from attributes
	fn mfGetChildByName rChildNameStr rbBeCaseSensitive: =
	(
		local lbBeCaseSensitive = if unsupplied == rbBeCaseSensitive then true else rbBeCaseSensitive
		local lChildrenNodesArr = #()
		local ltNewNode
		
		local i = 1
		while undefined == ltNewNode and mDotNetNode.ChildNodes.Count >= i do
		(
			lTmpNode = mDotNetNode.ChildNodes.ItemOf (i - 1)
			if not lbBeCaseSensitive then		-- not case sensitive
				if (rChildNameStr as name) == (lTmpNode.name as name) do
				(
					ltNewNode = tXMLNode()
					ltNewNode.mfInit lTmpNode
				)
			else								-- case sensitive
				if rChildNameStr == lTmpNode.name do
				(
					ltNewNode = tXMLNode()
					ltNewNode.mfInit lTmpNode
				)
				
			i+=1
		)
		
		return ltNewNode
	),
	

	
	-- rbAttributeContainsValue:	set to false: the node attribute must match the value rAttributeValueStr (default)
	--								set to true: the node attribute must contain the value rAttributeValueStr
	-- returns the first node matching the settings
	/* for example: rNode2 = rNode.mfGetChildByNameAndAttribute "node" "name" "FixCam" with rNode name = "nodes"
		will return something with rNode2 name = "node" and rNode2 attribute name is "FixCam"
		<nodes>
			<node name="FixTeapot">
				...
            </node>
			<node name="FixCam">
				...
			</node>
		</nodes>
	*/
	fn mfGetChildByNameAndAttribute rChildNameStr rAttributeStr rAttributeValueStr rbBeCaseSensitive: rbAttributeContainsValue: =
	(
		local lbBeCaseSensitive = if unsupplied == rbBeCaseSensitive then true else rbBeCaseSensitive
		local lbAttributeContainsValue = if unsupplied == rbAttributeContainsValue then false else rbAttributeContainsValue
		local lChildrenNodesArr = #()
		local ltNewNode
		
		local i = 1
		while undefined == ltNewNode and mDotNetNode.ChildNodes.Count >= i do
		(
		--	format "i: %, mDotNetNode.ChildNodes.Count: %\n" i mDotNetNode.ChildNodes.Count
			local lTmpNode = mDotNetNode.ChildNodes.ItemOf (i - 1)
			
			if not lbBeCaseSensitive then		-- not case sensitive
			(
				-- look for a child with the node name matching with rChildNameStr
				if (rChildNameStr as name) == (lTmpNode.name as name) do
				(
					local lAttribsArr = lTmpNode.Attributes
					
					local lAttribInd = 0		-- warning: index goes from 0 to count - 1
					-- get an attribute with same name as rAttributeStr
					while undefined == ltNewNode and lAttribsArr.Count > lAttribInd do
					(
						if ((lAttribsArr.ItemOf lAttribInd).Name as name) == (rAttributeStr as name) do		-- matching attrib name
							-- compare the value of the attribute
							if lbAttributeContainsValue then
							(
								local lTmpAttribValueStr = mfConvertStringToLowercase (lAttribsArr.ItemOf lAttribInd).Value
								local lAttributeValueStr = mfConvertStringToLowercase rAttributeValueStr
								if undefined != findString lTmpAttribValueStr lAttributeValueStr do
								(
									ltNewNode = tXMLNode()
									ltNewNode.mfInit lTmpNode
								)
							)
							else if ((lAttribsArr.ItemOf lAttribInd).Value as name) == (rAttributeValueStr as name) do		-- perfect matching of attrib value (excemp case sensitive)
								(
									ltNewNode = tXMLNode()
									ltNewNode.mfInit lTmpNode
								)
						lAttribInd += 1
					)
				)
			)
			else								-- case sensitive
				-- look for a child with the node name matching with rChildNameStr
				if rChildNameStr == lTmpNode.name do
				(
					local lAttribsArr = lTmpNode.Attributes
					
					local lAttribInd = 0		-- warning: index goes from 0 to count - 1
					-- get an attribute with same name as rAttributeStr
				--	format "lAttribsArr.Count: %\n" lAttribsArr.Count
					while undefined == ltNewNode and lAttribsArr.Count > lAttribInd do
					(
						if (lAttribsArr.ItemOf lAttribInd).Name == rAttributeStr do		-- matching attrib name
							-- compare the value of the attribute
							if lbAttributeContainsValue then
							(
								local lTmpAttribValueStr = (lAttribsArr.ItemOf lAttribInd).Value
								local lAttributeValueStr = rAttributeValueStr
								local lSubstringInd = findString lTmpAttribValueStr lAttributeValueStr
							--	format "lTmpAttribValueStr: %, lAttribInd:% \n" lTmpAttribValueStr lAttribInd
								if undefined != lSubstringInd do
								(
									-- case sensitive comparison of attribute values (utile??)
								--	local lSubstringStr = substring lTmpAttribValueStr lSubstringInd (lAttributeValueStr.count)
								--	if lSubstringStr == lAttributeValueStr do
									(
										ltNewNode = tXMLNode()
										ltNewNode.mfInit lTmpNode
									)
								)
							)
					-- wkip compare les valeurs en case sensitive
							--else if (lAttribsArr.ItemOf lAttribInd).Value == rAttributeValueStr do		-- perfect matching of attrib value (excemp case sensitive)
							else if ((lAttribsArr.ItemOf lAttribInd).Value as name) == (rAttributeValueStr as name) do		-- perfect matching of attrib value (excemp case sensitive)
								(
									ltNewNode = tXMLNode()
									ltNewNode.mfInit lTmpNode
								)
						lAttribInd += 1
					)
				)
				
			i+=1
		)
		
		return ltNewNode
	),
	
	fn mfDeleteChild childNode =
	(
		if classof childNode == tXMLNode then (
			mDotNetNode.RemoveChild childNode.mDotNetNode
			return true
		)
		else false
	),
	
	fn mfDisplayNodeInfos =
	(
		local lStr = "\n name: " + mDotNetNode.name + "  \n"
		local lArr = mfGetAllAttributes()
		for i=1 to lArr.count do
			lStr += "   " + lArr[i][1] as string + ": " + lArr[i][2] as string + "\n"
		
		--lStr += "\n"
		format lStr
	)
)

struct tXMLDocument
(
	mVersion = 1.04,
	mDotNetXmlDoc = undefined,
	mXmlFilePath = undefined,
	
	-- rActionStr can be "create", "load" or "save"
	fn mfIsPathValid rXmlFilePath rbDisplayErrorMessages rActionStr =
	(
		local lbContinue = true
		
		if undefined == rXmlFilePath do
		(
			lbContinue = false
			if rbDisplayErrorMessages do
				messagebox ("XML Document: Specified path is undefined\n\nCannot " + rActionStr + " XML file") title:"WkXmlLibrary - Error                        "
		)
		
		if lbContinue do		-- check directory
			if not doesFileExist (getFilenamePath rXmlFilePath) do
			(
				lbContinue = false
				if rbDisplayErrorMessages do
					messagebox ("XML Document: Specified file path is not valid:\n\n" + rXmlFilePath as string + "\n\nCannot " + rActionStr + " XML file") title:"WkXmlLibrary - Error                        "
			)
		
		if lbContinue and "create" == rActionStr do		-- check if file exists
			if doesFileExist rXmlFilePath do
			(
				lbContinue = false
				if rbDisplayErrorMessages do
					messagebox ("XML Document: Specified file already exists:\n\n" + rXmlFilePath as string + "\n\nCannot " + rActionStr + " XML file") title:"WkXmlLibrary - Error                        "
			)

		if lbContinue and "load" == rActionStr do		-- check if file exists
			if not doesFileExist rXmlFilePath do
			(
				lbContinue = false
				if rbDisplayErrorMessages do
					messagebox ("XML Document: Specified file not found:\n\n" + rXmlFilePath as string + "\n\nCannot " + rActionStr + " XML file") title:"WkXmlLibrary - Error                        "
			)
			
		return lbContinue
	),
	
	-- Create a new XML document
	-- By default the document is empty and has no root node, use mfSetRootNode for that once the document is created
	-- As long as mfSaveXML has not been called and the file path and name have not been set, the XML document is not writen to the disk
	-- Return true if the document has been created, false otherwise
	-- rXmlFilePath:	(optional): path and name of the xml file to create
	--					The file extension can be anything, not just "xml"
	-- 				** Warnings**:	- If the specified path is invalid, the document cannot be created
	-- 								- If the file already exists, the document cannot be created. In this case create the document without file name and use mfSaveXMLAs()
	--	eg: myXmlDoc.mfCreateXML()
	--	eg: myXmlDoc.mfCreateXML rXmlFilePath:"c:\\temp\\myXml.scene"
	fn mfCreateXML rXmlFilePath: rbDisplayErrorMessages:true =
	(
		local lbContinue = true
		
		if unsupplied != rXmlFilePath do
		(
			lbContinue = mfIsPathValid rXmlFilePath rbDisplayErrorMessages "create"
			if lbContinue do
				mXmlFilePath = copy rXmlFilePath
		)
		
		if lbContinue do
			mDotNetXmlDoc = dotNetObject "System.Xml.XmlDocument"
		
		return lbContinue
	),
	
	-- Load the content of a XML document from a text file
	-- There is no need to call mfCreateXML() when calling this function
	-- Return true if the document has been loaded, false otherwise
	-- rXmlFilePath:	path and name of the xml file to load
	--					The file extension can be anything, not just "xml"
	-- rbDisplayErrorMessages: (optional): By default an error message opens if an error appens
	--	eg: myXmlDoc.mfLoadXML rXmlFilePath: "c:\\temp\\myXml.scene"
	fn mfLoadXML rXmlFilePath rbDisplayErrorMessages:true =
	(
		local lbContinue = mfIsPathValid rXmlFilePath rbDisplayErrorMessages "load"
		
		if lbContinue do
		(
			if undefined == mDotNetXmlDoc do
				mDotNetXmlDoc = dotNetObject "System.Xml.XmlDocument"
			if undefined == mDotNetXmlDoc then
				lbContinue = false
			else
			(
				mDotNetXmlDoc.Load rXmlFilePath
				mXmlFilePath = copy rXmlFilePath
			)
		)
		
		return lbContinue
	),
	
	-- Save the content of the XML document to the file specified in mXmlFilePath
	-- Return true if the document has been saved, false otherwise
	-- rXmlFilePath:	path and name of the xml file to save
	--					The file extension can be anything, not just "xml"
	-- rbDisplayErrorMessages: (optional): By default an error message opens if an error appens
	--	eg: myXmlDoc.mfSaveXMLAs "c:\\temp\\myXml.scene"
	fn mfSaveXMLAs rXmlFilePath rbDisplayErrorMessages:true rbOverwriteIfExist:false =
	(
		local lbContinue = true
		
		if undefined == mDotNetXmlDoc do
		(
			lbContinue = false
			if rbDisplayErrorMessages do
				messagebox ("XMLDocument: XML document cannot be saved, it is not fully initialized.   \n\nWas is correctly created or loaded?") title:"WkXmlLibrary - Error                        "
		)
		
		if lbContinue do
			lbContinue = mfIsPathValid rXmlFilePath rbDisplayErrorMessages "save"
			
		if lbContinue do		-- check if file exists
			if doesFileExist rXmlFilePath and not rbOverwriteIfExist do
				lbContinue = querybox ("XML Document: Specified file already exists:\n\n" + rXmlFilePath as string + "\n\nDo you want to overwrite it?") title:"WkXmlLibrary - XML File Exists                        "
		
		if lbContinue do
		(
			-- document cannot be saved if it doesn't have a root node
			if undefined == mDotNetXmlDoc.DocumentElement then
			(
				lbContinue = false
				if rbDisplayErrorMessages do
					messagebox ("XMLDocument: Document cannot be saved because it has no root node:\n\n" + rXmlFilePath as string + "\n\n") title:"WkXmlLibrary - Error                        "			
			)
			else
			(
				try( mDotNetXmlDoc.Save rXmlFilePath )
				catch ( lbContinue = false )
				if lbContinue then
					mXmlFilePath = copy rXmlFilePath
				else if rbDisplayErrorMessages do
					messagebox ("XML Document: Specified file cannot be saved:\n\n" + rXmlFilePath as string + "\n\nCannot save XML file") title:"WkXmlLibrary - Error                        "			
			)
		)
		
		return lbContinue
	),
	
	-- Save the content of the XML document to the file specified in mXmlFilePath
	-- Return true if the document has been saved, false otherwise
	-- rbDisplayErrorMessages: (optional): By default an error message opens if an error appens
	fn mfSaveXML rbDisplayErrorMessages:true =
	(
		return mfSaveXMLAs mXmlFilePath rbDisplayErrorMessages:rbDisplayErrorMessages rbOverwriteIfExist:true
	),
	
	--xmldocument在save的時候encoding都會變成ansi，所以要透過xmlWriter存成utf-8格式(程式部門要求xml為utf-8格式)
	-- rbDisplayErrorMessages: (optional): By default an error message opens if an error appens
	fn mfSavebyXmlWriter rXmlFilePath rbDisplayErrorMessages:true =
	(
		local lbContinue = mfIsPathValid rXmlFilePath rbDisplayErrorMessages "load"
		
		if lbContinue do
		(
			if undefined == mDotNetXmlDoc do
				mDotNetXmlDoc = dotNetObject "System.Xml.XmlDocument"
			if undefined == mDotNetXmlDoc then
				lbContinue = false
			else
			(
				xmlWriter=dotNetClass "System.Xml.XmlWriter"
				xmlSettings = dotNetObject "System.Xml.XmlWriterSettings"
				xmlSettings.Indent = true						--Element會分行顯示
				xmlSettings.NewLineOnAttributes = false
				--omit(忽略) the XML declaration，(如果設定為false，輸出後xml第一行會多一行<?xml version="1.0" encoding="UTF-8"?>)
				xmlSettings.OmitXmlDeclaration = true	
				
				
				nav = mDotNetXmlDoc.CreateNavigator()	--將xmlDoc的撰寫位置與內容等相關資料全傳給nav(晚點會被writer用到)
				--nav.OuterXml										--以string的方式取得xml裡面的所有資料(單純檢查用)
				
				--Create the Writer
				writer = XmlWriter.Create rXmlFilePath xmlSettings
				writer.WriteStartDocument()					--Write the start tag.
				writer.WriteNode nav false						--將整段mDotNetXmlDoc以utf8的格式寫入
				writer.WriteEndDocument()
				writer.Close()										--Close the writer.
			)
		)
		return lbContinue
	),
	

	fn mfReleaseXML =
	(
		mDotNetXmlDoc = undefined
		mXmlFilePath = undefined
		gc()						-- note: we may probably call the DotNet garbage collector instead
	),
	
	-- Create a root node if none already exist
	-- return the root node of the document as a tXMLNode structure if the root node has been created,
	-- undefined otherwise.
	-- There can be only one root node. If a root node already exists the function returns false
	-- To modify an existing root node create a new node with mfGetNewNode() and set it with mfSetRootNode()
	fn mfCreateRootNode rName =
	(
		local lRootNode = undefined
		local lbContinue = undefined != mDotNetXmlDoc
				
		if lbContinue and undefined == mDotNetXmlDoc.DocumentElement do
		(
			local lDotNetNode = mDotNetXmlDoc.CreateElement rName
			mDotNetXmlDoc.AppendChild lDotNetNode
			if undefined != mDotNetXmlDoc.DocumentElement do
			(
				lRootNode = tXMLNode()
				lRootNode.mfInit mDotNetXmlDoc.DocumentElement
			)
		)
		
		return lRootNode
	),
	
	-- return the root node of the document as a tXMLNode structure, undefined if no root exists
	-- or if the document is not correctly initialized
	-- There can be only one root node
	fn mfGetRootNode =
	(
		local lRootNode = undefined
		local lbContinue = undefined != mDotNetXmlDoc
		
		if lbContinue and undefined != mDotNetXmlDoc.DocumentElement do
		(
			lRootNode = tXMLNode()
			lRootNode.mfInit mDotNetXmlDoc.DocumentElement
		)
		
		return lRootNode
	),

	-- return true if the node has been set, false otherwise
	-- There can be only one root node.
	-- If a root node already exists the existing one will be overwritten
	-- If the rNewRootNode is already in the tree, it is first removed
	-- rNewRootNode: tXMLNode structure containing the node to set as the new root
	fn mfSetRootNode rNewRootNode =
	(
		local lbContinue = undefined != mDotNetXmlDoc
		
		if lbContinue do
			lbContinue = (classof rNewRootNode == tXMLNode)
		
		if lbContinue do
			if undefined == mDotNetXmlDoc.DocumentElement then
				mDotNetXmlDoc.AppendChild rNewRootNode.mDotNetNode
			else mDotNetXmlDoc.ReplaceChild mDotNetXmlDoc.DocumentElement rNewRootNode.mDotNetNode
		
		return lbContinue
	),
	
	-- return a node in the form of a tXMLNode structure instance,
	-- undefined if the document has not been initialized with mfCreateXML() or mfLoadXML()
	-- The returned node has no parent and doesn't belong to the nodes hierarchy, it has to be added
	-- explicitly with wkip
	-- rName:	the name of the node
	-- eg:	myXmlDoc.mfGetNewNode "position"
	fn mfGetNewNode rName =
	(
		local ltNewNode 			-- new tXMLNode
		
	--	local lTmpDotNetNode = mDotNetXmlDoc.CreateElement rName
	--	format "  mfGetNewNode: lTmpDotNetNode = %\n" lTmpDotNetNode
	--	global lDotNetNode = mDotNetXmlDoc.ImportNode lTmpDotNetNode true
	--	format "  mfGetNewNode: lDotNetNode = %\n" lDotNetNode
		
		lDotNetNode = mDotNetXmlDoc.CreateElement rName
		
		ltNewNode = tXMLNode()
		ltNewNode.mfInit lDotNetNode

		
--		myLoadedXmlDoc.mDotNetXmlDoc.ImportNode (myLoadedXmlDoc.mDotNetXmlDoc.CreateElement "teset") true
--		myRootNode.mDotNetNode.AppendChild myNodeLevel2.mDotNetNode
		
		return ltNewNode
	)
)

/*
================================================
-------------- 好用 lib 結束  ----------------------------
================================================
*/