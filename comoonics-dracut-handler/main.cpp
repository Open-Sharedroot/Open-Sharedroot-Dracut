#include <QtCore/QCoreApplication>
#include <QStringList>
#include <iostream>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    std::cout << "Hallo Welt" << std::endl;
    QStringList args = QCoreApplication::arguments();
    for (int i = 1; i < args.size(); i++)
    {
        const QString &arg = args.at(i);
        if
        (
            arg == "--help"
            || arg == "-h"
            || arg == "/?"
            || arg == "/h"
        )
        {
            std::cerr << "Sorry! no help function..." << std::endl;
            return 1;
        } else if
        (
                arg == "--version"
                || arg == "-V"
        )
        {
            std::cerr << "Sorry! no informations..." << std::endl;
            return 1;
        } else
        {
            std::cerr << "Error: Invalid command-line argument: " << arg.toStdString() << std::endl;
            return 1;
        }
    }
    return a.exec();
}
