Configuration DscConfiguration
{
    param
    (
        [string[]]$ComputerName='localhost'
    )

    Import-DscResource -ModuleName PsDesiredStateConfiguration

    Node $ComputerName
    {
        WindowsFeature MyFeatureInstance
        {
            Ensure = 'Present'
            Name = 'RSAT'
        }

        WindowsFeature My2ndFeatureInstance
        {
            Ensure = 'Present'
            Name = 'DNS'
        }
        File HelloWorld {
            SourcePath = "C:\Users\Administrator\Documents\jor.txt"
            DestinationPath = "C:\Temp\HelloWorld.txt"
            Ensure = "Present"
            Contents   = "Hello World from DSC!"
        }
    }
}
DscConfiguration
