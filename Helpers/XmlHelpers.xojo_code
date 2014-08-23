#tag Module
Protected Module XmlHelpers
	#tag Method, Flags = &h0
		Function TextNodeValue(Extends n As XmlNode) As String
		  Dim result As String
		  
		  If Not (n.FirstChild Is Nil) And n.FirstChild.Type = XmlNodeType.TEXT_NODE Then
		    result = n.FirstChild.Value
		  End If
		  
		  Return result
		End Function
	#tag EndMethod


End Module
#tag EndModule
