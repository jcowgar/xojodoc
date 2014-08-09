#tag Class
Protected Class XdocProject
	#tag Method, Flags = &h0
		Sub Constructor(file As FolderItem)
		  Self.File = file
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReadManifest()
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
		      Dim fh As FolderItem = GetRelativeFolderItem(values(1), File.Parent)
		      Files.Append New XdocFile(values(0), fh)
		      
		    Case Else
		      // We are not interested in anything else
		      
		    End Select
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function VisibilityFor(text As String) As Integer
		  Static values() As String = Array("", "Private", "Protected", "Public", "Global")
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
