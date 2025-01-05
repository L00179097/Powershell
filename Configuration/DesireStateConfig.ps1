Configuration DscConfiguration
{
    param
    (
        [string[]]$ComputerName='localhost'
    )

    Import-DscResource -ModuleName PsDesiredStateConfiguration

    Node $ComputerName
    {
        WindowsFeature 'FTP Server'
        {
            Ensure = 'Present'
            Name = 'Web-Ftp-Server'
        }

        WindowsFeature 'IISServer'
        {
            Ensure = 'Present'
            Name = 'web-server'
        }
        File HelloWorld {
            SourcePath = "C:\Users\Administrator\Documents\test.txt"
            DestinationPath = "C:\Temp\HelloWorld.txt"
            Ensure = "Present"
            Contents   = "Hello World from DSC!"
        }
    }
}
DscConfiguration