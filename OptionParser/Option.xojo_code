#tag Class
Protected Class Option
	#tag Method, Flags = &h0
		Sub Constructor(shortKey As String, longKey As String, description As String, type As OptionType = OptionType.String)
		  // Validate and cleanup
		  shortKey = shortKey.Trim
		  longKey = longKey.Trim
		  description = ReplaceLineEndings(description.Trim, EndOfLine)
		  
		  While shortKey.Left(1) = "-"
		    shortKey = shortKey.Mid(2).Trim
		  Wend
		  While longKey.Left(1) = "-"
		    longKey = longKey.Mid(2).Trim
		  Wend
		  
		  If shortKey = "" and longKey = "" Then
		    Raise New OptionParserException("Option must specify at least one key.")
		  End If
		  If shortKey.Len > 1 Then
		    Raise New OptionParserException("Short Key is optional but may only be one character: " + shortKey)
		  End If
		  If longKey.Len = 1 Then
		    Raise New OptionParserException("Long Key is optional but must be more than one character: " + longKey)
		  End If
		  
		  Self.ShortKey = shortKey
		  Self.LongKey = longKey
		  Self.Description = description
		  Self.Type = type
		End Sub
	#tag EndMethod

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

	#tag Method, Flags = &h0
		Sub HandleValue(value As String)
		  WasSet = True
		  
		  Select Case Type
		  Case OptionType.Boolean
		    Select Case value
		    Case "", "y", "yes", "t", "true", "on", "1"
		      Self.Value = True
		      
		    Else
		      Self.Value = False
		    End Select
		    
		  Case OptionType.Date
		    Dim dValue As Date
		    
		    If ParseDate(value, dValue) Then
		      Self.Value = dValue
		    Else
		      Self.Value = value
		    End If
		    
		  Case OptionType.Directory
		    Self.Value = GetRelativeFolderItem(value)
		    
		  Case OptionType.Double
		    Self.Value = Val(value)
		    
		  Case OptionType.File
		    Self.Value = GetRelativeFolderItem(value)
		    
		  Case OptionType.Integer
		    Self.Value = Val(value)
		    
		  Case OptionType.String
		    Self.Value = value
		  End Select
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Description As String
	#tag EndProperty

	#tag Property, Flags = &h0
		IsReadableRequired As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		IsRequired As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If IsRequired And Not WasSet Then
			    Return False
			  End If
			  
			  If IsRequired Or WasSet Then
			    Select Case Type
			    Case OptionType.Date
			      If IsValidDateRequired Then
			        Dim d As Date = Value
			        
			        If d Is Nil Then
			          Return False
			        End If
			      End If
			      
			    Case OptionType.Directory, OptionType.File
			      Dim fi As FolderItem = Value
			      
			      If IsRequired Or WasSet Then
			        If IsReadableRequired And (fi Is Nil Or fi.IsReadable = False) Then
			          Return False
			        End If
			        
			        If IsWriteableRequired And (fi Is Nil Or fi.IsWriteable = False) Then
			          Return False
			        End If
			      End If
			      
			    Case OptionType.Double, OptionType.Integer
			      Dim d As Double = Value
			      
			      If MinimumNumber <> kNumberNotSet And d < MinimumNumber Then
			        Return False
			      End If
			      
			      If MaximumNumber <> kNumberNotSet And d > MaximumNumber Then
			        Return False
			      End If
			    End Select
			  End If
			  
			  Return True
			End Get
		#tag EndGetter
		IsValid As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		IsValidDateRequired As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		IsWriteableRequired As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		LongKey As String
	#tag EndProperty

	#tag Property, Flags = &h0
		MaximumNumber As Double = kNumberNotSet
	#tag EndProperty

	#tag Property, Flags = &h0
		MinimumNumber As Double = kNumberNotSet
	#tag EndProperty

	#tag Property, Flags = &h0
		ShortKey As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As OptionType
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Select Case Type
			  Case OptionType.Boolean
			    Return "BOOL"
			    
			  Case OptionType.Date
			    Return "DATE"
			    
			  Case OptionType.Directory
			    Return "DIR"
			    
			  Case OptionType.Double
			    Return "DOUBLE"
			    
			  Case OptionType.File
			    Return "FILE"
			    
			  Case OptionType.Integer
			    Return "INTEGER"
			    
			  Case OptionType.String
			    Return "STR"
			  End Select
			End Get
		#tag EndGetter
		TypeString As String
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		Value As Variant
	#tag EndProperty

	#tag Property, Flags = &h0
		WasSet As Boolean
	#tag EndProperty


	#tag Constant, Name = kNone, Type = String, Dynamic = False, Default = \"", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kNumberNotSet, Type = Double, Dynamic = False, Default = \"-32768", Scope = Private
	#tag EndConstant


	#tag Enum, Name = OptionType, Type = Integer, Flags = &h0
		String
		  Integer
		  Double
		  Date
		  Boolean
		  File
		Directory
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Description"
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
			Name="IsReadableRequired"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsRequired"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsValid"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsValidDateRequired"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsWriteableRequired"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LongKey"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MaximumNumber"
			Group="Behavior"
			InitialValue="kNumberNotSet"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinimumNumber"
			Group="Behavior"
			InitialValue="kNumberNotSet"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShortKey"
			Group="Behavior"
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
			Name="TypeString"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="WasSet"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
