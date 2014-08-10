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
		  
		  Dim fh As FolderItem
		  Dim asSingle As Boolean
		  
		  If Not (OutputFile Is Nil) Then
		    fh = OutputFile
		    asSingle = True
		  Else
		    fh = OutputFolder
		    asSingle = False
		  End If
		  
		  mdw.Write(fh, Project, asSingle)
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub ParseOptions(args() As String)
		  Options = New OptionParser
		  Options.ExtrasRequired = 1
		  
		  Dim o As Option
		  o = New Option("f", "output-file", "Write to a single file", Option.OptionType.File)
		  Options.AddOption o
		  
		  o = New Option("o", "output-directory", "Directory to write files to", Option.OptionType.Directory)
		  Options.AddOption o
		  
		  o = New Option("", "include-private", "Include items marked private", Option.OptionType.Boolean)
		  Options.AddOption o
		  
		  o = New Option("", "include-protected", "Include items marked protected", Option.OptionType.Boolean)
		  Options.AddOption o
		  
		  o = New Option("", "include-events", "Include implemented events", Option.OptionType.Boolean)
		  Options.AddOption o
		  
		  Options.Parse(args)
		  OutputFolder = Options.FileValue("output-directory")
		  OutputFile = Options.FileValue("output-file")
		  
		  If OutputFile Is Nil And OutputFolder Is Nil Then
		    stderr.WriteLine "When writing multiple files (no -s/--single), you must specify -o/--output-directory"
		    Options.ShowHelp
		    
		    Quit 1
		    
		  ElseIf Not (OutputFolder Is Nil) Then
		    OutputFolder.CreateAsFolder
		    
		  ElseIf Not (OutputFile Is Nil) Then
		    If Not OutputFile.IsWriteable Then
		      stderr.WriteLine "Output file: " + OutputFile.Name + " is not writable"
		      
		      Quit 1
		    End If
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
		* Hyperlink to referenced classes
		* Have a specific note in the App class named Project, it should be the very first thing written, not part of App class, but as a full project overview
		* Have a specific note to document Enums and Event Definitions since they can not be documented directly.
		  When an item appears in this note, it should not be output as a generic, non-documented item. All items not
		  in the note should be output as they are now, in a non-documented fashion
		
		
	#tag EndNote


	#tag Property, Flags = &h21
		Private Options As OptionParser
	#tag EndProperty

	#tag Property, Flags = &h21
		Private OutputFile As FolderItem
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
