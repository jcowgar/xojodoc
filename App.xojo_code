#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  ParseOptions(args)
		  
		  Project = New XdocProject(ProjectFile)
		  Project.ReadManifest
		  
		  For Each file As XdocFile In Project.Files
		    Print "Processing: " + file.File.Name
		    file.Parse
		  Next
		  
		  Dim mdw As New MarkdownWriter
		  mdw.IncludePrivate = options.BooleanValue("include-private")
		  mdw.IncludeProtected = options.BooleanValue("include-protected")
		  mdw.IncludeEvents = options.BooleanValue("include-events")
		  
		  mdw.Write(OutputFolder, Project)
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub ParseOptions(args() As String)
		  Options = New OptionParser
		  Options.ExtrasRequired = 1
		  
		  Dim o As Option
		  o = New Option("o", "output-directory", "Directory to write files to", Option.OptionType.Directory)
		  o.IsRequired = True
		  Options.AddOption o
		  
		  o = New Option("", "include-private", "Include items marked private", Option.OptionType.Boolean)
		  Options.AddOption o
		  
		  o = New Option("", "include-protected", "Include items marked protected", Option.OptionType.Boolean)
		  Options.AddOption o
		  
		  o = New Option("", "include-events", "Include implemented events", Option.OptionType.Boolean)
		  Options.AddOption o
		  
		  Options.Parse(args)
		  OutputFolder = Options.FileValue("output-directory")
		  
		  If Not OutputFolder.Exists Then
		    OutputFolder.CreateAsFolder
		  End If
		  
		  Dim projectFileName As String = Options.Extra(0)
		  ProjectFile = GetRelativeFolderItem(projectFileName)
		  If ProjectFile Is Nil Or Not ProjectFile.IsReadable Then
		    stderr.WriteLine "error: '" + projectFileName + "' does not exist or is not readable"
		    Quit 1
		  End If
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Abc()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event AbcXyz(name As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Xyz123() As String
	#tag EndHook


	#tag Note, Name = TODO
		* Parse and Write Enums
		* Parse and Write Constants
	#tag EndNote


	#tag Property, Flags = &h21
		Private Options As OptionParser
	#tag EndProperty

	#tag Property, Flags = &h21
		Private OutputFolder As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		Project As XdocProject
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ProjectFile As FolderItem
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
