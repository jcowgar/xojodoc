#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  ParseOptions(args)
		  
		  Project = New XdocProject(ProjectFile)
		  Project.ReadManifest
		  
		  For fIdx As Integer = 0 To Project.Files.Ubound
		    Dim file As XdocFile = Project.Files(fIdx)
		    Print "Processing: " + file.File.Name
		    file.Parse
		    
		    If Not (OutputFile Is Nil) And file.Name = "App" Then
		      // Look for a "Project Overview" Note
		      For nIdx As Integer = 0 To file.Notes.Ubound
		        Dim n As XdocNote = file.Notes(nIdx)
		        
		        If n.Name = "Project Overview" Then
		          Project.ProjectNote = n
		          file.Notes.Remove nIdx
		          Exit For nIdx
		        End If
		      Next
		    End If
		  Next
		  
		  Dim mdw As New MarkdownWriter
		  mdw.IncludePrivate = options.BooleanValue("include-private")
		  mdw.IncludeProtected = options.BooleanValue("include-protected")
		  mdw.IncludeEvents = options.BooleanValue("include-events")
		  mdw.ExcludePackages = ExcludePackages
		  
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
		  
		  o = New Option("e", "exclude-items", "Exclude items beginning with Full Name of")
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
		  
		  ExcludePackages = Options.StringValue("exclude-items").Split(",")
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0, Description = 48656C6C6F20576F726C64
		Event Abc()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event AbcXyz(name As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Xyz123() As String
	#tag EndHook

	#tag Note, Name = Project Overview
		xojodoc is an application that will process a Xojo manifest file and create
		source level documentation for the project and all included items.
		
	#tag EndNote

	#tag Note, Name = TODO
		* Hyperlink to referenced classes
		* Unescape constants, for example "first\x2Clast\X2Cage"
	#tag EndNote


	#tag Property, Flags = &h21
		Private ExcludePackages() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Options As OptionParser
	#tag EndProperty

	#tag Property, Flags = &h21
		Private OutputFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private OutputFolder As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 4D61696E2070726F6A656374207265666572656E6365
		Project As XdocProject
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ProjectFile As FolderItem
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
