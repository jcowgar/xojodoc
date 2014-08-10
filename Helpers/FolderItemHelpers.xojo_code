#tag Module
Protected Module FolderItemHelpers
	#tag Method, Flags = &h0
		Function GetRelativeFolderItem(path As String, relativeTo As FolderItem = Nil) As FolderItem
		  Dim prefix As String = ""
		  
		  #If TargetWin32 Then
		    Const pathSep = "\"
		    
		    //
		    // Maybe what is passed isn't actually a relative path
		    //
		    
		    If path.Mid(2, 1) = ":" Then
		      Return GetFolderItem(path, FolderItem.PathTypeShell)
		    End If
		    
		    If path.Left(1) = pathSep Then
		      relativeTo = GetFolderItem(SpecialFolder.CurrentWorkingDirectory.NativePath.Left(3))
		    End If
		    
		  #Else
		    Const pathSep = "/"
		    
		    //
		    // Maybe what is passed isn't actually a relative path
		    //
		    
		    If path.Left(1) = pathSep Then
		      Return GetFolderItem(path, FolderItem.PathTypeShell)
		    End If
		    
		    prefix = pathSep
		  #EndIf
		  
		  //
		  // OK, seems to be a relative path
		  //
		  
		  If relativeTo = Nil Then
		    relativeTo = SpecialFolder.CurrentWorkingDirectory
		  End If
		  
		  path = relativeTo.NativePath + pathSep + path
		  Dim newParts() As String
		  
		  Dim pathParts() As String = path.Split(pathSep)
		  For i As Integer = 0 to pathParts.Ubound
		    Dim p As String = pathParts(i)
		    If p = "" Then
		      // Can happen on Windows since it appends a pathSep onto the end of NativePath
		      // if relativeTo is a folder.
		      
		    ElseIf p = "." Then
		      // Skip this path component
		      
		    ElseIf p = ".." Then
		      // Remove the last path component from newParts
		      If newParts.Ubound > -1 Then
		        newParts.Remove newParts.Ubound
		      End If
		      
		    Else
		      // Nothing special about this path component
		      newParts.Append p
		    End If
		  Next
		  
		  path = prefix + Join(newParts, pathSep)
		  
		  Return GetFolderItem(path, FolderItem.PathTypeShell)
		End Function
	#tag EndMethod


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
End Module
#tag EndModule
