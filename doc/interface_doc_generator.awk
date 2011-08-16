#!/usr/bin/awk -f

# Use...
# awk -W lint -f  interface_doc_generator.awk `ls ../modules.d/96osr/lib/*.awk` > ~/interface-out.html


BEGIN{
    htmlIndex = ""
    htmlBody = ""
    htmlDoc = ""

    for (i = 1; i < ARGC; i++)
    {
        readeFile( ARGV[i] )
    }

    htmlDoc = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">"
    htmlDoc = htmlDoc "\n<html>"
    htmlDoc = htmlDoc "\n<head>"
    htmlDoc = htmlDoc "\n<title>Interface documentation</title>"
    htmlDoc = htmlDoc "\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"
    htmlDoc = htmlDoc "\n</head>"
    htmlDoc = htmlDoc "\n<body>"

    htmlDoc = htmlDoc "\n<ul>"
    htmlDoc = htmlDoc htmlIndex
    htmlDoc = htmlDoc "\n</ul>"
    htmlDoc = htmlDoc "\n<br>"
    htmlDoc = htmlDoc htmlBody

    htmlDoc = htmlDoc "\n</body>"
    htmlDoc = htmlDoc "\n</html>"

    print htmlDoc
}

function readeFile(_filename,  _bashComand,_returnVar,_tagName,_data)
{
    # initialize private variable
    _returnVar = ""
    _tagName = ""
    _bashComand = ""
    _data = ""

    htmlBody = htmlBody "<h1><div id=\"" _filename "\">File: " _filename "<div></h1>\n"
    htmlIndex = htmlIndex "<li><a href=\"#" _filename  "\">" _filename "</a></li>\n"
    htmlIndex = htmlIndex "<ul>"
    _bashComand = "cat "  _filename " | grep '^##' | sed 's/^##//'"
    while ((_bashComand | getline  _returnVar) > 0) {
        if ( index(_returnVar, "NAME:") != 0)
        {
            if ( _data != "")
            {
                htmlBody = htmlBody "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "h2"
            _data = "Function: "
        } else if (index(_returnVar, "NAMESPACE:") != 0)
        {
            if ( _data != "")
            {
                htmlBody = htmlBody "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "p"
            _data = "<b>Namespace:</b>"
        } else if (index(_returnVar, "DESCRIPTION:") != 0)
        {
            if ( _data != "")
            {
                htmlBody = htmlBody "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "p"
            _data = "<h3>Description:</h3>"
        } else if (index(_returnVar, "PARAMETER:") != 0)
        {
            _tagName = "h3"
            _data = "Parameter"
        } else if (index(_returnVar, "LOCALE:") != 0)
        {
            if ( _data != "")
            {
                htmlBody = htmlBody "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "h3"
            _data = "Local variables"
        } else if (index(_returnVar, "RETURN:") != 0)
        {
            if ( _data != "")
            {
                htmlBody = htmlBody "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "p"
            htmlBody = htmlBody "<h3>Return value</h3>\n"
            _data = ""
        } else if (index(_returnVar, "TODO:") != 0)
        {
            if ( _data != "")
            {
                htmlBody = htmlBody "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "p"
            htmlBody = htmlBody "<h3>To do</h3>\n"
            _data = ""
        } else if (index(_returnVar, "EXCEPTION:") != 0)
        {
            if ( _data != "")
            {
                htmlBody = htmlBody "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "p"
            htmlBody = htmlBody "<h3>Exceptions</h3>\n"
            _data = ""
        } else if (index(_returnVar, "ITEM:") != 0)
        {
            if ( _data != "")
            {
                htmlBody = htmlBody "<" _tagName ">" _data "</" _tagName ">\n"
            }
            split(_returnVar,  _list,":")
            _tagName = "p"
            _data = "<b>" _list[2] "</b> - "
        }else
        {
            if(_tagName == "h2")
            {
                _data = _data "<div id=\"" _filename "/" _returnVar "\">" _returnVar "<div>"
                htmlIndex = htmlIndex "<li>"
                htmlIndex = htmlIndex "<a href=\"#" _filename  "/" _returnVar  "\">"
                htmlIndex = htmlIndex  _returnVar "</a></li>\n"
            }else
            {
                _data = _data _returnVar
            }
        }

    }
    if ( _data != "")
    {
        htmlBody = htmlBody "<" _tagName ">" _data "</" _tagName ">\n"
    }
    close(_bashComand)
    htmlIndex = htmlIndex "</ul>"
}
