#tag Class
Protected Class XdocProject
	#tag Method, Flags = &h0
		Sub Constructor(file As FolderItem)
		  Self.File = file
		  Self.Folders = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReadManifest()
		  Const kName = 0
		  Const kPath = 1
		  Const kId = 2
		  Const kParentId = 3
		  Const kUnknown = 4
		  
		  Dim tis As TextInputStream = TextInputStream.Open(File)
		  
		  While Not tis.EOF
		    Dim line As String = tis.ReadLine.Trim
		    
		    If line = "" Then
		      Continue
		    End If
		    
		    Dim parts() As String = line.Split("=")
		    If parts.Ubound = 0 Then
		      // We are not interested in it
		      Continue
		    End If
		    
		    parts(1) = parts(1).Trim
		    If parts(1) = "" Then
		      // We are not interested in it
		      Continue
		    End If
		    
		    Dim partType As String = parts(0)
		    Dim values() As String = parts(1).Split(";")
		    
		    Select Case partType
		    Case "Class", "Interface", "Module"
		      If values(1).Right(10) = ".xojo_code" Or values(1).Right(14) = ".xojo_xml_code" Then
		        Dim fh As FolderItem = GetRelativeFolderItem(values(1), File.Parent)
		        
		        Dim f As New XdocFile(values(0), fh)
		        f.Id = values(2)
		        f.ParentId = values(3)
		        
		        Files.Append f
		      End If
		      
		      If partType = "Module" Then
		        Dim f As New XdocFolder
		        f.Name = values(kName)
		        f.Id = values(kId)
		        f.ParentId = values(kParentId)
		        
		        Folders.Value(f.Id) = f
		      End If
		      
		    Case "Folder"
		      Dim f As New XdocFolder
		      f.Name = values(0)
		      f.Id = values(2)
		      f.ParentId = values(3)
		      
		      Folders.Value(f.Id) = f
		      
		    Case Else
		      // We are not interested in anything else
		      
		    End Select
		  Wend
		  
		  For Each f As XdocFile In Files
		    If f.ParentId = "" Or f.ParentId = "&h0" Then
		      f.FullName = f.Name
		      Continue
		    End If
		    
		    Dim current As XdocFolder = Folders.Value(f.ParentId)
		    Dim parents() As XdocFolder
		    
		    Do
		      parents.Append current
		      current = Folders.Lookup(current.ParentId, Nil)
		    Loop Until current Is Nil
		    
		    Dim parentNames() As String
		    
		    For i As Integer = parents.Ubound DownTo 0
		      parentNames.Append parents(i).Name
		    Next
		    
		    parentNames.Append f.Name
		    
		    f.FullName = Join(parentNames, ".")
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 44657465726D696E65207669736962696C6974792069642066726F6D2061207669736962696C69747920737472696E67
		 Shared Function VisibilityFor(text As String) As Integer
		  //
		  // Takes `""`, `"Private"`, `"Protected"`, `"Public"`, `"Global"` and will return one of:
		  //
		  // * +<<Xdoc.XdocProject.kVisibilityNone,kVisibilityNone>>+
		  // * +<<Xdoc.XdocProject.kVisibilityPrivate,kVisibilityPrivate>>+
		  // * +<<Xdoc.XdocProject.kVisibilityProtected,kVisibilityProtected>>+
		  // * +<<Xdoc.XdocProject.kVisibilityPublic,kVisibilityPublic>>+
		  // * +<<Xdoc.XdocProject.kVisibilityGlobal,kVisibilityGlobal>>+
		  //
		  // .Example
		  // [source,vbnet]
		  // ----
		  // Dim visibility As Integer = XdocProject.VisibilityFor("Public")
		  // ' Visibility = kVisibilityPublic
		  // ----
		  
		  Static values() As String = Array("", "Private", "Protected", "Public", "Global")
		  
		  If text = "" Then
		    Return kVisibilityPublic
		  End If
		  
		  Return values.IndexOf(text)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		#tag Note
			Project manifest `FolderItem`
		#tag EndNote
		File As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		Files() As XdocFile
	#tag EndProperty

	#tag Property, Flags = &h0
		Folders As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		ProjectNote As XdocNote
	#tag EndProperty


	#tag Constant, Name = kVisibilityGlobal, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kVisibilityNone, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kVisibilityPrivate, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kVisibilityProtected, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kVisibilityPublic, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant


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
