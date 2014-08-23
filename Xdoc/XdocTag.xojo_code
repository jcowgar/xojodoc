#tag Class
Protected Class XdocTag
	#tag Method, Flags = &h0
		Sub Constructor()
		  
		End Sub
	#tag EndMethod

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


	#tag ViewBehavior
		#tag ViewProperty
			Name="Default"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Description"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Flags"
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
			Name="IsDynamic"
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
			Name="TagType"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Type"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visibility"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
