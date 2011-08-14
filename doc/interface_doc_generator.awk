#!/usr/bin/awk -f

BEGIN{
    htmlDoc = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">"
    htmlDoc = htmlDoc "\n<html>"
    htmlDoc = htmlDoc "\n<head>"
    htmlDoc = htmlDoc "\n<title>Interface documentation</title>"
    htmlDoc = htmlDoc "\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"
    htmlDoc = htmlDoc "\n</head>"
    htmlDoc = htmlDoc "\n<body>"

    for (i = 1; i < ARGC; i++)
        readeFile( ARGV[i] )
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

    _bashComand = "cat "  _filename " | grep '^##' | sed 's/^##//'"
    while ((_bashComand | getline  _returnVar) > 0) {
        if ( index(_returnVar, "NAME:") != 0)
        {
            if ( _data != "")
            {
                htmlDoc = htmlDoc "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "h1"
            _data = "Function: "
        } else if (index(_returnVar, "NAMESPACE:") != 0)
        {
            if ( _data != "")
            {
                htmlDoc = htmlDoc "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "p"
            _data = "<b>Namespace:</b>"
        } else if (index(_returnVar, "DESCRIPTION:") != 0)
        {
            if ( _data != "")
            {
                htmlDoc = htmlDoc "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "h2"
            _data = "Description:"
        } else if (index(_returnVar, "PARAMETER:") != 0)
        {
            _tagName = "h2"
            _data = "Parameter"
        } else if (index(_returnVar, "LOCALE:") != 0)
        {
            if ( _data != "")
            {
                htmlDoc = htmlDoc "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "h2"
            _data = "Local variables"
        } else if (index(_returnVar, "RETURN:") != 0)
        {
            if ( _data != "")
            {
                htmlDoc = htmlDoc "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "p"
            htmlDoc = htmlDoc "<h2>Return value</h2>\n"
            _data = ""
        } else if (index(_returnVar, "EXCEPTION:") != 0)
        {
            if ( _data != "")
            {
                htmlDoc = htmlDoc "<" _tagName ">" _data "</" _tagName ">\n"
            }
            _tagName = "p"
            htmlDoc = htmlDoc "<h2>Exceptions</h2>\n"
            _data = ""
        } else if (index(_returnVar, "ITEM:") != 0)
        {
            if ( _data != "")
            {
                htmlDoc = htmlDoc "<" _tagName ">" _data "</" _tagName ">\n"
            }
            split(_returnVar,  _list,":")
            _tagName = "p"
            _data = "<b>" _list[2] "</b> - "
        }else
        {
            _data = _data _returnVar
        }

    }
    if ( _data != "")
    {
        htmlDoc = htmlDoc "<" _tagName ">" _data "</" _tagName ">\n"
    }
    close(_bashComand)
}
