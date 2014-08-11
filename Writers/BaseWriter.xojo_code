#tag Class
Protected Class BaseWriter
	#tag Method, Flags = &h0
		Sub EndCurrentFile()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StartNewFile(basePath As FolderItem, baseName As String = "")
		  Self.File = file
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteFile(xFile As XdocFile)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteProjectOverview(overview As XdocNote)
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		File As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		Project As XdocProject
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
