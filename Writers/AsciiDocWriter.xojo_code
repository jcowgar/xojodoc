#tag Class
Protected Class AsciiDocWriter
Inherits BaseWriter
	#tag Method, Flags = &h0
		Sub EndCurrentFile()
		  Tos.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IdString(values() As String) As String
		  Dim v() As String
		  
		  For i As Integer = 0 To values.Ubound
		    Dim value As String = values(i)
		    
		    v.Append value.ReplaceAll(" ", "").ReplaceAll("(", "").ReplaceAll(")", "")
		  Next
		  
		  Return Join(v, ".")
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
		Sub StartNewFile(basePath As FolderItem, baseName As String = "")
		  If baseName <> "" Then
		    Dim fh As FolderItem = basePath.Child(baseName + ".adoc")
		    File = fh
		  Else
		    File = basePath
		  End If
		  
		  Tos = TextOutputStream.Create(File)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteAnchor(ParamArray names() As String)
		  If Not (CurrentFile Is Nil) Then
		    names.Insert 0, CurrentFile.FullName
		  End If
		  
		  Tos.WriteLine "[[" + IdString(names) + "]]"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteConstants(f As XdocFile)
		  If f.Constants.Ubound = -1 Then
		    Return
		  End If
		  
		  For Each n As XdocNote In CurrentFile.Notes
		    If n.Name = "Constants" Then
		      Return
		    End If
		  Next
		  
		  WriteAnchor "Constants"
		  Tos.WriteLine "=== Constants"
		  
		  For i As Integer = 0 To f.Constants.Ubound
		    Dim c As XdocConstant = f.Constants(i)
		    
		    WriteAnchor c.Name
		    Tos.WriteLine "==== +" + c.Name + " As " + c.Type + " = " + c.Value + "+"
		    If c.Tag.Description <> "" Then
		      Tos.WriteLine c.Tag.Description
		    End If
		    Tos.WriteLine ""
		  Next
		  
		  Tos.WriteLine ""
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteFile(xFile As XdocFile)
		  CurrentFile = xFile
		  
		  WriteAnchor
		  Tos.WriteLine "== " + xFile.Type + " " +  xFile.FullName
		  Tos.WriteLine ""
		  
		  If Not (xFile.OverviewNote Is Nil) Then
		    Tos.WriteLine xFile.OverviewNote.Text
		    Tos.WriteLine ""
		  End If
		  
		  WriteToc(xFile)
		  
		  Dim notes() As XdocNote = xFile.Notes
		  
		  If notes.Ubound > -1 Then
		    For i As Integer = 0 To notes.Ubound
		      WriteAnchor notes(i).Name
		      Tos.WriteLine "=== " + notes(i).Name
		      Tos.WriteLine notes(i).Text
		      Tos.WriteLine ""
		    Next
		  End If
		  
		  WriteConstants(xFile)
		  
		  If xFile.Enums.Ubound > -1 Then
		    Dim hasRelatedNote As Boolean
		    
		    For Each n As XdocNote In xFile.Notes
		      If n.Name = "Enums" Then
		        hasRelatedNote = True
		        Exit
		      End If
		    Next
		    
		    If Not hasRelatedNote Then
		      WriteAnchor "Enums"
		      Tos.WriteLine "=== Enums"
		      Tos.WriteLine ""
		      
		      For i As Integer = 0 To xFile.Enums.Ubound
		        Dim e As XdocEnum = xFile.Enums(i)
		        
		        WriteAnchor e.Name
		        Tos.WriteLine "==== +" + e.Name + "+"
		        If e.Tag.Description <> "" Then
		          Tos.WriteLine e.Tag.Description
		          Tos.WriteLine ""
		        End If
		        
		        Tos.WriteLine "===== Values"
		        For j As Integer = 0 To e.Values.Ubound
		          Tos.WriteLine "* +" + e.Values(j) + "+"
		        Next
		        
		        Tos.WriteLine ""
		      Next
		    End If
		  End If
		  
		  If xFile.EventDefinitions.Ubound > -1 Then
		    Dim hasRelatedNote As Boolean
		    
		    For Each n As XdocNote In xFile.Notes
		      If n.Name = "Event Definitions" Then
		        hasRelatedNote = True
		        Exit
		      End If
		    Next
		    
		    If Not hasRelatedNote Then
		      WriteAnchor "Event Definitions"
		      Tos.WriteLine "=== Event Definitions"
		      Tos.WriteLine ""
		      
		      For Each m As XdocMethod In xFile.EventDefinitions
		        Dim line As String = m.Name + "(" + Join(m.Parameters, ", ") + ")"
		        If m.ReturnType <> "" Then
		          line = line + " As " + m.ReturnType
		        End If
		        
		        WriteAnchor m.Name
		        Tos.WriteLine "==== +" + line + "+"
		        If m.Tag.Description <> "" Then
		          Tos.WriteLine m.Tag.Description
		        End If
		        
		        Tos.WriteLine ""
		      Next
		    End If
		  End If
		  
		  WriteMethods("Events", xFile, xFile.Events)
		  WriteProperties("Properties", xFile, xFile.Properties)
		  WriteMethods("Methods", xFile, xFile.Methods)
		  WriteProperties("Shared Properties", xFile, xFile.SharedProperties)
		  WriteMethods("Shared Methods", xFile, xFile.SharedMethods)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteMethods(sectionTitle As String, f As XdocFile, meths() As XdocMethod)
		  If meths.Ubound = -1 Then
		    Return
		  End If
		  
		  WriteAnchor sectionTitle
		  Tos.WriteLine "=== " + sectionTitle
		  Tos.WriteLine ""
		  
		  If meths.Ubound > -1 Then
		    For i As Integer = 0 To meths.Ubound
		      Dim m As XdocMethod = meths(i)
		      
		      Dim methodLine As String = m.Name + "(" + Join(m.Parameters, ", ") + ")"
		      If m.ReturnType <> "" Then
		        methodLine = methodLine + " As " + m.ReturnType
		      End If
		      
		      WriteAnchor m.Name
		      Tos.WriteLine "==== +" + methodLine + "+"
		      If m.Tag.Description <> "" Then
		        Tos.WriteLine m.Tag.Description
		        Tos.WriteLine ""
		      End If
		      
		      If m.Notes <> "" Then
		        Tos.WriteLine m.Notes
		        Tos.WriteLine ""
		      End If
		    Next
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteProjectOverview(overview As XdocNote)
		  tos.WriteLine "== " + overview.Name
		  tos.WriteLine overview.Text
		  tos.WriteLine ""
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteProperties(sectionTitle As String, f As XdocFile, props() As XdocProperty)
		  If props.Ubound = -1 Then
		    Return
		  End If
		  
		  WriteAnchor sectionTitle
		  Tos.WriteLine "=== " + sectionTitle
		  Tos.WriteLine ""
		  
		  If props.Ubound > -1 Then
		    For i As Integer = 0 To props.Ubound
		      Dim p As XdocProperty = props(i)
		      
		      WriteAnchor p.Name
		      Tos.WriteLine "==== +" + p.Declaration + "+"
		      Tos.WriteLine ""
		      
		      If p.Tag.Description <> "" Then
		        Tos.WriteLine p.Tag.Description
		        Tos.WriteLine ""
		      End If
		      
		      If p.Note <> "" Then
		        Tos.WriteLine p.Note
		        Tos.WriteLine ""
		      End If
		    Next
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteToc(xFile As XdocFile)
		  If xFile.EventDefinitions.Ubound + xFile.Properties.Ubound + xFile.Methods.Ubound = -3 Then
		    Return
		  End If
		  
		  Tos.WriteLine "=== Contents"
		  Tos.WriteLine ""
		  
		  Dim names() As String
		  
		  ReDim names(-1)
		  For i As Integer = 0 To xFile.EventDefinitions.Ubound
		    names.Append xFile.EventDefinitions(i).Name
		  Next
		  WriteToc(xFile, "Events", names)
		  
		  ReDim names(-1)
		  For i As Integer = 0 To xFile.Properties.Ubound
		    names.Append xFile.Properties(i).Name
		  Next
		  WriteToc(xFile, "Properties", names)
		  
		  ReDim names(-1)
		  For i As Integer = 0 To xFile.Methods.Ubound
		    names.Append xFile.Methods(i).Name
		  Next
		  WriteToc(xFile, "Methods", names)
		  
		  ReDim names(-1)
		  For i As Integer = 0 To xFile.SharedProperties.Ubound
		    names.Append xFile.SharedProperties(i).Name
		  Next
		  WriteToc(xFile, "Shared Properties", names)
		  
		  ReDim names(-1)
		  For i As Integer = 0 To xFile.SharedMethods.Ubound
		    names.Append xFile.SharedMethods(i).Name
		  Next
		  WriteToc(xFile, "Shared Methods", names)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteToc(xFile As XdocFile, title As String, names() As String)
		  Dim i As Integer = 1
		  
		  While i <= names.Ubound
		    If names(i - 1) = names(i) Then
		      names.Remove i
		    Else
		      i = i + 1
		    End If
		  Wend
		  
		  If names.Ubound > -1 Then
		    'Tos.WriteLine "==== " + title
		    Tos.WriteLine "." + title
		    Tos.WriteLine "****"
		    Tos.WriteLine "[grid=""none"",frame=""none""]"
		    Tos.WriteLine "|==================================="
		    
		    For i = 0 To names.Ubound
		      If i > 0 And i Mod 3 = 0 Then
		        Tos.WriteLine ""
		      End If
		      
		      Tos.Write "|+<<" + IdString(xFile.FullName, names(i)) + "," + names(i) + ">>+"
		    Next
		    For i = ((names.Ubound + 1) Mod 3) To 2
		      Tos.Write "|"
		    Next
		    Tos.WriteLine ""
		    Tos.WriteLine "|==================================="
		    Tos.WriteLine "****"
		    Tos.WriteLine ""
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private CurrentFile As XdocFile
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Tos As TextOutputStream
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
