#tag Class
Protected Class MarkdownWriter
Inherits BaseWriter
	#tag Method, Flags = &h0
		Sub EndCurrentFile()
		  Tos.Close
		End Sub
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
		    Dim fh As FolderItem = basePath.Child(baseName + ".md")
		    File = fh
		  Else
		    File = basePath
		  End If
		  
		  Tos = TextOutputStream.Create(File)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteConstants(f As XdocFile)
		  If f.Constants.Ubound = -1 Then
		    Return
		  End If
		  
		  Tos.WriteLine "## Constants {#" + IdString(f.FullName, "Constants") + "}"
		  
		  For i As Integer = 0 To f.Constants.Ubound
		    Dim c As XdocConstant = f.Constants(i)
		    
		    Tos.WriteLine "### " + c.Name + " As " + c.Type + " = " + c.Value + " {#" + IdString(f.FullName, c.Name) + "}"
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
		  Tos.WriteLine "# " + xFile.Type + " " +  xFile.FullName + " {#" + IdString(xFile.FullName) + "}"
		  Tos.WriteLine ""
		  
		  If Not (xFile.OverviewNote Is Nil) Then
		    Tos.WriteLine "## Overview {#" + IdString(xFile.FullName, "Overview") + "}"
		    Tos.WriteLine xFile.OverviewNote.Text
		    Tos.WriteLine ""
		  End If
		  
		  Dim notes() As XdocNote = xFile.Notes
		  
		  If notes.Ubound > -1 Then
		    For i As Integer = 0 To notes.Ubound
		      Tos.WriteLine "## " + notes(i).Name + " {#" + IdString(xFile.FullName, notes(i).Name) + "}"
		      Tos.WriteLine notes(i).Text
		      Tos.WriteLine ""
		    Next
		  End If
		  
		  WriteConstants(xFile)
		  
		  If xFile.Enums.Ubound > -1 Then
		    Tos.WriteLine "## Enums  {#" + xFile.FullName + ".Enums}"
		    Tos.WriteLine ""
		    
		    For i As Integer = 0 To xFile.Enums.Ubound
		      Dim e As XdocEnum = xFile.Enums(i)
		      
		      Tos.WriteLine "### " + e.Name + " {#" + IdString(xFile.FullName, e.Name) + "}"
		      If e.Tag.Description <> "" Then
		        Tos.WriteLine e.Tag.Description
		        Tos.WriteLine ""
		      End If
		      
		      Tos.WriteLine "#### Values"
		      For j As Integer = 0 To e.Values.Ubound
		        Tos.WriteLine "* `" + e.Values(j) + "`"
		      Next
		      
		      Tos.WriteLine ""
		    Next
		  End If
		  
		  If xFile.EventDefinitions.Ubound > -1 Then
		    Tos.WriteLine "## Event Definitions {#" + IdString(xFile.FullName, "EventDefinitions") + "}"
		    Tos.WriteLine ""
		    
		    For Each m As XdocMethod In xFile.EventDefinitions
		      Dim line As String = m.Name + "(" + Join(m.Parameters, ", ") + ")"
		      If m.ReturnType <> "" Then
		        line = line + " As " + m.ReturnType
		      End If
		      
		      Tos.WriteLine "### " + line + " {#" + IdString(xFile.FullName, m.Name) + "}"
		      If m.Tag.Description <> "" Then
		        Tos.WriteLine m.Tag.Description
		      End If
		      
		      Tos.WriteLine ""
		    Next
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
		  
		  Tos.WriteLine "## " + sectionTitle + " {#" + IdString(f.FullName, sectionTitle) + "}"
		  Tos.WriteLine ""
		  
		  If meths.Ubound > -1 Then
		    For i As Integer = 0 To meths.Ubound
		      Dim m As XdocMethod = meths(i)
		      
		      Dim methodLine As String = m.Name + "(" + Join(m.Parameters, ", ") + ")"
		      If m.ReturnType <> "" Then
		        methodLine = methodLine + " As " + m.ReturnType
		      End If
		      
		      Tos.WriteLine "### " + methodLine + " {#" + IdString(f.FullName, m.Name) + "}"
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
		  tos.WriteLine "# " + overview.Name
		  tos.WriteLine overview.Text
		  tos.WriteLine ""
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteProperties(sectionTitle As String, f As XdocFile, props() As XdocProperty)
		  If props.Ubound = -1 Then
		    Return
		  End If
		  
		  Tos.WriteLine "## " + sectionTitle + " {#" + IdString(f.FullName, sectionTitle) + "}"
		  Tos.WriteLine ""
		  
		  If props.Ubound > -1 Then
		    For i As Integer = 0 To props.Ubound
		      Dim p As XdocProperty = props(i)
		      
		      Tos.WriteLine "### " + p.Declaration + " {#" + IdString(f.FullName, p.Name) + "}"
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
