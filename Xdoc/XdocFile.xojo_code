#tag Class
Protected Class XdocFile
	#tag Method, Flags = &h0
		Sub Constructor(name As String, file As FolderItem)
		  Self.Name = name
		  Self.File = file
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EatTillTagEnd(tis As TextInputStream)
		  Dim line As String
		  
		  While line.Left(8) <> "#tag End"
		    line = tis.ReadLine.Trim
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function MatchMethodSignature(text As String) As RegExMatch
		  Static rx As RegEx
		  
		  If rx Is Nil Then
		    rx = New RegEx
		    rx.SearchPattern = "(?mi-Us)((Private|Protected|Public|Global)\s)*((Shared)\s)*(Event|Function|Sub)\s([a-z0-9_]+)\((.*)\)(\sAs\s(.*))*"
		    
		    dim rxOptions As RegExOptions = rx.Options
		    rxOptions.LineEndType = 4
		  End If
		  
		  Return rx.Search(text)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function MatchPropertySignature(text As String) As RegExMatch
		  Static rx As RegEx
		  
		  If rx Is Nil Then
		    rx = New RegEx
		    rx.SearchPattern = "(?mi-Us)^((Private|Protected|Public|Global)\s)?((Shared)\s)?([a-z0-9_\-\(\),]+)\sAs\s(.*)$"
		    
		    dim rxOptions As RegExOptions = rx.Options
		    rxOptions.LineEndType = 4
		  End If
		  
		  Return rx.Search(text)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function MatchTag(text As String) As RegExMatch
		  Static rx As RegEx
		  
		  If rx Is Nil Then
		    rx = New RegEx
		    rx.SearchPattern = "(?mi-Us)^\s*#tag\s([^,]+)(, Name = ([a-z0-9_\- ]+))*"
		    
		    Dim rxOptions As RegExOptions = rx.Options
		    rxOptions.LineEndType = 4
		  End If
		  
		  Return rx.Search(text)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 50617273652074686520636F6E74656E7473206F66207468652066696C6520706F70756C6174696E67206974732070726F70657274696573
		Sub Parse()
		  // .Parameters
		  // * `flags` - Bit flags regarding what to include or not, see +<<App.kIncludeEvents,App.kIncludeEvents>>+,
		  //   +<<App.kIncludePrivate,App.kIncludePrivate>>+,
		  //   +<<App.kIncludeProtected,App.kIncludeProtected>>+
		  //
		  // .Notes
		  // Current parses Event Definitions, Constants, Properties, Computed Properties,
		  // Methods, Events and Notes. Information is stored such as visibility, shared/instance,
		  // etc...
		  //
		  // Events, Event Definitions and Methods are all parsed as a +<<Xdoc.XdocMethod,Xdoc.XdocMethod>>+. All other
		  // items have specific classes to represent the parsed data.
		  //
		  // .See Also:
		  // +<<Xdoc.XdocConstant>>+, +<<Xdoc.XdocProperty>>+, +<<Xdoc.XdocMethod>>+ and +<<Xdoc.XdocNote>>+.
		  //
		  
		  If File.Name.Right(13) = "xojo_xml_code" Then
		    ParseXml
		  Else
		    ParseCode
		  End If
		  
		  For i As Integer = 0 To Notes.Ubound
		    Dim o As XdocNote = Notes(i)
		    
		    If o.Name = "Overview" Then
		      OverviewNote = o
		      Notes.Remove i
		      
		      Exit For i
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseCode()
		  Const kNone = 0
		  Const kMethod = 1
		  Const kProperty = 2
		  Const kEvent = 3
		  
		  Dim tis As TextInputStream = TextInputStream.Open(File)
		  
		  While Not tis.EOF
		    Dim line As String = tis.ReadLine.Trim
		    
		    If line.Instr("#tag") = 1 Then
		      Dim t As New XdocTag(line)
		      
		      Select Case t.TagType
		      Case "Method"
		        Dim o As XdocMethod = ParseMethod(tis)
		        o.Tag = t
		        
		        If o.IsShared Then
		          SharedMethods.Append o
		        Else
		          Methods.Append o
		        End If
		        
		      Case "Event"
		        Dim e As XdocMethod = ParseMethod(tis)
		        e.Tag = t
		        
		        Events.Append e
		        
		      Case "ComputedProperty", "Property"
		        Dim o As XdocProperty = ParseProperty(tis)
		        o.Tag = t
		        
		        If o.IsShared Then
		          SharedProperties.Append o
		        Else
		          Properties.Append o
		        End If
		        
		      Case "Note"
		        Dim o As XdocNote = ParseNote(tis, t.Name)
		        o.Tag = t
		        
		        Notes.Append o
		        
		      Case "Hook"
		        Dim o As XdocMethod = ParseMethod(tis)
		        o.Tag = t
		        
		        EventDefinitions.Append o
		        
		      Case "Enum"
		        Dim o As XdocEnum = ParseEnum(tis, t.Name)
		        o.Tag = t
		        o.Visibility = o.Tag.Visibility
		        
		        Enums.Append o
		        
		      Case "Constant"
		        Dim o As XdocConstant = ParseConstant(tis, t)
		        o.Tag = t
		        
		        Constants.Append o
		      End Select
		    End If
		  Wend
		  
		  tis.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseConstant(tis As TextInputStream, tag As XdocTag) As XdocConstant
		  Dim c As New XdocConstant
		  c.Name = tag.Name
		  c.Type = tag.Type
		  c.Value = tag.Default
		  c.Visibility = tag.Visibility
		  c.Description = tag.Description
		  
		  EatTillTagEnd(tis)
		  
		  Return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseEnum(tis As TextInputStream, name As String) As XdocEnum
		  Dim e As New XdocEnum
		  e.Name = name
		  
		  Dim line As String = tis.ReadLine.Trim
		  
		  While line <> "#tag EndEnum"
		    e.Values.Append line
		    line = tis.ReadLine.Trim
		  Wend
		  
		  Return e
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseMethod(tis As TextInputStream) As XdocMethod
		  Const kVisibility = 2
		  Const kShared = 4
		  Const kType = 5
		  Const kName = 6
		  Const kParameters = 7
		  Const kReturnType = 9
		  
		  Dim line As String = tis.ReadLine
		  Dim match As RegExMatch = MatchMethodSignature(line)
		  
		  If match Is Nil Then
		    stderr.WriteLine "Something went wrong..." + EndOfLine + _
		    ">>> " + line.Trim + "<<<" + EndOfLine + _
		    "should be a method signature but couldn't be parsed as one."
		    
		    Quit 1
		  End If
		  
		  Dim notes() As String
		  
		  While Not tis.EOF
		    line = tis.ReadLine.Trim
		    
		    If line.Left(1) = "'" Then
		      line = line.Mid(2).Trim
		      
		    ElseIf line.Left(2) = "//" Then
		      line = line.Mid(3).RTrim
		      If line.Left(1) = " " Then
		        line = line.Mid(2)
		      End If
		      
		    Else
		      // We are no longer in a comment
		      Exit
		    End If
		    
		    notes.Append line
		  Wend
		  
		  Dim meth As New XdocMethod
		  meth.Visibility = XdocProject.VisibilityFor(match.SubExpressionString(kVisibility))
		  meth.Type = If(match.SubExpressionString(kType) = "Sub", XdocMethod.kSub, XdocMethod.kFunction)
		  meth.Name = match.SubExpressionString(kName)
		  meth.Parameters = match.SubExpressionString(kParameters).Split(", ")
		  
		  If match.SubExpressionCount > kReturnType Then
		    meth.ReturnType = match.SubExpressionString(kReturnType)
		  End If
		  
		  meth.IsShared = (match.SubExpressionString(kShared) <> "")
		  
		  meth.Notes = Join(notes, EndOfLine)
		  
		  If line.Trim.InStr("#tag End") <> 1 Then
		    EatTillTagEnd(tis)
		  End If
		  
		  Return meth
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseNote(tis As TextInputStream, name As String) As XdocNote
		  Dim note As New XdocNote
		  note.Name = name
		  
		  Dim removeCount As Integer = -1
		  Dim lines() As String
		  
		  While Not tis.EOF
		    #Pragma Warning "Count leading spaces to remove, don't remove all!"
		    
		    // This will strip leading spaces, even in the note, some of which
		    // could be indentation important to formatting.
		    
		    Dim line As String = tis.ReadLine
		    If removeCount = -1 Then
		      Static spaceRx As RegEx
		      If spaceRx Is Nil Then
		        spaceRx = New RegEx
		        spaceRx.SearchPattern = "^\s*"
		      End If
		      
		      Dim match As RegExMatch = spaceRx.Search(line)
		      removeCount = match.SubExpressionString(0).Len
		    End If
		    
		    If line.Trim = "#tag EndNote" Then
		      Exit
		    End If
		    
		    lines.Append line
		  Wend
		  
		  For i As Integer = 0 To lines.Ubound
		    lines(i) = lines(i).Mid(removeCount + 1)
		  Next
		  
		  note.Text = Join(lines, EndOfLine)
		  
		  Return note
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseProperty(tis As TextInputStream) As XdocProperty
		  '#tag Property, Flags = &h0
		  '  #tag Note
		  '    Project manifest `FolderItem`
		  '  #tag EndNote
		  '  File As FolderItem
		  '#tag EndProperty
		  
		  '#tag ComputedProperty, Flags = &h0
		  '  #tag Note
		  '    Get or Set the font's BOLD state
		  '  #tag EndNote
		  '  #tag Getter
		  '    Get
		  '      Return Run.Bold
		  '    End Get
		  '  #tag EndGetter
		  '  #tag Setter
		  '    Set
		  '      Run.Bold = value
		  '    End Set
		  '  #tag EndSetter
		  '  Bold As Boolean
		  '#tag EndComputedProperty
		  
		  Dim prop As New XdocProperty
		  Dim line As String = tis.ReadLine.Trim
		  
		  If line = "#tag Note" Then
		    Dim n As XdocNote = ParseNote(tis, "")
		    prop.Note = n.Text
		    
		    line = tis.ReadLine.Trim
		  End If
		  
		  While line.Left(4) = "#tag"
		    EatTillTagEnd(tis)
		    
		    line = tis.ReadLine.Trim
		  Wend
		  
		  Const kVisibility = 2
		  Const kShared = 4
		  Const kName = 5
		  Const kType = 6
		  
		  Dim match As RegExMatch = MatchPropertySignature(line)
		  prop.Declaration = line
		  prop.Visibility = XdocProject.VisibilityFor(match.SubExpressionString(kVisibility))
		  prop.Name = match.SubExpressionString(kName)
		  prop.Type = match.SubExpressionString(kType)
		  prop.IsShared = (match.SubExpressionString(kShared) <> "")
		  
		  EatTillTagEnd(tis)
		  
		  Return prop
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseXml()
		  Dim xml As New XmlDocument(File)
		  Dim root As XmlNode = xml.Child(0).Child(0) // <block>...</block>
		  
		  Dim kv As Dictionary
		  
		  For i As Integer = 0 To root.ChildCount - 1
		    Dim n As XmlNode = root.Child(i)
		    
		    Select Case n.Name
		    Case "IsClass"
		      IsClass = (n.TextNodeValue = "1")
		      
		    Case "Method", "HookInstance"
		      kv = xParseItem(n, False)
		      
		      Dim o As New XdocMethod
		      o.Tag = New XdocTag
		      o.Tag.Description = kv.Lookup("CodeDescription", "")
		      o.Name = kv.Lookup("ItemName", "")
		      
		      o.IsShared = (kv.Lookup("IsShared", "0") = "1")
		      o.Notes = kv.Lookup("__note", "")
		      o.Parameters = kv.Lookup("ItemParams", "").StringValue.Split(", ")
		      o.ReturnType = kv.Lookup("ItemResult", "")
		      o.Type = kv.Lookup("__type", 0)
		      o.Visibility = kv.Lookup("__visibility", xDocProject.kVisibilityNone)
		      
		      If n.Name = "Method" Then
		        If o.IsShared Then
		          SharedMethods.Append o
		        Else
		          Methods.Append o
		        End If
		        
		      Else
		        Events.Append o
		      End If
		      
		    Case "Constant"
		      kv = xParseItem(n, False)
		      
		      Dim o As New XdocConstant
		      o.Tag = New XdocTag
		      o.Tag.Description = kv.Lookup("CodeDescription", "")
		      o.Description = o.Tag.Description
		      o.Name = kv.Lookup("ItemName", "")
		      o.Value = kv.Lookup("ItemDef", "")
		      o.Visibility = kv.Lookup("__visibility", xDocProject.kVisibilityNone)
		      
		      Select Case kv.Lookup("ItemType", "0")
		      Case "0"
		        o.Type = "String"
		        o.Value = """" + o.Value + """"
		      Case "1"
		        o.Type = "Number"
		      Case "2"
		        o.Type = "Color"
		      Case "3"
		        o.Type = "Boolean"
		      End Select
		      
		      Constants.Append o
		      
		    Case "Property"
		      kv = xParseItem(n, True, True)
		      
		      Dim o As New XdocProperty
		      o.Tag = New XdocTag
		      o.Tag.Description = kv.Lookup("CodeDescription", "")
		      o.Declaration = kv.Lookup("ItemDeclaration", "")
		      o.IsShared = (kv.Lookup("IsShared", "0") = "1")
		      o.Name = kv.Lookup("ItemName", "")
		      o.Note = kv.Lookup("__note", "")
		      o.Visibility = kv.Lookup("__visibility", xDocProject.kVisibilityNone)
		      
		      If o.IsShared Then
		        SharedProperties.Append o
		      Else
		        Properties.Append o
		      End If
		      
		    Case "Note"
		      kv = xParseItem(n, True, True)
		      
		      Dim o As New XdocNote
		      o.Tag = New XdocTag
		      o.Name = kv.Lookup("ItemName", "")
		      o.Text = kv.Lookup("__note", "")
		      
		      Notes.Append o
		      
		    Case "Enumeration"
		      kv = xParseItem(n, True)
		      
		      Dim o As New XdocEnum
		      o.Tag = New XdocTag
		      o.Tag.Description = kv.Lookup("CodeDescription", "")
		      o.Name = kv.Lookup("ItemName", "")
		      o.Values = kv.Lookup("__note", "").StringValue.Split(EndOfLine)
		      o.Visibility = kv.Lookup("__visibility", XdocProject.kVisibilityNone)
		      
		      Enums.Append o
		      
		    Case "Hook"
		      kv = xParseItem(n)
		      
		      Dim o As New XdocMethod
		      o.Tag = New XdocTag
		      o.Tag.Description = kv.Lookup("CodeDescription", "")
		      o.Name = kv.Lookup("ItemName", "")
		      o.Notes = kv.Lookup("__note", "")
		      o.Parameters = kv.Lookup("ItemParams", "").StringValue.Split(", ")
		      o.ReturnType = kv.Lookup("ItemResult", "")
		      o.Visibility = kv.Lookup("__visibility", xDocProject.kVisibilityNone)
		      
		      EventDefinitions.Append o
		      
		    End Select
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function xParseItem(parent As XmlNode, sourceAsNote As Boolean = False, ignoreFirstSourceLine As Boolean = False) As Dictionary
		  Dim result As New Dictionary
		  
		  For i As Integer = 0 To parent.ChildCount - 1
		    Dim child As XmlNode = parent.Child(i)
		    
		    If child.FirstChild Is Nil Then
		      result.Value(child.Name) = Nil
		      
		    ElseIf child.Name = "Flags" Or child.Name = "ItemFlags" Then
		      Dim vis As Integer = XdocProject.kVisibilityNone
		      
		      result.Value(child.Name) = child.TextNodeValue
		      
		      Select Case child.TextNodeValue
		      Case "0"
		        vis = If(IsClass, XdocProject.kVisibilityPublic, XdocProject.kVisibilityGlobal)
		        
		      Case "1"
		        vis = XdocProject.kVisibilityProtected
		        
		      Case "33"
		        vis = XdocProject.kVisibilityPrivate
		      End Select
		      
		      result.Value("__visibility") = vis
		      
		    ElseIf child.FirstChild.Type = XmlNodeType.TEXT_NODE Then
		      result.Value(child.Name) = child.TextNodeValue
		      
		    ElseIf child.Name = "ItemSource" Then
		      result.Value(child.Name) = child
		      
		      Dim lines() As String
		      Dim stripLeading As Integer = -1
		      Dim sourceCount As Integer
		      
		      For j As Integer = 0 To child.ChildCount - 1
		        Dim source As XmlNode = child.Child(j)
		        
		        If source.Name.Right(4) = "Line" Then
		          sourceCount = sourceCount + 1
		          
		          If sourceAsNote Then
		            If ignoreFirstSourceLine = False Or sourceCount > 1 Then
		              lines.Append source.TextNodeValue
		            End If
		          Else
		            Dim line As String
		            
		            
		            If Not (source.FirstChild Is Nil) Then
		              line = source.TextNodeValue
		              
		              If line.Left(1) = "'" Then
		                line = line.Mid(2)
		              ElseIf line.Left(2) = "//" Then
		                line = line.Mid(3)
		              ElseIf sourceCount > 1 Then
		                Exit For j
		              Else
		                If line.InStr("Sub") = 1 Then
		                  result.Value("__type") = XdocMethod.kSub
		                ElseIf line.InStr("Function") = 1 Then
		                  result.Value("__type") = XdocMethod.kFunction
		                Else
		                  result.Value("__type") = 0
		                End If
		                
		                Continue For j
		              End If
		              
		              If stripLeading = -1 And sourceCount > 1 Then
		                For k As Integer = 1 To line.Len
		                  If line.Mid(k, 1) <> " " Then
		                    stripLeading = k
		                    Exit For k
		                  End If
		                Next
		              End If
		              
		              lines.Append line.Mid(stripLeading)
		            End If
		          End If
		        End If
		      Next
		      
		      result.Value("__note") = Join(lines, EndOfLine)
		    End If
		  Next
		  
		  Return result
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Constants() As XdocConstant
	#tag EndProperty

	#tag Property, Flags = &h0
		Enums() As XdocEnum
	#tag EndProperty

	#tag Property, Flags = &h0
		EventDefinitions() As XdocMethod
	#tag EndProperty

	#tag Property, Flags = &h0
		Events() As XdocMethod
	#tag EndProperty

	#tag Property, Flags = &h0
		File As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		FullName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Id As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private IsClass As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Methods() As XdocMethod
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Notes() As XdocNote
	#tag EndProperty

	#tag Property, Flags = &h0
		OverviewNote As XdocNote
	#tag EndProperty

	#tag Property, Flags = &h0
		ParentId As String = "&h0"
	#tag EndProperty

	#tag Property, Flags = &h0
		Properties() As XdocProperty
	#tag EndProperty

	#tag Property, Flags = &h0
		SharedMethods() As XdocMethod
	#tag EndProperty

	#tag Property, Flags = &h0
		SharedProperties() As XdocProperty
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="FullName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Id"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ParentId"
			Group="Behavior"
			InitialValue="&h0"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Type"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
