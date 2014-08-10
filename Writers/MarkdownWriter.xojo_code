#tag Class
Protected Class MarkdownWriter
	#tag Method, Flags = &h21
		Private Function GetParent(root As FolderItem, f As XdocFile) As FolderItem
		  Dim filename As String = f.Name + ".md"
		  
		  If f.ParentId = "" Or f.ParentId = "&h0" Then
		    If root Is Nil Then
		      Return Nil
		    End If
		    
		    Return root.Child(filename)
		  End If
		  
		  Dim current As XdocFolder = Project.Folders.Value(f.ParentId)
		  Dim parents() As XdocFolder
		  
		  Do
		    parents.Append current
		    current = Project.Folders.Lookup(current.ParentId, Nil)
		  Loop Until current Is Nil
		  
		  Dim fh As FolderItem = root
		  
		  For i As Integer = parents.Ubound DownTo 0
		    If Not (root Is Nil) Then
		      fh = fh.Child(parents(i).Name)
		      
		      If Not fh.Exists Then
		        fh.CreateAsFolder
		      End If
		    End If
		  Next
		  
		  If root Is Nil Then
		    Return Nil
		  End If
		  
		  Return fh.Child(filename)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IdString(ParamArray values() As String) As String
		  Dim v() As String
		  
		  For i As Integer = 0 To values.Ubound
		    Dim value As String = values(i)
		    
		    v.Append value.ReplaceAll(" ", "").ReplaceAll("(", "").ReplaceAll(")", "")
		  Next
		  
		  Return Join(v, ".")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Write(path As FolderItem, project As XdocProject, asSingleFile As Boolean = False)
		  Self.Project = project
		  
		  Dim tos As TextOutputStream
		  
		  If asSingleFile Then
		    tos = TextOutputStream.Create(path)
		    
		    If Not (project.ProjectNote Is Nil) Then
		      Dim name As String = project.File.Name
		      name = name.Left(name.Len - 13)
		      
		      tos.WriteLine "# " + name + " Overview"
		      tos.WriteLine project.ProjectNote.Text
		      tos.WriteLine ""
		    End If
		  End If
		  
		  Dim files() As XdocFile = project.Files
		  Dim fileNames() As String
		  ReDim fileNames(files.Ubound)
		  
		  For fileIdx As Integer = 0 To files.Ubound
		    fileNames(fileIdx) = files(fileIdx).FullName
		  Next
		  
		  fileNames.SortWith(files)
		  
		  For fileIdx As Integer = 0 To files.Ubound
		    Dim f As XdocFile = files(fileIdx)
		    Dim fh As FolderItem = GetParent(If(asSingleFile, Nil, path), f)
		    
		    If Not asSingleFile Then
		      tos = TextOutputStream.Create(fh)
		    End If
		    
		    tos.WriteLine "# " + f.Type + " " +  f.FullName
		    tos.WriteLine ""
		    
		    If Not (f.OverviewNote Is Nil) Then
		      tos.WriteLine f.OverviewNote.Text
		      tos.WriteLine ""
		    End If
		    
		    Dim notes() As XdocNote = f.Notes
		    
		    If notes.Ubound > -1 Then
		      For i As Integer = 0 To notes.Ubound
		        tos.WriteLine "## " + notes(i).Name + " {#" + IdString(f.FullName, notes(i).Name) + "}"
		        tos.WriteLine notes(i).Text
		        tos.WriteLine ""
		      Next
		    End If
		    
		    WriteConstants(f, tos)
		    
		    If f.Enums.Ubound > -1 Then
		      tos.WriteLine "## Enums  {#" + f.FullName + ".Enums}"
		      tos.WriteLine ""
		      
		      For i As Integer = 0 To f.Enums.Ubound
		        Dim e As XdocEnum = f.Enums(i)
		        
		        tos.WriteLine "### " + e.Name + " {#" + IdString(f.FullName, e.Name) + "}"
		        If e.Tag.Description <> "" Then
		          tos.WriteLine e.Tag.Description
		          tos.WriteLine ""
		        End If
		        
		        tos.WriteLine "#### Values"
		        For j As Integer = 0 To e.Values.Ubound
		          tos.WriteLine "* `" + e.Values(j) + "`"
		        Next
		        
		        tos.WriteLine ""
		      Next
		    End If
		    
		    If f.EventDefinitions.Ubound > -1 Then
		      tos.WriteLine "## Event Definitions {#" + IdString(f.FullName, "EventDefinitions") + "}"
		      tos.WriteLine ""
		      
		      For Each m As XdocMethod In f.EventDefinitions
		        Dim line As String = m.Name + "(" + Join(m.Parameters, ", ") + ")"
		        If m.ReturnType <> "" Then
		          line = line + " As " + m.ReturnType
		        End If
		        
		        tos.WriteLine "### " + line + " {#" + IdString(f.FullName, m.Name) + "}"
		        If m.Tag.Description <> "" Then
		          tos.WriteLine m.Tag.Description
		        End If
		        
		        tos.WriteLine ""
		      Next
		    End If
		    
		    WriteMethods("Events", f, f.Events, tos)
		    
		    WriteProperties("Properties", f, f.Properties, tos)
		    WriteMethods("Methods", f, f.Methods, tos)
		    
		    WriteProperties("Shared Properties", f, f.SharedProperties, tos)
		    WriteMethods("Shared Methods", f, f.SharedMethods, tos)
		    
		    If Not asSingleFile Then
		      tos.Close
		    End If
		  Next
		  
		  tos.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteConstants(f As XdocFile, tos As TextOutputStream)
		  If f.Constants.Ubound = -1 Then
		    Return
		  End If
		  
		  tos.WriteLine "## Constants {#" + IdString(f.FullName, "Constants") + "}"
		  
		  For i As Integer = 0 To f.Constants.Ubound
		    Dim c As XdocConstant = f.Constants(i)
		    
		    tos.WriteLine "### " + c.Name + " As " + c.Type + " = " + c.Value + " {#" + IdString(f.FullName, c.Name) + "}"
		    If c.Tag.Description <> "" Then
		      tos.WriteLine c.Tag.Description
		    End If
		    tos.WriteLine ""
		  Next
		  
		  tos.WriteLine ""
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteMethods(sectionTitle As String, f As XdocFile, meths() As XdocMethod, tos As TextOutputStream)
		  If meths.Ubound = -1 Then
		    Return
		  End If
		  
		  tos.WriteLine "## " + sectionTitle + " {#" + IdString(f.FullName, sectionTitle) + "}"
		  tos.WriteLine ""
		  
		  If meths.Ubound > -1 Then
		    For i As Integer = 0 To meths.Ubound
		      Dim m As XdocMethod = meths(i)
		      
		      Dim methodLine As String = m.Name + "(" + Join(m.Parameters, ", ") + ")"
		      If m.ReturnType <> "" Then
		        methodLine = methodLine + " As " + m.ReturnType
		      End If
		      
		      tos.WriteLine "### " + methodLine + " {#" + IdString(f.FullName, m.Name) + "}"
		      If m.Tag.Description <> "" Then
		        tos.WriteLine m.Tag.Description
		        tos.WriteLine ""
		      End If
		      
		      If m.Notes <> "" Then
		        tos.WriteLine m.Notes
		        tos.WriteLine ""
		      End If
		    Next
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteProperties(sectionTitle As String, f As XdocFile, props() As XdocProperty, tos As TextOutputStream)
		  If props.Ubound = -1 Then
		    Return
		  End If
		  
		  tos.WriteLine "## " + sectionTitle + " {#" + IdString(f.FullName, sectionTitle) + "}"
		  tos.WriteLine ""
		  
		  If props.Ubound > -1 Then
		    For i As Integer = 0 To props.Ubound
		      Dim p As XdocProperty = props(i)
		      
		      tos.WriteLine "### " + p.Declaration + " {#" + IdString(f.FullName, p.Name) + "}"
		      tos.WriteLine ""
		      
		      If p.Tag.Description <> "" Then
		        tos.WriteLine p.Tag.Description
		        tos.WriteLine ""
		      End If
		      
		      If p.Note <> "" Then
		        tos.WriteLine p.Note
		        tos.WriteLine ""
		      End If
		    Next
		  End If
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Project As XdocProject
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="IncludeEvents"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludePrivate"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeProtected"
			Group="Behavior"
			Type="Boolean"
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
