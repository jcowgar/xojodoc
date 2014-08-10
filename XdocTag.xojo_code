#tag Class
Protected Class XdocTag
	#tag Method, Flags = &h0
		Sub Constructor(raw As String)
		  Dim parts() As String = raw.Split(", ")
		  
		  TagType = parts(0).Mid(6)
		  
		  '#tag Constant, Name = kFunction, Type = Double, Dynamic = False, Default = \"1", Scope = Public
		  
		  For Each part As String In parts
		    Dim kv() As String = part.Split(" = ")
		    If kv.Ubound = 0 Then
		      Continue
		    End If
		    
		    Select Case kv(0)
		    Case "Name"
		      Name = kv(1)
		      
		    Case "Type"
		      Type = kv(1)
		      
		    Case "Flags"
		      Flags = kv(1)
		      
		    Case "Default"
		      Default = kv(1)
		      
		      If Default.Left(2) = "\""" Then
		        Default = Default.Mid(3, Default.Len - 3)
		      End If
		      
		    Case "Scope"
		      Visibility = XdocProject.VisibilityFor(kv(1))
		      
		    Case "Description"
		      Description = kv(1)
		      Description = DecodeHex(Description)
		      
		      'Dim dLen As Integer = Description.Len
		      'Dim chrs() As String
		      '
		      'For chrIdx As Integer = 1 To dLen Step 2
		      'Dim chCode As Integer = Val(Description.Mid(chrIdx, 2))
		      'chrs.Append Chr(chCode)
		      'Next
		      '
		      'Description = Join(chrs, "")
		    End Select
		  Next
		  
		  If Type = "String" Then
		    Default = """" + Default + """"
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Default As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Description As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Flags As String
	#tag EndProperty

	#tag Property, Flags = &h0
		IsDynamic As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TagType As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Visibility As Integer
	#tag EndProperty


End Class
#tag EndClass
