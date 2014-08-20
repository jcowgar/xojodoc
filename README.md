XojoDoc
=======

Source code documentation tool for [Xojo](http://xojo.com).

Usage
-----

To your Xojo source, add Notes, Descriptions via Inspector, Comments at the top of
Methods or notes in the property editor. These will then appear in a formatted 
AsciiDoc file.

### Example

```
$ xojodoc -f myproject.adoc myproject.xojo_project
$ asciidoc myproject.adoc
```

Limitations
-----------

Currently only `.xojo_project` and `.xojo_code` files are processed. `.xojo_xml_code`
support is planned. `.xojo_binary_project` support is not.

App Help
--------

```
$ xojodoc --help
When writing multiple files (no -s/--single), you must specify -o/--output-directory
xojodoc

Help:
  -h, --help           Show help
  --output-format=STR  Format of the output, default: asciidoc, others:
                       markdown
  --flat               Flatten output directory structure
  -f FILE, --output-file=FILE
                       Write to a single file
  -o DIR, --output-directory=DIR
                       Directory to write files to
  --include-private    Include items marked private
  --include-protected  Include items marked protected
  --include-events     Include implemented events
  -e STR, --exclude=STR
                       Exclude items beginning with Full Name of
  -i STR, --include=STR
                       Include items beginning with Full Name of
```

Warning
-------

`xojodoc` is in its infancy. There are likely bugs and it's use, maybe even its name
is likely to change.

If you find a bug, please at bare minimum report it on the 
[github issue tracker](https://github.com/jcowgar/xojodoc/issues) but better yet, fork
the project on [github.com](http://github.com/jcowgar/xojodoc), fix the bug and create a
pull request.