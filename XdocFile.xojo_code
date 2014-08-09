#tag Class
Protected Class XdocFile
	#tag Method, Flags = &h0
		Sub Constructor(name As String, file As FolderItem)
		  Self.Name = name
		  Self.File = file
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function MatchMethodSignature(text As String) As RegExMatch
		  Static rx As RegEx
		  
		  If rx Is Nil Then
		    rx = New RegEx
		    rx.SearchPattern = "(?mi-Us)(Private|Protected|Public|Global)*\s(Event|Function|Sub)\s([a-z0-9_]+)\((.*)\)(\sAs\s(.*))*"
		    
		    dim rxOptions As RegExOptions = rx.Options
		    rxOptions.LineEndType = 4
		  End If
		  
		  Return rx.Search(text)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function MatchPropertySignature(text As String) As RegExMatch
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

	#tag Method, Flags = &h0
		 Shared Function MatchTag(text As String) As RegExMatch
		  Static rx As RegEx
		  
		  If rx Is Nil Then
		    rx = New RegEx
		    rx.SearchPattern = "(?mi-Us)^\s*#tag\s([a-z0-9_]+)(, Name = ([a-z0-9_ ]+))*"
		    
		    Dim rxOptions As RegExOptions = rx.Options
		    rxOptions.LineEndType = 4
		  End If
		  
		  Return rx.Search(text)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Parse()
		  Const kNone = 0
		  Const kMethod = 1
		  Const kProperty = 2
		  Const kEvent = 3
		  
		  Dim tis As TextInputStream = TextInputStream.Open(File)
		  
		  While Not tis.EOF
		    Dim line As String = tis.ReadLine.Trim
		    
		    Dim match As RegExMatch = MatchTag(line)
		    If match <> Nil Then
		      Select Case match.SubExpressionString(1)
		      Case "Method"
		        Methods.Append ParseMethod(tis)
		        
		      Case "Event"
		        Events.Append ParseMethod(tis)
		        
		      Case "Property"
		        Properties.Append ParseProperty(tis)
		        
		      Case "Note"
		        Notes.Append ParseNote(tis, match.SubExpressionString(3))
		        
		      Case "Hook"
		        EventDefinitions.Append ParseMethod(tis)
		      End Select
		    End If
		    
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseMethod(tis As TextInputStream) As XdocMethod
		  Const kVisibility = 1
		  Const kType = 2
		  Const kName = 3
		  Const kParameters = 4
		  Const kReturnType = 6
		  
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
		      line = line.Mid(3).Trim
		      
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
		  
		  meth.Notes = Join(notes, EndOfLine)
		  
		  Return meth
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseNote(tis As TextInputStream, name As String) As XdocNote
		  Dim note As New XdocNote
		  note.Name = name
		  
		  Dim lines() As String
		  
		  While Not tis.EOF
		    #Pragma Warning "Count leading spaces to remove, don't remove all!"
		    
		    // This will strip leading spaces, even in the note, some of which
		    // could be indentation important to formatting.
		    
		    Dim line As String = tis.ReadLine.Trim
		    
		    If line = "#tag EndNote" Then
		      Exit
		    End If
		    
		    lines.Append line
		  Wend
		  
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
		  
		  Dim prop As New XdocProperty
		  Dim line As String = tis.ReadLine.Trim
		  
		  If line = "#tag Note" Then
		    Dim n As XdocNote = ParseNote(tis, "")
		    prop.Note = n.Text
		    
		    line = tis.ReadLine.Trim
		  End If
		  
		  Const kVisibility = 2
		  Const kShared = 4
		  Const kName = 5
		  Const kType = 6
		  
		  Dim match As RegExMatch = MatchPropertySignature(line)
		  prop.Declaration = line
		  prop.Visibility = XdocProject.VisibilityFor(match.SubExpressionString(kVisibility))
		  prop.Name = match.SubExpressionString(kName)
		  prop.Type = match.SubExpressionString(kType)
		  
		  Return prop
		End Function
	#tag EndMethod


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
		Id As String
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
		ParentId As String = "&h0"
	#tag EndProperty

	#tag Property, Flags = &h0
		Properties() As XdocProperty
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As String
	#tag EndProperty


	#tag ViewBehavior
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
	#tag EndViewBehavior
End Class
#tag EndClass
