#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  ParseOptions(args)
		  
		  Project = New XdocProject(ProjectFile)
		  Project.ReadManifest
		  
		  For fIdx As Integer = Project.Files.Ubound DownTo 0
		    Dim file As XdocFile = Project.Files(fIdx)
		    
		    For Each exclude As String In ExcludePackages
		      If file.FullName.InStr(exclude) = 1 Then
		        Print "  Skipping: " + file.FullName
		        Project.Files.Remove fIdx
		      End If
		    Next
		  Next
		  
		  For fIdx As Integer = 0 To Project.Files.Ubound
		    Dim file As XdocFile = Project.Files(fIdx)
		    Print "Processing: " + file.File.Name
		    file.Parse(Flags)
		    
		    If Not (OutputFile Is Nil) And file.Name = "App" Then
		      // Look for a "Project Overview" Note
		      For nIdx As Integer = 0 To file.Notes.Ubound
		        Dim n As XdocNote = file.Notes(nIdx)
		        
		        If n.Name = "Project Overview" Then
		          n.Name = ProjectFile.Name.Left(ProjectFile.Name.Len - 13)
		          Project.ProjectNote = n
		          
		          file.Notes.Remove nIdx
		          Exit For nIdx
		        End If
		      Next
		    End If
		  Next
		  
		  Dim fh As FolderItem
		  Dim asSingle As Boolean
		  
		  If Not (OutputFile Is Nil) Then
		    fh = OutputFile
		    asSingle = True
		  Else
		    fh = OutputFolder
		    asSingle = False
		  End If
		  
		  Dim writer As BaseWriter
		  
		  Select Case OutputFormat
		  Case "markdown"
		    writer = New MarkdownWriter
		    
		  Case "asciidoc"
		    writer = New AsciiDocWriter
		    
		  Case Else
		    Print "Unknown format: " + OutputFormat
		    Print "known formats: markdown, asciidoc"
		    Quit 1
		  End Select
		  
		  writer.Project = project
		  
		  If asSingle Then
		    writer.StartNewFile(OutputFile)
		    
		    If Not (Project.ProjectNote Is Nil) Then
		      writer.WriteProjectOverview(Project.ProjectNote)
		    End If
		  End If
		  
		  Dim files() As XdocFile = Project.Files
		  Dim fileNames() As String
		  ReDim fileNames(files.Ubound)
		  
		  For fileIdx As Integer = 0 To files.Ubound
		    fileNames(fileIdx) = files(fileIdx).FullName
		  Next
		  
		  fileNames.SortWith(files)
		  
		  For fileIdx As Integer = 0 To files.Ubound
		    Dim f As XdocFile = files(fileIdx)
		    
		    If Not asSingle Then
		      If FlatOutput Then
		        writer.StartNewFile(OutputFolder, f.FullName)
		      Else
		        Dim rootFh As FolderItem = GetRoot(OutputFolder, f)
		        writer.StartNewFile(rootFh, f.Name)
		      End If
		    End If
		    
		    writer.WriteFile(f)
		    
		    If Not asSingle Then
		      writer.EndCurrentFile
		    End If
		  Next
		  
		  If asSingle Then
		    writer.EndCurrentFile
		  End If
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function GetRoot(root As FolderItem, f As XdocFile) As FolderItem
		  If f.ParentId = "" Or f.ParentId = "&h0" Then
		    Return root
		  End If
		  
		  Dim current As XdocFolder = Project.Folders.Value(f.ParentId)
		  Dim parents() As XdocFolder
		  
		  Do
		    parents.Append current
		    current = Project.Folders.Lookup(current.ParentId, Nil)
		  Loop Until current Is Nil
		  
		  Dim fh As FolderItem = root
		  
		  For i As Integer = parents.Ubound DownTo 0
		    fh = fh.Child(parents(i).Name)
		    
		    If Not fh.Exists Then
		      fh.CreateAsFolder
		    End If
		  Next
		  
		  Return fh
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseOptions(args() As String)
		  Options = New OptionParser
		  Options.ExtrasRequired = 1
		  
		  Dim o As Option
		  
		  o = New Option("", "output-format", "Format of the output, default: markdown, others: asciidoc")
		  Options.AddOption o
		  
		  o = New Option("", "flat", "Flatten output directory structure", Option.OptionType.Boolean)
		  Options.AddOption o
		  
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
		  
		  #Pragma Warning "How is this affecting all of our other applications, i.e. a symlink"
		  If Options.Extra(0) = "xojodoc" Then
		    Options.Extra.Remove 0
		  End If
		  
		  Dim projectFileName As String = Options.Extra(0)
		  ProjectFile = GetRelativeFolderItem(projectFileName)
		  If ProjectFile Is Nil Or Not ProjectFile.IsReadable Then
		    stderr.WriteLine "error: '" + projectFileName + "' does not exist or is not readable"
		    Quit 1
		  End If
		  
		  ExcludePackages = Options.StringValue("exclude-items").Split(",")
		  FlatOutput = Options.BooleanValue("flat")
		  
		  If options.BooleanValue("include-private") Then
		    Flags = Flags + kIncludePrivate
		  End If
		  
		  If options.BooleanValue("include-protected") Then
		    Flags = Flags + kIncludeProtected
		  End If
		  
		  If options.BooleanValue("include-events") Then
		    Flags = Flags + kIncludeEvents
		  End If
		  
		  OutputFormat = options.StringValue("output-format", "markdown")
		  
		End Sub
	#tag EndMethod


	#tag Note, Name = Project Overview
		## What is XojoDoc?
		
		`xojodoc` is an application that will process a Xojo manifest file and create
		source level documentation for the project and all included items.
		
		## Generating Documentation
		
		xojodoc currently only produces Markdown files, however using pandoc, one
		can convert those Markdown files into a variety of formats.
		
		~~~~sh
		$ xojodoc -f myproject.md myproject.xojo_project
		$ pandoc myproject.md -o myproject.html -s --toc --toc-depth=2
		$ pandoc myproject.md -o myproject.docx
		$ pandoc myproject.md -o myproject.pdf
		~~~~
	#tag EndNote

	#tag Note, Name = TODO
		* Hyperlink to referenced classes
		* Unescape constants, for example "first\x2Clast\X2Cage"
		
	#tag EndNote


	#tag Property, Flags = &h21
		Private ExcludePackages() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Flags As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private FlatOutput As Boolean
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

	#tag Property, Flags = &h21
		Private OutputFormat As String
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 5265666572656E636520746F206F75722063757272656E742050726F6A65637420746F2070726F6475636520646F63756D656E746174696F6E20666F72
		Project As XdocProject
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ProjectFile As FolderItem
	#tag EndProperty


	#tag Constant, Name = kIncludeEvents, Type = Double, Dynamic = False, Default = \"4", Scope = Public, Description = 42697420666F7220466C61677320746F20696E6469636174652063616C6C65722077616E747320746F20696E636C756465204576656E747320696E2074686520646F63756D656E746174696F6E
	#tag EndConstant

	#tag Constant, Name = kIncludePrivate, Type = Double, Dynamic = False, Default = \"1", Scope = Public, Description = 42697420666F7220466C61677320746F20696E6469636174652063616C6C65722077616E747320746F20696E636C7564652050726976617465206D656D6265727320696E2074686520646F63756D656E746174696F6E
	#tag EndConstant

	#tag Constant, Name = kIncludeProtected, Type = Double, Dynamic = False, Default = \"2", Scope = Public, Description = 42697420666F7220466C61677320746F20696E6469636174652063616C6C65722077616E747320746F20696E636C7564652050726F746563746564206D656D6265727320696E2074686520646F63756D656E746174696F6E
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
