#tag Class
Protected Class MarkdownWriter
	#tag Method, Flags = &h0
		Sub Write(path As FolderItem, project As XdocProject)
		  For Each f As XdocFile In project.Files
		    Dim fh As FolderItem = path.Child(f.Name + ".md")
		    Dim tos As TextOutputStream = TextOutputStream.Create(fh)
		    
		    tos.WriteLine "# " + f.Type + " " +  f.Name
		    tos.WriteLine ""
		    
		    //
		    // We want to print the Overview note first, if available.
		    // Then all other notes in the order they appeared in the
		    // documentation
		    //
		    
		    Dim notes() As XdocNote = f.Notes
		    Dim overviewNote As XdocNote
		    For i As Integer = 0 To notes.Ubound
		      If notes(i).Name = "Overview" Then
		        overviewNote = notes(i)
		        notes.Remove i
		        Exit
		      End If
		    Next
		    
		    If Not (overviewNote Is Nil) Then
		      tos.WriteLine overviewNote.Text
		      tos.WriteLine ""
		    End If
		    
		    If notes.Ubound > -1 Then
		      tos.WriteLine "## Notes"
		      tos.WriteLine ""
		      
		      For i As Integer = 0 To notes.Ubound
		        tos.WriteLine "### " + notes(i).Name
		        tos.WriteLine notes(i).Text
		        tos.WriteLine ""
		      Next
		    End If
		    
		    If False Then
		      tos.WriteLine "## Event Definitions"
		      tos.WriteLine ""
		    End If
		    
		    If IncludeEvents And f.Events.Ubound > -1 Then
		      tos.WriteLine "## Events"
		      tos.WriteLine ""
		      
		      For Each m As XdocMethod In f.Events
		        If m.Visibility = XdocProject.kVisibilityPrivate And Not IncludePrivate Then
		          Continue
		        End If
		        
		        If m.Visibility = XdocProject.kVisibilityProtected And Not IncludeProtected Then
		          Continue
		        End If
		        
		        Dim methodLine As String = m.Name + "(" + Join(m.Parameters, ", ") + ")"
		        If m.ReturnType <> "" Then
		          methodLine = methodLine + " As " + m.ReturnType
		        End If
		        
		        tos.WriteLine "### `" + methodLine + "`"
		        tos.WriteLine m.Notes
		        tos.WriteLine ""
		      Next
		    End If
		    
		    If f.Properties.Ubound > -1 Then
		      Dim lines() As String
		      
		      For i As Integer = 0 To f.Properties.Ubound
		        Dim p As XdocProperty = f.Properties(i)
		        
		        If p.Visibility = XdocProject.kVisibilityPrivate And Not IncludePrivate Then
		          Continue
		        End If
		        
		        If p.Visibility = XdocProject.kVisibilityProtected And Not IncludeProtected Then
		          Continue
		        End If
		        
		        lines.Append "### `" + p.Declaration + "`"
		        lines.Append ""
		        
		        If p.Note <> "" Then
		          lines.Append p.Note
		        End If
		        
		        tos.WriteLine ""
		      Next
		      
		      If lines.Ubound > -1 Then
		        tos.WriteLine "## Properties"
		        tos.WriteLine ""
		        tos.WriteLine Join(lines, EndOfLine)
		      End If
		    End If
		    
		    If f.Methods.Ubound > -1 Then
		      Dim methodLines() As String
		      
		      For Each m As XdocMethod In f.Methods
		        If m.Visibility = XdocProject.kVisibilityPrivate And Not IncludePrivate Then
		          Continue
		        End If
		        
		        If m.Visibility = XdocProject.kVisibilityProtected And Not IncludeProtected Then
		          Continue
		        End If
		        
		        Dim methodLine As String = m.Name + "(" + Join(m.Parameters, ", ") + ")"
		        If m.ReturnType <> "" Then
		          methodLine = methodLine + " As " + m.ReturnType
		        End If
		        
		        methodLines.Append "### `" + methodLine + "`"
		        methodLines.Append m.Notes
		        methodLines.Append ""
		      Next
		      
		      If methodLines.Ubound > -1 Then
		        tos.WriteLine "## Methods"
		        tos.WriteLine ""
		        tos.WriteLine Join(methodLines, EndOfLine)
		      End If
		    End If
		  Next
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		IncludeEvents As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		IncludePrivate As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		IncludeProtected As Boolean
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
