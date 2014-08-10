#tag Class
Protected Class OptionParser
	#tag Method, Flags = &h0
		Sub AddOption(o As Option)
		  // Add an option to the option parser.
		  //
		  // * `o` = Option to add
		  
		  // Validation
		  If o.ShortKey <> "" And Dict.HasKey(o.ShortKey.Asc) Then
		    Raise New OptionParserException("You can't add the same short key more than once: " + o.ShortKey)
		  End If
		  If o.LongKey <> "" And Dict.HasKey(o.LongKey) Then
		    Raise New OptionParserException("You can't add the same long key more than once: " + o.LongKey)
		  End If
		  If o.ShortKey = "?" Then
		    Raise New OptionParserException("You can't add the key ""?"" This means ""help"" and has already been added for you")
		  End If
		  
		  Options.Append o
		  
		  If o.ShortKey <> "" Then
		    Dict.Value(o.ShortKey.Asc) = o
		  End If
		  
		  If o.LongKey <> "" Then
		    Dict.Value(o.LongKey) = o
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Arguments() As String()
		  Return CopyStringArray(OriginalArgs)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BooleanValue(key As Variant, defaultValue As Boolean = False) As Boolean
		  // Retrieve a parameter as a boolean
		  //
		  // You may optionally specify a default value.
		  //
		  // * `key` = The short or long option key you wish to lookup
		  // * `defaultValue` = Default value to return if the `key` was not set
		  
		  Dim o As Option = OptionValue(key)
		  Return If(o Is Nil Or o.WasSet = False, defaultValue, o.Value.BooleanValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(appName As String = "", appDescription As String = "")
		  // Create a new OptionParser
		  //
		  // * `appName` = Application Name. This will be displayed in the help contents
		  //               in various places.
		  // * `appDescription` = Application Description. This will be displayed in the
		  //                      help contents at the top to describe the application.
		  
		  Dict = New Dictionary
		  
		  Self.AppName = If(appName = "", App.ExecutableFile.Name, appName)
		  Self.AppDescription = appDescription
		  
		  Dim helpOption As New Option("h", "help", "Show help", Option.OptionType.Boolean)
		  AddOption  helpOption
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CopyStringArray(arr() As String) As String()
		  Dim result() As String
		  If arr.Ubound = -1 Then Return result
		  
		  ReDim result(arr.Ubound)
		  For i As Integer = 0 to arr.Ubound
		    result(i) = arr(i)
		  Next i
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DateValue(key As Variant, defaultValue As Date = Nil) As Date
		  // Retrieve a parameter as a date
		  //
		  // You may optionally specify a default value.
		  
		  Dim v As Variant = Value(key)
		  Return If(v Is Nil, defaultValue, v.DateValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DoubleValue(key As Variant, defaultValue As Double = 0.0) As Double
		  // Retrieve a parameter as a boolean
		  //
		  // You may optionally specify a default value.
		  
		  Dim v As Variant = Value(key)
		  Return If(v Is Nil, defaultValue, v.DoubleValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ExpandArgs(args() As String) As String()
		  // Takes arguments that may be chained and expands them
		  
		  Dim expandedArgs() As String
		  
		  For argIndex As Integer = 0 To args.Ubound
		    Dim arg As String = args(argIndex)
		    
		    If arg = "--" Then
		      // Start of our "forced" extras
		      For i As Integer = argIndex To args.Ubound
		        expandedArgs.Append args(i)
		      Next
		      
		      Exit For argIndex
		      
		    ElseIf arg.Left(2) = "--" Then
		      expandedArgs.Append arg
		      
		    ElseIf arg.Left(1) = "-" And arg.Len > 2 Then
		      arg = arg.Mid(2) // Chop off the hyphen
		      Dim value As String
		      Dim equalIndex As Integer = arg.InStr(2, "=") // If they started the switch with "=", that doesn't count
		      
		      If equalIndex <> 0 Then
		        value = arg.Mid(equalIndex)
		        arg = arg.Left(equalIndex - 1)
		      End if
		      
		      Dim switches() As String = arg.Split("")
		      Dim lastIndex As Integer = switches.Ubound - 1
		      For i As Integer = 0 To lastIndex
		        expandedArgs.Append "-" + switches(i)
		      Next i
		      expandedArgs.Append "-" + switches(switches.Ubound) + value
		      
		    Else // Append as-is
		      expandedArgs.Append arg
		      
		    End If
		  Next argIndex
		  
		  Return expandedArgs
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FileValue(key As Variant, defaultValue As FolderItem = Nil) As FolderItem
		  Dim v As Variant = Value(key)
		  Return If(v Is Nil, defaultValue, FolderItem(v))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IntegerValue(key As Variant, defaultValue As Integer = 0) As Integer
		  Dim v As Variant = Value(key)
		  Return If(v Is Nil, defaultValue, v.IntegerValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function KeyWithDashes(key As String) As String
		  // Takes a key and converts it back to its single or double-dash version
		  
		  key = key.Trim
		  
		  If key = "" Then
		    Return ""
		    
		  ElseIf key.Left(1) = "-" Then // Already there
		    Return key
		    
		  ElseIf key.Len = 1 Then
		    Return "-" + key
		    
		  Else
		    Return "--" + key
		    
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OptionValue(key As String) As Option
		  Dim lookupKey As Variant = key
		  
		  If Not Dict.HasKey(lookupKey) Then
		    If key.Len = 1 Then
		      lookupKey = key.Asc
		    End If
		  End If
		  
		  Return Dict.Lookup(lookupKey, Nil)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PadRight(s as String, width as Integer, padding as String = " ") As String
		  // Pad a string to at least 'width' characters, by adding padding characters
		  // to the right side of the string.
		  
		  dim length as Integer
		  length = len(s)
		  if length >= width then return s
		  
		  dim mostToRepeat as Integer
		  mostToRepeat = ceil((width-length)/len(padding))
		  return s + mid(Repeat(padding, mostToRepeat),1,width-length)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Parse(args() As String)
		  OriginalArgs = CopyStringArray(args)
		  
		  args = ExpandArgs(args)
		  
		  Dim restAreExtras As Boolean
		  Dim optIdx As Integer = -1
		  
		  While optIdx < args.Ubound // args can be rewritten in the loop
		    optIdx = optIdx + 1
		    
		    If restAreExtras Then
		      Extra.Append args(optIdx)
		      
		      Continue
		    End If
		    
		    Dim arg As String = args(optIdx)
		    
		    If arg = "" Or arg = App.ExecutableFile.NativePath Then
		      Continue
		    End If
		    
		    If arg = "--" Then
		      restAreExtras = True
		      
		      Continue
		    End If
		    
		    Dim key As String
		    Dim value As String
		    
		    // Special case:
		    // -? is a synonym for help
		    If arg.Left(2) = "-?" Then
		      arg = "-h" + arg.Mid(3)
		    End If
		    
		    If arg.Left(2) = "--" Then
		      key = arg.Mid(3)
		      
		    ElseIf arg.Left(1) = "-" Then
		      key = arg.Mid(2)
		      
		    Else
		      If arg <> "" Then
		        Extra.Append arg
		      End If
		      Continue
		    End If
		    
		    Dim equalIdx As Integer = key.InStr(2, "=") // Start at the second character
		    If equalIdx <> 0 Then
		      value = key.Mid(equalIdx + 1)
		      key = key.Left(equalIdx - 1)
		    End If
		    
		    Dim opt As Option = OptionValue(key)
		    If opt = Nil Then
		      //
		      // Maybe the user has specified --no-option which should set a
		      // boolean value to False
		      //
		      
		      If key.Left(3) <> "no-" Then
		        RaiseUnrecognizedKeyException(key)
		      End If
		      
		      key = key.Mid(4)
		      opt = OptionValue(key)
		      
		      If opt = Nil Or opt.Type <> Option.OptionType.Boolean Then
		        RaiseUnrecognizedKeyException(key)
		      Else
		        value = "No"
		      End If
		    End If
		    
		    If value <> "" Then
		      // We already got the value, ignore everything else in this If
		      
		    ElseIf opt.Type = Option.OptionType.Boolean Then
		      value = "Yes"
		      
		    ElseIf Not Self.HelpRequested Then
		      // This requires a parameter and the parameter value was not
		      // given as an = assignment, thus it must be the next argument
		      // But if help was requested, it doesn't matter, so we skip this.
		      // If a value was given next, it will just be added to Extras.
		      
		      If optIdx = args.Ubound Then
		        RaiseInvalidKeyValueException(key, kMissingKeyValue)
		      End If
		      
		      optIdx = optIdx + 1
		      value = args(optIdx)
		    End If
		    
		    opt.HandleValue(value)
		  Wend
		  
		  //
		  // Validate Parsed Values
		  // but only if help wasn't requested.
		  // If it was, all bets are off and up to the caller to validate.
		  //
		  
		  If Not Self.HelpRequested Then
		    If ExtrasRequired > 0 And Extra.Ubound < (ExtrasRequired - 1) Then
		      Raise New OptionParserException("Insufficient extras specified")
		    End If
		    
		    For Each o As Option In Options
		      If Not o.IsValid Then
		        Dim key As String
		        If o.LongKey <> "" Then
		          key = o.LongKey
		        Else
		          key = o.ShortKey
		        End If
		        
		        If o.IsRequired And o.Value = Nil Then
		          RaiseMissingKeyException(key)
		        Else
		          RaiseInvalidKeyValueException(key, kInvalidKeyValue + " '" + o.Value.StringValue + "'")
		        End If
		      End If
		    Next
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RaiseInvalidKeyValueException(key As String, type As String)
		  Raise New OptionInvalidKeyValueException("Invalid key value: " + KeyWithDashes(key) + " (" + type + ")")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RaiseMissingKeyException(key As String)
		  
		  Raise New OptionMissingKeyException("Missing option: " + KeyWithDashes(key))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RaiseUnrecognizedKeyException(key As String)
		  Raise New OptionUnrecognizedKeyException("Unrecognized key: " + KeyWithDashes(key))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Repeat(s as String, repeatCount as Integer) As String
		  // Concatenate a string to itself 'repeatCount' times.
		  // Example: Repeat("spam ", 5) = "spam spam spam spam spam ".
		  
		  #pragma disablebackgroundTasks
		  
		  if repeatCount <= 0 then return ""
		  if repeatCount = 1 then return s
		  
		  // Implementation note: normally, you don't want to use string concatenation
		  // for something like this, since that creates a new string on each operation.
		  // But in this case, we can double the size of the string on iteration, which
		  // quickly reduces the overhead of concatenation to insignificance.  This method
		  // is faster than any other we've found (short of declares, which were only
		  // about 2X faster and were quite platform-specific).
		  
		  Dim desiredLenB As Integer = LenB(s) * repeatCount
		  dim output as String = s
		  dim cutoff as Integer = (desiredLenB+1)\2
		  dim curLenB as Integer = LenB(output)
		  
		  while curLenB < cutoff
		    output = output + output
		    curLenB = curLenB + curLenB
		  wend
		  
		  output = output + LeftB(output, desiredLenB - curLenB)
		  return output
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ShowHelp(sectionTitle As String = "Help")
		  Const kAlignCol = 20
		  Const kLineLength = 72
		  
		  Static descIndent As String = kIndentPrefix + Repeat(" ", kAlignCol + 1)
		  
		  Dim helpFor As String = AppName
		  If helpFor <> "" Then
		    If AppDescription <> "" Then
		      helpFor = kIndentPrefix + helpFor + " - " + AppDescription
		    End If
		    Print helpFor
		    Print ""
		  End If
		  
		  Print sectionTitle + ":"
		  
		  For i As Integer = 0 To Options.Ubound
		    Dim opt As Option = Options(i)
		    Dim keys() As String
		    
		    If opt.ShortKey <> "" Then
		      Dim keyString As String = KeyWithDashes(opt.ShortKey)
		      
		      If opt.Type <> Option.OptionType.Boolean Then
		        keyString = keyString + " " + opt.TypeString
		      End If
		      
		      keys.Append keyString
		    End If
		    
		    If opt.LongKey <> "" Then
		      Dim keyString As String = KeyWithDashes(opt.LongKey)
		      
		      If opt.Type <> Option.OptionType.Boolean Then
		        keyString = keyString + "=" + opt.TypeString
		      End If
		      
		      keys.Append keyString
		    End If
		    
		    Dim key As String = Join(keys, ", ")
		    
		    If key.Len > kAlignCol Or opt.Description.InStr(EndOfLine) <> 0 Then
		      Print kIndentPrefix + key
		      Print WrapTextWithIndent(opt.Description, kLineLength, descIndent)
		      
		    ElseIf (key.Len + opt.Description.Len) > kLineLength Then
		      key = kIndentPrefix + PadRight(key, kAlignCol + 1)
		      Dim desc As String = WrapTextWithIndent(opt.Description, kLineLength, descIndent)
		      desc = desc.Mid(key.Len + 1)
		      Print key + desc
		      
		    Else
		      Print kIndentPrefix + PadRight(key, kAlignCol + 1) + opt.Description
		      
		    End If
		  Next
		  
		  Dim notes As String = AdditionalHelpNotes.Trim
		  If notes <> "" Then
		    notes = WrapTextWithIndent(notes, kLineLength)
		    
		    Print ""
		    Print "Notes:"
		    Print notes
		    Print ""
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue(key As Variant, defaultValue As String = "") As String
		  Dim o As Option = OptionValue(key)
		  Return If(o Is Nil Or o.WasSet = False Or o.Value Is Nil, defaultValue, o.Value.StringValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Value(key As Variant) As Variant
		  Dim vk As String = key
		  Dim v As Variant = Dict.Lookup(vk, Nil)
		  
		  If v = Nil Then
		    v = Dict.Lookup(vk.Asc, Nil)
		  End If
		  
		  If v <> Nil Then
		    Return Option(v).Value
		  End If
		  
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WrapLines(lines() As String, charsPerLine As Integer = 72, paragraphFill As Boolean = true)
		  // Wrap the text so that no line is longer than charsPerLine.  If paragraphFill
		  // is true, then whenever one long line is followed by a line that does not
		  // start with whitespace, join them together into one continuous paragraph.
		  // Copied from StringUtils.
		  
		  If UBound(lines) < 0 Then Return
		  
		  // Start by joining lines, if called for.
		  If paragraphFill Then
		    Dim lineNum As Integer = 1
		    Dim lastLineShort As Boolean = (lines(0).Len < charsPerLine - 20)
		    While lineNum <= UBound(lines)
		      Dim line As String = lines(lineNum)
		      Dim firstChar As String = Left(line, 1)
		      If lastLineShort Then
		        // last line was short, so don't join this one to it
		        lineNum = lineNum + 1
		      elseif line = "" or firstChar <= " " or firstChar = ">" or firstChar = "|" Then
		        // this line is empty or starts with whitespace or other special char; don't join it
		        lineNum = lineNum + 1
		      Else
		        // this line starts with a character; join it to the previous line
		        lines(lineNum - 1) = lines(lineNum - 1) + " " + line
		        lines.Remove lineNum
		      End If
		      lastLineShort = (line.Len < charsPerLine - 20)
		    Wend
		  End If
		  
		  // Then, go through and do the wrapping.
		  For lineNum As Integer = 0 To UBound(lines)
		    Dim line As String = RTrim(lines(lineNum))
		    If line.Len <= charsPerLine Then
		      lines(lineNum) = line
		    Else
		      Dim breakPos As Integer
		      For breakPos = charsPerLine DownTo 1
		        Dim c As String = Mid(line, breakPos, 1)
		        If c <= " " or c = "-" Then Exit
		      Next
		      If breakPos < 2 Then breakPos = charsPerLine + 1 // no point breaking before char 1
		      lines.Insert lineNum + 1, LTrim(Mid(line, breakPos))
		      lines(lineNum) = LTrim(Left(line, breakPos - 1))
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WrapLinesWithIndent(lines() As String, charsPerLine As Integer, indent As String = kIndentPrefix)
		  WrapLines(lines, charsPerLine - indent.Len, False)
		  
		  For i As Integer = 0 To lines.Ubound
		    lines(i) = indent + lines(i)
		  Next i
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WrapTextWithIndent(text As String, charsPerLine As Integer, indent As String = kIndentPrefix) As String
		  text = ReplaceLineEndings(text, EndOfLine)
		  
		  Dim lines() As String = Split(text, EndOfLine)
		  WrapLinesWithIndent(lines, charsPerLine, indent)
		  Return Join(lines, EndOfLine)
		End Function
	#tag EndMethod


	#tag Note, Name = Features to Add
		- Default values for given options.
		- Switch aliases (short and long).
	#tag EndNote

	#tag Note, Name = Overview
		This here is the overview of the OptionParser class.
		
		Here you can add as much documentation as you'd like.
		
	#tag EndNote

	#tag Note, Name = Usage
		Key can be the short or long option name.
		
		* `.Value(key)` = Variant value
		* `.OptionValue(key)` = Option instance
		* `.StringValue`, `.DateValue`, `.BooleanValue`, etc... = Variant type cast to the appropriate result type
		
		Some Value accessors can return `Nil`, such as `DateValue` and `FileValue`.
		Others have a default return value if the default isn't sent to the method
		such as `BooleanValue`, `DoubleValue`, etc...
	#tag EndNote


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mAdditionalHelpNotes
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mAdditionalHelpNotes = ReplaceLineEndings(value.Trim, EndOfLine)
			End Set
		#tag EndSetter
		AdditionalHelpNotes As String
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		AppDescription As String
	#tag EndProperty

	#tag Property, Flags = &h0
		AppName As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Dict As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Extra() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ExtrasRequired As Integer = 0
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim o As Option = OptionValue("help")
			  If o Is Nil Then
			    Return False // Should never happen
			  Else
			    Return o.WasSet
			  End If
			  
			End Get
		#tag EndGetter
		HelpRequested As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mAdditionalHelpNotes As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Options() As Option
	#tag EndProperty

	#tag Property, Flags = &h21
		Private OriginalArgs() As String
	#tag EndProperty


	#tag Constant, Name = kIndentPrefix, Type = String, Dynamic = False, Default = \"  ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kInvalidKeyValue, Type = String, Dynamic = False, Default = \"key value is invalid", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMissingKeyValue, Type = String, Dynamic = False, Default = \"key value is missing", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="AdditionalHelpNotes"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AppDescription"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AppName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ExtrasRequired"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HelpRequested"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
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
